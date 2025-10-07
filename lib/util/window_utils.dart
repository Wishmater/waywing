import "dart:async";

import "package:fl_linux_window_manager/controller/input_region_controller.dart";
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
  _logger.log(Level.trace, "Setting main window title...");
  // we need to set monitor here as well, otherwise it flashes on the wrong monitor on startup
  await Future.wait([
    FlLinuxWindowManager.instance.setMonitor(mainConfig.monitor),
    FlLinuxWindowManager.instance.setLayerExclusiveZone(-1),
    FlLinuxWindowManager.instance.setTitle(title: "WayWings"),
  ]);
  await Future.delayed(_delayDuration);

  // // this doesn't seem to be necessary
  // logger.log(Level.trace, "Setting main window transparency enabled...");
  // await FlLinuxWindowManager.instance.enableTransparency();
  // await Future.delayed(_delayDuration);

  _logger.log(Level.trace, "Setting main window layer...");
  await FlLinuxWindowManager.instance.setLayer(WindowLayer.top);
  await FlLinuxWindowManager.instance.setKeyboardInteractivity(KeyboardMode.none);
  await Future.delayed(_delayDuration);

  _logger.log(Level.trace, "Setting main window anchors...");
  await FlLinuxWindowManager.instance.setLayerAnchor(
    anchor: ScreenEdge.values.map((e) => e.value).reduce((a, b) => a | b), // all anchors
  );
  await Future.delayed(_delayDuration);

  // Delay creating edge windows, because they depend on wings being initialized.
  // updateWindows() will be called again by ConfigWatcher widget when it is initialized.
  return updateWindows(onlyMainWindow: true);
}

Future<void>? _running; // rudimentary safety mechanism to make sure updates don't run at the same time
Future<void>? _waiting; // if another update is already waiting, this one is just not necessary
Future<void> updateWindows({
  bool onlyMainWindow =
      false, // the system for skipping some calls doesn't take into account params, this could be an issue.......
}) async {
  final id = DateTime.now().microsecondsSinceEpoch;
  _logger.debug("call updateWindows(onlyMainWindow: $onlyMainWindow) $id");
  final completer = Completer();
  if (_running != null) {
    if (_waiting != null) {
      return _waiting;
    }
    _waiting = completer.future;
    await _running;
    _waiting = null;
  }
  _running = completer.future;

  _logger.debug("execute updateWindows(onlyMainWindow: $onlyMainWindow) $id");
  await Future.wait([
    if (!onlyMainWindow) _updateEdgeWindows(),
    _updateMainWindow(),
  ]);

  completer.complete();
  _running = null;
  InputRegionController.notifyConfigChange();
}

Future<void> _updateMainWindow() async {
  // TODO: 3 allow setting monitor by name, would need to get more data from
  // hyprctl or wlr_randr, because gtk only returns model
  _logger.log(Level.trace, "Setting main window monitor...");
  _logger.log(Level.trace, "Setting main window exclusive zone...");
  // final monitors = await FlLinuxWindowManager.instance.listMonitors();
  // monitors.first.connector;
  // TODO: 2 this sets monitor by INDEX, instead of ID. Index and id is usually the same,
  // but at least in hyprland, if you remove and re-connect the ID-0 monitor, it will now
  // be the last index, but still ID-0.
  await Future.wait([
    FlLinuxWindowManager.instance.setMonitor(mainConfig.monitor),
    FlLinuxWindowManager.instance.setLayerExclusiveZone(-1),
  ]);

  // this needs to be re-applied every time main window changes monitors
  // setting -1 exclusiveSize makes this layer ignore exclusiveZones set by other layers
  await Future.delayed(_delayDuration);
}

Future<void> _updateEdgeWindows() async {
  final futures = <Future>[];
  for (final side in ScreenEdge.values) {
    futures.add(_updateEdgeWindow(side, mainConfig));
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
      _logger.log(Level.trace, "Closing window layer for side $side...");
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
    _logger.log(Level.trace, "Creating window layer for side $side...");
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

    _logger.log(Level.trace, "Setting window layer for side $side...");
    await FlLinuxWindowManager.instance.setLayer(
      WindowLayer.background,
      windowId: windowId,
    );
    await Future.delayed(_delayDuration);
  }

  _logger.log(Level.trace, "Setting window layer monitor for side $side...");
  await FlLinuxWindowManager.instance.setMonitor(
    config.monitor,
    windowId: windowId,
  );
  await Future.delayed(_delayDuration);

  _logger.log(Level.trace, "Setting window layer exclusive zone = $exclusiveSize for side $side...");
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(
    exclusiveSize,
    windowId: windowId,
  );
  await Future.delayed(_delayDuration);

  if (create) {
    _logger.log(Level.trace, "Setting window layer anchors for side $side...");
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
