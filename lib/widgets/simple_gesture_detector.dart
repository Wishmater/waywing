import "package:flutter/gestures.dart";
import "package:flutter/widgets.dart";

typedef SimpleGestureStarCallback = void Function(SimpleGestureStartDetails details);
typedef SimpleGestureGestureEndCallback = void Function(SimpleGestureEndDetails details);
typedef SimpleGestureUpdateCallback = void Function(SimpleGestureUpdateDetails details);
typedef SimpleGestureZoomEventCallback = void Function(SimpleGestureZoomEventDetails details);

enum SimpleGestureType { touchpad, mouse }

class SimpleGestureStartDetails {
  final Offset position;
  final SimpleGestureType type;

  const SimpleGestureStartDetails({required this.position, required this.type});
}

class SimpleGestureUpdateDetails {
  final Offset delta;
  final Offset position;
  final SimpleGestureType type;

  const SimpleGestureUpdateDetails({
    required this.delta,
    required this.position,
    required this.type,
  });
}

class SimpleGestureEndDetails {
  final Velocity velocity;
  final Offset position;
  final Offset delta;
  final SimpleGestureType type;

  const SimpleGestureEndDetails({
    required this.velocity,
    required this.position,
    required this.delta,
    required this.type,
  });
}

class SimpleGestureZoomEventDetails {
  final Offset position;
  final double zoom;

  const SimpleGestureZoomEventDetails({required this.position, required this.zoom});
}

class SimpleGestureDetector extends StatefulWidget {
  final Widget? child;

  final SimpleGestureStarCallback? onSwipeStart;

  final SimpleGestureGestureEndCallback? onGestureEnd;

  final SimpleGestureUpdateCallback? onSwipeUpdate;

  final SimpleGestureZoomEventCallback? onZoomEvent;

  const SimpleGestureDetector({
    super.key,
    this.child,
    this.onSwipeStart,
    this.onSwipeUpdate,
    this.onGestureEnd,
    this.onZoomEvent,
  });

  @override
  State<SimpleGestureDetector> createState() => SimpleGestureDetectorState();
}

class SimpleGestureDetectorState extends State<SimpleGestureDetector> {
  VelocityTracker _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.trackpad);
  Offset _endPosition = Offset.zero;
  Offset _startPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.mouse);
        _velocityTracker.addPosition(event.timeStamp, event.localPosition);
        _endPosition = event.localPosition;
        _startPosition = event.localPosition;

        widget.onSwipeStart?.call(
          SimpleGestureStartDetails(
            position: event.localPosition,
            type: SimpleGestureType.mouse,
          ),
        );
      },

      onPointerPanZoomStart: (event) {
        _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.trackpad);
        _velocityTracker.addPosition(event.timeStamp, event.localPosition);
        _endPosition = event.localPosition;
        _startPosition = event.localPosition;

        widget.onSwipeStart?.call(
          SimpleGestureStartDetails(
            position: event.localPosition,
            type: SimpleGestureType.touchpad,
          ),
        );
      },

      onPointerMove: (event) {
        _velocityTracker.addPosition(event.timeStamp, event.localPosition);
        _endPosition = event.localPosition;

        widget.onSwipeUpdate?.call(
          SimpleGestureUpdateDetails(
            delta: event.localDelta,
            position: event.localPosition,
            type: SimpleGestureType.mouse,
          ),
        );
      },

      onPointerPanZoomUpdate: (event) {
        _velocityTracker.addPosition(event.timeStamp, event.localPan);
        _endPosition = _endPosition + event.localPanDelta;

        if (event.scale != 1) {
          widget.onZoomEvent?.call(
            SimpleGestureZoomEventDetails(
              position: event.localPan,
              zoom: event.scale,
            ),
          );
        }
        widget.onSwipeUpdate?.call(
          SimpleGestureUpdateDetails(
            delta: event.localPanDelta,
            position: event.localPan,
            type: SimpleGestureType.touchpad,
          ),
        );
      },

      onPointerUp: (event) {
        final velocity = _velocityTracker.getVelocity();
        widget.onGestureEnd?.call(
          SimpleGestureEndDetails(
            velocity: velocity,
            position: _endPosition,
            delta: _endPosition - _startPosition,
            type: SimpleGestureType.mouse,
          ),
        );

        _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
      },

      onPointerPanZoomEnd: (event) {
        final velocity = _velocityTracker.getVelocity();
        widget.onGestureEnd?.call(
          SimpleGestureEndDetails(
            velocity: velocity,
            position: _endPosition,
            delta: _endPosition - _startPosition,
            type: SimpleGestureType.touchpad,
          ),
        );

        _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
      },

      child: widget.child,
    );
  }
}
