import 'package:flutter/widgets.dart';

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
  Widget build(BuildContext context) {
    widget.controller.getPositioning = getPositioning;
    return widget.child;
  }
}
