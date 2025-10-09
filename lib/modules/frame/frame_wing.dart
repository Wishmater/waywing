import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";

part "frame_wing.config.dart";

class FrameWing extends Wing<FrameConfig> {
  FrameWing._();

  static void registerFeather(RegisterFeatherCallback<FrameWing, FrameConfig> registerFeather) {
    registerFeather(
      "Frame",
      FeatherRegistration<FrameWing, FrameConfig>(
        constructor: FrameWing._,
        schemaBuilder: () => FrameConfig.schema,
        configBuilder: FrameConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Frame";

  @override
  ValueListenable<EdgeInsets> get exclusiveSize => _exclusiveSize;
  late final ValueNotifier<EdgeInsets> _exclusiveSize = ValueNotifier(_getExclusiveSize());
  EdgeInsets _getExclusiveSize() => EdgeInsets.fromLTRB(
    config.sizeLeft,
    config.sizeTop,
    config.sizeRight,
    config.sizeBottom,
  );
  @override
  void onConfigUpdated(FrameConfig oldConfig) {
    _exclusiveSize.value = _getExclusiveSize();
  }

  @override
  Widget buildWing(BuildContext context, EdgeInsets rerservedSpace) {
    // TODO: 2 implement shadows. Implementing it here is easy, but we also need Bar to play nice with it
    return MotionPositioned(
      motion: mainConfig.motions.expressive.spatial.slow,
      left: rerservedSpace.left,
      right: rerservedSpace.right,
      top: rerservedSpace.top,
      bottom: rerservedSpace.bottom,
      child: Material(
        color: Theme.of(context).canvasColor,
        shape: FrameShape(
          borderRadius: BorderRadius.all(Radius.circular(config.rounding)),
          sizeLeft: config.sizeLeft,
          sizeRight: config.sizeRight,
          sizeTop: config.sizeTop,
          sizeBottom: config.sizeBottom,
        ),
      ),
    );
  }
}

@Config()
mixin FrameConfigBase on FrameConfigI {
  // TODO: 2 validate >= 0
  static const _size = DoubleNumberField(defaultTo: 12);
  static const __sizeLeft = DoubleNumberField(nullable: true);
  double get sizeLeft => _sizeLeft ?? size;
  static const __sizeRight = DoubleNumberField(nullable: true);
  double get sizeRight => _sizeRight ?? size;
  static const __sizeTop = DoubleNumberField(nullable: true);
  double get sizeTop => _sizeTop ?? size;
  static const __sizeBottom = DoubleNumberField(nullable: true);
  double get sizeBottom => _sizeBottom ?? size;

  static const __rounding = DoubleNumberField(nullable: true);
  double get rounding => _rounding ?? mainConfig.theme.containerRounding;
}

class FrameShape extends ShapeBorder {
  final BorderRadius borderRadius;
  final double sizeLeft;
  final double sizeRight;
  final double sizeTop;
  final double sizeBottom;

  const FrameShape({
    required this.borderRadius,
    required this.sizeLeft,
    required this.sizeRight,
    required this.sizeTop,
    required this.sizeBottom,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero; // doesn't matter

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final innerRect = Rect.fromLTRB(
      rect.left + sizeLeft,
      rect.top + sizeTop,
      rect.right - sizeRight,
      rect.bottom - sizeBottom,
    );
    final innerPath = ExternalRoundedCornersBorder(
      borderRadius: borderRadius,
    ).getOuterPath(innerRect);
    final outerPath = Path();
    outerPath.addRect(rect);
    return Path.combine(PathOperation.difference, outerPath, innerPath);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return FrameShape(
      borderRadius: borderRadius * t,
      sizeLeft: sizeLeft * t,
      sizeRight: sizeRight * t,
      sizeTop: sizeTop * t,
      sizeBottom: sizeBottom * t,
    );
  }

  // TODO: 1 do we need anything else? lerp?
}
