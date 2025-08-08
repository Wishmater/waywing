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

  LoggingConfig({Level? levelFilter, required this.typeLevelFilters})
    : levelFilter = levelFilter ?? Level.info;

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
}
