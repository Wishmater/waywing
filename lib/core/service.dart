import "package:flutter/foundation.dart";
import "package:tronco/tronco.dart";

/// A Service provides utility / protocol / API functions needed by Feathers.
/// Can be used by one or more feathers, serviceas are initialized and disposed
/// by the ServiceRegistry as needed by the currently active Feathers.
abstract class Service<Conf> {
  @protected
  late Logger logger;
  late Conf config;

  Future<void> init();

  Future<void> dispose();

  onConfigUpdated(Conf oldConfig) {}
}
