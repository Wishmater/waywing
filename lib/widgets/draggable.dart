import "package:flutter/widgets.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/widgets/simple_gesture_detector.dart";

class DraggableWidget extends StatefulWidget {
  final Widget child;
  final void Function(SimpleGestureStartDetails)? onSwipeStart;
  final void Function(SimpleGestureUpdateDetails)? onSwipeUpdate;
  final void Function(SimpleGestureEndDetails)? onSwipeEnd;

  const DraggableWidget({
    super.key,
    required this.child,
    this.onSwipeStart,
    this.onSwipeUpdate,
    this.onSwipeEnd,
  });

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero; // Current position offset

  late BoundedSingleMotionController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = BoundedSingleMotionController(
      motion: mainConfig.motions.expressive.spatial.normal,
      vsync: this,
    );

    _animation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(_controller)
      ..addListener(() {
        setState(() {
          _offset = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startReturnAnimation() {
    _animation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(_controller);

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: SimpleGestureDetector(
        onSwipeStart: (details) {
          _controller.stop();
          widget.onSwipeStart?.call(details);
        },
        onSwipeUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
          widget.onSwipeUpdate?.call(details);
        },
        onGestureEnd: (details) {
          _startReturnAnimation();
          widget.onSwipeEnd?.call(details);
        },
        child: widget.child,
      ),
    );
  }
}
