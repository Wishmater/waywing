import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../tool.dart';

/// The supported `--optimize` values and their Zig build modes.
const _zigOptimize = {
  'debug': 'Debug',
  'safe': 'ReleaseSafe',
  'fast': 'ReleaseFast',
  'small': 'ReleaseSmall',
};

const _targetPlatforms = ['linux-x64', 'linux-arm64', 'linux-riscv64'];

class BuildReleaseCommand extends ToolCommand {
  BuildReleaseCommand() {
    argParser
      ..addOption(
        'dist',
        valueHelp: 'dir',
        help:
            'Bundle directory (default: build/wayland/<arch>/release/bundle).',
      )
      ..addOption(
        'app-name',
        valueHelp: 'name',
        help: 'Host executable name (default: the pubspec name).',
      )
      ..addOption(
        'target',
        valueHelp: 'file',
        defaultsTo: 'lib/main.dart',
        help: 'Dart entrypoint.',
      )
      ..addOption(
        'target-platform',
        valueHelp: 'name',
        allowed: _targetPlatforms,
        help: 'Flutter target platform (default: the host platform).',
      )
      ..addOption(
        'optimize',
        valueHelp: 'mode',
        allowed: _zigOptimize.keys,
        defaultsTo: 'fast',
        help: 'Zig optimization mode.',
      )
      ..addMultiOption(
        'dart-define',
        valueHelp: 'key=value',
        splitCommas: false,
        help: 'Dart define (repeatable).',
      )
      ..addMultiOption(
        'dart-define-from-file',
        valueHelp: 'file',
        splitCommas: false,
        help: 'JSON or .env file with Dart defines (repeatable).',
      );
  }

  @override
  String get name => 'build-release';

  @override
  String get description =>
      'Build an AOT bundle and a relocatable release dist.';

  @override
  Future<void> run() async {
    final results = argResults!;
    final appName = (results['app-name'] as String?) ?? tool.appName();
    final target = results['target'] as String;
    final targetPlatform =
        (results['target-platform'] as String?) ?? tool.hostTargetPlatform();
    final arch = tool.archForTargetPlatform(targetPlatform);
    final optimize = _zigOptimize[results['optimize'] as String]!;
    final distDir = p.join(
      tool.paths.appRoot,
      (results['dist'] as String?) ??
          tool.paths.defaultBundleDir(arch, "release"),
    );
    final dartDefines = results['dart-define'] as List<String>;
    final dartDefineFiles = results['dart-define-from-file'] as List<String>;
    final encodedDefines = _encodeDefines(
      tool.paths.appRoot,
      dartDefines,
      dartDefineFiles,
    );

    final packageConfig = File(
      '${tool.paths.appRoot}/.dart_tool/package_config.json',
    );
    if (!packageConfig.existsSync()) {
      throw ToolError(
        '${packageConfig.path} not found; run "flutter pub get" first',
      );
    }

    // Resolve the engine and ICU data first so a missing prerequisite fails
    // before the expensive Flutter build.
    final engine = tool.env('FILO_ENGINE_LIB_RELEASE') ??
        p.join(tool.paths.waylandDir, 'engine/release/libflutter_engine.so');
    if (!File(engine).existsSync()) {
      throw ToolError(
        'release engine file not found in $engine; '
        'set FILO_ENGINE_LIB_RELEASE in wayland/.env.local '
        'to a release-built libflutter_engine.so or copy one to '
        '${p.join(tool.paths.waylandDir, 'engine/release/libflutter_engine.so')}',
      );
    }
    final icu = tool.releaseIcu(targetPlatform);

    // `flutter assemble` only writes the outputs it is asked for; remove the
    // directory so a previous debug bundle cannot leave kernel_blob.bin or
    // other stale files in the release assets.
    final releaseDir = Directory(tool.paths.buildDir(arch, "release"));
    if (releaseDir.existsSync()) {
      releaseDir.deleteSync(recursive: true);
    }
    releaseDir.createSync(recursive: true);

    stdout.writeln('$toolName: building Flutter release bundle');
    await runInherited(
      'flutter',
      [
        'assemble',
        '--no-version-check',
        '--output=${releaseDir.path}',
        '-dTargetPlatform=$targetPlatform',
        '-dBuildMode=release',
        '-dTargetFile=$target',
        '-dTrackWidgetCreation=false',
        '-dTreeShakeIcons=true',
        '-dDartObfuscation=false',
        if (encodedDefines.isNotEmpty) '--DartDefines=$encodedDefines',
        'release_bundle_${targetPlatform}_assets',
      ],
      workingDirectory: tool.paths.appRoot,
      missingMessage: 'flutter is not on PATH',
    );

    final assets = Directory('${releaseDir.path}/flutter_assets');
    final aot = File('${releaseDir.path}/lib/libapp.so');
    if (!assets.existsSync()) {
      throw ToolError('flutter assemble did not create ${assets.path}');
    }
    if (!aot.existsSync()) {
      throw ToolError('flutter assemble did not create ${aot.path}');
    }

    stdout.writeln('$toolName: building release host');
    await runInherited(
      'zig',
      ['build', '-Doptimize=$optimize', '-Dapp-name=$appName'],
      workingDirectory: tool.paths.waylandDir,
      missingMessage: 'zig is not on PATH',
    );

    final host = File('${tool.paths.hostDir}/$appName');
    if (!host.existsSync()) {
      throw ToolError('zig build did not create ${host.path}');
    }

    final bundleDir = Directory(distDir);
    if (bundleDir.existsSync()) {
      bundleDir.deleteSync(recursive: true);
    }
    final binDir = Directory('${bundleDir.path}/bin')
      ..createSync(recursive: true);
    final libDir = Directory('${bundleDir.path}/lib')
      ..createSync(recursive: true);
    final dataDir = Directory('${bundleDir.path}/data')
      ..createSync(recursive: true);

    host.copySync('${binDir.path}/$appName');
    makeExecutable('${binDir.path}/$appName');
    // The engine is copied so the distributed bundle is relocatable. It is
    // expected to have `$ORIGIN` in its RUNPATH; that is what makes its own
    // dlopen calls find the native assets beside it.
    File(engine).copySync('${libDir.path}/libflutter_engine.so');
    aot.copySync('${libDir.path}/libapp.so');
    File(icu).copySync('${dataDir.path}/icudtl.dat');
    copyTree(assets, Directory('${dataDir.path}/flutter_assets'));

    final nativeAssets = tool.nativeAssetsDir(assets.path);
    if (nativeAssets != null) {
      for (final entity in nativeAssets.listSync(followLinks: true)) {
        if (entity is File && entity.path.endsWith('.so')) {
          entity.copySync('${libDir.path}/${p.basename(entity.path)}');
        }
      }
    }

    // Keep the normal launch state working after a release build, so
    // `dart wayland/tool/wayland.dart run` starts against the staged bundle.
    writeJson(
      tool.paths.launchFile,
      tool.launchManifest(
        appName: appName,
        engine: '${libDir.path}/libflutter_engine.so',
        icu: '${dataDir.path}/icudtl.dat',
        assets: '${dataDir.path}/flutter_assets',
        aot: '${libDir.path}/libapp.so',
      ),
    );
    stdout.writeln('$toolName: wrote ${tool.paths.launchFile}');

    // The staged bundle is relocatable: the launcher changes into the bundle
    // root and the manifest uses paths relative to it.
    writeJson(
      '${bundleDir.path}/.filo/launch.json',
      tool.launchManifest(
        appName: appName,
        engine: 'lib/libflutter_engine.so',
        icu: 'data/icudtl.dat',
        assets: 'data/flutter_assets',
        aot: 'lib/libapp.so',
      ),
    );
    final launcher = '${bundleDir.path}/$appName';
    writeLauncher(launcher, appName);

    stdout.writeln('$toolName: staged ${bundleDir.path}');
    stdout.writeln('$toolName: launcher $launcher');
  }
}

/// `flutter assemble` expects `DartDefines` to be a comma-separated list of
/// base64-encoded `key=value` entries. Parse the user-facing plain values and
/// files here, then encode them the way the Flutter build system expects.
String _encodeDefines(
  String appRoot,
  List<String> defines,
  List<String> files,
) {
  final values = <String, String>{};
  for (final file in files) {
    values.addAll(_readDefineFile(p.join(file, appRoot)));
  }
  for (final define in defines) {
    final equals = define.indexOf('=');
    if (equals <= 0) {
      throw ToolError('--dart-define expects KEY=VALUE, got "$define"');
    }
    values[define.substring(0, equals)] = define.substring(equals + 1);
  }
  return values.entries
      .map((entry) => base64.encode(utf8.encode('${entry.key}=${entry.value}')))
      .join(',');
}

Map<String, String> _readDefineFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw ToolError(
      'did not find the file passed to --dart-define-from-file: $path',
    );
  }
  final text = file.readAsStringSync();
  if (text.trimLeft().startsWith('{')) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (error) {
      throw ToolError('$path: ${error.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw ToolError('$path: expected a JSON object');
    }
    return {for (final entry in decoded.entries) entry.key: '${entry.value}'};
  }

  final values = <String, String>{};
  for (final raw in const LineSplitter().convert(text)) {
    var line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    if (line.startsWith('export ')) {
      line = line.substring('export '.length).trimLeft();
    }
    final equals = line.indexOf('=');
    if (equals <= 0) {
      throw ToolError('$path: expected KEY=VALUE, got "$line"');
    }
    final key = line.substring(0, equals).trim();
    var value = line.substring(equals + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    values[key] = value;
  }
  return values;
}
