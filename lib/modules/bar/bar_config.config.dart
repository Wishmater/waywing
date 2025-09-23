// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_config.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin BarConfigI {
  ScreenEdge get side;
  int get size;
  double get marginLeft;
  double get marginRight;
  double get marginTop;
  double get marginBottom;
  double? get _exclusiveSizeLeft;
  double? get _exclusiveSizeRight;
  double? get _exclusiveSizeTop;
  double? get _exclusiveSizeBottom;
  double get radiusInCross;
  double get radiusInMain;
  double get radiusOutCross;
  double get radiusOutMain;
  double? get _indicatorMinSize;
  double? get _indicatorPadding;
  Map<String, List<Object>> get dynamicSchemas;
}

class BarConfig extends ConfigBaseI with BarConfigI, BarConfigBase {
  static const TableSchema staticSchema = TableSchema(
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
      'radiusInCross': BarConfigBase._radiusInCross,
      'radiusInMain': BarConfigBase._radiusInMain,
      'radiusOutCross': BarConfigBase._radiusOutCross,
      'radiusOutMain': BarConfigBase._radiusOutMain,
      'indicatorMinSize': BarConfigBase.__indicatorMinSize,
      'indicatorPadding': BarConfigBase.__indicatorPadding,
    },
  );

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
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
  final Map<String, List<Object>> dynamicSchemas;

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
  final double radiusInCross;
  @override
  final double radiusInMain;
  @override
  final double radiusOutCross;
  @override
  final double radiusOutMain;
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
    double? radiusInCross,
    double? radiusInMain,
    double? radiusOutCross,
    double? radiusOutMain,
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
       radiusInCross = radiusInCross ?? 0,
       radiusInMain = radiusInMain ?? 0,
       radiusOutCross = radiusOutCross ?? 0,
       radiusOutMain = radiusOutMain ?? 0,
       _indicatorMinSize = indicatorMinSize,
       _indicatorPadding = indicatorPadding;

  factory BarConfig.fromMap(Map<String, dynamic> map) {
    final dynamicSchemas = <String, List<Object>>{};
    final schemas = BarConfigBase._getDynamicSchemaTables();
    for (final entry in schemas.entries) {
      if (map[entry.key] == null) continue;
      for (final e in map[entry.key]) {
        if (dynamicSchemas[entry.key] == null) {
          dynamicSchemas[entry.key] = [];
        }
        dynamicSchemas[entry.key]!.add(entry.value.from(e));
      }
    }

    return BarConfig(
      dynamicSchemas: dynamicSchemas,
      side: map['side'],
      size: map['size'],
      marginLeft: map['marginLeft'],
      marginRight: map['marginRight'],
      marginTop: map['marginTop'],
      marginBottom: map['marginBottom'],
      exclusiveSizeLeft: map['exclusiveSizeLeft'],
      exclusiveSizeRight: map['exclusiveSizeRight'],
      exclusiveSizeTop: map['exclusiveSizeTop'],
      exclusiveSizeBottom: map['exclusiveSizeBottom'],
      radiusInCross: map['radiusInCross'],
      radiusInMain: map['radiusInMain'],
      radiusOutCross: map['radiusOutCross'],
      radiusOutMain: map['radiusOutMain'],
      indicatorMinSize: map['indicatorMinSize'],
      indicatorPadding: map['indicatorPadding'],
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
	radiusInCross = $radiusInCross,
	radiusInMain = $radiusInMain,
	radiusOutCross = $radiusOutCross,
	radiusOutMain = $radiusOutMain,
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
        radiusInCross == other.radiusInCross &&
        radiusInMain == other.radiusInMain &&
        radiusOutCross == other.radiusOutCross &&
        radiusOutMain == other.radiusOutMain &&
        _indicatorMinSize == other._indicatorMinSize &&
        _indicatorPadding == other._indicatorPadding &&
        configMapEqual(dynamicSchemas, other.dynamicSchemas);
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
    radiusInCross,
    radiusInMain,
    radiusOutCross,
    radiusOutMain,
    _indicatorMinSize,
    _indicatorPadding,
    dynamicSchemas,
  ]);
}

mixin StartConfigI {
  Map<String, List<Object>> get dynamicSchemas;
}

class StartConfig extends ConfigBaseI with StartConfigI, StartConfigBase {
  static const TableSchema staticSchema = TableSchema(fields: {});

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
      ...StartConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...StartConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final Map<String, List<Object>> dynamicSchemas;

  StartConfig({required this.dynamicSchemas});

  factory StartConfig.fromMap(Map<String, dynamic> map) {
    final dynamicSchemas = <String, List<Object>>{};
    final schemas = StartConfigBase._getDynamicSchemaTables();
    for (final entry in schemas.entries) {
      if (map[entry.key] == null) continue;
      for (final e in map[entry.key]) {
        if (dynamicSchemas[entry.key] == null) {
          dynamicSchemas[entry.key] = [];
        }
        dynamicSchemas[entry.key]!.add(entry.value.from(e));
      }
    }

    return StartConfig(dynamicSchemas: dynamicSchemas);
  }

  @override
  String toString() {
    return '''StartConfig(
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant StartConfig other) {
    return configMapEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([dynamicSchemas]);
}

mixin CenterConfigI {
  Map<String, List<Object>> get dynamicSchemas;
}

class CenterConfig extends ConfigBaseI with CenterConfigI, CenterConfigBase {
  static const TableSchema staticSchema = TableSchema(fields: {});

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
      ...CenterConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...CenterConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final Map<String, List<Object>> dynamicSchemas;

  CenterConfig({required this.dynamicSchemas});

  factory CenterConfig.fromMap(Map<String, dynamic> map) {
    final dynamicSchemas = <String, List<Object>>{};
    final schemas = CenterConfigBase._getDynamicSchemaTables();
    for (final entry in schemas.entries) {
      if (map[entry.key] == null) continue;
      for (final e in map[entry.key]) {
        if (dynamicSchemas[entry.key] == null) {
          dynamicSchemas[entry.key] = [];
        }
        dynamicSchemas[entry.key]!.add(entry.value.from(e));
      }
    }

    return CenterConfig(dynamicSchemas: dynamicSchemas);
  }

  @override
  String toString() {
    return '''CenterConfig(
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant CenterConfig other) {
    return configMapEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([dynamicSchemas]);
}

mixin EndConfigI {
  Map<String, List<Object>> get dynamicSchemas;
}

class EndConfig extends ConfigBaseI with EndConfigI, EndConfigBase {
  static const TableSchema staticSchema = TableSchema(fields: {});

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
      ...EndConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...EndConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final Map<String, List<Object>> dynamicSchemas;

  EndConfig({required this.dynamicSchemas});

  factory EndConfig.fromMap(Map<String, dynamic> map) {
    final dynamicSchemas = <String, List<Object>>{};
    final schemas = EndConfigBase._getDynamicSchemaTables();
    for (final entry in schemas.entries) {
      if (map[entry.key] == null) continue;
      for (final e in map[entry.key]) {
        if (dynamicSchemas[entry.key] == null) {
          dynamicSchemas[entry.key] = [];
        }
        dynamicSchemas[entry.key]!.add(entry.value.from(e));
      }
    }

    return EndConfig(dynamicSchemas: dynamicSchemas);
  }

  @override
  String toString() {
    return '''EndConfig(
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant EndConfig other) {
    return configMapEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([dynamicSchemas]);
}
