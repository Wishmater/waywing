import "dart:math";

import "package:flutter/rendering.dart";
import "package:flutter/widgets.dart";

class Positioning {
  final Offset offset;
  final Size size;

  const Positioning(this.offset, this.size);

  Positioning.fromRect(Rect rect) : offset = Offset(rect.left, rect.top), size = rect.size;

  @override
  String toString() => "($offset $size)";

  @override
  int get hashCode => Object.hash(offset, size);

  @override
  bool operator ==(Object other) {
    if (other is Positioning) {
      return offset == other.offset && size == other.size;
    }
    return super == other;
  }

  Rect toRect() => Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
}

mixin StatePositioningMixin<T extends StatefulWidget> on State<T> {
  Positioning getPositioning({
    BuildContext? parentContext,
  }) {
    try {
      RenderBox box = context.findRenderObject()! as RenderBox;
      final position = box.localToGlobal(
        Offset.zero,
        ancestor: parentContext?.findRenderObject(),
      );
      if (position.dx.isNaN || position.dy.isNaN) {
        return _lastPositioning;
      }
      _lastPositioning = Positioning(position, box.size);
    } catch (_) {}
    return _lastPositioning;
  }

  // cache last known positioning, to use it if queried after widget is dismounted
  late Positioning _lastPositioning;
}

mixin StatePositioningNotifierMixin<T extends StatefulWidget> on StatePositioningMixin<T> {
  late ValueNotifier<Positioning?> positioningNotifier = ValueNotifier(null);
  late ValueNotifier<Offset?> offsetNotifier = ValueNotifier(null);
  late ValueNotifier<Size?> sizeNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    scheduleCheckPositioningChange();
  }

  void scheduleCheckPositioningChange() {
    WidgetsBinding.instance.addPostFrameCallback(checkPositioningChange);
  }

  void checkPositioningChange(_) {
    if (!mounted) return;
    final newPositioning = getPositioning();
    positioningNotifier.value = newPositioning;
    offsetNotifier.value = newPositioning.offset;
    sizeNotifier.value = newPositioning.size;
    scheduleCheckPositioningChange();
  }
}

typedef PositioningGetter = Positioning Function({BuildContext? parentContext});
typedef PositioningNullableGetter = Positioning? Function({BuildContext? parentContext});

class PositioningController {
  late PositioningGetter getPositioning;
}

class PositioningMonitor extends StatefulWidget {
  final PositioningController controller;
  final Widget child;

  const PositioningMonitor({
    required this.controller,
    required this.child,
    super.key,
  });

  @override
  State<PositioningMonitor> createState() => _PositioningMonitorState();
}

class _PositioningMonitorState extends State<PositioningMonitor>
    with StatePositioningMixin, StatePositioningControllerMixin {
  @override
  PositioningController getController(PositioningMonitor widget) => widget.controller;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

mixin StatePositioningControllerMixin<T extends StatefulWidget> on StatePositioningMixin<T> {
  PositioningController? getController(T widget);

  @override
  void initState() {
    super.initState();
    _updateControllerReferences();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (getController(widget) != getController(oldWidget)) {
      _updateControllerReferences();
    }
  }

  void _updateControllerReferences() {
    final controller = getController(widget);
    if (controller == null) return;
    controller.getPositioning = getPositioning;
  }
}

class PositioningNotifierController extends PositioningController {
  final ValueNotifier<Positioning?> positioningNotifier = ValueNotifier(null);
  final ValueNotifier<Offset?> offsetNotifier = ValueNotifier(null);
  final ValueNotifier<Size?> sizeNotifier = ValueNotifier(null);
}

class PositioningNotifierMonitor extends StatefulWidget {
  final PositioningNotifierController controller;
  final Widget child;

  const PositioningNotifierMonitor({
    required this.controller,
    required this.child,
    super.key,
  });

  @override
  State<PositioningNotifierMonitor> createState() => _PositioningNotidierMonitorState();
}

class _PositioningNotidierMonitorState extends State<PositioningNotifierMonitor>
    with StatePositioningMixin, StatePositioningNotifierMixin, StatePositioningNotifierControllerMixin {
  @override
  PositioningNotifierController getController(PositioningNotifierMonitor widget) => widget.controller;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

mixin StatePositioningNotifierControllerMixin<T extends StatefulWidget> on StatePositioningNotifierMixin<T> {
  PositioningNotifierController? getController(T widget);

  @override
  void initState() {
    super.initState();
    _updateControllerReferences();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (getController(widget) != getController(oldWidget)) {
      _updateControllerReferences();
    }
  }

  void _updateControllerReferences() {
    final controller = getController(widget);
    if (controller == null) return;
    controller.getPositioning = getPositioning;
    positioningNotifier = controller.positioningNotifier;
    offsetNotifier = controller.offsetNotifier;
    sizeNotifier = controller.sizeNotifier;
  }
}

/// This is useful to wrap widgets that change a lot (like a clock or a network thoughput indicator)
/// to make it so it has stable sizing and not affect the parent layout, which in turn makes it so
/// there are less layout and paint passes. Use devtools to debug paints.
class RememberMaxSize extends StatefulWidget {
  final Widget child;
  final Alignment alignment;

  /// pass this in to avoid having to build a LayoutBuilder
  final BoxConstraints? constraints;

  const RememberMaxSize({
    required this.alignment,
    required this.child,
    this.constraints,
    super.key,
  });

  @override
  State<RememberMaxSize> createState() => _RememberMaxSizeState();
}

class _RememberMaxSizeState extends State<RememberMaxSize> {
  final positioningController = PositioningNotifierController();
  Size? maxSize;

  @override
  void initState() {
    super.initState();
    positioningController.sizeNotifier.addListener(onSizeChange);
  }

  @override
  void dispose() {
    super.dispose();
    positioningController.sizeNotifier.removeListener(onSizeChange);
  }

  void onSizeChange() {
    final newSize = positioningController.sizeNotifier.value;
    if (newSize == null) return;
    if (maxSize == null || newSize.width > maxSize!.width || newSize.height > maxSize!.height) {
      setState(() {
        maxSize = Size(
          max(maxSize?.width ?? 0, newSize.width),
          max(maxSize?.height ?? 0, newSize.height),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.constraints != null) {
      return buildWithConstraints(context, widget.constraints!);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return buildWithConstraints(context, constraints);
      },
    );
  }

  Widget buildWithConstraints(BuildContext context, BoxConstraints constraints) {
    return SizedBox.fromSize(
      size: maxSize,
      child: OverflowBox(
        fit: maxSize == null ? OverflowBoxFit.deferToChild : OverflowBoxFit.max,
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
        minWidth: constraints.minWidth,
        minHeight: constraints.minHeight,
        alignment: widget.alignment,
        child: PositioningNotifierMonitor(
          controller: positioningController,
          child: widget.child,
        ),
      ),
    );
  }
}
