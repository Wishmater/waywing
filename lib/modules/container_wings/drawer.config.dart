// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'drawer.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin DrawerConfigI {
  @ConfigDocDefault<ScreenEdge>(ScreenEdge.bottom)
  ScreenEdge get side;
  List<(String, Object)> get dynamicSchemas;
}

class DrawerConfig extends ConfigBaseI with DrawerConfigI, DrawerConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'side': DrawerConfigBase._side},
  );

  static BlockSchema get schema => LazySchema(
    blocksGetter: () => {
      ...staticSchema.blocks,
      ...DrawerConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemasGetter: () => <String>{
      ...staticSchema.canBeMissingSchemas,
      ...DrawerConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final List<(String, Object)> dynamicSchemas;

  @override
  final ScreenEdge side;

  DrawerConfig({ScreenEdge? side, required this.dynamicSchemas})
    : side = side ?? ScreenEdge.bottom;

  factory DrawerConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = DrawerConfigBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
    }

    return DrawerConfig(dynamicSchemas: dynamicSchemas, side: fields['side']);
  }

  @override
  String toString() {
    return '''DrawerConfig(
	side = $side,
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant DrawerConfig other) {
    return side == other.side &&
        configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([side, dynamicSchemas]);
}
