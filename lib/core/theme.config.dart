// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'theme.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ThemeConfigI {
  @ConfigDocDefault<ThemeMode>(ThemeMode.system)
  ThemeMode get mode;

  /// Use this to set a custom font
  String? get fontFamily;

  @ConfigDocDefault<double>(kDefaultFontSize)
  /// Set the font size
  double get fontSize;

  double? get _iconSize;

  @ConfigDocDefault<List<IconType>>([
    IconType.flutter,
    IconType.direct,
    IconType.linux,
    IconType.nerdFont,
  ])
  List<IconType> get iconPriority;

  @ConfigDocDefault<ConfigIconVariation>(ConfigIconVariation.normal)
  ConfigIconVariation get iconFlutterVariation;

  @ConfigDocDefault<bool>(false)
  bool get iconFlutterTwoTone;

  @ConfigDocDefault<double>(0)
  double get iconFlutterFill;

  @ConfigDocDefault<double>(400)
  double get iconFlutterWeight;

  @ConfigDocDefault<MyColor>(MyColor(0xFF2196F3))
  MyColor get primaryColor;

  MyColor? get secondaryColor;

  MyColor? get tertiaryColor;

  MyColor? get errorColor;

  AdaptativeColor? get backgroundColor;

  MyColor? get foregroundColor;

  @ConfigDocDefault<double>(1.0)
  double get backgroundOpacity;

  @ConfigDocDefault<double>(1.0)
  double get shadows;

  @ConfigDocDefault<double>(12)
  double get buttonRounding;

  @ConfigDocDefault<double>(24)
  double get containerRounding;

  @ConfigDocDefault<double>(2)
  double get activeBorderSize;

  double? get _inactiveBorderSize;

  @ConfigDocDefault<List<MyColor>>([MyColor(0xee33ccff), MyColor(0xee00ff99)])
  List<MyColor> get activeBorderColors;

  @ConfigDocDefault<List<MyColor>>([MyColor(0xaa595959)])
  List<MyColor> get inactiveBorderColors;

  @ConfigDocDefault<double>(45)
  double get activeBorderAngle;

  @ConfigDocDefault<double>(45)
  double get inactiveBorderAngle;
}

class ThemeConfig extends ConfigBaseI with ThemeConfigI, ThemeConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'mode': ThemeConfigBase._mode,
      'fontFamily': ThemeConfigBase._fontFamily,
      'fontSize': ThemeConfigBase._fontSize,
      'iconSize': ThemeConfigBase.__iconSize,
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

  static BlockSchema get schema => staticSchema;

  @override
  final ThemeMode mode;
  @override
  final String? fontFamily;
  @override
  final double fontSize;
  @override
  final double? _iconSize;
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
  final AdaptativeColor? backgroundColor;
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
    double? iconSize,
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
       _iconSize = iconSize,
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

  factory ThemeConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return ThemeConfig(
      mode: fields['mode'],
      fontFamily: fields['fontFamily'],
      fontSize: fields['fontSize'],
      iconSize: fields['iconSize'],
      iconPriority: fields['iconPriority'],
      iconFlutterVariation: fields['iconFlutterVariation'],
      iconFlutterTwoTone: fields['iconFlutterTwoTone'],
      iconFlutterFill: fields['iconFlutterFill'],
      iconFlutterWeight: fields['iconFlutterWeight'],
      primaryColor: fields['primaryColor'],
      secondaryColor: fields['secondaryColor'],
      tertiaryColor: fields['tertiaryColor'],
      errorColor: fields['errorColor'],
      backgroundColor: fields['backgroundColor'],
      foregroundColor: fields['foregroundColor'],
      backgroundOpacity: fields['backgroundOpacity'],
      shadows: fields['shadows'],
      buttonRounding: fields['buttonRounding'],
      containerRounding: fields['containerRounding'],
      activeBorderSize: fields['activeBorderSize'],
      inactiveBorderSize: fields['inactiveBorderSize'],
      activeBorderColors: fields['activeBorderColors'],
      inactiveBorderColors: fields['inactiveBorderColors'],
      activeBorderAngle: fields['activeBorderAngle'],
      inactiveBorderAngle: fields['inactiveBorderAngle'],
    );
  }

  @override
  String toString() {
    return '''ThemeConfig(
	mode = $mode,
	fontFamily = $fontFamily,
	fontSize = $fontSize,
	_iconSize = $_iconSize,
	iconPriority = $iconPriority,
	iconFlutterVariation = $iconFlutterVariation,
	iconFlutterTwoTone = $iconFlutterTwoTone,
	iconFlutterFill = $iconFlutterFill,
	iconFlutterWeight = $iconFlutterWeight,
	primaryColor = $primaryColor,
	secondaryColor = $secondaryColor,
	tertiaryColor = $tertiaryColor,
	errorColor = $errorColor,
	backgroundColor = $backgroundColor,
	foregroundColor = $foregroundColor,
	backgroundOpacity = $backgroundOpacity,
	shadows = $shadows,
	buttonRounding = $buttonRounding,
	containerRounding = $containerRounding,
	activeBorderSize = $activeBorderSize,
	_inactiveBorderSize = $_inactiveBorderSize,
	activeBorderColors = $activeBorderColors,
	inactiveBorderColors = $inactiveBorderColors,
	activeBorderAngle = $activeBorderAngle,
	inactiveBorderAngle = $inactiveBorderAngle
)''';
  }

  @override
  bool operator ==(covariant ThemeConfig other) {
    return mode == other.mode &&
        fontFamily == other.fontFamily &&
        fontSize == other.fontSize &&
        _iconSize == other._iconSize &&
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
    _iconSize,
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
