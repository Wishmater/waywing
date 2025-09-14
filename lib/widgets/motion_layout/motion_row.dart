import "package:flutter/widgets.dart";
import "package:waywing/widgets/motion_layout/motion_flex.dart";

class MotionRow<T> extends MotionFlex<T> {
  const MotionRow({
    required super.data,
    required super.itemBuilder,
    super.transitionBuilder,
    required super.motion,
    super.addGlobalKeys = true,
    super.animateIndexChanges = true,
    // Column params
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.mainAxisSize = MainAxisSize.max,
    super.crossAxisAlignment = CrossAxisAlignment.center,
    super.textDirection,
    super.verticalDirection = VerticalDirection.down,
    super.textBaseline,
    super.clipBehavior = Clip.none,
    super.spacing = 0.0,
    super.key,
  }) : super(direction: Axis.horizontal);
}
