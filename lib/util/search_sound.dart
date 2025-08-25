import "dart:async";
import "dart:io";

import "package:dartx/dartx_io.dart";
import "package:path/path.dart";
import "package:ini/ini.dart" as ini;

Iterable<Directory> __directories() sync* {
  String? xdgDataDirs = Platform.environment["XDG_DATA_DIRS"];
  if (xdgDataDirs == null || xdgDataDirs.isEmpty) {
    xdgDataDirs = "/usr/local/share:/usr/share";
  }
  yield* xdgDataDirs.split(":").map((p) => Directory(p));
}

final List<Directory> _directories = __directories()
    .map((dir) => dir.subdir("sounds"))
    .where((dir) => dir.existsSync())
    .toList();

class _Theme {
  final File theme;
  final String path;
  _Theme._(this.theme, this.path);

  static _Theme? fromPath(String path) {
    final theme = File(join(path, "index.theme"));
    if (!theme.existsSync()) {
      return null;
    }
    return _Theme._(theme, path);
  }

  Future<String?> findSound(String soundName, Map<String, _Theme> all) async {
    final parsed = ini.Config.fromString(await theme.readAsString());
    final dirs = parsed.get("Sound Theme", "Directories")?.split(" ");
    if (dirs == null) {
      return null;
    }
    for (final dir in dirs) {
      final sound = await _findSoundInDirectory(join(path, dir), soundName);
      if (sound != null) {
        return sound;
      }
    }
    final parents = parsed.get("Sound Theme", "Inherits")?.split(",");
    if (parents == null) {
      return null;
    }

    for (final parent in parents) {
      final soundPath = await all[parent]?.findSound(soundName, all);
      if (soundPath != null) {
        return soundPath;
      }
    }
    return null;
  }

  Future<String?> _findSoundInDirectory(String path, String soundName) async {
    assert(isAbsolute(path), "$path is not absolute");
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return null;
    }
    await for (final entity in dir.list(followLinks: true)) {
      switch (entity.statSync().type) {
        case FileSystemEntityType.directory:
          final soundPath = await _findSoundInDirectory(entity.path, soundName);
          if (soundPath != null) {
            return soundPath;
          }
        case FileSystemEntityType.file:
          if ([".oga", ".ogg", "wav", "disable"].contains(entity.extension) &&
              soundName == entity.nameWithoutExtension) {
            return entity.path;
          }
        default:
          break;
      }
    }
    return null;
  }
}

Future<Map<String, _Theme>> _getThemes() async {
  final resp = <String, _Theme>{};

  for (final dir in _directories) {
    final entities = dir.list();
    await for (final entity in entities) {
      final themeName = entity.name;
      if (resp.containsKey(themeName)) {
        continue;
      }
      final theme = _Theme.fromPath(entity.path);
      if (theme != null) {
        resp[themeName] = theme;
      }
    }
  }

  return resp;
}

abstract final class SearchSound {
  static Future<String?> lookup(String name, [String themename = "freedesktop"]) async {
    final themes = await _getThemes();
    final theme = themes[themename] ?? themes["freedesktop"];
    if (theme == null) {
      return null;
    }
    final soundPath = await theme.findSound(name, themes);
    if (soundPath != null) {
      return soundPath;
    }
    if (themename != "freedesktop") {
      return themes["freedesktop"]?.findSound(name, themes);
    }
    return null;
  }
}
