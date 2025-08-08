import "package:waywing/core/feather.dart";
import "package:waywing/core/service.dart";
import "package:waywing/modules/clock/time_service.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/modules/system_tray/system_tray_service.dart";
import "package:waywing/util/logger.dart";

final serviceRegistry = ServiceRegistry._();

typedef ServiceConstructor<T extends Service> = T Function();

/// FeatherRegistry keeps track of all feather types and can map name strings to instances
/// this also makes sure that only one instance of each Feather is constructed,
/// and that it is de-referenced when disposing it
class ServiceRegistry {
  ServiceRegistry._() {
    _registerDefaultServices();
  }

  final Map<Type, ServiceConstructor> _registeredServices = {};
  final Map<Type, List<Feather>> _requestedServices = {};
  final Map<Type, Future<Service>> _initializedServices = {};

  void registerService<T extends Service>(ServiceConstructor<T> constructor) {
    final serviceType = T;
    assert(
      !_registeredServices.containsKey(serviceType),
      "Trying to register a Feather that already exists: $serviceType",
    );
    _registeredServices[serviceType] = constructor;
  }

  /// Feathers usually want to call this in their init method, await it,
  /// and keep the instance to then use in their widgets.
  /// Feather widgets aren't built until the feather init() is done, so if the
  /// feather init() awaits services requests, it will then be safe to use the
  /// returned instances in the build methods.
  Future<T> requestService<T extends Service>(Feather feather) async {
    final serviceType = T;
    final existingService = _initializedServices[serviceType];
    if (existingService != null) {
      return existingService as Future<T>;
    } else {
      assert(
        _registeredServices.containsKey(serviceType),
        "Trying to request a Service that isn't registered: $serviceType",
      );
      final initFuture = initializeService<T>();
      _initializedServices[serviceType] = initFuture;
      return initFuture;
    }
  }

  Future<T> initializeService<T extends Service>() async {
    final serviceType = T;
    final service = _registeredServices[serviceType]!() as T;
    service.logger = mainLogger.clone(properties: [LogType("$serviceType")]);
    await service.init();
    return service;
  }

  /// Feathers don't need to call this on dispose(), because disposed feathers
  /// are autommatically released of all requested services. The methot only exists
  /// for feathers that want to request/release services for a portion of the feather's
  /// lifetime, which should be rare.
  Future<void> releaseService(Feather feather, Type serviceType) async {
    assert(
      _requestedServices.containsKey(serviceType),
      "Trying to release a service that hasn't been requested by any feather: $serviceType $feather",
    );
    assert(
      _requestedServices[serviceType]!.contains(feather),
      "Trying to release a service that hasn't been requested by this feather: $serviceType $feather",
    );
    return _releaseService(feather, serviceType);
  }

  Future<void> _releaseService(Feather feather, Type serviceType) async {
    final dependentFeathers = _requestedServices[serviceType]!;
    final removed = dependentFeathers.remove(feather);
    if (removed && dependentFeathers.isEmpty) {
      _disposeService(serviceType);
    }
  }

  Future<void> _disposeService(Type serviceType) async {
    assert(
      _initializedServices.containsKey(serviceType),
      "Trying to dereference a Service that hasn't been initialized: $serviceType",
    );
    final service = await _initializedServices.remove(serviceType)!;
    return service.dispose();
  }

  // TODO: 3 only FeatherRegistry should be able to access this
  Future<void> onFeatherDereferenced(Feather feather) async {
    final futures = <Future<void>>[];
    for (final service in _requestedServices.keys) {
      futures.add(_releaseService(feather, service));
    }
    await Future.wait(futures);
  }

  void _registerDefaultServices() {
    TimeService.registerService(registerService);
    SystemTrayService.registerService(registerService);
    NetworkManagerService.registerService(registerService);
  }
}

typedef RegisterServiceCallback = void Function<T extends Service>(ServiceConstructor<T> constructor);
