import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/foundation.dart" hide StringProperty;
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";

/// This only works on hyprland as it relies on hyprctl
class KeyboardLayoutService extends Service {
  KeyboardLayoutService._();
  static void registerService(RegisterServiceCallback registerService) {
    registerService<KeyboardLayoutService, dynamic>(
      ServiceRegistration(
        constructor: KeyboardLayoutService._,
      ),
    );
  }

  ValueNotifier<String> layout = ValueNotifier("");
  ValueNotifier<List<String>> availableLayouts = ValueNotifier([]);
  ValueNotifier<bool> capsLockActive = ValueNotifier(false);
  ValueNotifier<bool> numsLockActive = ValueNotifier(false);

  String _activeKeyboardName = "";
  final Map<String, int> _layoutIndexes = {};

  Future<void> changeLayout(String layout) async {
    if (_activeKeyboardName == "") {
      logger.error("active keyboard name was empty when changeLayout function was called");
      return;
    }
    final index = _layoutIndexes[layout];
    if (index == null) {
      logger.error("invalid layout name expected one of ${_layoutIndexes.values} but was $layout");
      return;
    }
    Process.run("hyprctl", ["switchxkblayout", _activeKeyboardName, "$index"]);
  }

  late Map<String, String> _layouts;
  Future<void> _createLayout() async {
    _layouts = {};
    final xkbdataLines = (await File("/usr/share/X11/xkb/rules/evdev.lst").readAsString()).split("\n");
    bool inLayout = false;
    for (String line in xkbdataLines) {
      line = line.trim();
      if (inLayout) {
        if (line == "! layout") {
          inLayout = true;
        }
      } else {
        if (line == "") {
          break;
        }
        final data = line.split(RegExp("\\s+"));
        final layoutName = data[0];
        final humanReadableName = data[1];
        _layouts[layoutName] = humanReadableName;
      }
    }
  }

  late Timer _timer;

  @override
  Future<void> init() async {
    await _createLayout();

    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) async {
      final result = await Process.run(
        "hyprctl",
        ["devices", "-j"],
        stdoutEncoding: Utf8Codec(allowMalformed: true),
      );

      if (result.exitCode != 0) {
        logger.error(
          "Keyboard layout service stop. hyprctl devices -j returns non 0 exit code: ${result.exitCode}",
          properties: [StringProperty(result.stderr)],
        );
        timer.cancel();
        return;
      }

      final data = json.decode(result.stdout) as Map<String, dynamic>;
      final keyboards = data["keyboards"] as List<Map<String, dynamic>>?;
      if (keyboards == null) {
        logger.error(
          "Keyboard layout service stop. hyprctl devices -j no keyboards detected",
          properties: [StringProperty(result.stdout)],
        );
        timer.cancel();
        return;
      }

      for (final keyboard in keyboards) {
        if (keyboard["main"] == true) {
          capsLockActive.value = keyboard["capsLock"] as bool? ?? false;
          numsLockActive.value = keyboard["numLock"] as bool? ?? false;

          _activeKeyboardName = keyboard["name"];
          final layouts = (keyboard["layout"] as String).split(",");
          final humanReadableName = keyboard["active_keymap"] as String;
          _layoutIndexes.clear();

          int count = 0;
          List<String> newLayouts = [];
          for (final layout in layouts) {
            _layoutIndexes[layout] = count;
            count++;
            newLayouts.add(layout);

            if (_layouts[layout] == humanReadableName) {
              this.layout.value = layout;
            }
          }
          if (!listEquals(availableLayouts.value, newLayouts)) {
            availableLayouts.value = newLayouts;
          }
          break;
        }
      }
    });
  }

  @override
  Future<void> dispose() async {
    _timer.cancel();
    layout.dispose();
  }
}
