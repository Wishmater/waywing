import "package:flutter/widgets.dart";
import "package:motor/motor.dart";
import "package:waywing/widgets/motion_layout/motion_layout.dart";

class MotionFlex<T> extends StatelessWidget {
  final List<T> data;
  final ItemBuilder<T> itemBuilder;
  final ItemTransitionBuilder<T>? transitionBuilder;
  final Motion motion;
  final bool animateIndexChanges;
  final bool addGlobalKeys;
  // Flex params (Column / Row)
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final Clip clipBehavior;
  final double spacing;

  const MotionFlex({
    required this.data,
    required this.itemBuilder,
    this.transitionBuilder,
    required this.motion,
    this.addGlobalKeys = true,
    this.animateIndexChanges = true,
    // Flex params (Column / Row)
    required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.clipBehavior = Clip.none,
    this.spacing = 0.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MotionLayout<T>(
      data: data,
      itemBuilder: itemBuilder,
      transitionBuilder: transitionBuilder ?? defaultTransitionBuilder,
      motion: motion,
      addGlobalKeys: addGlobalKeys,
      animateIndexChanges: animateIndexChanges,
      layoutBuilder: (context, children) {
        return Flex(
          direction: direction,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
          spacing: spacing,
          children: children,
        );
      },
    );
  }

  Widget defaultTransitionBuilder(BuildContext context, T data, Widget child, Animation<double> animation) {
    // hack to prevent SizeTransition from breaking cross-axis sizing when inside IntrinsicWidth/Height
    child = Flex(
      direction: direction,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [child],
    );
    child = FadeTransition(
      opacity: animation,
      child: child,
    );
    child = SizeTransition(
      sizeFactor: animation,
      axis: direction,
      child: child,
    );
    // child = switch (mainConfig.animationFitting) {
    //   AnimationFitting.clip => SizeTransition(
    //     sizeFactor: animation,
    //     axis: direction,
    //     child: child,
    //   ),
    //   // TODO: 2 this crashse the layout, and it would be cool that it followed AnimationFitting.stretch
    //   AnimationFitting.stretch => FittedBox(
    //     clipBehavior: clipBehavior,
    //     child: Align(
    //       heightFactor: direction == Axis.vertical ? max(animation.value, 0.0) : null,
    //       widthFactor: direction == Axis.horizontal ? max(animation.value, 0.0) : null,
    //       child: child,
    //     ),
    //   ),
    // };
    return child;
  }
}
