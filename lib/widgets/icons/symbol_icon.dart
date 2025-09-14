import "package:flutter/material.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:waywing/core/config.dart";
import "package:waywing/widgets/icons/text_icon.dart";

/// does a few things that flutter default Icon should do, but it doesn't,
/// especially related to new material Symbols. like setting the appropriate
/// opticalSize
class SymbolIcon extends StatelessWidget {
  const SymbolIcon(
    this.icon, {
    super.key,
    this.size,
    this.fill,
    this.weight,
    this.grade,
    this.opticalSize,
    this.color,
    this.shadows,
    this.semanticLabel,
    this.textDirection,
    this.applyTextScaling,
    this.blendMode,
    this.fontWeight,
  });

  final IconData? icon;
  final double? size;
  final double? fill;
  final double? weight;
  final double? grade;
  final double? opticalSize;
  final Color? color;
  final List<Shadow>? shadows;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final bool? applyTextScaling;
  final BlendMode? blendMode;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    // TODO: 1 ICONS Implement two-tone
    final size = this.size ?? TextIcon.getIconEffectiveSize(context);
    final opticalSize = this.opticalSize ?? size.clamp(20, 48);
    var icon = this.icon;
    if (icon != null && icon is VariedIconData) {
      icon = icon.getVariation(mainConfig.theme.iconFlutterVariation.variation);
    }
    return Icon(
      icon,
      size: size,
      fill: fill ?? mainConfig.theme.iconFlutterFill,
      weight: weight ?? mainConfig.theme.iconFlutterWeight,
      grade: grade,
      opticalSize: opticalSize,
      color: color,
      shadows: shadows,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      applyTextScaling: applyTextScaling,
      blendMode: blendMode,
      fontWeight: fontWeight,
    );
  }
}
