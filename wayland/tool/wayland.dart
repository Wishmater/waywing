#!/usr/bin/env dart

// Wayland host tooling for a Flutter app using filo.
//
// This is the per-app custom-device helper: postBuild/install/uninstall/ping
// hooks, the launch manifest, and the first-time setup commands. It only uses
// the Dart SDK (`dart:io` and `dart:convert`), so it runs from any Flutter app
// without adding a package dependency.
//
// Custom devices run hooks from the app root. The app root is derived from this
// script's location (`<app>/wayland/tool/wayland.dart`), not from the current
// directory, so the tool also works when invoked manually.
//
// Run it as `dart wayland/tool/wayland.dart <command>` (not `dart run`): the
// plain form keeps the Dart VM in the process Flutter starts, which matters for
// the one-shot hooks.

import "dart:async";
import "dart:convert";
import "dart:io";

const _toolName = "filo-wayland";

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first == "--help" || args.first == "-h") {
    _printUsage();
    return;
  }

  try {
    final paths = _Paths.discover();
    final tool = _WaylandTool(paths);
    final command = args.first;
    final rest = args.sublist(1);

    if (command == "ping") {
      tool.ping(rest);
    } else if (command == "post-build") {
      await tool.postBuild(rest);
    } else if (command == "install") {
      await tool.install(rest);
    } else if (command == "uninstall") {
      await tool.uninstall(rest);
    } else if (command == "run") {
      await tool.run(rest);
    } else if (command == "setup-filo") {
      await tool.setupFilo(rest);
    } else if (command == "register-device") {
      await tool.registerDevice(rest);
    } else {
      throw _UsageError('unknown command "$command"');
    }
  } on _UsageError catch (error) {
    stderr.writeln("$_toolName: ${error.message}");
    _printUsage(toStderr: true);
    exitCode = 64;
  } on _ToolError catch (error) {
    stderr.writeln("$_toolName: ${error.message}");
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln("$_toolName: ${error.message}");
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln("$_toolName: ${error.message}");
    exitCode = 1;
  }
}

void _printUsage({bool toStderr = false}) {
  final out = toStderr ? stderr : stdout;
  out.writeln("Usage: dart wayland/tool/wayland.dart <command> [arguments]");
  out.writeln("");
  out.writeln("Commands:");
  out.writeln("  ping");
  out.writeln(
    "  post-build <appName> <localPath> <buildMode> <icuDataPath> <engineRevision>",
  );
  out.writeln("  install <appName> <localPath>");
  out.writeln("  uninstall <appName>");
  out.writeln("  run [dart arguments...]");
  out.writeln("  setup-filo <filo-package-url>");
  out.writeln("  register-device");
}

class _UsageError extends _ToolError {
  _UsageError(super.message);
}

class _ToolError implements Exception {
  _ToolError(this.message);

  final String message;
}

class _Paths {
  _Paths({required this.appRoot, required this.waylandDir});

  final String appRoot;
  final String waylandDir;

  String get hostDir => "$waylandDir/zig-out/bin";
  String get launchBuildFile => "$waylandDir/.filo-build/launch.json";
  String get launchFile => "$waylandDir/.filo/launch.json";
  String get dotenvFile => "$waylandDir/.env.local";
  String get customDeviceFile => "$waylandDir/custom-device.json";

  static _Paths discover() {
    String? script;
    try {
      script = File.fromUri(Platform.script).resolveSymbolicLinksSync();
    } on FileSystemException {
      script = null;
    }
    if (script != null) {
      final wayland = File(script).parent.parent;
      if (File("${wayland.path}/build.zig").existsSync()) {
        return _Paths(appRoot: wayland.parent.path, waylandDir: wayland.path);
      }
    }

    // Fallback for a copied script: walk up from the current directory to the
    // app root. This also handles being invoked from a subdirectory.
    var directory = Directory.current;
    while (true) {
      if (File("${directory.path}/wayland/build.zig").existsSync()) {
        return _Paths(
          appRoot: directory.path,
          waylandDir: "${directory.path}/wayland",
        );
      }
      final parent = directory.parent;
      if (parent.path == directory.path) break;
      directory = parent;
    }

    throw _ToolError(
      "cannot find the app root; run this from the Flutter app or keep "
      "wayland/tool/wayland.dart in place",
    );
  }
}

class _WaylandTool {
  _WaylandTool(this.paths);

  final _Paths paths;

  late final Map<String, String> _dotenv = _readDotEnv(paths.dotenvFile);

  void ping(List<String> args) {
    _expectCount(args, 0, "ping");
    final problems = <String>[];
    if (!File("${paths.waylandDir}/build.zig").existsSync()) {
      problems.add("wayland/build.zig not found");
    }
    if ((Platform.environment["WAYLAND_DISPLAY"] ?? "").isEmpty) {
      problems.add("WAYLAND_DISPLAY is not set");
    }
    if ((Platform.environment["XDG_RUNTIME_DIR"] ?? "").isEmpty) {
      problems.add("XDG_RUNTIME_DIR is not set");
    }
    if (problems.isEmpty) return;
    for (final problem in problems) {
      stderr.writeln("$_toolName: $problem");
    }
    exitCode = 1;
  }

  Future<void> postBuild(List<String> args) async {
    _expectCount(args, 5, "post-build");
    final appName = args[0];
    final localPath = args[1].isEmpty ? null : args[1];
    // args[2] (buildMode) and args[4] (engineRevision) are accepted for future
    // packaging steps; the debug host does not need them.
    final icuDataPath = args[3].isEmpty ? null : args[3];

    await _runInherited(
      "zig",
      ["build", "-Doptimize=Debug", "-Dapp-name=$appName"],
      workingDirectory: paths.waylandDir,
      missingMessage: "zig is not on PATH",
    );

    final host = File("${paths.hostDir}/$appName");
    if (!host.existsSync()) {
      throw _ToolError("zig build did not create ${host.path}");
    }

    final manifest = _resolveLaunch(
      appName: appName,
      localPath: localPath,
      icuOverride: icuDataPath,
    );
    _writeJson(paths.launchBuildFile, manifest);
    stdout.writeln("$_toolName: wrote ${paths.launchBuildFile}");
  }

  Future<void> install(List<String> args) async {
    _expectCount(args, 2, "install");
    final appName = args[0];
    final localPath = args[1].isEmpty ? null : args[1];
    final fallback = _readManifest(paths.launchBuildFile);
    final manifest = _resolveLaunch(
      appName: appName,
      localPath: localPath,
      fallback: fallback,
    );
    _writeJson(paths.launchFile, manifest);
  }

  Future<void> uninstall(List<String> args) async {
    _expectCount(args, 1, "uninstall");
    final directory = Directory("${paths.waylandDir}/.filo");
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }

  Future<void> run(List<String> args) async {
    final buildManifest = _readManifest(paths.launchBuildFile);
    final installedManifest = _readManifest(paths.launchFile);
    final fallback = installedManifest ?? buildManifest;
    final appName = _stringField(fallback, "app_name") ?? "app";
    final manifest = _resolveLaunch(appName: appName, fallback: fallback);
    _writeJson(paths.launchFile, manifest);

    final host = _resolveHost(appName);
    await _startAndWait(host, args, workingDirectory: paths.appRoot);
  }

  Future<void> setupFilo(List<String> args) async {
    _expectCount(args, 1, "setup-filo");
    await _runInherited(
      "zig",
      ["fetch", "--save=filo", args[0]],
      workingDirectory: paths.waylandDir,
      missingMessage: "zig is not on PATH",
    );
  }

  Future<void> registerDevice(List<String> args) async {
    _expectCount(args, 0, "register-device");
    final customDevice = File(paths.customDeviceFile);
    if (!customDevice.existsSync()) {
      throw _ToolError("${customDevice.path} not found");
    }
    final json = customDevice.readAsStringSync();

    await _runQuiet("flutter", [
      "config",
      "--enable-custom-devices",
    ], workingDirectory: paths.appRoot);
    // `custom-devices add` appends, so drop an older entry with the same id.
    await _runQuiet(
      "flutter",
      ["custom-devices", "delete", "-d", "filo_wayland"],
      workingDirectory: paths.appRoot,
      allowFailure: true,
    );
    await _runInherited(
      "flutter",
      ["custom-devices", "add", "--json", json, "--check"],
      workingDirectory: paths.appRoot,
      missingMessage: "flutter is not on PATH",
    );
  }

  Map<String, Object?> _resolveLaunch({
    required String appName,
    String? localPath,
    String? icuOverride,
    Map<String, Object?>? fallback,
  }) {
    final engine = _require(
      _pathSetting("FILO_ENGINE_LIB") ??
          _stringField(fallback, "engine") ??
          _localEngine(),
      "FILO_ENGINE_LIB is not set; add it to wayland/.env.local",
    );
    final icu = _require(
      _pathSetting("FILO_ICU_DATA") ??
          _resolveOptionalPath(icuOverride, paths.appRoot) ??
          _stringField(fallback, "icu"),
      "no Flutter ICU data path; run post-build or set FILO_ICU_DATA",
    );
    final assets = _require(
      _pathSetting("FILO_ASSETS") ??
          _resolveOptionalPath(localPath, paths.appRoot) ??
          _stringField(fallback, "assets") ??
          _defaultAssets(),
      "no flutter_assets directory; run install or set FILO_ASSETS",
    );
    final aot = _pathSetting("FILO_AOT_LIB") ?? _stringField(fallback, "aot");

    return {
      "app_name": appName,
      "engine": engine,
      "icu": icu,
      "assets": assets,
      "aot": aot,
      "dart_args":
          _dartArgsSetting() ??
          _stringListField(fallback, "dart_args") ??
          <String>[],
      "force_impeller": _flag(
        "FORCE_IMPELLER",
        fallback: _boolField(fallback, "force_impeller"),
      ),
      "vulkan_validation": _flag(
        "FILO_VULKAN_VALIDATION",
        fallback: _boolField(fallback, "vulkan_validation"),
      ),
      "trace": _flag("FILO_TRACE", fallback: _boolField(fallback, "trace")),
      "layer_only": _flag(
        "FILO_LAYER_ONLY",
        fallback: _boolField(fallback, "layer_only"),
      ),
      "windowing_spike": _flag(
        "FILO_WINDOWING_SPIKE",
        fallback: _boolField(fallback, "windowing_spike"),
      ),
    };
  }

  String _resolveHost(String appName) {
    for (final candidate in [appName, "app"]) {
      final file = File("${paths.hostDir}/$candidate");
      if (file.existsSync()) return file.path;
    }
    throw _ToolError(
      'host executable not found in ${paths.hostDir}; run "zig build" in '
      "wayland/",
    );
  }

  String? _pathSetting(String key) {
    final value = _setting(key);
    if (value == null || value.isEmpty) return null;
    return _resolvePath(value, paths.waylandDir);
  }

  String? _setting(String key) => Platform.environment[key] ?? _dotenv[key];

  String? _localEngine() {
    final file = File("${paths.waylandDir}/engine/libflutter_engine.so");
    return file.existsSync() ? file.path : null;
  }

  String? _defaultAssets() {
    final directory = Directory("${paths.appRoot}/build/flutter_assets");
    return directory.existsSync() ? directory.path : null;
  }

  bool _flag(String key, {required bool fallback}) {
    final value = _setting(key);
    if (value == null) return fallback;
    return value.isNotEmpty;
  }

  List<String>? _dartArgsSetting() {
    final value = _setting("FILO_DART_ENTRYPOINT_ARGS");
    if (value == null) return null;
    if (value.isEmpty) return <String>[];
    final lines = value.split("\n");
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
    return [
      for (final line in lines)
        if (line.endsWith("\r")) line.substring(0, line.length - 1) else line,
    ];
  }
}

String _require(String? value, String message) {
  if (value == null) throw _ToolError(message);
  return value;
}

String _resolvePath(String path, String base) {
  final absolute = path.startsWith("/") ? path : "$base/$path";
  return Uri.file(absolute).normalizePath().toFilePath();
}

String? _resolveOptionalPath(String? path, String base) {
  if (path == null || path.isEmpty) return null;
  return _resolvePath(path, base);
}

String? _stringField(Map<String, Object?>? map, String key) {
  final value = map?[key];
  return value is String && value.isNotEmpty ? value : null;
}

bool _boolField(Map<String, Object?>? map, String key) => map?[key] == true;

List<String>? _stringListField(Map<String, Object?>? map, String key) {
  final value = map?[key];
  if (value is! List) return null;
  return [
    for (final item in value)
      if (item is String) item,
  ];
}

Map<String, Object?>? _readManifest(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on FormatException catch (error) {
    throw _ToolError("$path: ${error.message}");
  }
  if (decoded is! Map<String, dynamic>) {
    throw _ToolError("$path: expected a JSON object");
  }
  return decoded;
}

void _writeJson(String path, Map<String, Object?> value) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
}

Map<String, String> _readDotEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return const {};
  final values = <String, String>{};
  final lines = file.readAsLinesSync();
  for (var index = 0; index < lines.length; index++) {
    final location = "$path:${index + 1}";
    var line = lines[index].trim();
    if (line.isEmpty || line.startsWith("#")) continue;
    if (line.startsWith("export ")) {
      line = line.substring("export ".length).trimLeft();
    }
    final equals = line.indexOf("=");
    if (equals <= 0) {
      throw _ToolError("$location: expected KEY=VALUE");
    }
    final key = line.substring(0, equals).trim();
    if (!_envKey.hasMatch(key)) {
      throw _ToolError('$location: invalid variable name "$key"');
    }
    final raw = line.substring(equals + 1).trim();
    values[key] = _parseDotEnvValue(raw, location);
  }
  return values;
}

final _envKey = RegExp(r"^[A-Za-z_][A-Za-z0-9_]*$");
final _shellExpansion = RegExp(r"\$[A-Za-z_{(]");

String _parseDotEnvValue(String raw, String location) {
  if (raw.isEmpty) return "";
  if (raw.startsWith(r"$'")) {
    if (raw.length < 3 || !raw.endsWith("'")) {
      throw _ToolError("$location: unterminated \$'...' value");
    }
    return _parseAnsiC(raw.substring(2, raw.length - 1), location);
  }
  if (raw.startsWith("'")) {
    if (raw.length < 2 || !raw.endsWith("'")) {
      throw _ToolError("$location: unterminated single-quoted value");
    }
    return raw.substring(1, raw.length - 1);
  }
  if (raw.startsWith('"')) {
    if (raw.length < 2 || !raw.endsWith('"')) {
      throw _ToolError("$location: unterminated double-quoted value");
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
    if (char == r"\" &&
        index + 1 < body.length &&
        (body[index + 1] == '"' || body[index + 1] == r"\")) {
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
    if (char != r"\") {
      out.write(char);
      continue;
    }
    index++;
    if (index >= body.length) {
      throw _ToolError("$location: trailing backslash in \$'...' value");
    }
    switch (body[index]) {
      case "n":
        out.write("\n");
      case "r":
        out.write("\r");
      case "t":
        out.write("\t");
      case r"\":
        out.write(r"\");
      case "'":
        out.write("'");
      case '"':
        out.write('"');
      default:
        throw _ToolError(
          "$location: unknown escape \"\\${body[index]}\" in \$'...' value",
        );
    }
  }
  return out.toString();
}

void _rejectExpansion(String value, String location) {
  if (value.contains("`") || _shellExpansion.hasMatch(value)) {
    throw _ToolError(
      "$location: shell expansion is not supported; use a literal value",
    );
  }
}

void _expectCount(List<String> args, int count, String command) {
  if (args.length != count) {
    throw _UsageError(
      "$command expects $count argument(s), got ${args.length}",
    );
  }
}

Future<void> _runInherited(
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
    throw _ToolError(missingMessage);
  }
  final code = await process.exitCode;
  if (code != 0) {
    throw _ToolError(
      '$executable ${arguments.join(' ')} failed with exit code $code',
    );
  }
}

Future<void> _runQuiet(
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
    throw _ToolError("$executable is not on PATH");
  }
  if (result.exitCode == 0 || allowFailure) return;
  final output = "${result.stdout}${result.stderr}".trim();
  throw _ToolError(
    '$executable ${arguments.join(' ')} failed with exit code '
    '${result.exitCode}${output.isEmpty ? '' : ':\n$output'}',
  );
}

Future<void> _startAndWait(
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
    throw _ToolError("failed to run $executable");
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
