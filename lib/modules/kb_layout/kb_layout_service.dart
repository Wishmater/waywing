import "dart:async";
import "dart:io";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx_io.dart";
import "package:flutter/foundation.dart" hide StringProperty;
import "package:path/path.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/hyprland/hyprland_service.dart";
import "package:waywing/modules/hyprland/hyrpland_models.dart";

part "kb_layout_service.config.dart";

/// This only works on hyprland as it relies on hyprctl
class KeyboardLayoutService extends Service<KbLayoutServiceConfig> {
  late HyprlandService _hyprlandService;

  KeyboardLayoutService._();
  static void registerService(RegisterServiceCallback registerService) {
    registerService<KeyboardLayoutService, KbLayoutServiceConfig>(
      ServiceRegistration(
        constructor: KeyboardLayoutService._,
        schemaBuilder: () => KbLayoutServiceConfig.schema,
        configBuilder: KbLayoutServiceConfig.fromBlock,
      ),
    );
  }

  ValueNotifier<String> layout = ValueNotifier("");
  ValueNotifier<List<String>> availableLayouts = ValueNotifier([]);
  ValueNotifier<bool> capsLockActive = ValueNotifier(false);
  ValueNotifier<bool> numsLockActive = ValueNotifier(false);
  late HyprlandKeyboardDevice currentKeyboard;
  bool _disposed = false;
  bool _requestedNumCapsLockPull = false;

  Future<void> changeLayout(String layout) async {
    final index = currentKeyboard.layouts.indexOf(layout);
    if (index == -1) {
      logger.error("$layout not found in ${currentKeyboard.layouts}");
      return;
    }
    await _hyprlandService.sendCommand("switchxkblayout", args: [currentKeyboard.name, "$index"]);
  }

  late Map<String, String> _layouts;
  File _searchFile() {
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

  Future<void> _createLayout() async {
    _layouts = {};
    final xkbdataLines = (await _searchFile().readAsString()).split("\n");
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
        _layouts[layoutName] = humanReadableName;
      }
    }
  }

  Future<HyprlandKeyboardDevice> _fromRef(HyprlandKeyboardDeviceRef ref) async {
    if (ref is HyprlandKeyboardDevice) {
      return ref;
    }
    final keyboards = await _hyprlandService.keyboards();
    final keyboardNullable = keyboards.firstOrNullWhere((e) => e.name == ref.name);
    if (keyboardNullable == null) {
      throw StateError("keyboard ${ref.name} not found");
    }
    return keyboardNullable;
  }

  @override
  Future<void> init() async {
    await _createLayout();
    _hyprlandService = await serviceRegistry.requestService<HyprlandService>(this);

    currentKeyboard = await _fromRef(_hyprlandService.values.currentKeyboardLayout.value);
    layout.value = await _findLayout(currentKeyboard) ?? "";
    _hyprlandService.values.currentKeyboardLayout.addListener(() async {
      HyprlandKeyboardDeviceRef ref = _hyprlandService.values.currentKeyboardLayout.value;
      final HyprlandKeyboardDevice keyboard = await _fromRef(ref);
      currentKeyboard = keyboard;

      final laoyutName = await _findLayout(keyboard) ?? "";
      layout.value = laoyutName;
      capsLockActive.value = keyboard.capsLock;
      numsLockActive.value = keyboard.numLock;
      if (!listEquals(availableLayouts.value, keyboard.layouts)) {
        availableLayouts.value = keyboard.layouts;
      }
    });

  }

  void requestNumCapsPull() {
    if (_requestedNumCapsLockPull) {
      return;
    }
    // TODO 2: if feather gets removed this will continue. Needs fix
    _pullNumCaps();
    _requestedNumCapsLockPull = true;
  }

  Future<void> _pullNumCaps() async {
    if (config.pullInterval < 0)  {
      /// TODO 2: if config changes this wont reload. Needs fix
      return;
    }
    while (!_disposed) {
      logger.trace("request active keyboard");
      final keyboard = await _hyprlandService.activeKeyboard();
      logger.trace("request active keyboard $keyboard");
      if (keyboard != null) {
        capsLockActive.value = keyboard.capsLock;
        numsLockActive.value = keyboard.numLock;
      }
      await Future.delayed(Duration(milliseconds: config.pullInterval));
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    layout.dispose();
    capsLockActive.dispose();
    numsLockActive.dispose();
    availableLayouts.dispose();
  }

  Future<String?> _findLayout(HyprlandKeyboardDevice ref) async {
    HyprlandKeyboardDevice? keyboard = ref;
    for (final layout in keyboard.layouts) {
      if (_layouts[layout] == keyboard.activeKeymap) {
        return layout;
      }
    }
    return null;
  }
}


@Config()
mixin KbLayoutServiceConfigBase {
  /// pull interval in milliseconds
  static const _pullInterval = IntegerNumberField(defaultTo: 500);
}
