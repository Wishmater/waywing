import "dart:async";

import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:fl_linux_window_manager/models/keyboard_mode.dart";
import "package:fl_linux_window_manager/models/layer.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/logger.dart";

final _logger = mainLogger.clone(properties: [LogType("FlLinuxWindowManager")]);

// we need to await an arbitrary time in between windowManager calls
// to avoid race conditions, because Futures returned by the lib cant' be trusted
const _delayDuration = Duration(milliseconds: 100);

Future<void> setupMainWindow() async {
  _logger.log(Level.debug, "Setting main window title...");
  // we need to set monitor here as well, otherwise it flashes on the wrong monitor on startup
  await Future.wait([
    FlLinuxWindowManager.instance.setMonitor(config.barMonitor),
    FlLinuxWindowManager.instance.setLayerExclusiveZone(-1),
    FlLinuxWindowManager.instance.setTitle(title: "WayWings"),
  ]);
  await Future.delayed(_delayDuration);

  // // this doesn't seem to be necessary
  // logger.log(Level.debug, "Setting main window transparency enabled...");
  // await FlLinuxWindowManager.instance.enableTransparency();
  // await Future.delayed(_delayDuration);

  _logger.log(Level.debug, "Setting main window layer...");
  await FlLinuxWindowManager.instance.setLayer(WindowLayer.top);
  await FlLinuxWindowManager.instance.setKeyboardInteractivity(KeyboardMode.none);
  await Future.delayed(_delayDuration);

  _logger.log(Level.debug, "Setting main window anchors...");
  await FlLinuxWindowManager.instance.setLayerAnchor(
    anchor: ScreenEdge.values.map((e) => e.value).reduce((a, b) => a | b), // all anchors
  );
  await Future.delayed(_delayDuration);

  return updateWindows();
}

Future<void>? _runningEdgeWindowsUpdate; // rudimentary safety mechanism to make sure updates don't run at the same time
Future<void>? _waitingEdgeWindowsUpdate; // if another update is already waiting, this one is just not necessary
Future<void> updateWindows() async {
  final completer = Completer();
  if (_runningEdgeWindowsUpdate != null) {
    if (_waitingEdgeWindowsUpdate != null) {
      return _waitingEdgeWindowsUpdate;
    }
    _waitingEdgeWindowsUpdate = completer.future;
    await _runningEdgeWindowsUpdate;
    _waitingEdgeWindowsUpdate = null;
  }
  _runningEdgeWindowsUpdate = completer.future;

  Future.wait([
    _updateEdgeWindows(),
    _updateMainWindow(),
  ]);

  completer.complete();
  _runningEdgeWindowsUpdate = null;
}

Future<void> _updateMainWindow() async {
  // TODO: 3 allow setting monitor by name, would need to get more data from
  // hyprctl or wlr_randr, because gtk only returns model
  _logger.log(Level.debug, "Setting main window monitor...");
  _logger.log(Level.debug, "Setting main window exclusive zone...");
  // final monitors = await FlLinuxWindowManager.instance.listMonitors();
  // monitors.first.connector;
  await Future.wait([
    FlLinuxWindowManager.instance.setMonitor(config.barMonitor),
    FlLinuxWindowManager.instance.setLayerExclusiveZone(-1),
  ]);

  // this needs to be re-applied every time main window changes monitors
  // setting -1 exclusiveSize makes this layer ignore exclusiveZones set by other layers
  await Future.delayed(_delayDuration);
}

Future<void> _updateEdgeWindows() async {
  final futures = <Future>[];
  for (final side in ScreenEdge.values) {
    futures.add(_updateEdgeWindow(side, config));
  }
  await Future.wait(futures);
}

Set<ScreenEdge> _existingDummyLayers = {};

Future<void> _updateEdgeWindow(ScreenEdge side, MainConfig config) async {
  final exclusiveSize = config.getExclusiveSizeForSide(side)?.round() ?? 0;
  final windowId = "WayWings$side";

  // // removing a window crashes the app for some reason, so just init all at the start
  if (exclusiveSize == 0) {
    if (_existingDummyLayers.contains(side)) {
      _logger.log(Level.debug, "Closing window layer for side $side...");
      _existingDummyLayers.remove(side);
      await FlLinuxWindowManager.instance.closeWindow(
        windowId: windowId,
      );
      await Future.delayed(_delayDuration);
    }
    return;
  }

  bool create = !_existingDummyLayers.contains(side);
  if (create) {
    _logger.log(Level.debug, "Creating window layer for side $side...");
    _existingDummyLayers.add(side);
    await FlLinuxWindowManager.instance.createWindow(
      windowId: windowId,
      isLayer: true,
      initializeFlutter: false,
      args: ["--dummy-layer"],
      title: windowId,
      width: 0,
      height: 0,
    );
    await Future.delayed(_delayDuration);

    _logger.log(Level.debug, "Setting window layer for side $side...");
    await FlLinuxWindowManager.instance.setLayer(
      WindowLayer.background,
      windowId: windowId,
    );
    await Future.delayed(_delayDuration);
  }

  _logger.log(Level.debug, "Setting window layer monitor for side $side...");
  await FlLinuxWindowManager.instance.setMonitor(
    config.barMonitor,
    windowId: windowId,
  );
  await Future.delayed(_delayDuration);

  _logger.log(Level.debug, "Setting window layer exclusive zone = $exclusiveSize for side $side...");
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(
    exclusiveSize,
    windowId: windowId,
  );
  await Future.delayed(_delayDuration);

  if (create) {
    _logger.log(Level.debug, "Setting window layer anchors for side $side...");
    await FlLinuxWindowManager.instance.setLayerAnchor(
      windowId: windowId,
      anchor: switch (side) {
        ScreenEdge.top => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.top.value,
        ScreenEdge.bottom => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.bottom.value,
        ScreenEdge.left => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.left.value,
        ScreenEdge.right => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.right.value,
      },
    );
    await Future.delayed(_delayDuration);
  }
}
