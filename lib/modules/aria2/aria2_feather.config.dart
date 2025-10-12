// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'aria2_feather.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin Aria2ConfigI {
  @ConfigDocDefault<bool>(true)
  bool get showUploadsSeparate;
}

class Aria2Config extends ConfigBaseI with Aria2ConfigI, Aria2ConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {'showUploadsSeparate': Aria2ConfigBase._showUploadsSeparate},
  );

  static BlockSchema get schema => staticSchema;

  @override
  final bool showUploadsSeparate;

  Aria2Config({bool? showUploadsSeparate})
    : showUploadsSeparate = showUploadsSeparate ?? true;

  factory Aria2Config.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return Aria2Config(showUploadsSeparate: fields['showUploadsSeparate']);
  }

  @override
  String toString() {
    return '''Aria2Config(
	showUploadsSeparate = $showUploadsSeparate
)''';
  }

  @override
  bool operator ==(covariant Aria2Config other) {
    return showUploadsSeparate == other.showUploadsSeparate;
  }

  @override
  int get hashCode => Object.hashAll([showUploadsSeparate]);
}
