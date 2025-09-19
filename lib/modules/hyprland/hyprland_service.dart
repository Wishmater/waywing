import "dart:async";
import "dart:convert";
import "dart:io";
import "package:dartx/dartx.dart";
import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:path/path.dart" as path;
import "package:tronco/tronco.dart";

import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/hyprland/hyrpland_models.dart";
import "package:waywing/util/derived_value_notifier.dart";

class HyprlandService extends Service {
  late final Socket _socket;
  late final HyprlandValues values;

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
    socket.write(cmd);
    logger.debug("send command to hyprland: $cmd");
    final response = await completer.future;
    socket.close();
    return response;
  }

  Future<List<HyprlandWorkspace>> workspaces() async {
    final data = await sendCommand("workspaces", flags: ["-j"]);
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((e) => HyprlandWorkspace.fromJson(e as Map<String, Object?>)).toList();
  }

  Future<HyprlandWorkspace?> activeworkspace() async {
    final data = await sendCommand("activeworkspace", flags: ["-j"]);
    final Map<String, Object?> decoded = json.decode(data);
    if (decoded.isEmpty) return null;
    return HyprlandWorkspace.fromJson(decoded);
  }

  Future<List<HyprlandWindow>> windows() async {
    final data = await sendCommand("windows", flags: ["-j"]);
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((e) => HyprlandWindow.fromJson(e as Map<String, Object?>)).toList();
  }

  Future<HyprlandWindow?> activewindow() async {
    final data = await sendCommand("activewindow", flags: ["-j"]);
    final Map<String, Object?> decoded = json.decode(data);
    if (decoded.isEmpty) return null;
    return HyprlandWindow.fromJson(decoded);
  }

  Future<List<HyprlandKeyboardDevice>> keyboards() async {
    final data = await sendCommand("devices", flags: ["-j"]);
    final Map<String, Object?> decoded = json.decode(data);
    final List<dynamic>? keyboards = decoded["keyboards"] as List<dynamic>?;
    if (keyboards == null) return [];
    return keyboards.map((e) => HyprlandKeyboardDevice.fromJson(e as Map<String, Object?>)).toList();
  }

  Future<HyprlandKeyboardDevice?> activeKeyboard() async {
    final list = await keyboards();
    if (list.isEmpty) return null;
    return list.firstOrNullWhere((keyboard) => keyboard.main == true);
  }

  HyprlandService._()
    : _currentWorkspace = StreamController.broadcast(),
      _urgent = StreamController.broadcast(),
      _currentKeyboardLayout = StreamController.broadcast(),
      _activeWindow = StreamController.broadcast(),
      _screencast = StreamController.broadcast(),
      _createWorkspace = StreamController.broadcast(),
      _destroyWorkspace = StreamController.broadcast(),
      _specialWorkspaceChange = StreamController.broadcast(),
      _configReloaded = StreamController.broadcast(),
      _windowTitleChange = StreamController.broadcast();

  static registerService(RegisterServiceCallback registerService) {
    registerService<HyprlandService, dynamic>(
      ServiceRegistration(
        constructor: HyprlandService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    _socket = await Socket.connect(InternetAddress(eventsSocketPath, type: InternetAddressType.unix), 0);
    _socket.listen((data) => addEvents(String.fromCharCodes(data)));
    values = HyprlandValues(this, logger);
  }

  void addEvents(String data) {
    final lines = data.split("\n");
    for (final line in lines) {
      final separatorIndex = line.indexOf(">>");
      if (separatorIndex == -1) {
        continue;
      }
      _eventsHandlers[line.substring(0, separatorIndex)]?.call(line.substring(separatorIndex + 2));
    }
  }

  final StreamController<HyprlandWorkspaceRef> _currentWorkspace;

  /// emitted on workspace change. Is emitted ONLY when a user requests a workspace change,
  /// and is not emitted on mouse movements (see focusedmon)
  Stream<HyprlandWorkspaceRef> get currentWorkspace => _currentWorkspace.stream;

  void _workspaceChangeAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length < 2) {
      return;
    }
    final id = int.tryParse(splitted[0]);
    if (id == null) {
      return;
    }
    final name = splitted.sublist(1).join(",");
    _currentWorkspace.add(HyprlandWorkspaceRef(id: id, name: name));
  }

  final StreamController<String> _urgent;

  /// emitted when a window requests an urgent state
  ///
  /// the value is WINDOWADDRESS
  Stream<String> get urgent => _urgent.stream;

  void _urgentAddEvent(String event) {
    _urgent.add(event);
  }

  final StreamController<({String addr, String title})> _windowTitleChange;

  /// emitted when a window title changes.
  Stream<({String addr, String title})> get windowTitleChange => _windowTitleChange.stream;

  void _windowTitleChangeAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length < 2) {
      return;
    }
    final addr = splitted[0];
    final title = splitted.sublist(1).join(",");
    _windowTitleChange.add((addr: addr, title: title));
  }

  final StreamController<HyprlandKeyboardDeviceRef> _currentKeyboardLayout;

  // emitted on a layout change of the active keyboard
  Stream<HyprlandKeyboardDeviceRef> get currentKeyboardLayout => _currentKeyboardLayout.stream;

  void _keyboardLayoutAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length != 2) {
      return;
    }
    final keyboard = splitted[0];
    final layout = splitted[1];
    _currentKeyboardLayout.add(HyprlandKeyboardDeviceRef(name: keyboard, activeKeymap: layout));
  }

  final StreamController<HyprlandWindowRef> _activeWindow;

  /// emitted on the active window being changed.
  ///
  /// The value respresent the windows address
  Stream<HyprlandWindowRef> get activeWindow => _activeWindow.stream;

  void _activeWindowAddEvent(String event) {
    _activeWindow.add(HyprlandWindowRef(address: event));
  }

  final StreamController<({ScreenShareState state, ScreenShareOwner owner})> _screencast;

  /// emitted when a screencopy state of a client changes. Keep in mind there might be multiple
  /// separate clients.
  Stream<({ScreenShareState state, ScreenShareOwner owner})> get screencast => _screencast.stream;

  void _screencastAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length != 2) {
      return;
    }
    final state = int.tryParse(splitted[0]);
    final owner = int.tryParse(splitted[1]);
    if (state == null || owner == null) {
      return;
    }
    _screencast.add((state: ScreenShareState.from(state), owner: ScreenShareOwner.from(owner)));
  }

  final StreamController<HyprlandWorkspaceRef> _createWorkspace;

  /// emitted when a workspace is created
  Stream<HyprlandWorkspaceRef> get createWorkspace => _createWorkspace.stream;

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

    _createWorkspace.add(HyprlandWorkspaceRef(id: id, name: name));
  }

  final StreamController<HyprlandWorkspaceRef> _destroyWorkspace;

  /// emitted when a workspace is destroyed
  Stream<HyprlandWorkspaceRef> get destroyWorkspace => _destroyWorkspace.stream;

  void _destroyWorkspaceAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length != 2) {
      return;
    }
    final id = int.tryParse(splitted[0]);
    if (id == null) {
      return;
    }
    final name = splitted[1];

    _destroyWorkspace.add(HyprlandWorkspaceRef(id: id, name: name));
  }

  final StreamController<({int? id, String? name, String monitor})> _specialWorkspaceChange;

  /// emitted when the special workspace opened in a monitor changes
  ///
  /// closing results in null id and name values
  Stream<({int? id, String? name, String monitor})> get specialWorkspaceChange => _specialWorkspaceChange.stream;

  void _specialWorkspaceChangeAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length != 3) {
      return;
    }
    int? workspaceId = int.tryParse(splitted[0]);
    String? name = splitted[1];
    if (name == "") {
      name = null;
    }
    String monitor = splitted[2];
    _specialWorkspaceChange.add((id: workspaceId, name: name, monitor: monitor));
  }

  final StreamController<()> _configReloaded;

  /// emitted when the config is done reloading
  Stream<()> get configReload => _configReloaded.stream;

  void _configReloadedAddEvent(String _) {
    _configReloaded.add(());
  }

  late final _eventsHandlers = <String, void Function(String)>{
    "workspacev2": _workspaceChangeAddEvent,
    "urgent": _urgentAddEvent,
    "windowtitlev2": _windowTitleChangeAddEvent,
    "activelayout": _keyboardLayoutAddEvent,
    "activewindowv2": _activeWindowAddEvent,
    "screencast": _screencastAddEvent,
    "createworkspacev2": _createWorkspaceAddEvent,
    "destroyworkspacev2": _destroyWorkspaceAddEvent,
    "activespecialv2": _specialWorkspaceChangeAddEvent,
    "configreloaded": _configReloadedAddEvent,
  };

  @override
  Future<void> dispose() async {
    await Future.wait([
      _socket.close(),
      _createWorkspace.close(),
      _destroyWorkspace.close(),
      _currentWorkspace.close(),
      _urgent.close(),
      _windowTitleChange.close(),
      _activeWindow.close(),
      _currentKeyboardLayout.close(),
      _screencast.close(),
      _specialWorkspaceChange.close(),
      _configReloaded.close(),
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

class HyprlandValues {
  // final ValueListenable activeSpecialWorkspace;
  final ValueNotifier<HyprlandWorkspaceRef> currentWorkspace;
  final ValueNotifier<HyprlandKeyboardDeviceRef> currentKeyboardLayout;
  final ValueNotifier<HyprlandWindowRef> currentWindow;
  final ManualValueNotifier<Set<HyprlandWorkspaceRef>> workspaceList;

  HyprlandValues(HyprlandService service, Logger logger)
    : workspaceList = ManualValueNotifier({}),
      currentWindow = ValueNotifier(HyprlandWindowRef(address: "")),
      currentKeyboardLayout = ValueNotifier(HyprlandKeyboardDeviceRef(name: "", activeKeymap: "")),
      currentWorkspace = ValueNotifier(HyprlandWorkspaceRef(id: 0, name: "")) {
    service.currentWorkspace.listen((v) => currentWorkspace.value = v);
    service.activeworkspace().then((v) => currentWorkspace.value = v ?? currentWorkspace.value);

    service.currentKeyboardLayout.listen((v) => currentKeyboardLayout.value = v);
    service.activeKeyboard().then((v) => currentKeyboardLayout.value = v ?? currentKeyboardLayout.value);

    service.activeWindow.listen((v) => currentWindow.value = v);
    service.activewindow().then((v) => currentWindow.value = v ?? currentWindow.value);

    service.createWorkspace.listen((v) {
      if (workspaceList.value.add(v)) {
        workspaceList.manualNotifyListeners();
      }
    });
    service.destroyWorkspace.listen((v) {
      if (workspaceList.value.remove(v)) {
        workspaceList.manualNotifyListeners();
      }
    });
    service.workspaces().then((v) {
      workspaceList.value.clear();
      for (final workspace in v) {
        workspaceList.value.add(workspace);
      }
      workspaceList.manualNotifyListeners();
    });
  }
}
