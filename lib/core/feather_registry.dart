import "package:config/config.dart";
import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/battery/battery_feather.dart";
import "package:waywing/modules/clock/clock_feather.dart";
import "package:waywing/modules/nm/nm_feather.dart";
import "package:waywing/modules/system_tray/system_tray_feather.dart";
import "package:waywing/modules/volume/volume_feather.dart";
import "package:waywing/util/logger.dart";

final featherRegistry = FeatherRegistry._();

typedef FeatherConstructor<T extends Feather> = T Function();

class FeatherRegistration<T extends Feather<Conf>, Conf> {
  final FeatherConstructor<T> constructor;
  final SchemaBuilder? schemaBuilder;
  final ConfigBuilder? configBuilder;

  FeatherRegistration({
    required this.constructor,
    this.schemaBuilder,
    this.configBuilder,
  }) : assert(schemaBuilder == null && configBuilder == null || schemaBuilder != null && configBuilder != null);
}

/// FeatherRegistry keeps track of all feather types and can map name strings to instances
/// this also makes sure that only one instance of each Feather is constructed,
/// and that it is de-referenced when disposing it
class FeatherRegistry {
  FeatherRegistry._() {
    _registerDefaultFeathers();
  }

  final Map<String, FeatherRegistration> _registeredFeathers = {};
  final Map<String, Feather> _instancedFeathers = {};
  final Map<Feather, Future<void>> _initializedFeathers = {};

  void registerFeather<T extends Feather<Conf>, Conf>(String name, FeatherRegistration<T, Conf> registration) {
    assert(!_registeredFeathers.containsKey(name), "Trying to register a Feather that already exists: $name");
    _registeredFeathers[name] = registration;
  }

  // TODO: 3 only Config should be able to access this
  Feather getFeatherByName(String name) {
    var feather = _instancedFeathers[name];
    if (feather == null) {
      assert(_registeredFeathers.containsKey(name), "Trying to get an unknown Feather by name: $name");
      final registration = _registeredFeathers[name]!;
      feather = registration.constructor();
      assert(
        feather.name == name,
        "The name exposed by a Feather (${feather.name}) is not the same name that was used to register said Feather ($name).",
      );
      _instancedFeathers[name] = feather;
    }
    return feather;
  }

  // TODO: 3 only ConfigWatcher should be able to call this
  /// Check all feathers currently in config against those already registered in this servcice.
  /// Dispose and remove those no longer in config; add and initialize new ones.
  void onConfigUpdated(BuildContext context) {
    // TODO: 2 this should crawl around config and get all feathers (somehow)
    final configFeathers = <Feather>{...config.barStartFeathers, ...config.barCenterFeathers, ...config.barEndFeathers};
    _updateFeathers(context, configFeathers);
  }

  Future<void> awaitInitialization(Feather feather) {
    return _initializedFeathers[feather]!;
  }

  Map<String, TableSchema> getSchemaTables() => {
    for (final e in _registeredFeathers.entries)
      if (e.value.schemaBuilder != null) e.key: e.value.schemaBuilder!(),
  };

  void _updateFeathers(BuildContext context, Iterable<Feather> configFeathers) {
    _removeOldFeathersNotInNewConfig(configFeathers);
    _updateFeathersConfig();
    _addNewFeathersNotInOldConfig(context, configFeathers);
    assert(
      !_instancedFeathers.values.any((e) => !_initializedFeathers.containsKey(e)),
      "After updating Feathers, there are still Feathers that were instanced but not initialized, this should never happen.",
    );
  }

  void _removeOldFeathersNotInNewConfig(Iterable<Feather> configFeathers) {
    final toRemove = <Feather>[]; // hack to avoid concurrent modification error
    for (final old in _initializedFeathers.keys) {
      if (!configFeathers.contains(old)) {
        toRemove.add(old);
      }
    }
    for (final e in toRemove) {
      _disposeFeather(e);
    }
  }

  void _updateFeathersConfig() {
    for (final e in _initializedFeathers.keys) {
      final registration = _registeredFeathers[e.name]!;
      if (registration.configBuilder == null) continue;
      final oldConfig = e.config;
      final newConfig = registration.configBuilder!(rawMainConfig[e.name]);
      e.config = newConfig;
      e.onConfigUpdated(oldConfig);
    }
  }

  void _addNewFeathersNotInOldConfig(BuildContext context, Iterable<Feather> configFeathers) {
    for (final ne in configFeathers) {
      if (!_initializedFeathers.containsKey(ne)) {
        _initializeFeather(context, ne);
      }
    }
  }

  // TODO: 2 find a modular way to have multiple "containers" (Wings?).
  // Bar is an example of a Wing, there could be others like a Widgets panel or an OSD.
  // Each Wing needs to manage its Feathers and its config (somehow).
  // Feathers probably also need to still be added to the global Feathers service for init/dispose control.

  /// Adds the feather to the provided inner list, and to the all likst, and runs init() on it.
  /// Returns the Future from calling init() on the feather.
  Future<void> _initializeFeather(BuildContext context, Feather feather) async {
    assert(!_initializedFeathers.containsKey(feather), "Trying to add a feather that is already in Feathers.all");
    // ignore: invalid_use_of_protected_member
    feather.logger = mainLogger.clone(properties: [LogType(feather.name)]);
    final registration = _registeredFeathers[feather.name]!;
    if (registration.configBuilder != null) {
      feather.config = registration.configBuilder!(rawMainConfig[feather.name]);
    }
    final initFuture = feather.init(context);
    _initializedFeathers[feather] = initFuture;
    return initFuture;
  }

  /// Adds the feather to the list and runs dispose() on it.
  /// Returns the Future from calling dispose() on the feather.
  Future<void> _disposeFeather(Feather feather) async {
    assert(_initializedFeathers.containsKey(feather), "Trying to remove a feather that is not in Feathers.all");
    _initializedFeathers.remove(feather);
    // de-reference the instance, so that a clean instance is built if the same Feather is re-added
    featherRegistry._dereferenceFeather(feather.name);
    await feather.dispose();
    // ignore: invalid_use_of_protected_member
    await feather.logger.destroy();
  }

  void _dereferenceFeather(String name) {
    assert(_instancedFeathers.containsKey(name), "Trying to de-reference a Feather that is not currently built: $name");
    final feather = _instancedFeathers.remove(name)!;
    serviceRegistry.onFeatherDereferenced(feather);
  }

  void _registerDefaultFeathers() {
    ClockFeather.registerFeather(registerFeather);
    SystemTrayFeather.registerFeather(registerFeather);
    NetworkManagerFeather.registerFeather(registerFeather);
    BatteryFeather.registerFeather(registerFeather);
    VolumeFeather.registerFeather(registerFeather);
  }
}

typedef RegisterFeatherCallback = void Function(String name, FeatherRegistration registration);
