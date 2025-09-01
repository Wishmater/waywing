import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/animation_utils.dart";

// TODO: 1 implement this everywhere
class OverflowOrFit extends StatelessWidget {
  final Clip clipBehavior;
  final AlignmentGeometry alignment;
  final BoxFit fit;
  final Widget child;

  const OverflowOrFit({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.none,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (mainConfig.animationFitting) {
      case AnimationFitting.clip:
        final screenSize = MediaQuery.sizeOf(context);
        return OverflowBox(
          fit: OverflowBoxFit.deferToChild,
          minWidth: 0,
          minHeight: 0,
          maxWidth: screenSize.width,
          maxHeight: screenSize.height,
          child: child,
        );
      case AnimationFitting.stretch:
        return FittedBox(
          clipBehavior: clipBehavior,
          alignment: alignment,
          fit: fit,
          child: child,
        );
    }
  }
}
