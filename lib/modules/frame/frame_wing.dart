import "dart:ui";

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
    return MotionPositioned(
      motion: mainConfig.motions.expressive.spatial.slow,
      left: rerservedSpace.left,
      right: rerservedSpace.right,
      top: rerservedSpace.top,
      bottom: rerservedSpace.bottom,
      child: WingedContainer(
        color: Theme.of(context).canvasColor,
        addInputRegion: false,
        focusContainerOnMouseOver: false,
        activeBorder: null,
        inactiveBorder: null,
        elevation: 5,
        shape: FrameShape(
          borderRadius: BorderRadius.all(Radius.circular(config.rounding)),
          edgeInsets: config.edgeInsets,
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
  EdgeInsets get edgeInsets => EdgeInsets.fromLTRB(sizeLeft, sizeTop, sizeRight, sizeBottom);

  static const __rounding = DoubleNumberField(nullable: true);
  double get rounding => _rounding ?? mainConfig.theme.containerRounding;
}

class FrameShape extends ShapeBorder {
  final BorderRadius borderRadius;
  final EdgeInsets edgeInsets;

  const FrameShape({
    required this.borderRadius,
    required this.edgeInsets,
  });

  @override
  // EdgeInsetsGeometry get dimensions => edgeInsets; // this causes WingedContainer to misbehave
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final innerRect = Rect.fromLTRB(
      rect.left + edgeInsets.left,
      rect.top + edgeInsets.top,
      rect.right - edgeInsets.right,
      rect.bottom - edgeInsets.bottom,
    );
    final innerPath = ExternalRoundedCornersBorder(
      borderRadius: borderRadius,
    ).getOuterPath(innerRect);
    final outerPath = Path();
    // inflating outerPath is a hack to make fram always have thick shadows even when it's thin
    outerPath.addRect(rect.inflate(10000));
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
      edgeInsets: edgeInsets * t,
    );
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b == null) {
      return super.lerpTo(b, t);
    }
    if (b is FrameShape) {
      return null; // defer to lerpFrom of b
    }
    if (t < 0.5) {
      return scale(1 - (t * 2));
    }
    return b.scale((t - 0.5) * 2);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a == null) {
      return super.lerpFrom(a, t);
    }
    if (a is FrameShape) {
      return FrameShape(
        borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!.resolve(TextDirection.ltr),
        edgeInsets: EdgeInsets.lerp(a.edgeInsets, edgeInsets, t)!,
      );
    }
    if (t < 0.5) {
      return a.scale(1 - (t * 2));
    }
    return scale((t - 0.5) * 2);
  }

  @override
  bool operator ==(Object other) {
    return other is FrameShape && other.borderRadius == borderRadius && other.edgeInsets == edgeInsets;
  }

  @override
  int get hashCode => Object.hash(borderRadius, edgeInsets);

  @override
  String toString() {
    return "$runtimeType($borderRadius, $edgeInsets)";
  }
}
