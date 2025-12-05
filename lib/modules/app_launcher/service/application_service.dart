import "dart:io";

import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/app_launcher/service/database.dart";
import "package:waywing/modules/app_launcher/service/application.dart";
import "package:waywing/util/logger.dart" hide Filter;

class ApplicationService extends Service {
  ApplicationService._();

  LauncherDatabase? _db;

  static registerService(RegisterServiceCallback registerService) {
    registerService<ApplicationService, dynamic>(
      ServiceRegistration(
        constructor: ApplicationService._,
      ),
    );
  }

  @override
  Future<void> init() async {}

  Future<void> initDatbase(String path) async {
    try {
      _db ??= await LauncherDatabase.open(path);
      final _ = await _db!.getAll();
    } catch (e) {
      /// TODO 3: find a less aggressive way to solve compatibility issues in the app json encode
      /// as this will make waywing forget user history.
      logger.error(
        "Caugth error while opening database in path $path. Deleting database to restart the state",
        error: e,
      );
      // in case the throw was while opening the database
      if (_db == null) {
        File(path).deleteSync();
        _db ??= await LauncherDatabase.open(path);
      }
      await _db!.clean();
    }
  }

  Future<void> run(Application app, String? terminal) async {
    logger.debug("running app ${app.name}");
    _db!.increaseExecCounter(app);
    terminal ??= await _findTerminal();
    await app.run(logger: logger, terminal: terminal);
  }

  Future<List<Application>> applications() => loadApplications(_db!, logger);

  /// Match by desktop file name without the .desktop extension
  Future<Application?> fromDekstopName(String name) async {
    final savedApps = await _db!.getAll();
    for (final app in savedApps) {
      if (app.desktopFileName == name) {
        return app;
      }
    }
    return null;
  }

  @override
  Future<void> dispose() async {
    await _db?.close();
  }

  static const _terminals = <String>[
    "ghostty",
    "wezterm",
    "alacritty",
    "kitty",
    "gnome-terminal",
    "konsole",
  ];
  Future<String> _findTerminal() async {
    String? terminal = Platform.environment["TERMINAL"];
    if (terminal != null && terminal.isNotEmpty) return terminal;

    for (final terminal in _terminals) {
      final p = await Process.run("sh", ["-c", "command -v $terminal"]);
      if (p.exitCode == 0) {
        return terminal;
      }
    }

    throw "Terminal application not found";
  }
}

Future<List<Application>> loadApplications(LauncherDatabase db, Logger logger) async {
  final Iterable<Application> list = await db.getAll();

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
  apps.sort();
  return apps;
}
