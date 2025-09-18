import "dart:async";
import "dart:io";
import "package:path/path.dart" as path;

import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";

class HyprlandService extends Service {
  late final Socket _socket;

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

  HyprlandService._()
    : _currentWorkspace = StreamController.broadcast(),
      _urgent = StreamController.broadcast(),
      _currentLayout = StreamController.broadcast(),
      _activeWindow = StreamController.broadcast(),
      _screencast = StreamController.broadcast(),
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
  }

  void addEvents(String data) {
    final separatorIndex = data.indexOf(">>");
    if (separatorIndex == -1) {
      return;
    }
    _eventsHandlers[data.substring(0, separatorIndex)]?.call(data.substring(separatorIndex + 2));
  }

  final StreamController<({int id, String name})> _currentWorkspace;

  /// emitted on workspace change. Is emitted ONLY when a user requests a workspace change,
  /// and is not emitted on mouse movements (see focusedmon)
  Stream<({int id, String name})> get currentWorkspace => _currentWorkspace.stream;

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
    _currentWorkspace.add((id: id, name: name));
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

  final StreamController<({String keyboard, String layout})> _currentLayout;

  // emitted on a layout change of the active keyboard
  Stream<({String keyboard, String layout})> get currentLayout => _currentLayout.stream;

  void _layoutAddEvent(String event) {
    final splitted = event.split(",");
    if (splitted.length != 2) {
      return;
    }
    final keyboard = splitted[0];
    final layout = splitted[1];
    _currentLayout.add((keyboard: keyboard, layout: layout));
  }

  final StreamController<String> _activeWindow;

  /// emitted on the active window being changed.
  ///
  /// The value respresent the windows address
  Stream<String> get activeWindow => _activeWindow.stream;

  void _activeWindowAddEvent(String event) {
    _activeWindow.add(event);
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

  late final _eventsHandlers = <String, void Function(String)>{
    "workspacev2": _workspaceChangeAddEvent,
    "urgent": _urgentAddEvent,
    "windowtitlev2": _windowTitleChangeAddEvent,
    "activelayout": _layoutAddEvent,
    "activewindowv2": _activeWindowAddEvent,
    "screencast": _screencastAddEvent,
  };

  @override
  Future<void> dispose() async {
    await _socket.close();
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
