import "dart:async";

import "package:dartx/dartx_io.dart";
import "package:flutter/foundation.dart";
import "package:niri/niri.dart";
import "package:waywing/services/compositors/layout_utils.dart";

import "../compositor.dart";

class NiriService extends CompositorService {
  late final NiriSocket commandSocket;
  late final NiriSocket eventSocket;
  final NiriEventStreamState state = NiriEventStreamState();

  @override
  Future<void> init() async {
    commandSocket = await NiriSocket.connect();
    eventSocket = await NiriSocket.connect();
    eventSocket.eventStream().listen(
      (event) {
        logger.debug("New event ${event.runtimeType}");
        state.apply(event);
      },
      onDone: () => logger.info("stop listening to event stream"),
      onError: (e, st) => logger.error("Error while listening to event stream", error: e, stackTrace: st),
    );

    state.keyboardLayouts.addListener(() {
      final kb = state.keyboardLayouts.keyboardLayouts;
      if (kb == null) {
        keyboardLayouts.value = null;
      } else {
        keyboardLayouts.value = CompositorKeyboardLayouts(
          kb.names.map((e) => LayoutUtils.findLayout(e) ?? e).toList(),
          kb.currentIdx,
          kb,
        );
      }
    });

    state.windows.addListener(() {
      windows.value = state.windows.windows
          .toList()
          .map((window) => window.second)
          .map(
            (window) => CompositorWindows(
              id: window.id.toString(),
              title: window.title,
              appId: window.appId,
              pid: window.pid,
              hasFocus: window.isFocused,
              isFloating: window.isFloating,
              isUrgent: window.isUrgent,
              inner: window,
            ),
          )
          .toList(growable: false);
    });

    state.workspaces.addListener(() async {
      final workspacesList = state.workspaces.workspaces
          .toList()
          .map((window) => window.second)
          .map(
            (workspace) => CompositorWorkspace(
              workspace.id.toString(),
              workspace.id.toString(),
              workspace.idx,
              workspace,
            ),
          )
          .toList(growable: false);

      final focused = <(CompositorMonitor, CompositorWorkspace)>[];

      for (final entry in state.workspaces.workspaces.entries) {
        final workspace = entry.value;
        if (workspace.isActive && workspace.output != null) {
          final monitor = CompositorMonitor(workspace.output!, workspace.output, null);
          final w = workspacesList.firstWhere((e) => (e.inner as Workspace).id == workspace.id);
          focused.add((monitor, w));
        }
      }

      workspaces.value = CompositorWorkspaceManager(workspacesList, focused);
    });
  }

  @override
  Future<void> dispose() async {
    eventSocket.close();
    commandSocket.close();
  }

  @override
  bool get supportKeyboardLayouts => true;

  @override
  final ValueNotifier<CompositorKeyboardLayouts?> keyboardLayouts = ValueNotifier(null);

  @override
  Future<void> switchLayout(int index) async {
    final request = Request.action(Action.switchLayout(LayoutSwitchTarget.index(index)));
    await commandSocket.send(request);
  }

  @override
  bool get supportWindows => true;

  @override
  final ValueNotifier<List<CompositorWindows>> windows = ValueNotifier([]);

  @override
  bool get supportWorkspaces => true;

  @override
  Future<void> switchWorkspace(CompositorWorkspace workspace) async {
    logger.debug("switchWorkspace to ${workspace.id}");
    final w = workspace.inner as Workspace;
    final request = Request.action(Action.focusWorkspace(WorkspaceReferenceArg.id(w.id)));
    await commandSocket.send(request);
  }

  @override
  ValueNotifier<CompositorWorkspaceManager> workspaces = ValueNotifier(CompositorWorkspaceManager([], []));

  @override
  bool get supportMonitors => false;

  @override
  ValueNotifier<List<CompositorMonitor>> get monitors => throw UnsupportedError("Monitors is not supported");

  @override
  bool get supportCapslock => false;

  @override
  ValueListenable<bool> get isCapslockActive => throw UnsupportedError("Capslock is not supported");

  @override
  bool get supportNumlock => false;

  @override
  ValueListenable<bool> get isNumlockActive => throw UnsupportedError("Numlock is not supported");
}
