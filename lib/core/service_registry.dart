import "package:config/config.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/service.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/modules/clock/time_service.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/modules/nm/service/nm_service.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/session/os_info_service.dart";
import "package:waywing/modules/session/session_service.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/util/logger.dart";

final serviceRegistry = ServiceRegistry._();

typedef ServiceConstructor<T extends Service> = T Function();

class ServiceRegistration<T extends Service<Conf>, Conf> {
  final ServiceConstructor<T> constructor;
  final SchemaBuilder? schemaBuilder;
  final ConfigBuilder? configBuilder;

  ServiceRegistration({
    required this.constructor,
    this.schemaBuilder,
    this.configBuilder,
  }) : assert(schemaBuilder == null && configBuilder == null || schemaBuilder != null && configBuilder != null);
}

/// FeatherRegistry keeps track of all feather types and can map name strings to instances
/// this also makes sure that only one instance of each Feather is constructed,
/// and that it is de-referenced when disposing it
class ServiceRegistry {
  ServiceRegistry._() {
    _registerDefaultServices();
  }

  final Map<Type, ServiceRegistration> _registeredServices = {};
  final Map<Type, List<Feather>> _requestedServices = {};
  final Map<Type, Future<Service>> _initializedServices = {};

  void registerService<T extends Service<Conf>, Conf>(ServiceRegistration<T, Conf> registration) {
    final serviceType = T;
    assert(
      !_registeredServices.containsKey(serviceType),
      "Trying to register a Feather that already exists: $serviceType",
    );
    _registeredServices[serviceType] = registration;
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
    final registration = _registeredServices[serviceType]!;
    final service = registration.constructor() as T;
    // ignore: invalid_use_of_protected_member
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

  Map<String, TableSchema> getSchemaTables() => {
    for (final e in _registeredServices.entries)
      if (e.value.schemaBuilder != null) e.key.toString(): e.value.schemaBuilder!(),
  };

  void onConfigUpdated() {
    for (final e in _initializedServices.entries) {
      final registration = _registeredServices[e.key]!;
      if (registration.configBuilder == null) continue;
      e.value.then((service) {
        final oldConfig = service.config;
        final newConfig = registration.configBuilder!(rawMainConfig[e.key.toString()]);
        service.config = newConfig;
        service.onConfigUpdated(oldConfig);
      });
    }
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
    await service.dispose();
    // ignore: invalid_use_of_protected_member
    await service.logger.destroy();
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
    BatteryService.registerService(registerService);
    VolumeService.registerService(registerService);
    SessionService.registerService(registerService);
    OsInfoService.registerService(registerService);
    NotificationService.registerService(registerService);
    KeyboardLayoutService.registerService(registerService);
  }
}

typedef RegisterServiceCallback =
    void Function<T extends Service<Conf>, Conf>(ServiceRegistration<T, Conf> constructor);
