import "package:flutter/widgets.dart";

mixin StatePositioningMixin<T extends StatefulWidget> on State<T> {
  (Offset, Size) getPositioning({
    BuildContext? parentContext,
  }) {
    try {
      RenderBox box = context.findRenderObject()! as RenderBox;
      final position = box.localToGlobal(
        Offset.zero,
        ancestor: parentContext?.findRenderObject(),
      );
      _lastPositioning = (position, box.size);
    } catch (_) {}
    return _lastPositioning;
  }

  // cache last known positioning, to use it if queried after widget is dismounted
  late (Offset, Size) _lastPositioning;
}

mixin StatePositioningNotifierMixin<T extends StatefulWidget> on StatePositioningMixin<T> {
  late ValueNotifier<(Offset, Size)?> positioningNotifier = ValueNotifier(null);
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
    offsetNotifier.value = newPositioning.$1;
    sizeNotifier.value = newPositioning.$2;
    scheduleCheckPositioningChange();
  }
}

typedef PositioningGetter = (Offset, Size) Function({BuildContext? parentContext});
typedef PositioningNullableGetter = (Offset, Size)? Function({BuildContext? parentContext});

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
  final ValueNotifier<(Offset, Size)?> positioningNotifier = ValueNotifier(null);
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
