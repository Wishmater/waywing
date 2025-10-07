// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modal.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ModalConfigI {
  @ConfigDocDefault<MyColor>(MyColor(0x8A000000))
  MyColor get barrierColor;

  @ConfigDocDefault<bool>(true)
  bool get barrierDismissable;

  @ConfigDocDefault<double>(400)
  double get width;

  @ConfigDocDefault<double>(400)
  double get height;

  double? get maxWidth;

  double? get maxHeight;
  List<(String, Object)> get dynamicSchemas;
}

class ModalConfig extends ConfigBaseI with ModalConfigI, ModalConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'barrierColor': ModalConfigBase._barrierColor,
      'barrierDismissable': ModalConfigBase._barrierDismissable,
      'width': ModalConfigBase._width,
      'height': ModalConfigBase._height,
      'maxWidth': ModalConfigBase._maxWidth,
      'maxHeight': ModalConfigBase._maxHeight,
    },
  );

  static BlockSchema get schema => LazySchema(
    blocksGetter: () => {
      ...staticSchema.blocks,
      ...ModalConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemasGetter: () => <String>{
      ...staticSchema.canBeMissingSchemas,
      ...ModalConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final List<(String, Object)> dynamicSchemas;

  @override
  final MyColor barrierColor;
  @override
  final bool barrierDismissable;
  @override
  final double width;
  @override
  final double height;
  @override
  final double? maxWidth;
  @override
  final double? maxHeight;

  ModalConfig({
    MyColor? barrierColor,
    bool? barrierDismissable,
    double? width,
    double? height,
    this.maxWidth,
    this.maxHeight,
    required this.dynamicSchemas,
  }) : barrierColor = barrierColor ?? MyColor(0x8A000000),
       barrierDismissable = barrierDismissable ?? true,
       width = width ?? 400,
       height = height ?? 400;

  factory ModalConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = ModalConfigBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
    }

    return ModalConfig(
      dynamicSchemas: dynamicSchemas,
      barrierColor: fields['barrierColor'],
      barrierDismissable: fields['barrierDismissable'],
      width: fields['width'],
      height: fields['height'],
      maxWidth: fields['maxWidth'],
      maxHeight: fields['maxHeight'],
    );
  }

  @override
  String toString() {
    return '''ModalConfig(
	barrierColor = $barrierColor,
	barrierDismissable = $barrierDismissable,
	width = $width,
	height = $height,
	maxWidth = $maxWidth,
	maxHeight = $maxHeight,
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant ModalConfig other) {
    return barrierColor == other.barrierColor &&
        barrierDismissable == other.barrierDismissable &&
        width == other.width &&
        height == other.height &&
        maxWidth == other.maxWidth &&
        maxHeight == other.maxHeight &&
        configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([
    barrierColor,
    barrierDismissable,
    width,
    height,
    maxWidth,
    maxHeight,
    dynamicSchemas,
  ]);
}
