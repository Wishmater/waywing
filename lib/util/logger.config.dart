// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'logger.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin LoggingConfigI {
  @ConfigDocDefault<Level>((kDebugMode ? Level.trace : Level.info))
  Level get levelFilter;

  @ConfigDocDefault<Map<String, Level>>(<String, Level>{})
  Map<String, Level> get typeLevelFilters;

  String? get output;
}

class LoggingConfig extends ConfigBaseI with LoggingConfigI, LoggingConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'levelFilter': LoggingConfigBase._levelFilter,
      'typeLevelFilters': LoggingConfigBase._typeLevelFilters,
      'output': LoggingConfigBase._output,
    },
  );

  static BlockSchema get schema => staticSchema;

  @override
  final Level levelFilter;
  @override
  final Map<String, Level> typeLevelFilters;
  @override
  final String? output;

  LoggingConfig({
    Level? levelFilter,
    Map<String, Level>? typeLevelFilters,
    this.output,
  }) : levelFilter = levelFilter ?? (kDebugMode ? Level.trace : Level.info),
       typeLevelFilters = typeLevelFilters ?? <String, Level>{};

  factory LoggingConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields.map(
      (k, v) => MapEntry(k.value, v),
    );
    return LoggingConfig(
      levelFilter: fields['levelFilter'],
      typeLevelFilters: fields['typeLevelFilters'],
      output: fields['output'],
    );
  }

  @override
  String toString() {
    return '''LoggingConfig(
	levelFilter = $levelFilter,
	typeLevelFilters = $typeLevelFilters,
	output = $output
)''';
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
