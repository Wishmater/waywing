// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  desktopFilePath: json['desktopFilePath'] as String,
  name: json['name'] as String,
  exec: json['exec'] as String?,
  tryExec: json['tryExec'] as String?,
  comment: json['comment'] as String?,
  icon: json['icon'] as String?,
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$CategoriesEnumMap, e))
      .toList(),
  dBusActivatable: json['dBusActivatable'] as bool? ?? false,
  terminal: json['terminal'] as bool? ?? false,
  onlyShownIn: (json['onlyShownIn'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  notShownIn: (json['notShownIn'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  keywords: (json['keywords'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  timesExec: (json['timesExec'] as num?)?.toInt() ?? 0,
  lastModified: DateTime.parse(json['lastModified'] as String),
  filepath: json['filepath'] as String,
);

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'desktopFilePath': instance.desktopFilePath,
      'name': instance.name,
      'comment': instance.comment,
      'icon': instance.icon,
      'onlyShownIn': instance.onlyShownIn,
      'notShownIn': instance.notShownIn,
      'dBusActivatable': instance.dBusActivatable,
      'tryExec': instance.tryExec,
      'exec': instance.exec,
      'terminal': instance.terminal,
      'categories': instance.categories
          ?.map((e) => _$CategoriesEnumMap[e]!)
          .toList(),
      'keywords': instance.keywords,
      'lastModified': instance.lastModified.toIso8601String(),
      'filepath': instance.filepath,
      'timesExec': instance.timesExec,
    };

const _$CategoriesEnumMap = {
  Categories.audioVideo: 'audioVideo',
  Categories.audio: 'audio',
  Categories.video: 'video',
  Categories.development: 'development',
  Categories.education: 'education',
  Categories.game: 'game',
  Categories.graphics: 'graphics',
  Categories.network: 'network',
  Categories.office: 'office',
  Categories.science: 'science',
  Categories.settings: 'settings',
  Categories.system: 'system',
  Categories.utility: 'utility',
};
