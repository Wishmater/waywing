import "package:flutter/services.dart";

class HyprlandWorkspaceRef {
  /// Workspace id
  final int id;

  /// Workspace name
  final String name;

  const HyprlandWorkspaceRef({required this.id, required this.name});

  @override
  bool operator==(covariant HyprlandWorkspaceRef other)  {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class HyprlandWorkspace extends HyprlandWorkspaceRef {
  /// Monitor name ej: `eDP-1`
  final String monitorName;

  /// Monitor id
  final int monitorId;

  /// Amount of windows in the workspace
  final int windows;

  /// Address of the last windows (seen/focused?) in this workspaces
  final String lastWindowsAddr;

  /// If the workspace has a fullscreen window
  final bool hasFullscreen;

  const HyprlandWorkspace({
    required super.id,
    required super.name,
    required this.monitorId,
    required this.monitorName,
    required this.windows,
    required this.lastWindowsAddr,
    required this.hasFullscreen,
  });

  factory HyprlandWorkspace.fromJson(Map<String, Object?> json) {
    return HyprlandWorkspace(
      id: json["id"] as int,
      name: json["name"] as String,
      monitorName: json["monitor"] as String,
      monitorId: json["monitorID"] as int,
      windows:json["windows"] as int,
      lastWindowsAddr: json["lastwindow"] as String,
      hasFullscreen: json["hasfullscreen"] as bool,
    );
  }
}

class HyprlandWindowRef {
  final String address;

  const HyprlandWindowRef({required this.address});

  @override
  bool operator==(covariant HyprlandWindowRef other)  {
    return address == other.address;
  }

  @override
  int get hashCode => address.hashCode;
}

class HyprlandWindow extends HyprlandWindowRef {
  final Size size;
  final bool floating;
  final String className;
  final String title;
  final String initialClassName;
  final String initialTitle;
  final int pid;
  final bool xwayland;

  const HyprlandWindow({
    required super.address,
    required this.size,
    required this.floating,
    required this.className,
    required this.title,
    required this.initialClassName,
    required this.initialTitle,
    required this.pid,
    required this.xwayland,
  });

  factory HyprlandWindow.fromJson(Map<String, Object?> json) {
    final size = json["address"] as List<int>;
    return HyprlandWindow(
      address: json["address"] as String,
      size: Size(size[0].toDouble(), size[1].toDouble()),
      floating: json["floating"] as bool,
      className: json["class"] as String,
      initialClassName: json["initialClass"] as String,
      title: json["title"] as String,
      initialTitle: json["initialTitle"] as String,
      pid: json["pid"] as int,
      xwayland: json["xwayland"] as bool,
    );
  }
  /// TODO create equality
}

class HyprlandKeyboardDeviceRef {
  final String name;
  /// The current active keymap.. related to layout but not quite the same
  ///
  /// ej: English (US)
  final String activeKeymap;

  const HyprlandKeyboardDeviceRef({required this.name, required this.activeKeymap});
}

class HyprlandKeyboardDevice extends HyprlandKeyboardDeviceRef {
  final String address;
  /// Layout list
  ///
  /// ej: ["us", "es"]
  final List<String> layouts;
  final String rules;
  final String model;
  final String variant;

  /// True if capsLock is activated
  final bool capsLock;

  /// True if numLock is activated
  final bool numLock;

  /// True if this is the current active keyboard
  final bool main;

  const HyprlandKeyboardDevice({
    required super.activeKeymap,
    required super.name,
    required this.address,
    required this.capsLock,
    required this.layouts,
    required this.main,
    required this.model,
    required this.numLock,
    required this.rules,
    required this.variant,
  });

  factory HyprlandKeyboardDevice.fromJson(Map<String, Object?> json) {
    return HyprlandKeyboardDevice(
      address: json["address"] as String,
      name: json["name"] as String,
      rules: json["rules"] as String,
      model: json["model"] as String,
      layouts: (json["layout"] as String).split(","),
      variant: json["variant"] as String,
      capsLock: json["capsLock"] as bool,
      numLock: json["numLock"] as bool,
      main: json["main"] as bool,
      activeKeymap: json["active_keymap"] as String,
    );
  }
}
