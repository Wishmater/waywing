import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:args/command_runner.dart';

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
  String get buildDir => '$appRoot/build/wayland';
  String get releaseDir => '$buildDir/release';
  String get defaultDistDir => '$buildDir/dist';
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

String resolvePath(String path, String base) {
  final absolute = path.startsWith('/') ? path : '$base/$path';
  return Uri.file(absolute).normalizePath().toFilePath();
}

String? resolveOptionalPath(String? path, String base) {
  if (path == null || path.isEmpty) return null;
  return resolvePath(path, base);
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

String? stringField(Map<String, Object?>? map, String key) {
  final value = map?[key];
  return value is String && value.isNotEmpty ? value : null;
}

bool boolField(Map<String, Object?>? map, String key) => map?[key] == true;

List<String>? stringListField(Map<String, Object?>? map, String key) {
  final value = map?[key];
  if (value is! List) return null;
  return [
    for (final item in value)
      if (item is String) item,
  ];
}

String requireValue(String? value, String message) {
  if (value == null) throw ToolError(message);
  return value;
}

/// Parse `wayland/.env.local`.
///
/// Supports `KEY=VALUE`, comments, single/double quoted values and `$'...'`
/// escapes. Variable expansion and command substitution are rejected.
Map<String, String> readDotEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return const {};
  final values = <String, String>{};
  final lines = file.readAsLinesSync();
  for (var index = 0; index < lines.length; index++) {
    final location = '$path:${index + 1}';
    var line = lines[index].trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    if (line.startsWith('export ')) {
      line = line.substring('export '.length).trimLeft();
    }
    final equals = line.indexOf('=');
    if (equals <= 0) {
      throw ToolError('$location: expected KEY=VALUE');
    }
    final key = line.substring(0, equals).trim();
    if (!_envKey.hasMatch(key)) {
      throw ToolError('$location: invalid variable name "$key"');
    }
    final raw = line.substring(equals + 1).trim();
    values[key] = _parseDotEnvValue(raw, location);
  }
  return values;
}

final _envKey = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
final _shellExpansion = RegExp(r'\$[A-Za-z_{(]');

String _parseDotEnvValue(String raw, String location) {
  if (raw.isEmpty) return '';
  if (raw.startsWith(r"$'")) {
    if (raw.length < 3 || !raw.endsWith("'")) {
      throw ToolError("$location: unterminated \$'...' value");
    }
    return _parseAnsiC(raw.substring(2, raw.length - 1), location);
  }
  if (raw.startsWith("'")) {
    if (raw.length < 2 || !raw.endsWith("'")) {
      throw ToolError('$location: unterminated single-quoted value');
    }
    return raw.substring(1, raw.length - 1);
  }
  if (raw.startsWith('"')) {
    if (raw.length < 2 || !raw.endsWith('"')) {
      throw ToolError('$location: unterminated double-quoted value');
    }
    return _parseDoubleQuoted(raw.substring(1, raw.length - 1), location);
  }
  _rejectExpansion(raw, location);
  return raw;
}

String _parseDoubleQuoted(String body, String location) {
  _rejectExpansion(body, location);
  final out = StringBuffer();
  for (var index = 0; index < body.length; index++) {
    final char = body[index];
    if (char == r'\' &&
        index + 1 < body.length &&
        (body[index + 1] == '"' || body[index + 1] == r'\')) {
      out.write(body[index + 1]);
      index++;
    } else {
      out.write(char);
    }
  }
  return out.toString();
}

String _parseAnsiC(String body, String location) {
  final out = StringBuffer();
  for (var index = 0; index < body.length; index++) {
    final char = body[index];
    if (char != r'\') {
      out.write(char);
      continue;
    }
    index++;
    if (index >= body.length) {
      throw ToolError("$location: trailing backslash in \$'...' value");
    }
    switch (body[index]) {
      case 'n':
        out.write('\n');
      case 'r':
        out.write('\r');
      case 't':
        out.write('\t');
      case r'\':
        out.write(r'\');
      case "'":
        out.write("'");
      case '"':
        out.write('"');
      default:
        throw ToolError(
          "$location: unknown escape \"\\${body[index]}\" in \$'...' value",
        );
    }
  }
  return out.toString();
}

void _rejectExpansion(String value, String location) {
  if (value.contains('`') || _shellExpansion.hasMatch(value)) {
    throw ToolError(
      '$location: shell expansion is not supported; use a literal value',
    );
  }
}

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

Future<void> runQuiet(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  bool allowFailure = false,
}) async {
  final ProcessResult result;
  try {
    result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
  } on ProcessException {
    throw ToolError('$executable is not on PATH');
  }
  if (result.exitCode == 0 || allowFailure) return;
  final output = '${result.stdout}${result.stderr}'.trim();
  throw ToolError(
    '$executable ${arguments.join(' ')} failed with exit code '
    '${result.exitCode}${output.isEmpty ? '' : ':\n$output'}',
  );
}

Future<void> startAndWait(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
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
    throw ToolError('failed to run $executable');
  }

  final subscriptions = <StreamSubscription<ProcessSignal>>[];
  void forward(ProcessSignal signal) {
    try {
      subscriptions.add(
        signal.watch().listen((_) {
          process.kill(signal);
        }),
      );
    } on SignalException {
      // Signal is not supported on this platform; ignore it.
    }
  }

  forward(ProcessSignal.sigterm);
  forward(ProcessSignal.sigint);
  forward(ProcessSignal.sighup);

  final code = await process.exitCode;
  for (final subscription in subscriptions) {
    await subscription.cancel();
  }
  if (code != 0) {
    exitCode = code < 0 ? 128 - code : code;
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

  String? setting(String key) => Platform.environment[key] ?? _dotenv[key];

  String? pathSetting(String key) {
    final value = setting(key);
    if (value == null || value.isEmpty) return null;
    return resolvePath(value, paths.waylandDir);
  }

  bool flag(String key, {required bool fallback}) {
    final value = setting(key);
    if (value == null) return fallback;
    return value.isNotEmpty;
  }

  List<String>? dartArgsSetting() {
    final value = setting('FILO_DART_ENTRYPOINT_ARGS');
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
    final engine = requireValue(
      pathSetting('FILO_ENGINE_LIB') ??
          stringField(fallback, 'engine') ??
          localEngine(),
      'FILO_ENGINE_LIB is not set; add it to wayland/.env.local',
    );
    final icu = requireValue(
      pathSetting('FILO_ICU_DATA') ??
          resolveOptionalPath(icuOverride, paths.appRoot) ??
          stringField(fallback, 'icu'),
      'no Flutter ICU data path; run post-build or set FILO_ICU_DATA',
    );
    final assets = requireValue(
      pathSetting('FILO_ASSETS') ??
          resolveOptionalPath(localPath, paths.appRoot) ??
          stringField(fallback, 'assets') ??
          defaultAssets(),
      'no flutter_assets directory; run install or set FILO_ASSETS',
    );
    final aot = pathSetting('FILO_AOT_LIB') ?? stringField(fallback, 'aot');

    return launchManifest(
      appName: appName,
      engine: engine,
      icu: icu,
      assets: assets,
      aot: aot,
      fallback: fallback,
    );
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
          dartArgsSetting() ??
          stringListField(fallback, 'dart_args') ??
          <String>[],
      'force_impeller': flag(
        'FORCE_IMPELLER',
        fallback: boolField(fallback, 'force_impeller'),
      ),
      'vulkan_validation': flag(
        'FILO_VULKAN_VALIDATION',
        fallback: boolField(fallback, 'vulkan_validation'),
      ),
      'trace': flag('FILO_TRACE', fallback: boolField(fallback, 'trace')),
      'layer_only': flag(
        'FILO_LAYER_ONLY',
        fallback: boolField(fallback, 'layer_only'),
      ),
      'windowing_spike': flag(
        'FILO_WINDOWING_SPIKE',
        fallback: boolField(fallback, 'windowing_spike'),
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

  String releaseEngine() {
    final configured = pathSetting('FILO_ENGINE_LIB_RELEASE');
    if (configured != null) {
      if (!File(configured).existsSync()) {
        throw ToolError(
          'FILO_ENGINE_LIB_RELEASE points to a missing file: $configured',
        );
      }
      return configured;
    }
    final local = File(
      '${paths.waylandDir}/engine/release/libflutter_engine.so',
    );
    if (local.existsSync()) return local.path;
    throw ToolError(
      'no release engine; set FILO_ENGINE_LIB_RELEASE in wayland/.env.local '
      'to a release-built libflutter_engine.so',
    );
  }

  String releaseIcu(String targetPlatform) {
    final buildManifest = readManifest(paths.launchBuildFile);
    final installedManifest = readManifest(paths.launchFile);
    final candidates = <String?>[
      pathSetting('FILO_ICU_DATA'),
      stringField(buildManifest, 'icu'),
      stringField(installedManifest, 'icu'),
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
    final root = decoded['flutterRoot'];
    if (root is! String || root.isEmpty) return null;
    for (final platform in {targetPlatform, 'linux-x64'}) {
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
