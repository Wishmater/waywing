import "dart:io";

import "package:flutter/foundation.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/services/compositors/niri/niri_service.dart";
import "package:waywing/services/compositors/hyprland/hyprland_service.dart";

abstract class CompositorService extends Service {
  CompositorService();

  factory CompositorService._() {
    final currentDesktop = Platform.environment["XDG_CURRENT_DESKTOP"];
    switch (currentDesktop) {
      case "niri":
        return NiriService();
      case "Hyprland":
        return HyprlandService();
      default:
        throw "Unknown XDG_CURRENT_DESKTOP enviroment value $currentDesktop";
    }
  }

  static registerService(RegisterServiceCallback registerService) {
    registerService<CompositorService, dynamic>(
      ServiceRegistration(
        constructor: CompositorService._,
      ),
    );
  }

  /// With this the compositor service promote him self as
  /// capable of managing keyboard layouts
  bool get supportKeyboardLayouts;

  /// Feathers and other services can use this to get the current keyboard layout
  /// and also react to changes
  ValueListenable<CompositorKeyboardLayouts?> get keyboardLayouts;

  /// Change the keyboard layout to the index. The index is the index in the layouts list
  Future<void> switchLayout(int index);

  /// Weather this compositor supports capslock notification or not
  bool get supportCapslock;

  ValueListenable<bool> get isCapslockActive;

  /// Weather this compositor supports numLock notification or not
  bool get supportNumlock;

  ValueListenable<bool> get isNumlockActive;

  //-----------------------------------------------------------------------------

  /// With this the compositor service promote him self as
  /// capable of managing workspaces
  bool get supportWorkspaces;

  /// List of all monitors.
  ValueListenable<CompositorWorkspaceManager> get workspaces;

  /// Change the current active workspace
  Future<void> switchWorkspace(CompositorWorkspace workspace);

  //-----------------------------------------------------------------------------

  /// With this the compositor service promote him self as
  /// capable of managing monitors
  bool get supportMonitors;

  /// List of all monitors.
  ValueListenable<List<CompositorMonitor>> get monitors;

  //-----------------------------------------------------------------------------

  /// With this the compositor service promote him self as
  /// capable of managing windows
  bool get supportWindows;

  ValueListenable<List<CompositorWindows>> get windows;
}

class CompositorKeyboardLayouts {
  /// Layouts names that can be display to the user
  List<String> layouts;

  /// Current layout index inside the layouts
  int index;

  /// Get the current layout
  String get current => layouts[index];

  /// Especific keyboard object that the compositor implementation handles
  ///
  /// This allows feathers to take advantage of compositors features
  /// that [CompositorKeyboardLayouts] does not expose and the implementations
  /// to access extended data when recieving Compositor objects
  Object? inner;

  CompositorKeyboardLayouts(this.layouts, this.index, this.inner);
}

class CompositorWindows {
  /// Windows identifier
  final String id;

  /// Window current title
  String? title;

  /// Application id (also class) that spawned the windows
  /// Tipically this is the desktop file name without the extension
  String? appId;

  /// Application process id that spawned the windows
  int? pid;

  /// If the application is in floating mode. For stacking window manager this is
  /// always true
  bool isFloating;

  /// If the windows wants the user attention.
  bool isUrgent;

  /// If the window has input focus
  bool hasFocus;

  /// Especific window object that the compositor implementation handles
  ///
  /// This allows feathers to take advantage of compositors features
  /// that [CompositorWindows] does not expose and the implementations
  /// to access extended data when recieving Compositor objects
  final Object? inner;

  CompositorWindows({
    required this.id,
    required this.title,
    required this.appId,
    required this.pid,
    required this.isFloating,
    required this.isUrgent,
    required this.hasFocus,
    required this.inner,
  });
}

class CompositorWorkspaceManager {
  /// List of all workspaces
  List<CompositorWorkspace> workspaces;
  List<(CompositorMonitor, CompositorWorkspace)> focused;

  CompositorWorkspaceManager(this.workspaces, this.focused);
}

class CompositorWorkspace {
  /// Workspace identifier
  final String id;

  /// Used to display the workspace identification to the user.
  /// Most of the time this is the id but in some cases can have
  /// an actual name.
  String name;

  /// This indicate the position in the monitor.
  /// User can use this to display the workspaces in order
  int position;

  /// Especific workspace object that the compositor implementation handles
  ///
  /// This allows feathers to take advantage of compositors features
  /// that [CompositorWorkspace] does not expose and the implementations
  /// to access extended data when recieving Compositor objects
  Object? inner;

  CompositorWorkspace(this.id, this.name, this.position, this.inner);
}

class CompositorMonitor {
  /// Monitor id
  final String id;

  /// Monitor name
  String? name;

  /// Especific monitor object that the compositor implementation handles
  ///
  /// This allows feathers to take advantage of compositors features
  /// that [CompositorMonitor] does not expose and the implementations
  /// to access extended data when recieving Compositor objects
  Object? inner;

  CompositorMonitor(this.id, this.name, this.inner);
}

class CompositorError {}

class InvalidCompositor extends CompositorError {}
