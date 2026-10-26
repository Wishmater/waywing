import "package:flutter/widgets.dart";
import "package:flutter/scheduler.dart";
import "package:waywing/util/bindings.dart";

class InputRegion extends StatefulWidget {
  final Widget child;
  final int viewId;
  final bool active;
  final bool isNegative;

  const InputRegion({
    required this.child,
    required this.viewId,
    this.active = true,
    this.isNegative = false,
    super.key,
  });
  const InputRegion.negative({
    required this.child,
    required this.viewId,
    this.active = true,
    super.key,
  }) : isNegative = true;

  @override
  State<InputRegion> createState() => _InputRegionState();
}

class _InputRegionState extends State<InputRegion> {
  // TODO: 1 don't use a global key, instead pass a callback into the controller that can get size from context
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Add the input region GlobalKey to the controller
    if (widget.active) {
      InputRegionController.addKey(
        _key,
        widget.viewId,
        isNegative: widget.isNegative,
      );
      scheduleCheckForPositionOrSizeChanges();
    }
  }

  @override
  void didUpdateWidget(covariant InputRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewId != oldWidget.viewId) {
      // The widget now renders into a different native window.
      if (oldWidget.active) {
        InputRegionController.removeKey(_key, oldWidget.viewId);
      }
      if (widget.active) {
        InputRegionController.addKey(
          _key,
          widget.viewId,
          isNegative: widget.isNegative,
        );
        scheduleCheckForPositionOrSizeChanges();
      }
      return;
    }
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        InputRegionController.addKey(
          _key,
          widget.viewId,
          isNegative: widget.isNegative,
        );
      } else {
        InputRegionController.removeKey(_key, widget.viewId);
      }
    } else if (widget.active) {
      if (oldWidget.isNegative != widget.isNegative) {
        // Update the key in the controller with the new isNegative value
        InputRegionController.addKey(
          _key,
          widget.viewId,
          isNegative: widget.isNegative,
        );
      }
    }
  }

  @override
  void dispose() {
    /// Remove the input region key from the controller.
    InputRegionController.removeKey(_key, widget.viewId);
    super.dispose();
  }

  void scheduleCheckForPositionOrSizeChanges() {
    WidgetsBinding.instance.addPostFrameCallback(checkForPositionOrSizeChanges);
  }

  Size? previousSize;
  Offset? previousPosition;
  void checkForPositionOrSizeChanges(_) {
    if (!mounted) return;
    try {
      RenderBox box = context.findRenderObject()! as RenderBox;
      final size = box.size;
      final position = box.localToGlobal(Offset.zero);
      if (previousSize != null && previousPosition != null) {
        if (previousSize != size || previousPosition != position) {
          /// Update the input region when the size changes
          InputRegionController.notifyRegionChange(_key, widget.viewId);
        }
      }
      previousSize = size;
      previousPosition = position;
    } catch (_) {}
    scheduleCheckForPositionOrSizeChanges();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

class InputRegionController {
  static Map<int, InputRegionController> controllersPerView = {};

  InputRegionController(this.viewId) : region = RegionBindings.createRegion();

  int viewId;

  RegionPtr region;

  bool _disposed = false;

  /// A list of global keys attached to the InputRegion widgets.
  ///
  /// The widgets attched to this key are representing positive input regions,
  /// that is we should enable inputs in this region.
  final Set<GlobalKey> _positiveRegionKeys = {};

  /// A list of global keys attached to the InputRegion widgets.
  ///
  /// The widgets attched to this key are representing negative input regions,
  /// that is we should disable inputs in this region.
  final Set<GlobalKey> _negativeRegionKeys = {};

  /// Adds a global key to the list of keys.
  static void addKey(
    GlobalKey key,
    int viewId, {
    bool isNegative = false,
  }) {
    final controller = controllersPerView.putIfAbsent(viewId, () => InputRegionController(viewId));

    bool added;
    if (isNegative) {
      controller._positiveRegionKeys.remove(key); // just in case a key switches isNegative
      added = controller._negativeRegionKeys.add(key);
    } else {
      controller._negativeRegionKeys.remove(key); // just in case a key switches isNegative
      added = controller._positiveRegionKeys.add(key);
    }
    if (added) {
      controller._ensureUpdateScheduled();
    }
  }

  /// Removes a global key from the list of keys.
  static void removeKey(GlobalKey key, int viewId) {
    final controller = controllersPerView[viewId];
    if (controller == null) return;

    final removedNegative = controller._negativeRegionKeys.remove(key);
    final removedPositive = controller._positiveRegionKeys.remove(key);
    if (removedNegative || removedPositive) {
      if (controller._negativeRegionKeys.isEmpty && controller._positiveRegionKeys.isEmpty) {
        controller._disposed = true;
        controllersPerView.remove(viewId);
        if (controller.region.address != 0) {
          RegionBindings.destroyRegion(controller.region);
        }
      } else {
        controller._ensureUpdateScheduled();
      }
    }
  }

  static void notifyRegionChange(GlobalKey key, int viewId) {
    controllersPerView[viewId]?._ensureUpdateScheduled();
  }

  static void notifyConfigChange(int viewId) {
    controllersPerView[viewId]?._ensureUpdateScheduled();
  }

  bool _refreshScheduled = false;

  void _ensureUpdateScheduled() {
    if (_disposed || _refreshScheduled) return;
    _refreshScheduled = true;
    // Runs after layout so every key has a size and position.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      _refreshInputRegion();
      // Make sure another frame happens, even if the UI did not need one.
      SchedulerBinding.instance.scheduleFrame();
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  /// This will be called whenever there is a change in the InputRegion widget.
  /// like size change, position change, etc.
  ///
  /// This will change the native window input region to the new input region.
  void _refreshInputRegion() {
    if (_disposed) return;
    final previousRegion = region;
    region = RegionBindings.createRegion();

    try {
      /// Sort the keys based on the depth of the widget.
      final List<({GlobalKey key, bool isNegative})> keys = [
        ..._positiveRegionKeys.map((key) => (key: key, isNegative: false)),
        ..._negativeRegionKeys.map((key) => (key: key, isNegative: true)),
      ];
      keys.sort((a, b) => _findDepth(a.key).compareTo(_findDepth(b.key)));

      Size? screenSize;
      for (final item in keys) {
        /// Get the size and position of the widget.
        final context = item.key.currentContext;
        if (context == null || !context.mounted) continue;

        final renderObject = context.findRenderObject();
        if (renderObject is! RenderBox || !renderObject.hasSize) continue;

        final size = renderObject.size;
        final position = renderObject.localToGlobal(Offset.zero);

        /// Set the input region to the size and position of the widget.
        screenSize ??= MediaQuery.sizeOf(context);
        final Rect region = Rect.fromLTWH(
          position.dx.clamp(0, screenSize.width),
          position.dy.clamp(0, screenSize.height),
          size.width.clamp(0, screenSize.width),
          size.height.clamp(0, screenSize.height),
        );

        if (item.isNegative) {
          RegionBindings.regionSubtract(
            this.region,
            region.left.ceil(),
            region.top.ceil(),
            region.width.ceil(),
            region.height.ceil(),
          );
        } else {
          RegionBindings.regionAdd(
            this.region,
            region.left.ceil(),
            region.top.ceil(),
            region.width.ceil(),
            region.height.ceil(),
          );
        }
      }

      RegionBindings.setInputRegion(viewId, region);
    } finally {
      if (previousRegion.address != 0) {
        RegionBindings.destroyRegion(previousRegion);
      }
    }
  }

  /// Find the depth of the InputRegion widget with the given key.
  static int _findDepth(GlobalKey key) {
    /// If the key is not attached to any widget, then return -1.
    if (key.currentContext == null || !key.currentContext!.mounted) {
      return -1;
    }

    Element element = key.currentContext! as Element;
    return element.depth;
  }
}
