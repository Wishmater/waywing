import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/application-launcher/database.dart";
import "package:waywing/modules/application-launcher/application.dart";

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
    _db ??= await LauncherDatabase.open(path);
  }

  Future<void> run(Application app) async {
    _db!.increaseExecCounter(app);
    app.run();
  }

  Future<List<Application>> applications() => loadApplications(_db!, logger);

  @override
  Future<void> dispose() async {
    await _db?.close();
  }
}
