import "dart:io";

import "package:tronco/tronco.dart";
import "package:sembast/sembast_io.dart";
import "package:waywing/modules/application-launcher/models/application.dart";
import "package:path/path.dart" as path;
import "package:waywing/util/logger.dart";
import "package:waywing/util/xdg_dirs.dart";

class LauncherDatabase {
  Database db;
  StoreRef<String, Map<String, Object?>> store;

  LauncherDatabase._(this.db, this.store);

  Future<void> close() async {
    await db.close();
  }

  static Future<LauncherDatabase> open(String path) async {
    final db = await databaseFactoryIo.openDatabase(path);
    return LauncherDatabase._(db, stringMapStoreFactory.store());
  }

  Future<List<Application>> getAll() async {
    final query = await store.find(db, finder: Finder());
    return query.map((e) => Application.fromJson(e.value)).toList();
  }

  Future<void> clean() async {
    await store.delete(db, finder: Finder());
  }

  Future<void> upsert(Application app) async {
    await store.record(app.name).put(db, app.toJson());
  }

  Future<void> increaseExecCounter(Application app) async {
    final obj = await store.record(app.name).get(db);
    if (obj == null) {
      return;
    }
    final dbapp = Application.fromJson(obj);
    dbapp.timesExec += 1;
    store.record(app.name).put(db, dbapp.toJson(), merge: true);
  }

  Future<void> saveAll(List<Application> apps) async {
    store.addAll(db, apps.map((e) => e.toJson()).toList());
    await store.records(apps.map((e) => e.name)).put(db, apps.map((e) => e.toJson()).toList());
  }
}

List<Application> loadApplicationsFromDisk(Map<String, Application> old, Logger logger) {
  final response = <Application>{};

  for (final dirPath in applicationDirectories) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      continue;
    }
    logger.trace("searching apps in ${dir.absolute}");
    for (final entry in dir.listSync(followLinks: true, recursive: true)) {
      if (entry is! File) {
        continue;
      }
      if (path.extension(entry.path) != ".desktop") {
        continue;
      }
      logger.trace("found possible app ${entry.absolute.path}");
      final oldApp = old[entry.absolute.path];

      /// if in cache check for lastModified. If lastModified is equal to file is a cache hit
      if (oldApp != null) {
        final oldLastModified = oldApp.lastModified;
        if (oldLastModified == (entry.statSync().modified)) {
          // in case of two apps having the same name, the freedesktop spec says the first one
          // is the valid one
          if (response.contains(oldApp)) {
            logger.warning("cache hit but found repetead application entry for ${response.lookup(oldApp)} : $oldApp");
            continue;
          }
          // check try exec
          if (oldApp.tryExec != null && !tryExec(oldApp.tryExec!)) {
            continue;
          }
          response.add(oldApp);
          continue;
        }
      }

      try {
        final app = Application.parseFromFile(entry);
        // in case of two apps having the same name, the freedesktop spec says the first one
        // is the valid one
        if (response.contains(app)) {
          logger.warning("found repetead application entry for ${response.lookup(app)} : $app");
          continue;
        }
        // check try exec
        if (app.tryExec != null && !tryExec(app.tryExec!)) {
          continue;
        }
        if (app.icon != null) {
          // futures.add(
          //   managerSearchIcon.run(app.icon!).then((value) => app.iconPath = value),
          // );
        }
        response.add(app);
      } on DesktopEntryInvalidStateException catch (e) {
        if (e.state == InvalidStateEnum.hidden) {
          logger.trace("desktop entry at ${entry.absolute.path} is hidden");
        } else {
          logger.warning("invalid desktop entry at ${entry.absolute.path}", error: e);
        }
      } on FileSystemException catch (e) {
        logger.error("file system error while reading entry at ${entry.absolute.path}", error: e);
      } catch (e, st) {
        logger.error("Exception while loading ${entry.absolute.path}", error: e, stackTrace: st);
      }
    }
  }
  return response.toList();
}

Future<List<Application>> loadApplications(LauncherDatabase db, Logger logger) async {
  final List<Application> list = await db.getAll();

  final aggreateLogger = logger.create(Level.trace, "Applications loaded from database");
  if (aggreateLogger != null) {
    for (final app in list) {
      aggreateLogger.add(app.toString());
    }
    aggreateLogger.end();
  }

  final map = Map.fromEntries(list.map((e) => MapEntry(e.filepath, e)));
  final apps = loadApplicationsFromDisk(map, logger);
  for (final app in apps) {
    final old = map[app.filepath];
    if (old != null && old.lastModified == app.lastModified) {
      continue;
    }
    logger.log(Level.trace, "new application found $app");
    db.upsert(app);
  }
  return _orderApps(apps, logger);
}

List<Application> _orderApps(List<Application> apps, Logger logger) {
  Map<String, Application> seenBefore = {};
  List<Application> response = [];

  int searchIndex(int timesExec) {
    int index = 0;
    for (final responseApp in response) {
      if (timesExec > responseApp.timesExec) {
        return index;
      }
      index++;
    }
    return -1;
  }

  for (final app in apps) {
    if (seenBefore.containsKey(app.name)) {
      logger.error("duplicated application error ${seenBefore[app.name]} - $app");
    } else {
      seenBefore[app.name] = app;
    }

    final index = searchIndex(app.timesExec);
    if (index == -1) {
      response.add(app);
    } else {
      response.insert(index, app);
    }
  }
  return response;
}

bool tryExec(String tryExec) {
  if (path.isAbsolute(tryExec)) {
    final file = File(tryExec);
    if (!file.existsSync()) {
      return false;
    }
    return file.statSync().mode & 256 != 0;
  }
  for (final dir in pathDirectories) {
    final file = File(path.join(dir, tryExec));
    if (file.existsSync()) {
      return file.statSync().mode & 256 != 0;
    }
  }
  return false;
}

/// Returns all potential directories where desktop entries might reside.
/// Some directories might not exist.
Iterable<String> get applicationDirectories => dataDirectories.map((dir) => path.join(dir, "applications"));
