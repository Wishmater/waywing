import "dart:io";

import "package:path/path.dart" as path;
import "package:waywing/util/logger.dart";

String get runtimeDir {
  final runtimeDir = Platform.environment["XDG_RUNTIME_DIR"];
  if (runtimeDir != null) {
    return runtimeDir;
  }
  mainLogger.warning("XDG_RUNTIME_DIR enviroment variable not set. Fallback to /tmp");
  return "/temp";
}

String get dataHomeDir =>
    Platform.environment["XDG_DATA_HOME"] ?? path.join(Platform.environment["HOME"]!, ".local/share");

/// https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
Iterable<String> get dataDirectories sync* {
  yield dataHomeDir;
  yield* (Platform.environment["XDG_DATA_DIRS"] ?? "/usr/local/share:/usr/share").split(":");
}

Iterable<String> get pathDirectories sync* {
  final pathenv = Platform.environment["PATH"];
  if (pathenv == null) {
    return;
  }
  yield* Platform.environment["PATH"]!.split(":");
}

String get configDir => Platform.environment["XDG_CONFIG_HOME"] ?? path.join(Platform.environment["HOME"]!, ".config");
