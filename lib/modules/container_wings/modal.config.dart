// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'modal.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ModalConfigI {
  @ConfigDocDefault<MyColor>(MyColor(0x8A000000))
  MyColor get barrierColor;

  @ConfigDocDefault<bool>(true)
  bool get barrierDismissable;

  double? get maxWidth;

  double? get maxHeight;
  List<(String, Object)> get dynamicSchemas;
}

class ModalConfig extends ConfigBaseI with ModalConfigI, ModalConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'barrierColor': ModalConfigBase._barrierColor,
      'barrierDismissable': ModalConfigBase._barrierDismissable,
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
  final double? maxWidth;
  @override
  final double? maxHeight;

  ModalConfig({
    MyColor? barrierColor,
    bool? barrierDismissable,
    this.maxWidth,
    this.maxHeight,
    required this.dynamicSchemas,
  }) : barrierColor = barrierColor ?? MyColor(0x8A000000),
       barrierDismissable = barrierDismissable ?? true;

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
      maxWidth: fields['maxWidth'],
      maxHeight: fields['maxHeight'],
    );
  }

  @override
  String toString() {
    return '''ModalConfig(
	barrierColor = $barrierColor,
	barrierDismissable = $barrierDismissable,
	maxWidth = $maxWidth,
	maxHeight = $maxHeight,
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant ModalConfig other) {
    return barrierColor == other.barrierColor &&
        barrierDismissable == other.barrierDismissable &&
        maxWidth == other.maxWidth &&
        maxHeight == other.maxHeight &&
        configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([
    barrierColor,
    barrierDismissable,
    maxWidth,
    maxHeight,
    dynamicSchemas,
  ]);
}
