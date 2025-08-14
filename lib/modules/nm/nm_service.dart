import "dart:async";
import "dart:convert";

import "package:dartx/dartx_io.dart";
import "package:dbus/dbus.dart";
import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:nm/nm.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/util/slice.dart";

class NetworkManagerService extends Service {
  List<WifiDeviceValues> wifiDevicesValues;
  List<EthernetDeviceValues> ethernetDevicesValues; // TODO this values can go off.. we need to handle this
  final NetworkManagerClient client;

  NetworkManagerService._() : client = NetworkManagerClient(), wifiDevicesValues = [], ethernetDevicesValues = [];

  static registerService(RegisterServiceCallback registerService) {
    registerService<NetworkManagerService, dynamic>(
      ServiceRegistration(
        constructor: NetworkManagerService._,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    for (final wifi in wifiDevicesValues) {
      wifi.dispose();
    }
    for (final ethernet in ethernetDevicesValues) {
      ethernet.dispose();
    }
    await client.close();
  }

  @override
  Future<void> init() async {
    await client.connect();

    for (final device in client.devices) {
      if (device.deviceType == NetworkManagerDeviceType.wifi) {
        wifiDevicesValues.add(WifiDeviceValues(device));
      } else if (device.deviceType == NetworkManagerDeviceType.ethernet) {
        ethernetDevicesValues.add(EthernetDeviceValues(device));
      }
    }
    if (wifiDevicesValues.isEmpty) {
      throw UnimplementedError("TODO: handle when there is no wifi device");
    }
  }

  WifiDeviceValues getWifiDeviceValuesFirst() {
    return wifiDevicesValues[0];
  }

  EthernetDeviceValues getEtherenetDeviceValuesFirst() {
    return ethernetDevicesValues[0];
  }

  Future<ConnectResponse> connect(
    NetworkManagerDevice device,
    NetworkManagerAccessPoint ap, {
    bool autoconnect = false,
    String? userPassword,
  }) async {
    final connAndSettings = await _searchForConnection(device, ap);
    if (connAndSettings != null) {
      var (conn, settings) = connAndSettings;
      logger.debug("Activating connection: ${device.interface} ${utf8.decode(ap.ssid)}");

      if (ap.rsnFlags.isNotEmpty) {
        final password = userPassword ?? await _getSavedWifiPsk(device, ap, conn, settings);
        if (password == null) {
          return ConnectResponse.needsPassword;
        }
        if (userPassword != null) {
          // if a user password was provided, update connection settings
          final securityField = _getSecurityField(settings);
          if (settings[securityField] == null) {
            throw StateError("Settings does not has a security field:\n$settings");
          }
          logger.trace("Updating connection settings\n$settings");
          settings[securityField]!["psk"] = DBusString(password);
          logger.trace("New connection settings\n$settings");
          await _updateConnectionAndWait(conn, settings);
          logger.trace("Connection settings after update\n${await conn.getSettings()}");
        }
      }
      try {
        await client.activateConnection(device: device, accessPoint: ap, connection: conn);
      } catch (e, st) {
        if (e.toString() == "Null check operator used on a null value") {
          logger.warning(
            "It seems there is a bug on the nm "
            "library, it throws a null check operator error and "
            "ignoring the error seems to be safe",
            error: e,
            stackTrace: st,
          );
        } else {
          logger.error("client.activateConnection", error: e, stackTrace: st);
        }
      }
    } else {
      logger.trace(
        "Creating ${ap.rsnFlags.isNotEmpty ? '' : 'and activating '}connection: ${device.interface} ${utf8.decode(ap.ssid)}",
      );
      await client.addAndActivateConnection(device: device, accessPoint: ap);
      if (ap.rsnFlags.isNotEmpty) {
        return ConnectResponse.needsPassword;
      }
    }
    return ConnectResponse.success;
  }

  Future<void> _updateConnectionAndWait(
    NetworkManagerSettingsConnection conn,
    Map<String, Map<String, DBusValue>> settings,
  ) async {
    await conn.update(settings);
  }

  String _getSecurityField(Map<String, Map<String, DBusValue>> settings) {
    final type = settings["connection"]?["type"];
    if (type == null) {
      throw StateError("Connection settings does not have a connection type: $settings");
    }
    final securityName = "${type.asString()}-security";
    return securityName;
  }

  Future<String?> _getSavedWifiPsk(
    NetworkManagerDevice device,
    NetworkManagerAccessPoint accessPoint,
    NetworkManagerSettingsConnection connSettings,
    Map<String, Map<String, DBusValue>> settings,
  ) async {
    final securityName = _getSecurityField(settings);
    Map<String, Map<String, DBusValue>> secrets;
    try {
      secrets = await connSettings.getSecrets(securityName);
    } on DBusMethodResponseException catch (e) {
      logger.debug("connSettings.getSecrets exception throw, assuming no secrets\n$e");
      return null;
    }
    if (secrets.isNotEmpty) {
      final security = secrets[securityName];
      if (security != null) {
        final psk = security["psk"]; // TODO could this be other value???
        if (psk != null) {
          return psk.toNative();
        }
      }
    }
    return null;
  }

  Future<(NetworkManagerSettingsConnection, Map<String, Map<String, DBusValue>>)?> _searchForConnection(
    NetworkManagerDevice device,
    NetworkManagerAccessPoint ap,
  ) async {
    final interface = DBusString(device.interface);
    final ssid = DBusString(utf8.decode(ap.ssid));
    for (final conn in client.settings.connections) {
      final settings = await conn.getSettings();
      final connSettings = settings["connection"];
      if (connSettings == null) {
        continue;
      }
      if (connSettings["id"] == ssid && connSettings["interface-name"] == interface) {
        return (conn, settings);
      }
    }
    return null;
  }

  Future<void> disconnect(NetworkManagerDevice device) async {
    logger.trace("Disconnecting device: ${device.interface}");
    await device.disconnect();
  }

  Future<void> requestScan(NetworkManagerDeviceWireless device) async {
    await device.requestScan();
  }
}

enum ConnectResponse {
  needsPassword,
  success,
}

class TxRxWatcher {
  final NetworkManagerDeviceStatistics statistics;
  int _prevTxBytes;
  final ValueNotifier<int> txBytes;
  int _prevRxBytes;
  final ValueNotifier<int> rxBytes;
  late final DerivedValueNotifier<double> txRate;
  late final DerivedValueNotifier<double> rxRate;

  // late final DerivedValueNotifier reactToAll;

  final Completer<void> _initRefreshRateMs;
  late int _refreshRateMs;
  late StreamSubscription _subscription;

  TxRxWatcher(this.statistics)
    : txBytes = ValueNotifier(statistics.txBytes),
      rxBytes = ValueNotifier(statistics.rxBytes),
      _prevTxBytes = statistics.txBytes,
      _prevRxBytes = statistics.rxBytes,
      _initRefreshRateMs = Completer();

  void _dispose() {
    txBytes.dispose();
    rxBytes.dispose();
    txRate.dispose();
    rxRate.dispose();
  }

  void dispose() {
    _subscription.cancel().then(
      (_) => _dispose(),
      onError: (e, st) {
        _dispose();
        mainLogger.log(
          // TODO we need to inject logger here instead of relaying on a hardcoded LogType
          Level.error,
          "error while canceling subscription to device statistic refreshRateMs",
          properties: [LogType("$NetworkManagerService")],
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  void init() {
    txRate = DerivedValueNotifier(
      dependencies: [txBytes],
      derive: () => (txBytes.value - _prevTxBytes).toDouble() / _refreshRateMs.toDouble(),
      defaultsTo: 0,
    );
    rxRate = DerivedValueNotifier(
      dependencies: [rxBytes],
      derive: () => (rxBytes.value - _prevRxBytes).toDouble() / _refreshRateMs.toDouble(),
      defaultsTo: 0,
    );

    if (statistics.refreshRateMs != 0) {
      _refreshRateMs = statistics.refreshRateMs;
      _initRefreshRateMs.complete();
    } else {
      statistics.setRefreshRateMs(1000).then((_) {
        _refreshRateMs = 1000;
        _initRefreshRateMs.complete();
      });
    }

    _subscription = statistics.propertiesChanged.listen((properties) {
      if (!_initRefreshRateMs.isCompleted) {
        return;
      }
      if (properties.contains("TxBytes")) {
        _prevTxBytes = txBytes.value;
        txBytes.value = statistics.txBytes;
      }
      if (properties.contains("RxBytes")) {
        _prevRxBytes = rxBytes.value;
        rxBytes.value = statistics.rxBytes;
      }
    });
  }
}

class AccessPointValues {
  final NetworkManagerAccessPoint accessPoint;

  AccessPointValues(this.accessPoint) : strength = _ValueNotifier(accessPoint.strength) {
    accessPoint.propertiesChanged.where((props) => props.contains("Strength")).listen((_) {
      strength.value = accessPoint.strength;
      (strength as _ValueNotifier)._markAsDirty();
    });
  }

  ValueNotifier<int> strength;

  void dispose() {
    strength.dispose();
  }
}

class WifiDeviceValues {
  final NetworkManagerDevice device;
  NetworkManagerDeviceWireless get wireless => device.wireless!;

  WifiDeviceValues(this.device) {
    accessPoints = ValueNotifier(Slice(wireless.accessPoints));
    wireless.propertiesChanged.listen((props) {
      if (props.containsAny(["AccessPoints"])) {
        accessPoints.value = Slice(wireless.accessPoints);
      }
    });

    activeAccessPoint = _ValueNotifier(wireless.activeAccessPoint);
    wireless.propertiesChanged.listen((props) {
      if (props.containsAny(["ActiveAccessPoint"])) {
        activeAccessPoint.value = wireless.activeAccessPoint;
      }
    });

    lastScan = ValueNotifier(wireless.lastScan);
    wireless.propertiesChanged.listen((props) {
      if (props.containsAny(["LastScan"])) {
        lastScan.value = wireless.lastScan;
      }
    });
  }

  late ValueNotifier<Slice<NetworkManagerAccessPoint>> accessPoints;

  late ValueNotifier<NetworkManagerAccessPoint?> activeAccessPoint;

  late ValueNotifier<int> lastScan;

  void dispose() {
    accessPoints.dispose();
    activeAccessPoint.dispose();
    lastScan.dispose();
  }
}

class EthernetDeviceValues {
  NetworkManagerDevice device;
  NetworkManagerDeviceWired get wiredDevice => device.wired!;

  /// Design speed of the device, in megabits/second (Mb/s).
  ///
  /// TODO: this needs testing connecting different cables to see how the update should work
  final int speed;

  final DBusProperyValueNotifier<bool> isConnected;

  EthernetDeviceValues(this.device)
    : speed = device.wired!.speed,
      isConnected = DBusProperyValueNotifier(
        value: device.interfaceFlags.contains(NetworkManagerDeviceInterfaceFlag.carrier),
        name: "InterfaceFlags",
        stream: device.propertiesChanged,
        callback: () => device.interfaceFlags.contains(NetworkManagerDeviceInterfaceFlag.carrier),
      );

  void dispose() {
    isConnected.dispose();
  }
}

class _ValueNotifier<T> extends ValueNotifier<T> {
  _ValueNotifier(super.value);

  void _markAsDirty() {
    notifyListeners();
  }
}
