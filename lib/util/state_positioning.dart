import "package:flutter/widgets.dart";

mixin StatePositioningMixin<T extends StatefulWidget> on State<T> {
  (Offset, Size) getPositioning() {
    try {
      RenderBox box = context.findRenderObject()! as RenderBox;
      final position = box.localToGlobal(
        Offset.zero,
        // // this shouldn't be necessary since we always have a single provider at the root
        // ancestor: _provider?.context.findRenderObject(), // hack to support UI scale
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

typedef PositioningGetter = (Offset, Size) Function();

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

class _PositioningMonitorState extends State<PositioningMonitor> with StatePositioningMixin {
  @override
  void initState() {
    super.initState();
    widget.controller.getPositioning = getPositioning;
  }

  @override
  void didUpdateWidget(covariant PositioningMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      widget.controller.getPositioning = getPositioning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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
    with StatePositioningMixin, StatePositioningNotifierMixin {
  @override
  void initState() {
    super.initState();
    _updateControllerReferences();
  }

  @override
  void didUpdateWidget(covariant PositioningNotifierMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateControllerReferences();
    }
  }

  void _updateControllerReferences() {
    widget.controller.getPositioning = getPositioning;
    positioningNotifier = widget.controller.positioningNotifier;
    offsetNotifier = widget.controller.offsetNotifier;
    sizeNotifier = widget.controller.sizeNotifier;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
