import "dart:io";

import "package:path/path.dart";

final class LayoutUtils {
  static Map<String, String>? _layouts;
  static Map<String, String> get layouts {
    if (_layouts != null) _layouts;
    _createLayout();
    return _layouts!;
  }

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
    final path = "X11/xkb/rules/evdev.lst";
    final dirs = (Platform.environment["XDG_DATA_DIRS"] ?? "/usr/local/share:/usr/share").split(":");
    for (final dir in dirs) {
      final file = File(join(dir, path));
      if (file.existsSync()) {
        return file;
      }
    }
    throw StateError("X11/xkb/rules/evdev.lst file not found");
  }
}
