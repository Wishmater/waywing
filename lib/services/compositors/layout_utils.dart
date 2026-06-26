import "dart:io";

import "package:flutter/foundation.dart";
import "package:path/path.dart";
import "package:waywing/services/compositors/xkb_ffi.dart";
import "package:tronco/tronco.dart";
import "package:waywing/util/logger.dart";

final _logger = mainLogger.clone(properties: [LogType("LayoutUtils")]);

typedef SearchStrategy = File? Function();

final class LayoutUtils {
  static Map<String, String>? _layouts;

  static Map<String, String> get layouts {
    if (_layouts != null) return _layouts!;
    _createLayout();
    return _layouts!;
  }

  /// Find layout from human readable to short
  static String? findLayout(String layout) {
    return layouts[layout];
  }

  static void _createLayout() {
    _layouts = {};
    final xkbdataLines = (_searchFile().readAsStringSync()).split("\n");
    bool inLayout = false;
    for (String line in xkbdataLines) {
      line = line.trim();
      if (!inLayout) {
        if (line == "! layout") {
          inLayout = true;
        }
      } else {
        if (line == "") {
          break;
        }
        final data = line.split(RegExp("\\s+"));
        final layoutName = data[0];
        final humanReadableName = line.substring(data[0].length).trim();
        _layouts![humanReadableName] = layoutName;
      }
    }
  }

  static File _searchFile() {
    final strategies = <(String, SearchStrategy)>[
      ("libxkbcommon FFI", _searchViaXkbCommon),
      ("XDG_DATA_DIRS", _searchViaXdgDataDirs),
    ];

    final failed = <String>[];
    for (final (name, strategy) in strategies) {
      try {
        final result = strategy();
        if (result != null) {
          _logger.log(Level.trace, "Found evdev.lst via $name");
          return result;
        }
      } catch (e) {
        failed.add("$name: $e");
        continue;
      }
      failed.add(name);
    }

    throw StateError(
      "evdev.lst file not found. Tried:\n${failed.map((f) => "  - $f").join("\n")}",
    );
  }

  static File? _searchViaXkbCommon() {
    final configPath = XkbFfi.getXkbConfigPath();
    if (configPath == null) return null;
    final file = File(join(configPath, "rules/evdev.lst"));
    if (file.existsSync()) return file;
    return null;
  }

  static File? _searchViaXdgDataDirs() {
    final path = "X11/xkb/rules/evdev.lst";
    final dirs = (Platform.environment["XDG_DATA_DIRS"] ?? "/usr/local/share:/usr/share").split(":");
    for (final dir in dirs) {
      final file = File(join(dir, path));
      if (file.existsSync()) {
        return file;
      }
    }
    return null;
  }
}
