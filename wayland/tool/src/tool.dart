import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'env_parser.dart';

/// The prefix used for all tool output.
const toolName = 'filo-wayland';

/// A runtime failure that should be reported as a normal tool error.
class ToolError implements Exception {
  ToolError(this.message);

  final String message;
}

/// The app and Wayland runner directories used by every command.
class ToolPaths {
  ToolPaths({required this.appRoot, required this.waylandDir});

  final String appRoot;
  final String waylandDir;

  String get hostDir => '$waylandDir/zig-out/bin';
  String buildDir(String arch, String mode) =>
      '$appRoot/build/wayland/$arch/$mode';
  String defaultBundleDir(String arch, String mode) =>
      '${buildDir(arch, mode)}/bundle';
  String get launchBuildFile => '$waylandDir/.filo-build/launch.json';
  String get launchFile => '$waylandDir/.filo/launch.json';
  String get dotenvFile => '$waylandDir/.env.local';
  String get customDeviceFile => '$waylandDir/custom-device.json';

  static ToolPaths discover() {
    String? script;
    try {
      script = File.fromUri(Platform.script).resolveSymbolicLinksSync();
    } on FileSystemException {
      script = null;
    }
    if (script != null) {
      final wayland = File(script).parent.parent;
      if (File('${wayland.path}/build.zig').existsSync()) {
        return ToolPaths(
          appRoot: wayland.parent.path,
          waylandDir: wayland.path,
        );
      }
    }

    // Fallback for a copied script: walk up from the current directory to the
    // app root. This also handles being invoked from a subdirectory.
    var directory = Directory.current;
    while (true) {
      if (File('${directory.path}/wayland/build.zig').existsSync()) {
        return ToolPaths(
          appRoot: directory.path,
          waylandDir: '${directory.path}/wayland',
        );
      }
      final parent = directory.parent;
      if (parent.path == directory.path) break;
      directory = parent;
    }

    throw ToolError(
      'cannot find the app root; run this from the Flutter app or keep '
      'wayland/tool/wayland.dart in place',
    );
  }
}

Map<String, Object?>? readManifest(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on FormatException catch (error) {
    throw ToolError('$path: ${error.message}');
  }
  if (decoded is! Map<String, dynamic>) {
    throw ToolError('$path: expected a JSON object');
  }
  return decoded;
}

void writeJson(String path, Map<String, Object?> value) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
}

extension MapExt on Map<String, Object?>? {
  T fieldRequire<T>(String key, String message) {
    if (this == null) throw ToolError(message);
    final value = this![key];
    if (value is! T) throw ToolError(message);
    return value;
  }

  String? fieldStr(String key) {
    final value = this?[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  bool fieldBool(String key) => this?[key] == true;

  List<String>? fieldStrList(String key) {
    final value = this?[key];
    if (value is! List) return null;
    return [
      for (final item in value)
        if (item is String) item,
    ];
  }
}

T require<T>(T? value, String message) =>
    value == null ? throw ToolError(message) : value;

Future<void> runInherited(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  required String missingMessage,
}) async {
  final Process process;
  try {
    process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.inheritStdio,
    );
  } on ProcessException {
    throw ToolError(missingMessage);
  }
  final code = await process.exitCode;
  if (code != 0) {
    throw ToolError(
      '$executable ${arguments.join(' ')} failed with exit code $code',
    );
  }
}

void copyTree(Directory source, Directory destination) {
  destination.createSync(recursive: true);
  for (final entity in source.listSync(recursive: true, followLinks: true)) {
    final relative = entity.path.substring(source.path.length + 1);
    final target = '${destination.path}/$relative';
    if (entity is Directory) {
      Directory(target).createSync(recursive: true);
    } else if (entity is File) {
      final file = File(target);
      file.parent.createSync(recursive: true);
      entity.copySync(target);
    }
  }
}

void removePath(String path) {
  final type = FileSystemEntity.typeSync(path, followLinks: false);
  switch (type) {
    case FileSystemEntityType.notFound:
      return;
    case FileSystemEntityType.link:
      Link(path).deleteSync();
      return;
    case FileSystemEntityType.directory:
      Directory(path).deleteSync(recursive: true);
      return;
    default:
      File(path).deleteSync();
      return;
  }
}

void clearDirectory(Directory directory) {
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    return;
  }
  for (final entity in directory.listSync(followLinks: false)) {
    removePath(entity.path);
  }
}

void replaceLink(String linkPath, String target) {
  removePath(linkPath);
  Link(linkPath).createSync(target);
}

/// The files of a prepared debug/release bundle, ready to be recorded in a
/// launch manifest.
class PreparedBundle {
  PreparedBundle({
    required this.root,
    required this.engine,
    required this.icu,
    required this.assets,
    this.aot,
  });

  final String root;
  final String engine;
  final String icu;
  final String assets;
  final String? aot;
}

void makeExecutable(String path) {
  final result = Process.runSync('chmod', ['755', path]);
  if (result.exitCode != 0) {
    throw ToolError('failed to mark $path executable');
  }
}

void writeLauncher(String path, String appName) {
  File(path).writeAsStringSync(
    '#!/bin/sh\n'
    'set -eu\n'
    'cd "\$(dirname "\$0")"\n'
    'exec "./bin/$appName" "\$@"\n',
  );
  makeExecutable(path);
}

/// Shared state for the commands: paths, `.env.local`, manifests and release
/// path resolution.
class Tool {
  Tool(this.paths);

  final ToolPaths paths;

  late final Map<String, String> _dotenv = readDotEnv(paths.dotenvFile);

  static Tool discover() => Tool(ToolPaths.discover());

  String? env(String key) => Platform.environment[key] ?? _dotenv[key];

  String? pathEnv(String key) {
    final value = env(key);
    if (value == null || value.isEmpty) return null;
    return _resolvePath(value);
  }

  String _resolvePath(String value) {
    return p.isAbsolute(value)
        ? p.normalize(value)
        : p.join(paths.waylandDir, value);
  }

  String _resolveAppPath(String value) {
    return p.isAbsolute(value)
        ? p.normalize(value)
        : p.join(paths.appRoot, value);
  }

  /// If [path] is a symlink inside a generated bundle, return its target. This
  /// keeps repeated `post-build`/`install`/`run` calls from linking a bundle
  /// entry to itself when they fall back to the previous launch manifest.
  String _bundleSource(String path) {
    final normalized = p.normalize(p.absolute(path));
    final buildWayland = p.join(paths.appRoot, 'build', 'wayland');
    if (!p.isWithin(buildWayland, normalized)) return normalized;
    if (FileSystemEntity.typeSync(normalized, followLinks: false) !=
        FileSystemEntityType.link) {
      return normalized;
    }
    try {
      final target = Link(normalized).targetSync();
      final resolved = p.isAbsolute(target)
          ? p.normalize(target)
          : p.normalize(p.join(p.dirname(normalized), target));
      return p.equals(resolved, normalized) ? normalized : resolved;
    } on FileSystemException {
      return normalized;
    }
  }

  bool flag(String key, {required bool fallback}) {
    final value = env(key);
    if (value == null) return fallback;
    return value.isNotEmpty;
  }

  List<String>? dartArgsSetting() {
    final value = env('FILO_DART_ENTRYPOINT_ARGS');
    if (value == null) return null;
    if (value.isEmpty) return <String>[];
    final lines = value.split('\n');
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
    return [
      for (final line in lines)
        if (line.endsWith('\r')) line.substring(0, line.length - 1) else line,
    ];
  }

  Map<String, Object?> resolveLaunch({
    required String appName,
    String? localPath,
    String? icuOverride,
    Map<String, Object?>? fallback,
  }) {
    final engine = _bundleSource(
      require(
        pathEnv('FILO_ENGINE_LIB') ??
            fallback.fieldStr('engine') ??
            localEngine(),
        'FILO_ENGINE_LIB is not set; add it to wayland/.env.local',
      ),
    );
    final icu = _bundleSource(
      require(
        pathEnv('FILO_ICU_DATA') ??
            (icuOverride != null ? _resolveAppPath(icuOverride) : null) ??
            fallback.fieldStr('icu'),
        'no Flutter ICU data path; run post-build or set FILO_ICU_DATA',
      ),
    );
    final assets = _bundleSource(
      require(
        pathEnv('FILO_ASSETS') ??
            (localPath != null ? _resolveAppPath(localPath) : null) ??
            fallback.fieldStr('assets') ??
            defaultAssets(),
        'no flutter_assets directory; run install or set FILO_ASSETS',
      ),
    );
    final bundle = prepareBundle(
      mode: 'debug',
      assets: assets,
      engine: engine,
      icu: icu,
    );

    return launchManifest(
      appName: appName,
      engine: bundle.engine,
      icu: bundle.icu,
      assets: bundle.assets,
      aot: null,
      fallback: fallback,
    );
  }

  /// Lay out the debug bundle like Flutter's Linux bundle:
  ///
  /// `build/wayland/<arch>/debug/bundle/lib` contains the engine and the
  /// native asset libraries, and `data` contains the assets and ICU data.
  /// The engine is only symlinked: it must already have `$ORIGIN` in its
  /// RUNPATH so its own `dlopen` calls find the native assets next to it.
  PreparedBundle prepareBundle({
    required String mode,
    required String assets,
    required String engine,
    required String icu,
    String? aot,
  }) {
    final arch = hostArch();
    final root = paths.defaultBundleDir(arch, mode);
    final libDir = Directory(p.join(root, 'lib'))..createSync(recursive: true);
    final dataDir = Directory(p.join(root, 'data'))
      ..createSync(recursive: true);
    clearDirectory(libDir);
    clearDirectory(dataDir);

    final assetsLink = p.join(dataDir.path, 'flutter_assets');
    final enginePath = p.join(libDir.path, 'libflutter_engine.so');
    final icuPath = p.join(dataDir.path, 'icudtl.dat');

    var assetsSource = _bundleSource(assets);
    if (p.equals(assetsSource, assetsLink)) {
      final fallback = defaultAssets();
      if (fallback == null) {
        throw ToolError(
          'the launch manifest points flutter_assets at the bundle itself; '
          'run post-build or set FILO_ASSETS',
        );
      }
      assetsSource = fallback;
    }
    var engineSource = _bundleSource(engine);
    if (p.equals(engineSource, enginePath)) {
      final fallback = localEngine();
      if (fallback == null) {
        throw ToolError(
          'the launch manifest points the engine at the bundle itself; '
          'set FILO_ENGINE_LIB',
        );
      }
      engineSource = fallback;
    }
    final icuSource = _bundleSource(icu);
    if (p.equals(icuSource, icuPath)) {
      throw ToolError(
        'the launch manifest points ICU data at the bundle itself; '
        'set FILO_ICU_DATA',
      );
    }

    replaceLink(enginePath, p.absolute(engineSource));

    final nativeDir = nativeAssetsDir(assetsSource);
    if (nativeDir != null) {
      for (final entity in nativeDir.listSync(followLinks: true)) {
        if (entity is File && entity.path.endsWith('.so')) {
          entity.copySync(p.join(libDir.path, p.basename(entity.path)));
        }
      }
    }

    String? aotPath;
    if (aot != null) {
      aotPath = p.join(libDir.path, 'libapp.so');
      File(aot).copySync(aotPath);
    }

    replaceLink(assetsLink, p.absolute(assetsSource));
    replaceLink(icuPath, p.absolute(icuSource));

    return PreparedBundle(
      root: root,
      engine: enginePath,
      icu: icuPath,
      assets: assetsLink,
      aot: aotPath,
    );
  }

  Directory? nativeAssetsDir(String assets) {
    for (final candidate in [
      p.join(assets, 'native_assets', 'linux'),
      p.join(assets, '..', 'native_assets', 'linux'),
    ]) {
      final directory = Directory(candidate);
      if (directory.existsSync()) return directory;
    }
    return null;
  }

  Map<String, Object?> launchManifest({
    required String appName,
    required String engine,
    required String icu,
    required String assets,
    String? aot,
    Map<String, Object?>? fallback,
  }) {
    return {
      'app_name': appName,
      'engine': engine,
      'icu': icu,
      'assets': assets,
      'aot': aot,
      'dart_args':
          dartArgsSetting() ?? fallback.fieldStrList('dart_args') ?? <String>[],
      'force_impeller': flag(
        'FORCE_IMPELLER',
        fallback: fallback.fieldBool('force_impeller'),
      ),
      'vulkan_validation': flag(
        'FILO_VULKAN_VALIDATION',
        fallback: fallback.fieldBool('vulkan_validation'),
      ),
      'trace': flag('FILO_TRACE', fallback: fallback.fieldBool('trace')),
      'layer_only': flag(
        'FILO_LAYER_ONLY',
        fallback: fallback.fieldBool('layer_only'),
      ),
      'windowing_spike': flag(
        'FILO_WINDOWING_SPIKE',
        fallback: fallback.fieldBool('windowing_spike'),
      ),
    };
  }

  String resolveHost(String appName) {
    for (final candidate in [appName, 'app']) {
      final file = File('${paths.hostDir}/$candidate');
      if (file.existsSync()) return file.path;
    }
    throw ToolError(
      'host executable not found in ${paths.hostDir}; run "zig build" in '
      'wayland/',
    );
  }

  String? localEngine() {
    final file = File('${paths.waylandDir}/engine/libflutter_engine.so');
    return file.existsSync() ? file.path : null;
  }

  String? defaultAssets() {
    final directory = Directory('${paths.appRoot}/build/flutter_assets');
    return directory.existsSync() ? directory.path : null;
  }

  String appName() {
    final pubspec = File('${paths.appRoot}/pubspec.yaml');
    if (!pubspec.existsSync()) return 'app';
    final name = RegExp(
      r'''^\s*name\s*:\s*['"]?([A-Za-z0-9_]+)['"]?\s*(?:#.*)?$''',
    );
    for (final line in pubspec.readAsLinesSync()) {
      final match = name.firstMatch(line);
      if (match != null) return match.group(1)!;
    }
    return 'app';
  }

  String hostTargetPlatform() {
    switch (Abi.current().toString()) {
      case 'linux_x64':
        return 'linux-x64';
      case 'linux_arm64':
        return 'linux-arm64';
      case 'linux_riscv64':
        return 'linux-riscv64';
      default:
        throw ToolError(
          'unsupported host architecture; pass --target-platform',
        );
    }
  }

  String hostArch() {
    switch (Abi.current().toString()) {
      case 'linux_x64':
        return 'x64';
      case 'linux_arm64':
        return 'arm64';
      case 'linux_riscv64':
        return 'riscv64';
      default:
        throw ToolError('unsupported host architecture');
    }
  }

  String archForTargetPlatform(String targetPlatform) {
    switch (targetPlatform) {
      case 'linux-x64':
        return 'x64';
      case 'linux-arm64':
        return 'arm64';
      case 'linux-riscv64':
        return 'riscv64';
      default:
        throw ToolError('unsupported target platform $targetPlatform');
    }
  }

  String releaseIcu(String targetPlatform) {
    final buildManifest = readManifest(paths.launchBuildFile);
    final installedManifest = readManifest(paths.launchFile);
    final candidates = <String?>[
      pathEnv('FILO_ICU_DATA'),
      buildManifest.fieldStr('icu'),
      installedManifest.fieldStr('icu'),
      '${paths.waylandDir}/engine/icudtl.dat',
      flutterIcu(targetPlatform),
    ];
    for (final candidate in candidates) {
      if (candidate == null || candidate.isEmpty) continue;
      if (File(candidate).existsSync()) return candidate;
    }
    throw ToolError(
      'no Flutter ICU data; set FILO_ICU_DATA in wayland/.env.local or run a '
      "debug build once so post-build records Flutter's icuDataPath",
    );
  }

  String? flutterIcu(String targetPlatform) {
    final ProcessResult result;
    try {
      result = Process.runSync('flutter', ['--version', '--machine']);
    } on ProcessException {
      return null;
    }
    if (result.exitCode != 0 || result.stdout is! String) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(result.stdout as String);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final root = decoded['flutterRoot']! as String;
    for (final platform in [targetPlatform, 'linux-x64']) {
      final file = File(
        '$root/bin/cache/artifacts/engine/$platform/icudtl.dat',
      );
      if (file.existsSync()) return file.path;
    }
    return null;
  }
}

/// Base class for the tool's leaf commands. `tool` is discovered lazily, so
/// `--help` and argument errors do not require a Flutter app.
abstract class ToolCommand extends Command<void> {
  late final Tool tool = Tool.discover();

  void expectCount(List<String> args, int count) {
    if (args.length != count) {
      usageException('$name expects $count argument(s), got ${args.length}');
    }
  }
}
