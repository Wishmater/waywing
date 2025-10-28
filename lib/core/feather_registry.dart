import "dart:math";

import "package:config/config.dart";
import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/app_launcher/launcher_feather.dart";
import "package:waywing/modules/aria2/aria2_feather.dart";
import "package:waywing/modules/bar/bar_wing.dart";
import "package:waywing/modules/battery/battery_feather.dart";
import "package:waywing/modules/bitwarden/bitwarden_feather.dart";
import "package:waywing/modules/clock/clock_feather.dart";
import "package:waywing/modules/command_palette/command_palette_feather.dart";
import "package:waywing/modules/container_wings/drawer.dart";
import "package:waywing/modules/container_wings/modal.dart";
import "package:waywing/modules/frame/frame_wing.dart";
import "package:waywing/modules/kb_layout/caps_lock_feather.dart";
import "package:waywing/modules/kb_layout/kb_layout_feather.dart";
import "package:waywing/modules/kb_layout/num_lock_feather.dart";
import "package:waywing/modules/menu/menu_wing.dart";
import "package:waywing/modules/nm/nm_feather.dart";
import "package:waywing/modules/notification/notification_wing.dart";
import "package:waywing/modules/session/session_feather.dart";
import "package:waywing/modules/system_tray/system_tray_feather.dart";
import "package:waywing/modules/util_feathers/divider.dart";
import "package:waywing/modules/util_feathers/spacer.dart";
import "package:waywing/modules/volume/volume_feather.dart";
import "package:waywing/modules/workspace_switcher/workspace_switcher_feather.dart";
import "package:waywing/util/logger.dart";

final featherRegistry = FeatherRegistry._();
final _logger = mainLogger.clone(properties: [LogType("FeatherRegistry")]);

typedef FeatherConstructor<T extends Feather> = T Function();

class FeatherRegistration<T extends Feather<Conf>, Conf> {
  final FeatherConstructor<T> constructor;
  final SchemaBuilder? schemaBuilder;
  final ConfigBuilder<Conf>? configBuilder;

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

  void registerFeather<T extends Feather<Conf>, Conf>(
    String name,
    FeatherRegistration<T, Conf> registration,
  ) {
    assert(!_registeredFeathers.containsKey(name), "Trying to register a Feather that already exists: $name");
    _registeredFeathers[name] = registration;
  }

  Map<Feather, dynamic> _feathersPendingConfigUpdate = {};
  Feather getFeatherInstance(
    String featherName,
    String uniqueId, [
    BlockData configOverrideBlock = const BlockData.constEmpty(),
  ]) {
    assert(_registeredFeathers.containsKey(featherName), "Trying to get an unknown Feather by name: $featherName");
    final registration = _registeredFeathers[featherName]!;
    var feather = _instancedFeathers[uniqueId];
    final alreadyExists = feather != null;
    if (!alreadyExists) {
      feather = registration.constructor();
      assert(
        feather.name == featherName,
        "The name exposed by a Feather (${feather.name}) is not the same name that was used to register said Feather ($featherName).",
      );
      feather.uniqueId = uniqueId;
      _instancedFeathers[uniqueId] = feather;
    }
    if (registration.configBuilder != null) {
      final dynamic newConfigBlock;
      final globalConfigBlock =
          mainConfig.featherDefaults?.dynamicSchemas.firstOrNullWhere((e) => e.$1 == feather!.name)?.$2 as BlockData?;
      if (globalConfigBlock == null) {
        newConfigBlock = configOverrideBlock;
      } else {
        newConfigBlock = configOverrideBlock.merge(globalConfigBlock);
      }
      final newConfig = registration.configBuilder!(newConfigBlock);
      if (alreadyExists) {
        _feathersPendingConfigUpdate[feather] = newConfig;
      } else {
        feather.config = newConfig;
      }
    }
    return feather;
  }

  // TODO: 3 SCOPING only ConfigWatcher should be able to call this
  /// Check all feathers currently in config against those already registered in this servcice.
  /// Dispose and remove those no longer in config; add and initialize new ones.
  void onConfigUpdated(BuildContext context) {
    _logger.debug("onConfigUpdated");
    final configFeathers = <Feather>[...mainConfig.wings];
    _logger.trace("getting all feathers from starting wings: ${listToString(configFeathers)}");
    _executePendingFeathersConfigUpdate();
    for (int i = 0; i < configFeathers.length; i++) {
      final feather = configFeathers[i];
      if (feather is Wing) {
        _logger.trace("addAll feathers from wing: $feather");
        configFeathers.addAll(feather.getFeathers());
        _executePendingFeathersConfigUpdate();
      }
    }
    _logger.trace(
      "got all feathers: ${listToString(configFeathers)}",
    );
    _logger.trace("initializing all feathers not in old config...");
    // we should init new feathers before disposing old ones, to prevent shared services from being dispose
    _initializeNewFeathersNotInOldConfig(context, configFeathers);
    _logger.trace("disposing all feathers not in new config...");
    _disposeOldFeathersNotInNewConfig(configFeathers);
    assert(
      !_instancedFeathers.values.any((e) => !_initializedFeathers.containsKey(e)),
      "After updating Feathers, there are still Feathers that were instanced but not initialized, this should never happen."
      " The following are the offending feathers: ${_instancedFeathers.values.where((e) => !_initializedFeathers.containsKey(e))}",
    );
  }

  Future<void> awaitInitialization(Feather feather) {
    return _initializedFeathers[feather]!;
  }

  Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> getDynamicFeathersSchemas({
    bool parseConfigs = false,
  }) {
    final response = <String, ({BlockSchema schema, dynamic Function(BlockData) from})>{};

    for (final entry in _registeredFeathers.entries) {
      if (entry.value.schemaBuilder != null) {
        final from = parseConfigs ? entry.value.configBuilder! : (e) => e;
        response[entry.key] = (schema: entry.value.schemaBuilder!(), from: from);
      } else {
        final from = parseConfigs ? EmptyConfig.fromMap : (e) => e;
        response[entry.key] = (schema: EmptyConfig.schema, from: from);
      }
    }

    return response;
  }

  void _executePendingFeathersConfigUpdate() {
    while (_feathersPendingConfigUpdate.isNotEmpty) {
      final currentDeathersPendingConfigUpdate = _feathersPendingConfigUpdate;
      _feathersPendingConfigUpdate = {};
      _logger.trace("executing config update on pending feathers: ${currentDeathersPendingConfigUpdate.keys}");
      for (final e in currentDeathersPendingConfigUpdate.entries) {
        final feather = e.key;
        final newConfig = e.value;
        final oldConfig = feather.config;
        feather.config = newConfig;
        feather.onConfigUpdated(oldConfig);
      }
    }
  }

  void _disposeOldFeathersNotInNewConfig(Iterable<Feather> configFeathers) {
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

  void _initializeNewFeathersNotInOldConfig(BuildContext context, Iterable<Feather> configFeathers) {
    for (final ne in configFeathers) {
      if (!_initializedFeathers.containsKey(ne)) {
        _initializeFeather(context, ne);
      }
    }
  }

  /// Adds the feather to the provided inner list, and to the all likst, and runs init() on it.
  /// Returns the Future from calling init() on the feather.
  Future<void> _initializeFeather(BuildContext context, Feather feather) async {
    _logger.debug("initializing feather $feather");
    assert(!_initializedFeathers.containsKey(feather), "Trying to add a feather that is already initialized");
    // ignore: invalid_use_of_protected_member
    feather.logger = mainLogger.clone(properties: [LogType(feather.uniqueId)]);
    // add feather routes actions
    if (feather.actions case final actions?) {
      // TODO: 1 router declarations don't react to config reload (modal)
      for (final entry in actions.entries) {
        WaywingServer.instance.router.register(
          join(feather.actionsPath, entry.key),
          entry.value,
        );
      }
    }
    final initFuture = feather.init(context);
    _initializedFeathers[feather] = initFuture;
    try {
      await initFuture;
    } catch (e, st) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      feather.logger.error(
        "Error thrown while initializing ${feather is Wing ? 'wing' : 'feather'} ${feather.name} (${feather.uniqueId})",
        error: e,
        stackTrace: e is ServiceInitializationError ? null : st,
      );
      feather.hasInitializationError = true;

      // TODO: 1 show error notification, and remove it when the feather is disposed
    }
    feather.isInitialized = true;
    _logger.trace("finished initializing feather $feather");
  }

  /// Adds the feather to the list and runs dispose() on it.
  /// Returns the Future from calling dispose() on the feather.
  Future<void> _disposeFeather(Feather feather) async {
    _logger.debug("disposing feather $feather");
    assert(_initializedFeathers.containsKey(feather), "Trying to remove a feather that is not in Feathers.all");
    _initializedFeathers.remove(feather);
    // remove feather routes
    if (feather.actions case final actions?) {
      for (final entry in actions.entries) {
        WaywingServer.instance.router.unregister(join(feather.actionsPath, entry.key));
      }
    }
    // de-reference the instance, so that a clean instance is built if the same Feather is re-added
    featherRegistry._dereferenceFeather(feather.uniqueId);
    await feather.dispose();
    _logger.trace("finished disposing feather $feather");
    await feather.logger.destroy(); // ignore: invalid_use_of_protected_member
    _logger.trace("finished destroying log for feather $feather");
  }

  void _dereferenceFeather(String uniqueId) {
    assert(
      _instancedFeathers.containsKey(uniqueId),
      "Trying to de-reference a Feather that is not currently built: $uniqueId",
    );
    final feather = _instancedFeathers.remove(uniqueId)!;
    serviceRegistry.onFeatherDereferenced(feather);
  }

  void _registerDefaultFeathers() {
    // Wings
    ModalWing.registerFeather(registerFeather);
    DrawerWing.registerFeather(registerFeather);
    BarWing.registerFeather(registerFeather);
    NotificationsWing.registerFeather(registerFeather);
    MenuWing.registerFeather(registerFeather);
    FrameWing.registerFeather(registerFeather);
    // Feathers
    SpacerFeather.registerFeather(registerFeather);
    DividerFeather.registerFeather(registerFeather);
    ClockFeather.registerFeather(registerFeather);
    SystemTrayFeather.registerFeather(registerFeather);
    NetworkManagerFeather.registerFeather(registerFeather);
    BatteryFeather.registerFeather(registerFeather);
    VolumeFeather.registerFeather(registerFeather);
    SessionFeather.registerFeather(registerFeather);
    KeyboardLayoutFeather.registerFeather(registerFeather);
    CapsLockFeather.registerFeather(registerFeather);
    NumLockFeather.registerFeather(registerFeather);
    WorkspaceSwitcherFeather.registerFeather(registerFeather);
    AppLauncherFeather.registerFeather(registerFeather);
    CommandPaletteFeather.registerFeather(registerFeather);
    Aria2Feather.registerFeather(registerFeather);
    BitwardenLauncherFeather.registerFeather(registerFeather);
  }
}

typedef RegisterFeatherCallback<T extends Feather<Conf>, Conf> =
    void Function(String name, FeatherRegistration<T, Conf> registration);
