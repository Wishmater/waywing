import "dart:async";
import "dart:convert";

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
  final NetworkManagerClient client;

  NetworkManagerService._() : client = NetworkManagerClient(), wifiDevicesValues = [];

  static registerService(RegisterServiceCallback registerService) {
    registerService<NetworkManagerService, dynamic>(
      ServiceRegistration(
        constructor: NetworkManagerService._,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await client.close();
  }

  @override
  Future<void> init() async {
    await client.connect();

    for (final device in client.devices) {
      if (device.deviceType == NetworkManagerDeviceType.wifi) {
        wifiDevicesValues.add(WifiDeviceValues(device));
      }
    }
    if (wifiDevicesValues.isEmpty) {
      throw UnimplementedError("TODO: handle when there is no wifi device");
    }
  }

  WifiDeviceValues getWifiDeviceValuesFirst() {
    return wifiDevicesValues[0];
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

class WifiDeviceValues {
  final NetworkManagerDevice device;
  NetworkManagerDeviceWireless get wirelessDevice => device.wireless!;

  WifiDeviceValues(this.device) {
    accessPoints = ValueNotifier(Slice(wirelessDevice.accessPoints));
    __accessPointsChangeNotifier = _accessPointsChangeNotifier();
    __accessPointsChangeNotifier.addListener(() => accessPoints.value = Slice(wirelessDevice.accessPoints));

    activeAccessPoint = ValueNotifier(wirelessDevice.activeAccessPoint);
    __activeAPChangeNotifier = _activeAccessPointChangeNotifier();
    __activeAPChangeNotifier.addListener(() => activeAccessPoint.value = wirelessDevice.activeAccessPoint);

    isScanning = ValueNotifier(false);
    __receieveLastScan = _recieveLastScan();
    __receieveLastScan.addListener(() => isScanning.value = false);
  }

  void dispose() {
    accessPoints.dispose();
    __accessPointsChangeNotifier.dispose();

    activeAccessPoint.dispose();
    __activeAPChangeNotifier.dispose();

    isScanning.dispose();
    __receieveLastScan.dispose();
  }

  late ValueNotifier<Slice<NetworkManagerAccessPoint>> accessPoints;
  late NMObjectChangeNotifier __accessPointsChangeNotifier;
  NMObjectChangeNotifier _accessPointsChangeNotifier() {
    return NMObjectChangeNotifier(wirelessDevice.propertiesChanged, {
      "AccessPoints": null,
      "LastScan": null,
      "ActiveAccessPoint": null,
    });
  }

  late ValueNotifier<NetworkManagerAccessPoint?> activeAccessPoint;
  late ChangeNotifier __activeAPChangeNotifier;
  ChangeNotifier _activeAccessPointChangeNotifier() {
    return NullableChangeNotifier(
      // This function will be called whenever the second param notifies
      () {
        if (wirelessDevice.activeAccessPoint != null) {
          return NMObjectChangeNotifier(wirelessDevice.activeAccessPoint!.propertiesChanged, {
            "Strength": null,
          });
        } else {
          return null;
        }
      },
      NMObjectChangeNotifier(wirelessDevice.propertiesChanged, {
        "ActiveAccessPoint": null,
      }),
    );
  }

  late ValueNotifier<bool> isScanning;
  late ChangeNotifier __receieveLastScan;
  ChangeNotifier _recieveLastScan() {
    return NMObjectChangeNotifier(wirelessDevice.propertiesChanged, {
      "LastScan": null,
    });
  }

  Future<void> requestScan() async {
    if (isScanning.value) {
      return;
    }
    isScanning.value = true;
    await wirelessDevice.requestScan();
  }
}

class NMObjectValueNotfier<T> extends ValueNotifier<T> {
  final ChangeNotifier notifier;

  NMObjectValueNotfier(super.value, this.notifier) {
    notifier.addListener(notifyListeners);
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }
}

/// class Utility to react to NMObject changedProperties stream
class NMObjectChangeNotifier extends BatchChangeNotifier {
  Stream<List<String>> stream;
  final Map<String, VoidCallback?> properties;
  late final StreamSubscription<List<String>> _subscription;
  Timer? _automaticNotifierTimer;

  NMObjectChangeNotifier(
    this.stream,
    this.properties, {
    Duration? automaticNotifier,
  }) {
    _subscription = stream.listen((propertiesChanged) {
      for (final changed in propertiesChanged) {
        if (properties.containsKey(changed)) {
          // instead of spamming notifyListener calls (which can be some what expensive)
          // use markAsDirty to allow BatchChangeNotifier to efficiently call notifyListener
          markAsDirty();
          final cb = properties[changed];
          if (cb != null) {
            cb();
          }
        }
      }
    });
    if (automaticNotifier != null) {
      _automaticNotifierTimer = Timer.periodic(automaticNotifier, (_) => markAsDirty());
    }
  }

  @override
  void dispose() {
    _automaticNotifierTimer?.cancel();
    _subscription.cancel().then((_) => super.dispose());
  }
}

class NullableChangeNotifier<T extends ChangeNotifier> with ChangeNotifier {
  T? _changeNotifier;

  final ChangeNotifier _notifyChangeNotifier;
  final T? Function() _getChangeNotifier;

  void _changeChangeNotifier() {
    final newChangeNotifier = _getChangeNotifier();
    if (newChangeNotifier != _changeNotifier) {
      _changeNotifier?.dispose();
      _changeNotifier = newChangeNotifier;

      notifyListeners();
      _changeNotifier?.addListener(notifyListeners);
    }
  }

  NullableChangeNotifier(this._getChangeNotifier, this._notifyChangeNotifier) {
    _changeNotifier = _getChangeNotifier();
    _changeNotifier?.addListener(notifyListeners);
    _notifyChangeNotifier.addListener(_changeChangeNotifier);
  }

  @override
  void dispose() {
    _changeNotifier?.dispose();
    _notifyChangeNotifier.dispose();
    super.dispose();
  }
}

/// Class to manage a nullable listener.
///
/// Owns the listener, which means that will dispose the previous listener on a change
class OwnedNullableListener<T extends ChangeNotifier> with ChangeNotifier {
  T? _listener;
  T? get listener => _listener;

  set listener(T? newListener) {
    if (_listener != newListener) {
      _listener?.dispose();
      _listener = newListener;
      notifyListeners();
      _listener?.addListener(notifyListeners);
    }
  }

  OwnedNullableListener(this._listener);

  @override
  void dispose() {
    listener?.dispose();
    super.dispose();
  }
}
