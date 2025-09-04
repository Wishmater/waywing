// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LoggingConfigI {
  Level get levelFilter;
  Map<String, Level> get typeLevelFilters;
}

class LoggingConfig with LoggingConfigI, LoggingConfigBase {
  final Level levelFilter;
  final Map<String, Level> typeLevelFilters;

  LoggingConfig({Level? levelFilter, Map<String, Level>? typeLevelFilters})
    : levelFilter = levelFilter ?? Level.info,
      typeLevelFilters = typeLevelFilters ?? <String, Level>{};

  factory LoggingConfig.fromMap(Map<String, dynamic> map) {
    return LoggingConfig(
      levelFilter: map['levelFilter'],
      typeLevelFilters: map['typeLevelFilters'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'levelFilter': LoggingConfigBase._levelFilter,
      'typeLevelFilters': LoggingConfigBase._typeLevelFilters,
    },
  );

  @override
  String toString() {
    return 'LoggingConfiglevelFilter = $levelFilter, typeLevelFilters = $typeLevelFilters';
  }

  @override
  bool operator ==(covariant LoggingConfig other) {
    return levelFilter == other.levelFilter &&
        typeLevelFilters == other.typeLevelFilters;
  }

  @override
  int get hashCode => Object.hashAll([levelFilter, typeLevelFilters]);
}
