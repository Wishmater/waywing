// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LoggingConfigI {
  Level get levelFilter;
  Map<String, Level> get typeLevelFilters;
  String? get output;
}

class LoggingConfig with LoggingConfigI, LoggingConfigBase {
  final Level levelFilter;
  final Map<String, Level> typeLevelFilters;
  final String? output;

  LoggingConfig({
    Level? levelFilter,
    Map<String, Level>? typeLevelFilters,
    this.output,
  }) : levelFilter = levelFilter ?? Level.info,
       typeLevelFilters = typeLevelFilters ?? <String, Level>{};

  factory LoggingConfig.fromMap(Map<String, dynamic> map) {
    return LoggingConfig(
      levelFilter: map['levelFilter'],
      typeLevelFilters: map['typeLevelFilters'],
      output: map['output'],
    );
  }

  static TableSchema get schema => TableSchema(
    fields: {
      'levelFilter': LoggingConfigBase._levelFilter,
      'typeLevelFilters': LoggingConfigBase._typeLevelFilters,
      'output': LoggingConfigBase._output,
    },
  );

  @override
  String toString() {
    return 'LoggingConfiglevelFilter = $levelFilter, typeLevelFilters = $typeLevelFilters, output = $output';
  }

  @override
  bool operator ==(covariant LoggingConfig other) {
    return levelFilter == other.levelFilter &&
        typeLevelFilters == other.typeLevelFilters &&
        output == other.output;
  }

  @override
  int get hashCode => Object.hashAll([levelFilter, typeLevelFilters, output]);
}
