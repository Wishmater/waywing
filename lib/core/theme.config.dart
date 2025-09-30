// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ThemeConfigI {
  ThemeMode get mode;

  /// Use this to set a custom font
  String? get fontFamily;

  /// Set the font size
  double get fontSize;
  List<IconType> get iconPriority;
  ConfigIconVariation get iconFlutterVariation;
  bool get iconFlutterTwoTone;
  double get iconFlutterFill;
  double get iconFlutterWeight;
  MyColor get primaryColor;
  MyColor? get secondaryColor;
  MyColor? get tertiaryColor;
  MyColor? get errorColor;
  MyColor? get backgroundColor;
  MyColor? get foregroundColor;
  double get backgroundOpacity;
  double get shadows;
  double get buttonRounding;
  double get containerRounding;
  double get activeBorderSize;
  double? get _inactiveBorderSize;
  List<MyColor> get activeBorderColors;
  List<MyColor> get inactiveBorderColors;
  double get activeBorderAngle;
  double get inactiveBorderAngle;
}

class ThemeConfig with ThemeConfigI, ThemeConfigBase {
  static const TableSchema staticSchema = TableSchema(
    fields: {
      'mode': ThemeConfigBase._mode,
      'fontFamily': ThemeConfigBase._fontFamily,
      'fontSize': ThemeConfigBase._fontSize,
      'iconPriority': ThemeConfigBase._iconPriority,
      'iconFlutterVariation': ThemeConfigBase._iconFlutterVariation,
      'iconFlutterTwoTone': ThemeConfigBase._iconFlutterTwoTone,
      'iconFlutterFill': ThemeConfigBase._iconFlutterFill,
      'iconFlutterWeight': ThemeConfigBase._iconFlutterWeight,
      'primaryColor': ThemeConfigBase._primaryColor,
      'secondaryColor': ThemeConfigBase._secondaryColor,
      'tertiaryColor': ThemeConfigBase._tertiaryColor,
      'errorColor': ThemeConfigBase._errorColor,
      'backgroundColor': ThemeConfigBase._backgroundColor,
      'foregroundColor': ThemeConfigBase._foregroundColor,
      'backgroundOpacity': ThemeConfigBase._backgroundOpacity,
      'shadows': ThemeConfigBase._shadows,
      'buttonRounding': ThemeConfigBase._buttonRounding,
      'containerRounding': ThemeConfigBase._containerRounding,
      'activeBorderSize': ThemeConfigBase._activeBorderSize,
      'inactiveBorderSize': ThemeConfigBase.__inactiveBorderSize,
      'activeBorderColors': ThemeConfigBase._activeBorderColors,
      'inactiveBorderColors': ThemeConfigBase._inactiveBorderColors,
      'activeBorderAngle': ThemeConfigBase._activeBorderAngle,
      'inactiveBorderAngle': ThemeConfigBase._inactiveBorderAngle,
    },
  );

  static TableSchema get schema => staticSchema;

  @override
  final ThemeMode mode;
  @override
  final String? fontFamily;
  @override
  final double fontSize;
  @override
  final List<IconType> iconPriority;
  @override
  final ConfigIconVariation iconFlutterVariation;
  @override
  final bool iconFlutterTwoTone;
  @override
  final double iconFlutterFill;
  @override
  final double iconFlutterWeight;
  @override
  final MyColor primaryColor;
  @override
  final MyColor? secondaryColor;
  @override
  final MyColor? tertiaryColor;
  @override
  final MyColor? errorColor;
  @override
  final MyColor? backgroundColor;
  @override
  final MyColor? foregroundColor;
  @override
  final double backgroundOpacity;
  @override
  final double shadows;
  @override
  final double buttonRounding;
  @override
  final double containerRounding;
  @override
  final double activeBorderSize;
  @override
  final double? _inactiveBorderSize;
  @override
  final List<MyColor> activeBorderColors;
  @override
  final List<MyColor> inactiveBorderColors;
  @override
  final double activeBorderAngle;
  @override
  final double inactiveBorderAngle;

  ThemeConfig({
    ThemeMode? mode,
    this.fontFamily,
    double? fontSize,
    List<IconType>? iconPriority,
    ConfigIconVariation? iconFlutterVariation,
    bool? iconFlutterTwoTone,
    double? iconFlutterFill,
    double? iconFlutterWeight,
    MyColor? primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.errorColor,
    this.backgroundColor,
    this.foregroundColor,
    double? backgroundOpacity,
    double? shadows,
    double? buttonRounding,
    double? containerRounding,
    double? activeBorderSize,
    double? inactiveBorderSize,
    List<MyColor>? activeBorderColors,
    List<MyColor>? inactiveBorderColors,
    double? activeBorderAngle,
    double? inactiveBorderAngle,
  }) : mode = mode ?? ThemeMode.system,
       fontSize = fontSize ?? kDefaultFontSize,
       iconPriority =
           iconPriority ??
           [
             IconType.flutter,
             IconType.direct,
             IconType.linux,
             IconType.nerdFont,
           ],
       iconFlutterVariation =
           iconFlutterVariation ?? ConfigIconVariation.normal,
       iconFlutterTwoTone = iconFlutterTwoTone ?? false,
       iconFlutterFill = iconFlutterFill ?? 0,
       iconFlutterWeight = iconFlutterWeight ?? 400,
       primaryColor = primaryColor ?? MyColor(0xFF2196F3),
       backgroundOpacity = backgroundOpacity ?? 1.0,
       shadows = shadows ?? 1.0,
       buttonRounding = buttonRounding ?? 12,
       containerRounding = containerRounding ?? 24,
       activeBorderSize = activeBorderSize ?? 2,
       _inactiveBorderSize = inactiveBorderSize,
       activeBorderColors =
           activeBorderColors ?? [MyColor(0xee33ccff), MyColor(0xee00ff99)],
       inactiveBorderColors = inactiveBorderColors ?? [MyColor(0xaa595959)],
       activeBorderAngle = activeBorderAngle ?? 45,
       inactiveBorderAngle = inactiveBorderAngle ?? 45;

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      mode: map['mode'],
      fontFamily: map['fontFamily'],
      fontSize: map['fontSize'],
      iconPriority: map['iconPriority'],
      iconFlutterVariation: map['iconFlutterVariation'],
      iconFlutterTwoTone: map['iconFlutterTwoTone'],
      iconFlutterFill: map['iconFlutterFill'],
      iconFlutterWeight: map['iconFlutterWeight'],
      primaryColor: map['primaryColor'],
      secondaryColor: map['secondaryColor'],
      tertiaryColor: map['tertiaryColor'],
      errorColor: map['errorColor'],
      backgroundColor: map['backgroundColor'],
      foregroundColor: map['foregroundColor'],
      backgroundOpacity: map['backgroundOpacity'],
      shadows: map['shadows'],
      buttonRounding: map['buttonRounding'],
      containerRounding: map['containerRounding'],
      activeBorderSize: map['activeBorderSize'],
      inactiveBorderSize: map['inactiveBorderSize'],
      activeBorderColors: map['activeBorderColors'],
      inactiveBorderColors: map['inactiveBorderColors'],
      activeBorderAngle: map['activeBorderAngle'],
      inactiveBorderAngle: map['inactiveBorderAngle'],
    );
  }

  @override
  String toString() {
    return 'ThemeConfig(mode = $mode, fontFamily = $fontFamily, fontSize = $fontSize, iconPriority = $iconPriority, iconFlutterVariation = $iconFlutterVariation, iconFlutterTwoTone = $iconFlutterTwoTone, iconFlutterFill = $iconFlutterFill, iconFlutterWeight = $iconFlutterWeight, primaryColor = $primaryColor, secondaryColor = $secondaryColor, tertiaryColor = $tertiaryColor, errorColor = $errorColor, backgroundColor = $backgroundColor, foregroundColor = $foregroundColor, backgroundOpacity = $backgroundOpacity, shadows = $shadows, buttonRounding = $buttonRounding, containerRounding = $containerRounding, activeBorderSize = $activeBorderSize, _inactiveBorderSize = $_inactiveBorderSize, activeBorderColors = $activeBorderColors, inactiveBorderColors = $inactiveBorderColors, activeBorderAngle = $activeBorderAngle, inactiveBorderAngle = $inactiveBorderAngle)';
  }

  @override
  bool operator ==(covariant ThemeConfig other) {
    return mode == other.mode &&
        fontFamily == other.fontFamily &&
        fontSize == other.fontSize &&
        iconPriority == other.iconPriority &&
        iconFlutterVariation == other.iconFlutterVariation &&
        iconFlutterTwoTone == other.iconFlutterTwoTone &&
        iconFlutterFill == other.iconFlutterFill &&
        iconFlutterWeight == other.iconFlutterWeight &&
        primaryColor == other.primaryColor &&
        secondaryColor == other.secondaryColor &&
        tertiaryColor == other.tertiaryColor &&
        errorColor == other.errorColor &&
        backgroundColor == other.backgroundColor &&
        foregroundColor == other.foregroundColor &&
        backgroundOpacity == other.backgroundOpacity &&
        shadows == other.shadows &&
        buttonRounding == other.buttonRounding &&
        containerRounding == other.containerRounding &&
        activeBorderSize == other.activeBorderSize &&
        _inactiveBorderSize == other._inactiveBorderSize &&
        activeBorderColors == other.activeBorderColors &&
        inactiveBorderColors == other.inactiveBorderColors &&
        activeBorderAngle == other.activeBorderAngle &&
        inactiveBorderAngle == other.inactiveBorderAngle;
  }

  @override
  int get hashCode => Object.hashAll([
    mode,
    fontFamily,
    fontSize,
    iconPriority,
    iconFlutterVariation,
    iconFlutterTwoTone,
    iconFlutterFill,
    iconFlutterWeight,
    primaryColor,
    secondaryColor,
    tertiaryColor,
    errorColor,
    backgroundColor,
    foregroundColor,
    backgroundOpacity,
    shadows,
    buttonRounding,
    containerRounding,
    activeBorderSize,
    _inactiveBorderSize,
    activeBorderColors,
    inactiveBorderColors,
    activeBorderAngle,
    inactiveBorderAngle,
  ]);
}
