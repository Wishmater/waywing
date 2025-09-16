import "dart:async";
import "dart:convert";

import "package:dartx/dartx.dart";
import "package:dbus/dbus.dart";
import "package:flutter/foundation.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:nm/nm.dart";
import "package:waywing/modules/nm/service/nm_connection_settings.dart";
import "package:waywing/util/dbus_utils.dart";
import "package:waywing/util/derived_value_notifier.dart";

class NetworkManagerService extends Service {
  late final NetworkManagerClient _client;
  late final NMServiceDevices devices;

  NetworkManagerService._();

  static registerService(RegisterServiceCallback registerService) {
    registerService<NetworkManagerService, dynamic>(
      ServiceRegistration(
        constructor: NetworkManagerService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    _client = NetworkManagerClient();
    await _client.connect();
    devices = NMServiceDevices(_client, logger);
    await devices.init();
  }

  @override
  Future<void> dispose() async {
    await devices.dispose();
    await _client.close();
  }
}

class NMServiceDevices extends ChangeNotifier implements ValueListenable<List<NMServiceDevice>> {
  @override
  final List<NMServiceDevice> value = [];

  final NetworkManagerClient _client;
  final Logger _logger;
  NMServiceDevices(this._client, this._logger);

  late StreamSubscription _deviceAddedSubscription;
  late StreamSubscription _deviceRemovedSubscription;

  Future<void> init() async {
    for (final e in _client.devices) {
      if (e.activeConnection?.id == "lo") continue; // ignore loopback interface
      value.add(NMServiceDevice.build(_client, e, _logger));
    }
    _deviceAddedSubscription = _client.deviceAdded.listen((e) async {
      _logger.debug("added device: ${e.deviceType} ${e.path}");
      final device = NMServiceDevice.build(_client, e, _logger);
      await device.init();
      value.add(device);
      notifyListeners();
    });
    _deviceRemovedSubscription = _client.deviceRemoved.listen((e) {
      _logger.debug("removed device: ${e.deviceType} ${e.path}");
      value.removeWhere((v) => v._device == e);
      notifyListeners();
    });
    await Future.wait(value.map((e) => e.init()));
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    for (final e in value) {
      e.dispose();
    }
    await Future.wait([
      _deviceAddedSubscription.cancel(),
      _deviceRemovedSubscription.cancel(),
    ]);
  }
}

class NMServiceDevice {
  ValueListenable<NetworkManagerActiveConnection?> get activeConnection => _activeConnection;
  late final ValueListenable<NetworkManagerActiveConnection?> _activeConnection;

  ValueListenable<String?> get activeConnectionName => _activeConnectionName;
  late final ValueListenable<String?> _activeConnectionName;

  ValueListenable<bool> get isConnected => _isConnected;
  late final DerivedValueNotifier<bool> _isConnected;

  ValueListenable<int?> get txBytes => _txBytes;
  late final DBusPropertyValueNotifier<int?> _txBytes;

  ValueListenable<int?> get rxBytes => _rxBytes;
  late final DBusPropertyValueNotifier<int?> _rxBytes;

  ValueListenable<double?> get txRate => _txRate;
  late final DerivedValueNotifier<double?> _txRate;

  ValueListenable<double?> get rxRate => _rxRate;
  late final DerivedValueNotifier<double?> _rxRate;

  NetworkManagerDeviceType get deviceType => _device.deviceType;
  String get path => _device.path;

  final NetworkManagerClient _client;
  final NetworkManagerDevice _device;
  final Logger _logger;
  NMServiceDevice(this._client, this._device, this._logger);

  factory NMServiceDevice.build(NetworkManagerClient client, NetworkManagerDevice device, Logger logger) {
    if (device.deviceType == NetworkManagerDeviceType.wifi) {
      return NMServiceWifiDevice(client, device, logger);
    }
    return NMServiceDevice(client, device, logger);
  }

  int? _prevTxBytes;
  int? _prevRxBytes;

  @mustCallSuper
  Future<void> init() async {
    if (_device.statistics?.refreshRateMs == 0) {
      // TODO: 2 NM should we expose statistics refreshRateMs as an option?
      await _device.statistics!.setRefreshRateMs(1000);
    }

    _activeConnection = DBusPropertyValueNotifier(
      name: "ActiveConnection",
      stream: _device.propertiesChanged,
      callback: () => _device.activeConnection,
    );
    _isConnected = DerivedValueNotifier(
      dependencies: [_activeConnection],
      derive: () => _activeConnection.value != null,
    );
    initActiveConnectionName();

    // TODO: 3 can "Statistics" object change, which means we would need to re-init this (or update the stream in the notifier)
    _txBytes = DBusPropertyValueNotifier(
      name: "TxBytes",
      stream: _device.statistics?.propertiesChanged,
      callback: () => _device.statistics?.txBytes,
    );
    _rxBytes = DBusPropertyValueNotifier(
      name: "RxBytes",
      stream: _device.statistics?.propertiesChanged,
      callback: () => _device.statistics?.rxBytes,
    );

    _txRate = DerivedValueNotifier(
      dependencies: [_txBytes],
      derive: () {
        final prevTxBytes = _prevTxBytes;
        _prevTxBytes = _txBytes.value;
        if (prevTxBytes == null) return null;
        final txBytes = _txBytes.value;
        if (txBytes == null) return null;
        final refreshRateMs = _device.statistics?.refreshRateMs;
        if (refreshRateMs == null) return null;
        return (txBytes - prevTxBytes) / (refreshRateMs / 1000);
      },
    );
    _rxRate = DerivedValueNotifier(
      dependencies: [_rxBytes],
      derive: () {
        final prevRxBytes = _prevRxBytes;
        _prevRxBytes = _rxBytes.value;
        if (prevRxBytes == null) return null;
        final rxBytes = _rxBytes.value;
        if (rxBytes == null) return null;
        final refreshRateMs = _device.statistics?.refreshRateMs;
        if (refreshRateMs == null) return null;
        return (rxBytes - prevRxBytes) / (refreshRateMs / 1000);
      },
    );
  }

  void initActiveConnectionName() {
    _activeConnectionName = DerivedValueNotifier(
      dependencies: [_activeConnection],
      derive: () => _activeConnection.value?.id,
    );
  }

  @mustCallSuper
  void dispose() {
    _txBytes.dispose();
    _rxBytes.dispose();
    _txRate.dispose();
    _rxRate.dispose();
  }
}

extension on Iterable<NetworkManagerAccessPoint> {
  Iterable<NetworkManagerAccessPoint> removeHidden() sync* {
    for (final e in this) {
      if (e.ssid.isNotEmpty) {
        yield e;
      }
    }
  }

  Iterable<NetworkManagerAccessPoint> removeInvalidUtf8Ssid() sync* {
    for (final e in this) {
      try {
        utf8.decode(e.ssid);
        yield e;
      } catch (_) {}
    }
  }

  Iterable<NetworkManagerAccessPoint> removeDuplicated(NetworkManagerAccessPoint? currentConnection) sync* {
    final state = <_RemoveDuplicatedElement>{};
    int index = -1;
    final list = toList();
    for (final e in list) {
      index++;

      final element = _RemoveDuplicatedElement(e.ssid, index);
      if (e.hwAddress == currentConnection?.hwAddress) {
        state.add(element);
        continue;
      }

      if (!state.contains(element)) {
        state.add(element);
        continue;
      }

      final prev = list[state.lookup(element)!.index];
      if (prev.hwAddress == currentConnection?.hwAddress) {
        continue;
      }

      final prevRank = _rankAccessPoint(prev);
      final newRank = _rankAccessPoint(e);
      if (newRank > prevRank) {
        state.add(element);
      }
    }

    for (final e in state) {
      yield list[e.index];
    }
  }
}

double _rankAccessPoint(NetworkManagerAccessPoint accessPoint) {
  /// TODO 2 prioritize previously connected accessPoint (use BSSID to identify)
  return accessPoint.maxBitrate * (accessPoint.strength / 100);
}

class _RemoveDuplicatedElement {
  List<int> ssid;
  int index;
  _RemoveDuplicatedElement(this.ssid, this.index);

  @override
  bool operator ==(covariant _RemoveDuplicatedElement other) {
    if (identical(ssid, other.ssid)) {
      return true;
    }
    if (ssid.length != other.ssid.length) {
      return false;
    }
    for (int i = 0; i < ssid.length; i++) {
      if (ssid[i] != other.ssid[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(ssid);
}

class NMServiceWifiDevice extends NMServiceDevice {
  ValueListenable<List<NMServiceAccessPoint>> get accessPoints => _accessPoints;
  late final DBusPropertyValueNotifier<List<NMServiceAccessPoint>> _accessPoints;

  ValueListenable<NMServiceAccessPoint?> get activeAccessPoint => _activeAccessPoint;
  late final DBusPropertyValueNotifier<NMServiceAccessPoint?> _activeAccessPoint;

  ValueListenable<int> get lastScan => _lastScan;
  late final DBusPropertyValueNotifier<int> _lastScan;

  ValueListenable<bool> get wirelessEnabled => _wirelessEnabled;
  late final DBusPropertyValueNotifier<bool> _wirelessEnabled;

  NMServiceWifiDevice(super._client, super._device, super._logger);

  @override
  Future<void> init() async {
    await super.init();
    _activeAccessPoint = DBusPropertyValueNotifier(
      name: "ActiveAccessPoint",
      stream: _device.wireless!.propertiesChanged,
      callback: () {
        if (_device.wireless!.activeAccessPoint == null) return null;
        final result = NMServiceAccessPoint(_device.wireless!.activeAccessPoint!);
        result.init();
        return result;
      },
    );
    _initActiveConnectionName();
    // TODO: 3 is probably that there is a leak here because the previous NMServiceAccessPoint
    // did not dispose when changed (same in _activeAccessPoint)
    _accessPoints = DBusPropertyValueNotifier(
      name: "AccessPoints",
      stream: _device.wireless!.propertiesChanged,
      callback: () => _device.wireless!.accessPoints
          .removeHidden()
          .removeInvalidUtf8Ssid()
          .removeDuplicated(_device.wireless!.activeAccessPoint)
          .map((e) {
            final result = NMServiceAccessPoint(e);
            result.init();
            return result;
          })
          .sortedByDescending((e) => e._accessPoint.strength)
          .toList(),
    );
    _lastScan = DBusPropertyValueNotifier(
      name: "LastScan",
      stream: _device.wireless!.propertiesChanged,
      callback: () => _device.wireless!.lastScan,
    );
    _wirelessEnabled = DBusPropertyValueNotifier(
      name: "WirelessEnabled",
      stream: _client.propertiesChanged,
      callback: () => _client.wirelessEnabled,
    );
  }

  @override
  void initActiveConnectionName() {}
  void _initActiveConnectionName() {
    // hack to manually run this at the END of init, because it depends on other notifiers
    _activeConnectionName = DerivedValueNotifier(
      dependencies: [_activeConnection, _activeAccessPoint],
      derive: () {
        if (_activeConnection.value == null) return null;
        return _activeAccessPoint.value?.ssid ?? _activeConnection.value!.id;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _activeAccessPoint.dispose();
    _accessPoints.dispose();
    _lastScan.dispose();
    _wirelessEnabled.dispose();
  }

  Future<void> requestScan() async {
    await _device.wireless!.requestScan();
  }

  Future<void> awaitScan() async {
    final completer = Completer();
    listener() => completer.complete();
    lastScan.addListener(listener);
    await completer.future;
    lastScan.removeListener(listener);
  }

  Future<void> setWirelessEnabled(bool enabled) async {
    await _client.setWirelessEnabled(enabled);
  }

  Future<void> disconnect() async {
    _logger.trace("Disconnecting device: ${_device.interface}");
    await _device.disconnect();
  }

  Future<ConnectResponse> _activateConnection(
    NetworkManagerSettingsConnection conn,
    Map<String, Map<String, DBusValue>> settings,
    NMServiceAccessPoint ap,
    String? userPassword,
  ) async {
    _logger.debug(
      "Activating connection: inferface: ${_device.interface} ssid: ${utf8.decode(ap._accessPoint.ssid)}",
    );

    if (ap._accessPoint.rsnFlags.isNotEmpty) {
      final password = userPassword ?? await _getSavedWifiPsk(_device, ap._accessPoint, conn, settings);
      if (password == null) {
        return ConnectResponse.needsPassword;
      }
      if (userPassword != null) {
        // if a user password was provided, update connection settings
        final securityField = _getSecurityField(settings);
        if (settings[securityField] == null) {
          throw StateError("Settings does not has a security field:\n$settings");
        }
        _logger.trace("Updating connection settings\n$settings");
        settings[securityField]!["psk"] = DBusString(password);
        _logger.trace("New connection settings\n$settings");
        await _updateConnectionAndWait(conn, settings);
        _logger.trace("Connection settings after update\n${await conn.getSettings()}");
      }
    }
    try {
      await _client.activateConnection(device: _device, accessPoint: ap._accessPoint, connection: conn);
    } catch (e, st) {
      if (e.toString() == "Null check operator used on a null value") {
        _logger.warning(
          "It seems there is a bug on the nm "
          "library, it throws a null check operator error and "
          "ignoring the error seems to be safe",
          error: e,
          stackTrace: st,
        );
      } else {
        _logger.error("client.activateConnection", error: e, stackTrace: st);
        return ConnectResponse.unknownError;
      }
    }
    return ConnectResponse.success;
  }

  Future<ConnectResponse> _createConnection(NMServiceAccessPoint ap, String? userPassword, bool? autoconnect) async {
    assert(ap._accessPoint.rsnFlags.isEmpty || userPassword != null);
    _logger.trace(
      "Creating and activating connection: ${_device.interface} ${utf8.decode(ap._accessPoint.ssid)}",
    );
    final settings = createSettings(ap._accessPoint, _device, password: userPassword, autoconnect: autoconnect);
    _logger.trace("New connection: $settings");
    await _client.addAndActivateConnection(
      device: _device,
      accessPoint: ap._accessPoint,
      connection: settings,
    );
    return ConnectResponse.success;
  }

  Future<ConnectResponse> connect(
    NMServiceAccessPoint ap, {
    bool? autoconnect,
    String? userPassword,
  }) async {
    final connAndSettings = await _searchForConnection(_device, ap._accessPoint);
    if (connAndSettings != null) {
      // activate exisiting connection
      return _activateConnection(connAndSettings.$1, connAndSettings.$2, ap, userPassword);
    } else {
      // creating and activate a new connection
      if (ap._accessPoint.rsnFlags.isNotEmpty && userPassword == null) {
        _logger.trace(
          "Connection is protected but no password was recieved ${_device.interface} ${utf8.decode(ap._accessPoint.ssid)}",
        );
        return ConnectResponse.needsPassword;
      }
      return _createConnection(ap, userPassword, autoconnect);
    }
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
      _logger.debug("connSettings.getSecrets exception throw, assuming no secrets\n$e");
      return null;
    }
    if (secrets.isNotEmpty) {
      final security = secrets[securityName];
      if (security != null) {
        final psk = security["psk"]; // TODO: 2 could this be other value???
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
    final ssid = utf8.decode(ap.ssid);
    for (final conn in _client.settings.connections) {
      final settings = await conn.getSettings();
      final connSettings = settings["connection"];
      if (connSettings == null) {
        continue;
      }
      if (connSettings["id"]?.asString().startsWith("waywing-") != true) {
        // reject all connection not created by this project
        // TODO 3 there are bugs when working with connections from other apps. We need to fix this
        _logger.trace("Connection rejected because was not created in this application. File: ${conn.filename}");
        continue;
      }
      if (connSettings["id"]?.asString() != "waywing-$ssid" || connSettings["interface-name"] != interface) {
        _logger.trace(
          "Connection rejected because ssid and intreface did not match. "
          "File: ${conn.filename} id: ${connSettings["id"]?.asString()} != waywing-$ssid "
          "${connSettings["interface-name"]} != interface",
        );
        continue;
      }
      _logger.trace("Connection accepted. File: ${conn.filename}");
      return (conn, settings);
    }
    return null;
  }
}

class NMServiceAccessPoint {
  ValueListenable<double> get strength => _strength;
  late final DBusPropertyValueNotifier<double> _strength;

  late final String ssid = utf8.decode(_accessPoint.ssid);

  List<NetworkManagerWifiAccessPointSecurityFlag> get rsnFlags => _accessPoint.rsnFlags;

  List<NetworkManagerWifiAccessPointSecurityFlag> get wpaFlags => _accessPoint.wpaFlags;

  late final isSecured = rsnFlags.isNotEmpty || wpaFlags.isNotEmpty;

  final NetworkManagerAccessPoint _accessPoint;
  NMServiceAccessPoint(this._accessPoint);

  void init() {
    _strength = DBusPropertyValueNotifier(
      name: "Strength",
      stream: _accessPoint.propertiesChanged,
      callback: () => _accessPoint.strength / 100,
    );
  }

  void dispose() {
    _strength.dispose();
  }

  @override
  int get hashCode => ssid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is NMServiceAccessPoint) other.ssid == ssid;
    return super == other;
  }
}

enum ConnectResponse {
  needsPassword,
  success,
  unknownError,
}
