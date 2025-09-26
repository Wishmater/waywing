import "dart:collection";

import "package:flutter/foundation.dart";
import "package:waywing/modules/hyprland/hyprland_service.dart";
import "package:waywing/modules/hyprland/hyrpland_models.dart";
import "package:waywing/util/derived_value_notifier.dart";

abstract class IWorkspaceSwitcherProvider {
  ValueListenable<Workspace> get current;

  ValueListenable<Set<Workspace>> get workspaces;

  void changeWorkspace(Workspace workspace);
}

class Workspace implements Comparable<Workspace> {
  final int id;
  final String name;

  const Workspace({required this.id, required this.name});

  @override
  bool operator ==(covariant Workspace other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  int compareTo(Workspace other) {
    return id.compareTo(other.id);
  }
}

final class HyprlandWorkspaceSwitcherProvider extends IWorkspaceSwitcherProvider {
  final HyprlandService _service;

  HyprlandWorkspaceSwitcherProvider(this._service)
    : _current = ValueNotifier(Workspace(id: 0, name: "")),
      _workspaces = ManualValueNotifier<SplayTreeSet<Workspace>>(SplayTreeSet()) {
    _service.currentWorkspace.listen((active) {
      _current.value = from(active);
    });
    _service.activeworkspace().then((workspace) {
      if (workspace != null) {
        _current.value = from(workspace);
      }
    });

    _service.workspaces().then((workspaces) {
      _workspaces.value.clear();
      _workspaces.value.addAll(workspaces.where((w) => w.id > 0).map(from));
      _workspaces.manualNotifyListeners();
    });

    _service.createWorkspace.listen((workspace) {
      if (workspace.id > 0) {
        _workspaces.value.add(from(workspace));
      }
    });

    _service.destroyWorkspace.listen((workspace) {
      if (workspace.id > 0) {
        _workspaces.value.remove(from(workspace));
      }
    });
  }

  @override
  ValueListenable<Workspace> get current => _current;
  final ValueNotifier<Workspace> _current;

  @override
  ValueListenable<SplayTreeSet<Workspace>> get workspaces => _workspaces;
  final ManualValueNotifier<SplayTreeSet<Workspace>> _workspaces;

  static Workspace from(HyprlandWorkspaceRef workspace) {
    return Workspace(id: workspace.id, name: workspace.name);
  }

  @override
  void changeWorkspace(Workspace workspace) {
    _service.changeWorkspace(workspace.id);
  }
}
