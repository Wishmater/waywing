// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin BarConfigI {
  @ConfigDocDefault<ScreenEdge>(ScreenEdge.bottom)
  ScreenEdge get side;

  @ConfigDocDefault<int>(30)
  int get size;

  @ConfigDocDefault<double>(0)
  double get marginLeft;

  @ConfigDocDefault<double>(0)
  double get marginRight;

  @ConfigDocDefault<double>(0)
  double get marginTop;

  @ConfigDocDefault<double>(0)
  double get marginBottom;

  double? get _exclusiveSizeLeft;

  double? get _exclusiveSizeRight;

  double? get _exclusiveSizeTop;

  double? get _exclusiveSizeBottom;

  double? get _rounding;

  double? get _indicatorMinSize;

  double? get _indicatorPadding;
  List<(String, Object)> get dynamicSchemas;
}

class BarConfig extends ConfigBaseI with BarConfigI, BarConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'side': BarConfigBase._side,
      'size': BarConfigBase._size,
      'marginLeft': BarConfigBase._marginLeft,
      'marginRight': BarConfigBase._marginRight,
      'marginTop': BarConfigBase._marginTop,
      'marginBottom': BarConfigBase._marginBottom,
      'exclusiveSizeLeft': BarConfigBase.__exclusiveSizeLeft,
      'exclusiveSizeRight': BarConfigBase.__exclusiveSizeRight,
      'exclusiveSizeTop': BarConfigBase.__exclusiveSizeTop,
      'exclusiveSizeBottom': BarConfigBase.__exclusiveSizeBottom,
      'rounding': BarConfigBase.__rounding,
      'indicatorMinSize': BarConfigBase.__indicatorMinSize,
      'indicatorPadding': BarConfigBase.__indicatorPadding,
    },
  );

  static BlockSchema get schema => BlockSchema(
    blocks: {
      ...staticSchema.blocks,
      ...BarConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...BarConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final List<(String, Object)> dynamicSchemas;

  @override
  final ScreenEdge side;
  @override
  final int size;
  @override
  final double marginLeft;
  @override
  final double marginRight;
  @override
  final double marginTop;
  @override
  final double marginBottom;
  @override
  final double? _exclusiveSizeLeft;
  @override
  final double? _exclusiveSizeRight;
  @override
  final double? _exclusiveSizeTop;
  @override
  final double? _exclusiveSizeBottom;
  @override
  final double? _rounding;
  @override
  final double? _indicatorMinSize;
  @override
  final double? _indicatorPadding;

  BarConfig({
    ScreenEdge? side,
    int? size,
    double? marginLeft,
    double? marginRight,
    double? marginTop,
    double? marginBottom,
    double? exclusiveSizeLeft,
    double? exclusiveSizeRight,
    double? exclusiveSizeTop,
    double? exclusiveSizeBottom,
    double? rounding,
    double? indicatorMinSize,
    double? indicatorPadding,
    required this.dynamicSchemas,
  }) : side = side ?? ScreenEdge.bottom,
       size = size ?? 30,
       marginLeft = marginLeft ?? 0,
       marginRight = marginRight ?? 0,
       marginTop = marginTop ?? 0,
       marginBottom = marginBottom ?? 0,
       _exclusiveSizeLeft = exclusiveSizeLeft,
       _exclusiveSizeRight = exclusiveSizeRight,
       _exclusiveSizeTop = exclusiveSizeTop,
       _exclusiveSizeBottom = exclusiveSizeBottom,
       _rounding = rounding,
       _indicatorMinSize = indicatorMinSize,
       _indicatorPadding = indicatorPadding;

  factory BarConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = BarConfigBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
    }

    return BarConfig(
      dynamicSchemas: dynamicSchemas,
      side: fields['side'],
      size: fields['size'],
      marginLeft: fields['marginLeft'],
      marginRight: fields['marginRight'],
      marginTop: fields['marginTop'],
      marginBottom: fields['marginBottom'],
      exclusiveSizeLeft: fields['exclusiveSizeLeft'],
      exclusiveSizeRight: fields['exclusiveSizeRight'],
      exclusiveSizeTop: fields['exclusiveSizeTop'],
      exclusiveSizeBottom: fields['exclusiveSizeBottom'],
      rounding: fields['rounding'],
      indicatorMinSize: fields['indicatorMinSize'],
      indicatorPadding: fields['indicatorPadding'],
    );
  }

  @override
  String toString() {
    return '''BarConfig(
	side = $side,
	size = $size,
	marginLeft = $marginLeft,
	marginRight = $marginRight,
	marginTop = $marginTop,
	marginBottom = $marginBottom,
	_exclusiveSizeLeft = $_exclusiveSizeLeft,
	_exclusiveSizeRight = $_exclusiveSizeRight,
	_exclusiveSizeTop = $_exclusiveSizeTop,
	_exclusiveSizeBottom = $_exclusiveSizeBottom,
	_rounding = $_rounding,
	_indicatorMinSize = $_indicatorMinSize,
	_indicatorPadding = $_indicatorPadding,
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant BarConfig other) {
    return side == other.side &&
        size == other.size &&
        marginLeft == other.marginLeft &&
        marginRight == other.marginRight &&
        marginTop == other.marginTop &&
        marginBottom == other.marginBottom &&
        _exclusiveSizeLeft == other._exclusiveSizeLeft &&
        _exclusiveSizeRight == other._exclusiveSizeRight &&
        _exclusiveSizeTop == other._exclusiveSizeTop &&
        _exclusiveSizeBottom == other._exclusiveSizeBottom &&
        _rounding == other._rounding &&
        _indicatorMinSize == other._indicatorMinSize &&
        _indicatorPadding == other._indicatorPadding &&
        configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([
    side,
    size,
    marginLeft,
    marginRight,
    marginTop,
    marginBottom,
    _exclusiveSizeLeft,
    _exclusiveSizeRight,
    _exclusiveSizeTop,
    _exclusiveSizeBottom,
    _rounding,
    _indicatorMinSize,
    _indicatorPadding,
    dynamicSchemas,
  ]);
}

mixin BarFeathersContainerI {
  List<(String, Object)> get dynamicSchemas;
}

class BarFeathersContainer extends ConfigBaseI
    with BarFeathersContainerI, BarFeathersContainerBase {
  static const BlockSchema staticSchema = BlockSchema(fields: {});

  static BlockSchema get schema => BlockSchema(
    blocks: {
      ...staticSchema.blocks,
      ...BarFeathersContainerBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...BarFeathersContainerBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final List<(String, Object)> dynamicSchemas;

  BarFeathersContainer({required this.dynamicSchemas});

  factory BarFeathersContainer.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = BarFeathersContainerBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
    }

    return BarFeathersContainer(dynamicSchemas: dynamicSchemas);
  }

  @override
  String toString() {
    return '''BarFeathersContainer(
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant BarFeathersContainer other) {
    return configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([dynamicSchemas]);
}
