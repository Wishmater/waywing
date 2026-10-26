// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import "package:filo_windowing/filo_windowing.dart";
import "package:flutter/src/widgets/_window.dart";
import "package:flutter/widgets.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/screen_edge.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/widgets/input_region.dart";

final _logger = mainLogger.clone(properties: [LogType("WaywingWindows")]);

/// The window manager for this isolate. Assigned during startup, before the
/// root widget is built.
late final WaywingWindowManager windowManager;

/// Owns the layer windows that make up the shell.
///
/// The main window renders the wings. One additional layer surface per screen
/// edge reserves space for that side's exclusive size.
class WaywingWindowManager extends ChangeNotifier {
  WaywingWindowManager(this.owner);

  final FiloWindowingOwner owner;

  late FiloLayerWindowController main;
  final Map<ScreenEdge, FiloLayerWindowController> _edges = {};

  bool _initialized = false;
  bool _updateScheduled = false;

  int _requestedOutput = -1;
  int _surfaceOutput = -1;

  bool get isInitialized => _initialized;

  Iterable<FiloLayerWindowController> get edgeControllers => _edges.values;

  /// Creates the main layer window. Must be called once, after the windowing
  /// owner is installed and the config is loaded.
  void initialize() {
    if (_initialized) return;
    _initialized = true;
    _requestedOutput = mainConfig.monitor;

    final (:controller, :output) = _createMainWithFallback(_requestedOutput);
    main = controller;
    _surfaceOutput = output;
  }

  /// Applies the current config to the layer windows.
  ///
  /// Layer surfaces cannot change output after creation, so a monitor change
  /// recreates all of them.
  void update() {
    if (!_initialized) return;

    if (mainConfig.monitor != _requestedOutput) {
      _recreateAll(mainConfig.monitor);
      return;
    }

    for (final side in ScreenEdge.values) {
      final exclusiveSize = _exclusiveSize(side);
      final existing = _edges[side];

      if (exclusiveSize > 0 && existing == null) {
        _logger.trace("Creating edge layer for $side with exclusive size $exclusiveSize");
        final controller = _tryCreateEdge(side, _surfaceOutput, exclusiveSize);
        if (controller != null) {
          _edges[side] = controller;
          notifyListeners();
        }
      } else if (exclusiveSize <= 0 && existing != null) {
        _logger.trace("Removing edge layer for $side");
        _removeEdge(side, existing);
      } else if (exclusiveSize > 0 && existing != null) {
        existing.setExclusiveZone(exclusiveSize);
      }
    }

    // Wings may have moved or changed size after the exclusive zones changed.
    InputRegionController.notifyConfigChange(main.viewId);
  }

  /// Schedules [update] for after the current frame.
  ///
  /// Calls can come from build/initState while wings update their exclusive
  /// sizes. Creating or destroying windows there is unsafe.
  void scheduleUpdate() {
    if (!_initialized || _updateScheduled) return;
    _updateScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      update();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Builds the views for the main window and every active edge spacer.
  List<Widget> buildViews(Widget mainContent) {
    assert(_initialized);
    return [
      FiloLayerWindow(
        key: ValueKey(main.viewId),
        controller: main,
        child: mainContent,
      ),
      for (final controller in _edges.values)
        FiloLayerWindow(
          key: ValueKey(controller.viewId),
          controller: controller,
          child: const ColoredBox(
            // Paint at least one frame so the layer surface is mapped and its
            // exclusive zone is applied. The surface is only one pixel thick.
            color: Color(0x00000000),
            child: SizedBox.expand(),
          ),
        ),
    ];
  }

  void _recreateAll(int requestedOutput) {
    _logger.debug("Recreating layer windows for monitor $requestedOutput");

    final (:controller, :output) = _createMainWithFallback(requestedOutput);
    final oldControllers = [main, ..._edges.values];

    main = controller;
    _edges.clear();
    _requestedOutput = requestedOutput;
    _surfaceOutput = output;

    for (final side in ScreenEdge.values) {
      final exclusiveSize = _exclusiveSize(side);
      if (exclusiveSize > 0) {
        final controller = _tryCreateEdge(side, _surfaceOutput, exclusiveSize);
        if (controller != null) _edges[side] = controller;
      }
    }

    notifyListeners();

    // Remove the old views from the tree before their native windows go away.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in oldControllers) {
        controller.destroy();
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  void _removeEdge(ScreenEdge side, FiloLayerWindowController controller) {
    _edges.remove(side);
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.destroy();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  ({FiloLayerWindowController controller, int output}) _createMainWithFallback(int requestedOutput) {
    try {
      return (controller: _createMain(requestedOutput), output: requestedOutput);
    } on FiloWindowingException catch (error, stackTrace) {
      if (requestedOutput == -1) rethrow;
      _logger.error(
        "Failed to create the main layer on output $requestedOutput, falling back to the compositor default",
        error: error,
        stackTrace: stackTrace,
      );
      return (controller: _createMain(-1), output: -1);
    }
  }

  FiloLayerWindowController? _tryCreateEdge(ScreenEdge side, int output, int exclusiveSize) {
    try {
      return _createEdge(side, output, exclusiveSize);
    } on FiloWindowingException catch (error, stackTrace) {
      _logger.error(
        "Failed to create the edge layer for $side on output $output",
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  FiloLayerWindowController _createMain(int output) {
    return owner.createLayerWindowController(
      delegate: _LayerWindowDelegate(),
      layerSurface: FiloLayerSurface(
        layer: FiloLayer.top,
        anchors: FiloLayerAnchors.all,
        exclusiveZone: -1,
        keyboardInteractivity: mainConfig.requestKeyboardFocus
            ? FiloLayerKeyboardInteractivity.onDemand
            : FiloLayerKeyboardInteractivity.none,
        namespace: "waywing-main",
        acceptsInput: false,
        output: output,
      ),
      // Both axes are anchored to opposite edges, so the compositor owns them.
      size: Size.zero,
      sizedToContent: true,
      reuseImplicitView: false,
    );
  }

  FiloLayerWindowController _createEdge(ScreenEdge side, int output, int exclusiveSize) {
    late final FiloLayerWindowController controller;
    controller = owner.createLayerWindowController(
      delegate: _LayerWindowDelegate(() {
        if (identical(_edges[side], controller)) {
          _edges.remove(side);
          notifyListeners();
        }
      }),
      layerSurface: FiloLayerSurface(
        layer: FiloLayer.background,
        anchors: side.layerAnchors,
        exclusiveZone: exclusiveSize,
        keyboardInteractivity: FiloLayerKeyboardInteractivity.none,
        namespace: "waywing-edge-${side.name}-z",
        acceptsInput: false,
        output: output,
      ),
      size: _edgeSize(side),
      sizedToContent: false,
      reuseImplicitView: false,
    );
    return controller;
  }

  int _exclusiveSize(ScreenEdge side) {
    return mainConfig.getExclusiveSizeForSide(side)?.round() ?? 0;
  }

  @override
  void dispose() {
    if (_initialized) {
      final controllers = [main, ..._edges.values];
      _edges.clear();
      _initialized = false;
      for (final controller in controllers) {
        controller.destroy();
      }
    }
    super.dispose();
  }
}

Size _edgeSize(ScreenEdge side) {
  return switch (side) {
    // The compositor owns the stretched axis; keep the other one at one pixel.
    ScreenEdge.top || ScreenEdge.bottom => const Size(0, 1),
    ScreenEdge.left || ScreenEdge.right => const Size(1, 0),
  };
}

class _LayerWindowDelegate with RegularWindowControllerDelegate {
  _LayerWindowDelegate([this.onDestroyed]);

  final VoidCallback? onDestroyed;

  @override
  void onWindowDestroyed() => onDestroyed?.call();
}

/// Applies the current config to the shell windows.
void updateWindows() {
  windowManager.scheduleUpdate();
}
