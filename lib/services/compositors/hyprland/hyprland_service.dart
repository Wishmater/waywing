import "dart:async";
import "dart:convert";
import "dart:io";
import "package:dartx/dartx.dart";
import "package:flutter/foundation.dart";
import "package:path/path.dart" as path;

import "package:waywing/services/compositors/compositor.dart";
import "package:waywing/services/compositors/layout_utils.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "hyrpland_models.dart";

class HyprlandService extends CompositorService {
  HyprlandService();

  late final Socket _socket;
  // late final HyprlandValues values;

  String get commandSocketPath {
    final hyprlandRuntimeDir = path.join(
      Platform.environment["XDG_RUNTIME_DIR"]!,
      "hypr/${Platform.environment["HYPRLAND_INSTANCE_SIGNATURE"]}",
    );
    return path.join(hyprlandRuntimeDir, ".socket.sock");
  }

  String get eventsSocketPath {
    final hyprlandRuntimeDir = path.join(
      Platform.environment["XDG_RUNTIME_DIR"]!,
      "hypr/${Platform.environment["HYPRLAND_INSTANCE_SIGNATURE"]}",
    );
    return path.join(hyprlandRuntimeDir, ".socket2.sock");
  }

  Future<Socket> _newConnectio() {
    return Socket.connect(InternetAddress(commandSocketPath, type: InternetAddressType.unix), 0);
  }

  Future<String> sendCommand(
    String command, {
    List<String> args = const [],
    List<String> flags = const [],
  }) async {
    final socket = await _newConnectio();
    final completer = Completer<String>();
    socket.listen((data) {
      completer.complete(String.fromCharCodes(data));
    });
    final cmd =
        "${flags.isNotEmpty ? "${flags.join(' ')}/" : ''}$command${args.isNotEmpty ? " ${args.join(' ')}" : ''}";
    // TODO 3: this throw sometimes...
    socket.write(cmd);
    logger.debug("send command to hyprland: $cmd");
    final response = await completer.future;
    socket.close();
    return response;
  }

  Future<List<HyprlandWorkspace>> callWorkspaces() async {
    final data = await sendCommand("workspaces", flags: ["-j"]);
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((e) => HyprlandWorkspace.fromJson(e as Map<String, Object?>)).toList();
  }

  Future<HyprlandWorkspace?> callActiveWorkspace() async {
    final data = await sendCommand("activeworkspace", flags: ["-j"]);
    final Map<String, Object?> decoded = json.decode(data);
    if (decoded.isEmpty) return null;
    return HyprlandWorkspace.fromJson(decoded);
  }

  Future<void> callChangeWorkspace(int id) async {
    await sendCommand("dispatch", args: ["workspace", "$id"], flags: ["-j"]);
  }

  Future<List<HyprlandWindow>> callWindows() async {
    final data = await sendCommand("clients", flags: ["-j"]);
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((e) => HyprlandWindow.fromJson(e as Map<String, Object?>)).toList();
  }

  Future<HyprlandWindow?> callActiveWindow() async {
    final data = await sendCommand("activewindow", flags: ["-j"]);
    final Map<String, Object?> decoded = json.decode(data);
    if (decoded.isEmpty) return null;
    return HyprlandWindow.fromJson(decoded);
  }

  Future<List<HyprlandKeyboardDevice>> callKeyboards() async {
    final data = await sendCommand("devices", flags: ["-j"]);
    final Map<String, Object?> decoded = json.decode(data);
    final List<dynamic>? keyboards = decoded["keyboards"] as List<dynamic>?;
    if (keyboards == null) return [];
    return keyboards.map((e) => HyprlandKeyboardDevice.fromJson(e as Map<String, Object?>)).toList();
  }

  Future<HyprlandKeyboardDevice?> callActiveKeyboard() async {
    final list = await callKeyboards();
    if (list.isEmpty) return null;
    return list.firstOrNullWhere((keyboard) => keyboard.main == true);
  }

  @override
  Future<void> init() async {
    _socket = await Socket.connect(InternetAddress(eventsSocketPath, type: InternetAddressType.unix), 0);

    {
      final windowsHypr = await callWindows();
      final activeWindow = await callActiveWindow();
      windows.value = windowsHypr
          .map(
            (w) => CompositorWindows(
              id: w.address,
              pid: w.pid,
              appId: w.className,
              title: w.title,
              hasFocus: w.address == activeWindow?.address,
              isFloating: w.floating,
              isUrgent: false,
              inner: w,
            ),
          )
          .toList(growable: false);
    }
    {
      final workspacesHypr = await callWorkspaces();
      final activeWorkspace = await callActiveWorkspace();
      workspaces.value = CompositorWorkspaceManager(
        workspacesHypr
            // Avoid special workspaces
            .where((e) => e.id >= 0)
            .map(
              (w) => CompositorWorkspace(
                w.id.toString(),
                w.name,
                w.id,
                w,
              ),
            )
            .toList(),
        activeWorkspace != null
            ? [
                (
                  CompositorMonitor(activeWorkspace.monitorId.toString(), activeWorkspace.monitorId.toString(), null),
                  CompositorWorkspace(
                    activeWorkspace.id.toString(),
                    activeWorkspace.name,
                    activeWorkspace.id,
                    activeWorkspace,
                  ),
                ),
              ]
            : [],
      );
    }
    {
      final keyboard = await callActiveKeyboard();
      if (keyboard != null) {
        isNumlockActive.value = keyboard.numLock;
        isCapslockActive.value = keyboard.capsLock;
        final idx = keyboard.layouts.indexOf(LayoutUtils.findLayout(keyboard.activeKeymap) ?? "__not_found__");
        if (idx == -1) {
          keyboardLayouts.value = null;
        } else {
          keyboardLayouts.value = CompositorKeyboardLayouts(keyboard.layouts, idx, keyboard);
        }
      }
      _pollNumlockCapslockData();
    }

    _socket.listen((data) => addEvents(String.fromCharCodes(data)));
  }

  Future<void> _pollNumlockCapslockData() async {
    while (!_disposed) {
      await Future.delayed(Duration(milliseconds: 100));
      final keyboard = await callActiveKeyboard();
      if (keyboard != null) {
        isNumlockActive.value = keyboard.numLock;
        isCapslockActive.value = keyboard.capsLock;
      }
    }
  }

  void addEvents(String data) {
    logger.debug("New event $data");
    final lines = data.split("\n");
    for (final line in lines) {
      if (line.isEmpty) continue;

      final separatorIndex = line.indexOf(">>");
      if (separatorIndex == -1) {
        logger.error("invalid event data $line");
        continue;
      }
      _eventsHandlers[line.substring(0, separatorIndex)]?.call(line.substring(separatorIndex + 2));
    }
  }

  @override
  final ValueNotifier<CompositorKeyboardLayouts?> keyboardLayouts = ValueNotifier(null);

  @override
  bool get supportKeyboardLayouts => true;

  @override
  Future<void> switchLayout(int index) async {
    final device = keyboardLayouts.value?.inner as HyprlandKeyboardDevice;
    await sendCommand("switchxkblayout", args: [device.name, "$index"]);
  }

  @override
  Future<void> switchLayoutNext() async {
    final device = keyboardLayouts.value?.inner as HyprlandKeyboardDevice;
    await sendCommand("switchxkblayout", args: [device.name, "next"]);
  }

  @override
  Future<void> switchLayoutPrevious() async {
    final device = keyboardLayouts.value?.inner as HyprlandKeyboardDevice;
    await sendCommand("switchxkblayout", args: [device.name, "prev"]);
  }

  @override
  // TODO 3: fill monitors on start
  bool get supportMonitors => false;

  @override
  final ManualValueNotifier<List<CompositorMonitor>> monitors = ManualValueNotifier([]);

  @override
  bool get supportCapslock => true;

  @override
  // TODO: implement isCapslockActive
  final ValueNotifier<bool> isCapslockActive = ValueNotifier(false);

  @override
  bool get supportNumlock => true;

  @override
  // TODO: implement isNumlockActive
  final ValueNotifier<bool> isNumlockActive = ValueNotifier(false);

  @override
  bool get supportWindows => true;

  @override
  ValueNotifier<List<CompositorWindows>> windows = ValueNotifier([]);

  @override
  bool get supportWorkspaces => true;

  @override
  ValueNotifier<CompositorWorkspaceManager> workspaces = ValueNotifier(CompositorWorkspaceManager([], []));

  @override
  Future<void> switchWorkspace(CompositorWorkspace workspace) async {
    await callChangeWorkspace(int.parse(workspace.id));
  }

  void _workspaceChangeEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length < 2) {
      return;
    }
    final id = int.tryParse(splitted[0]);
    if (id == null) {
      return;
    }
    final name = splitted.sublist(1).join(",");
    for (final w in workspaces.value.workspaces) {
      if (w.id == id.toString()) {
        w.name = name;
        workspaces.value.focused.first = (workspaces.value.focused.first.$1, w);
        break;
      }
    }
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    workspaces.notifyListeners();
  }

  void _urgentAddEvent(String event) {
    for (final w in windows.value) {
      if (w.id == event) {
        w.isUrgent = !w.isUrgent;
        break;
      }
    }
  }

  void _windowTitleChangeAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length < 2) {
      return;
    }
    final addr = splitted[0];
    final title = splitted.sublist(1).join(",");
    for (final w in windows.value) {
      if (w.id == addr) {
        w.title = title;
        break;
      }
    }
  }

  void _keyboardLayoutAddEvent(String event) async {
    final splitted = event.split(",");
    if (splitted.length != 2) {
      return;
    }
    // final keyboard = splitted[0];
    final layout = splitted[1];

    final keyboard = await callActiveKeyboard();
    if (keyboard == null) {
      keyboardLayouts.value = null;
      return;
    }

    isCapslockActive.value = keyboard.capsLock;
    isNumlockActive.value = keyboard.numLock;

    final idx = keyboard.layouts.indexOf(layout);
    if (idx == -1) {
      keyboardLayouts.value = null;
      return;
    }
    keyboardLayouts.value = CompositorKeyboardLayouts(keyboard.layouts, idx, keyboard);
  }

  void _activeWindowAddEvent(String event) {
    for (final w in windows.value) {
      if (w.id == event) {
        w.hasFocus = !w.hasFocus;
        break;
      }
    }
  }

  void _createWorkspaceAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length != 2) {
      return;
    }
    final id = int.tryParse(splitted[0]);
    if (id == null) {
      return;
    }
    final name = splitted[1];
    workspaces.value.workspaces.add(CompositorWorkspace(id.toString(), name, id, null));
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    workspaces.notifyListeners();
  }

  void _destroyWorkspaceAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length != 2) {
      return;
    }
    final id = int.tryParse(splitted[0]);
    if (id == null) {
      return;
    }
    workspaces.value.workspaces.removeWhere((e) => e.id == id.toString());
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    workspaces.notifyListeners();
  }

  void _monitorRemoved(String event) {
    final splitted = event.split(",");
    if (splitted.length != 3) {
      return;
    }
    final monitorId = splitted[0];
    // final monitorName = splitted[1];
    // final monitorDescription = splitted[2];
    monitors.value.removeWhere((m) => m.id == monitorId);
    monitors.manualNotifyListeners();
  }

  void _monitorAdded(String event) {
    final splitted = event.split(",");
    if (splitted.length != 3) {
      return;
    }
    final monitorId = splitted[0];
    final monitorName = splitted[1];
    // final monitorDescription = splitted[2];
    monitors.value.add(CompositorMonitor(monitorId, monitorName, []));
    monitors.manualNotifyListeners();
  }

  void _openWindow(String event) {
    final splitted = event.split(",");
    if (splitted.length != 4) {
      return;
    }
    final addr = splitted[0];
    // final wokspaceName = splitted[1];
    final wclass = splitted[2];
    final title = splitted[3];
    windows.value.add(
      CompositorWindows(
        id: addr,
        appId: wclass,
        title: title,
        pid: null,
        inner: null,
        hasFocus: false,
        isFloating: false,
        isUrgent: false,
      ),
    );
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    windows.notifyListeners();
  }

  void _closeWindow(String event) {
    final addr = event;
    windows.value.removeWhere((e) => e.id == addr);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    windows.notifyListeners();
  }

  late final _eventsHandlers = <String, void Function(String)>{
    "urgent": _urgentAddEvent,
    "windowtitlev2": _windowTitleChangeAddEvent,
    "activelayout": _keyboardLayoutAddEvent,
    "activewindowv2": _activeWindowAddEvent,
    "workspacev2": _workspaceChangeEvent,
    "createworkspacev2": _createWorkspaceAddEvent,
    "destroyworkspacev2": _destroyWorkspaceAddEvent,
    "monitorremovedv2": _monitorRemoved,
    "monitoraddedv2": _monitorAdded,
    "openwindow": _openWindow,
    "closewindow": _closeWindow,
  };

  bool _disposed = false;
  @override
  Future<void> dispose() async {
    _disposed = true;
    await Future.wait([
      _socket.close(),
    ]).onError((_, _) => []);
  }
}

enum ScreenShareState {
  close(0),
  open(1);

  final int value;
  const ScreenShareState(this.value);

  static ScreenShareState from(int value) {
    return ScreenShareState.values.firstWhere((e) => e.value == value);
  }
}

enum ScreenShareOwner {
  monitor(0),
  window(1);

  final int value;
  const ScreenShareOwner(this.value);

  static ScreenShareOwner from(int value) {
    return ScreenShareOwner.values.firstWhere((e) => e.value == value);
  }
}
