import "dart:io";

import "package:flutter/foundation.dart";
import "package:tronco/tronco.dart";
import "package:path/path.dart" as path;
import "package:waywing/core/config.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/service_registry.dart";

/// A Service provides utility / protocol / API functions needed by Feathers.
/// Can be used by one or more feathers, serviceas are initialized and disposed
/// by the ServiceRegistry as needed by the currently active Feathers.
abstract class Service<Conf> implements ServiceConsumer {
  @visibleForTesting
  @protected
  late Logger logger;
  late Conf config;

  Directory? _dataDir;

  /// Service directory where any kind of runtime data can be set
  Directory get dataDir {
    if (_dataDir == null) {
      _dataDir = Directory(path.join(mainDataHomeDir.path, "service", runtimeType.toString()));
      _dataDir!.createSync(recursive: true);
    }
    return _dataDir!;
  }

  Map<String, WaywingAction>? get actions => null;

  bool isInitialized = false;
  bool hasInitializationError = false;
  Future<void> init();

  Future<void> dispose();

  onConfigUpdated(Conf oldConfig) {}
}
