import "dart:async";
import "dart:convert";

import "package:dartx/dartx.dart";
import "package:dbus/dbus.dart";
import "package:flutter/foundation.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:nm/nm.dart";
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

  ValueListenable<bool> get isConnected => _isConnected;
  late final DerivedValueNotifier<bool> _isConnected;

  ValueListenable<int?> get txBytes => _txBytes;
  late final DBusProperyValueNotifier<int?> _txBytes;

  ValueListenable<int?> get rxBytes => _rxBytes;
  late final DBusProperyValueNotifier<int?> _rxBytes;

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

    _activeConnection = DBusProperyValueNotifier(
      name: "ActiveConnection",
      stream: _device.propertiesChanged,
      callback: () => _device.activeConnection,
    );
    _isConnected = DerivedValueNotifier(
      dependencies: [_activeConnection],
      derive: () => _activeConnection.value != null,
    );

    // TODO: 3 can "Statistics" object change, which means we would need to re-init this (or update the stream in the notifier)
    _txBytes = DBusProperyValueNotifier(
      name: "TxBytes",
      stream: _device.statistics?.propertiesChanged,
      callback: () => _device.statistics?.txBytes,
    );
    _rxBytes = DBusProperyValueNotifier(
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
  late final DBusProperyValueNotifier<List<NMServiceAccessPoint>> _accessPoints;

  ValueListenable<NMServiceAccessPoint?> get activeAccessPoint => _activeAccessPoint;
  late final DBusProperyValueNotifier<NMServiceAccessPoint?> _activeAccessPoint;

  ValueListenable<int> get lastScan => _lastScan;
  late final DBusProperyValueNotifier<int> _lastScan;

  ValueListenable<bool> get wirelessEnabled => _wirelessEnabled;
  late final DBusProperyValueNotifier<bool> _wirelessEnabled;

  NMServiceWifiDevice(super._client, super._device, super._logger);

  @override
  Future<void> init() async {
    await super.init();
    _activeAccessPoint = DBusProperyValueNotifier(
      name: "ActiveAccessPoint",
      stream: _device.wireless!.propertiesChanged,
      callback: () {
        if (_device.wireless!.activeAccessPoint == null) return null;
        final result = NMServiceAccessPoint(_device.wireless!.activeAccessPoint!);
        result.init();
        return result;
      },
    );
    // TODO: 3 is probably that there is a leak here because the previous NMServiceAccessPoint
    // did not dispose when changed (same in _activeAccessPoint)
    _accessPoints = DBusProperyValueNotifier(
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
    _lastScan = DBusProperyValueNotifier(
      name: "LastScan",
      stream: _device.wireless!.propertiesChanged,
      callback: () => _device.wireless!.lastScan,
    );
    _wirelessEnabled = DBusProperyValueNotifier(
      name: "WirelessEnabled",
      stream: _client.propertiesChanged,
      callback: () => _client.wirelessEnabled,
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
  late final DBusProperyValueNotifier<double> _strength;

  late final String ssid = utf8.decode(_accessPoint.ssid);

  List<NetworkManagerWifiAccessPointSecurityFlag> get rsnFlags => _accessPoint.rsnFlags;

  List<NetworkManagerWifiAccessPointSecurityFlag> get wpaFlags => _accessPoint.wpaFlags;

  late final isSecured = rsnFlags.isNotEmpty || wpaFlags.isNotEmpty;

  final NetworkManagerAccessPoint _accessPoint;
  NMServiceAccessPoint(this._accessPoint);

  void init() {
    _strength = DBusProperyValueNotifier(
      name: "Strength",
      stream: _accessPoint.propertiesChanged,
      callback: () => _accessPoint.strength / 100,
    );
  }

  void dispose() {
    _strength.dispose();
  }
}

enum ConnectResponse {
  needsPassword,
  success,
  unknownError,
}

/// See docs here https://networkmanager.dev/docs/api/latest/settings-connection.html
class NMAccessPointSettingConnection {
  /// Whether or not the connection should be automatically connected by NetworkManager
  /// when the resources for the connection are available. TRUE to automatically activate
  /// the connection, FALSE to require manual intervention to activate the connection.
  /// Autoconnect happens when the circumstances are suitable. That means for example that
  /// the device is currently managed and not active.
  ///
  /// Autoconnect thus never replaces or competes with an already active profile.
  /// Note that autoconnect is not implemented for VPN profiles. See "secondaries"
  /// as an alternative to automatically connect VPN profiles. If multiple profiles
  /// are ready to autoconnect on the same device, the one with the better
  /// "connection.autoconnect-priority" is chosen. If the priorities are equal, then
  /// the most recently connected profile is activated. If the profiles were not connected
  /// earlier or their "connection.timestamp" is identical, the choice is undefined.
  /// Depending on "connection.multi-connect", a profile can (auto)connect only once at a
  /// time or multiple times.
  bool? autoconnect;

  /// The autoconnect priority in range -999 to 999.
  ///
  /// If the connection is set to autoconnect, connections with higher priority will be preferred.
  /// The higher number means higher priority.
  ///
  /// Defaults to 0.
  ///
  /// Note that this property only matters if there are more than one candidate profile to select
  /// for autoconnect. In case of equal priority, the profile used most recently is chosen.
  int? autoconnectPriority;

  /// A human readable unique identifier for the connection, like "Work Wi-Fi" or "T-Mobile 3G".
  ///
  /// Usually the access point ssid
  String id;

  /// The name of the network interface this connection is bound to.
  ///
  /// If not set, then the connection can be attached to any interface of the appropriate type
  /// (subject to restrictions imposed by other settings).
  ///
  /// For software devices this specifies the name of the created device.
  /// For connection types where interface names cannot easily be made persistent
  /// (e.g. mobile broadband or USB Ethernet), this property should not be used.
  /// Setting this property restricts the interfaces a connection can be used with,
  /// and if interface names change or are reordered the connection may be applied to
  /// the wrong interface.
  String interfaceName;

  /// List of connection UUIDs that should be activated when the base connection itself is activated.
  ///
  /// Currently, only VPN connections are supported.
  ///
  /// TODO: not used yet
  List<String>? secondaries;

  /// The time, in seconds since the Unix Epoch, that the connection was last _successfully_
  /// fully activated.
  ///
  /// NetworkManager updates the connection timestamp periodically when the connection is active
  /// to ensure that an active connection has the latest timestamp.
  ///
  /// The property is only meant for reading (changes to this property will not be preserved).
  int? timestamp;

  /// Base type of the connection. For hardware-dependent connections, should contain the
  /// setting name of the hardware-type specific setting (ie, "802-3-ethernet" or "802-11-wireless"
  /// or "bluetooth", etc), and for non-hardware dependent connections like VPN or otherwise,
  /// should contain the setting name of that setting type (ie, "vpn" or "bridge", etc).
  String type;

  /// A universally unique identifier for the connection, for example generated with libuuid.
  /// It should be assigned when the connection is created, and never changed as long as the
  /// connection still applies to the same network.
  ///
  /// For example, it should not be changed when the "id" property or NMSettingIP4Config changes,
  /// but might need to be re-created when the Wi-Fi SSID, mobile broadband network provider,
  /// or "type" property changes.
  ///
  /// The UUID must be in the format "2815492f-7e56-435e-b2e9-246bd7cdc664" (ie, contains only
  /// hexadecimal characters and "-").
  String? uuid;

  /// The trust level of a the connection.
  /// Free form case-insensitive string (for example "Home", "Work", "Public").
  ///
  /// NULL or unspecified zone means the connection will be placed in the default zone as
  /// defined by the firewall.
  ///
  /// When updating this property on a currently activated connection,
  /// the change takes effect immediately.
  String? zone;

  NMAccessPointSettingConnection({
    required this.id,
    required this.interfaceName,
    required this.type,
    this.autoconnectPriority,
    this.autoconnect,
    this.timestamp,
    this.secondaries,
    this.zone,
    this.uuid,
  });

  /// This function constructor can throw if the accessPoint.ssid
  /// is not a valid utf8 and an id was not provided
  factory NMAccessPointSettingConnection.fromAccessPoint(
    NetworkManagerAccessPoint accessPoint,
    NetworkManagerDevice device, {
    String? id,
    bool? autoconnect,
    int? autoconnectPriority,
  }) {
    id ??= utf8.decode(accessPoint.ssid);
    return NMAccessPointSettingConnection(
      id: id,
      interfaceName: device.interface,
      autoconnect: autoconnect,
      autoconnectPriority: autoconnectPriority,
      type: "802-11-wireless",
    );
  }

  Map<String, DBusValue> values() {
    final resp = <String, DBusValue>{
      "id": DBusString(id),
      "interface-name": DBusString(interfaceName),
      "type": DBusString(type),
    };
    if (autoconnect != null) {
      resp["autoconnect"] = DBusBoolean(autoconnect!);
      if (autoconnectPriority != null) {
        resp["autoconnect-priority"] = DBusInt32(autoconnectPriority!);
      }
    }
    if (timestamp != null) {
      resp["timestamp"] = DBusUint64(timestamp!);
    }
    if (secondaries != null && secondaries!.isNotEmpty) {
      resp["secondaries"] = DBusArray.string(secondaries!);
    }
    if (zone != null) {
      resp["zone"] = DBusString(zone!);
    }
    if (uuid != null) {
      resp["uuid"] = DBusString(uuid!);
    }
    return resp;
  }
}

/// See docs here https://networkmanager.dev/docs/api/latest/settings-802-11-wireless.html
class NMAccessPointSettingWireless {
  /// SSID of the Wi-Fi network
  List<int> ssid;

  /// Wi-Fi network mode; one of "infrastructure", "mesh", "adhoc" or "ap".
  ///
  /// If blank, infrastructure is assumed.
  NetworkManagerWifiMode mode;

  ///	802.11 frequency band of the network.
  /// One of "a" for 5GHz 802.11a or "bg" for 2.4GHz 802.11.
  ///
  /// This will lock associations to the Wi-Fi network to the specific band,
  /// i.e. if "a" is specified, the device will not associate with the same network
  /// in the 2.4GHz band even if the network's settings are compatible.
  ///
  /// This setting depends on specific driver capability and may not work with all drivers.
  String? band;

  NMAccessPointSettingWireless({
    required this.ssid,
    required this.mode,
    this.band,
  });

  factory NMAccessPointSettingWireless.fromAccessPoint(NetworkManagerAccessPoint accessPoint) {
    return NMAccessPointSettingWireless(
      ssid: accessPoint.ssid,
      mode: accessPoint.mode,
    );
  }

  Map<String, DBusValue> values() {
    final resp = {
      "ssid": DBusArray.byte(ssid),
      "mode": DBusString(switch (mode) {
        NetworkManagerWifiMode.unknown => "infrastructure",
        NetworkManagerWifiMode.adhoc => "adhoc",
        NetworkManagerWifiMode.infra => "infrastructure",
        NetworkManagerWifiMode.ap => "ap",
        NetworkManagerWifiMode.mesh => "mesh",
      }),
    };
    if (band != null) {
      resp["band"] = DBusString(band!);
    }
    return resp;
  }
}

/// {@template NMSettingSecretFlags}
/// - 0x0 (none) - the system is responsible for providing and storing this secret.
///
/// - 0x1 (agent-owned) - a user-session secret agent is responsible for providing
///   and storing this secret; when it is required, agents will be asked to provide it.
///
/// - 0x2 (not-saved) - this secret should not be saved but should be requested from
///   the user each time it is required. This flag should be used for One-Time-Pad secrets,
///   PIN codes from hardware tokens, or if the user simply does not want to save the secret.
///
/// - 0x4 (not-required) - in some situations it cannot be automatically determined that
///   a secret is required or not. This flag hints that the secret is not required and
///   should not be requested from the user.
/// {@endtemplate}

/// See docs here https://networkmanager.dev/docs/api/latest/settings-802-11-wireless-security.html
class NMAccessPointSettingWirelessSecurity {
  /// When WEP is used (ie, key-mgmt = "none" or "ieee8021x") indicate the 802.11
  /// authentication algorithm required by the AP here.
  ///
  /// One of "open" for Open System, "shared" for Shared Key, or "leap" for Cisco LEAP.
  /// When using Cisco LEAP (ie, key-mgmt = "ieee8021x" and auth-alg = "leap") the
  /// "leap-username" and "leap-password" properties must be specified.
  String authAlg;

  ///	Key management used for the connection. One of:
  /// - "none" (WEP or no password protection)
  /// - "ieee8021x" (Dynamic WEP)
  /// - "owe" (Opportunistic Wireless Encryption)
  /// - "wpa-psk" (WPA2 + WPA3 personal)
  /// - "sae" (WPA3 personal only)
  /// - "wpa-eap" (WPA2 + WPA3 enterprise)
  /// - "wpa-eap-suite-b-192" (WPA3 enterprise only).
  ///
  /// This property must be set for any Wi-Fi connection that uses security.
  String keyMgmt;

  /// The login password for legacy LEAP connections
  /// (ie, key-mgmt = "ieee8021x" and auth-alg = "leap").
  String? leapPassword;

  /// The login username for legacy LEAP connections
  /// (ie, key-mgmt = "ieee8021x" and auth-alg = "leap").
  String? leapUsername;

  /// Flags indicating how to handle the "leap-password" property.
  ///
  /// {@macro NMSettingSecretFlags}
  ///
  /// type: uint32
  int? leapPasswordFlags;

  /// Pre-Shared-Key for WPA networks. For WPA-PSK, it's either an ASCII passphrase of 8 to 63
  /// characters that is (as specified in the 802.11i standard) hashed to derive the actual key,
  /// or the key in form of 64 hexadecimal character.
  ///
  /// The WPA3-Personal networks use a passphrase of any length for SAE authentication.
  String? psk;

  /// Flags indicating how to handle the "psk" property.
  ///
  /// {@macro NMSettingSecretFlags}
  ///
  /// type: uint32
  int? pskFlags;

  ///	Flags indicating how to handle the "wep-key0", "wep-key1", "wep-key2", and "wep-key3" properties.
  ///
  /// {@macro NMSettingSecretFlags}
  ///
  /// type: uint32
  int? wepKeyFlags;

  ///	Controls the interpretation of WEP keys. Allowed values are
  /// - 1 (key), in which case the key
  ///   is either a 10 or 26 character hexadecimal string, or a 5 or 13 character ASCII password;
  ///
  /// - 2 (passphrase), in which case the passphrase is provided as a string and will be hashed
  ///   using the de-facto MD5 method to derive the actual WEP key.
  ///
  /// type: uint32
  int? wepKeyType;

  /// Index 0 WEP key. This is the WEP key used in most networks.
  /// See the "wep-key-type" property for a description of how this key is interpreted.
  String? wepKey0;

  /// Index 1 WEP key. This WEP index is not used by most networks.
  /// See the "wep-key-type" property for a description of how this key is interpreted.
  String? wepKey1;

  /// Index 2 WEP key. This WEP index is not used by most networks.
  /// See the "wep-key-type" property for a description of how this key is interpreted.
  String? wepKey2;

  /// Index 3 WEP key. This WEP index is not used by most networks.
  /// See the "wep-key-type" property for a description of how this key is interpreted.
  String? wepKey3;

  /// When static WEP is used (ie, key-mgmt = "none") and a non-default WEP key index is
  /// used by the AP, put that WEP key index here. Valid values are 0 (default key) through 3.
  ///
  /// Note that some consumer access points (like the Linksys WRT54G) number the keys 1 - 4.
  ///
  /// type: uint32
  int? wepTxKeyidx;

  NMAccessPointSettingWirelessSecurity({
    required this.authAlg,
    required this.keyMgmt,
    this.leapPassword,
    this.leapPasswordFlags,
    this.leapUsername,
    this.psk,
    this.pskFlags,
    this.wepKey0,
    this.wepKey1,
    this.wepKey2,
    this.wepKey3,
    this.wepKeyFlags,
    this.wepKeyType,
    this.wepTxKeyidx,
  });

  factory NMAccessPointSettingWirelessSecurity.fromAccessPoint(NetworkManagerAccessPoint ap, String? password) {
    if (password != null && (password.length < 8 || password.length > 63)) {
      throw StateError(
        "Wireless password is bigger shorter than 8 or bigger than 63. Password length: ${password.length}",
      );
    }
    return NMAccessPointSettingWirelessSecurity(
      authAlg: "open",
      keyMgmt: "wpa-psk",
      psk: password,
    );
  }

  Map<String, DBusValue> values() {
    final resp = <String, DBusValue>{
      "auth-alg": DBusString(authAlg),
      "key-mgmt": DBusString(keyMgmt),
    };
    if (leapPassword != null) {
      resp["leap-password"] = DBusString(leapPassword!);
    }
    if (leapPasswordFlags != null) {
      resp["leap-password-flags"] = DBusUint32(leapPasswordFlags!);
    }
    if (leapUsername != null) {
      resp["leap-username"] = DBusString(leapUsername!);
    }
    if (psk != null) {
      resp["psk"] = DBusString(psk!);
    }
    if (pskFlags != null) {
      resp["psk-flags"] = DBusUint32(pskFlags!);
    }
    if (wepKey0 != null) {
      resp["wep-key0"] = DBusString(wepKey0!);
    }
    if (wepKey1 != null) {
      resp["wep-key1"] = DBusString(wepKey1!);
    }
    if (wepKey2 != null) {
      resp["wep-key2"] = DBusString(wepKey2!);
    }
    if (wepKey3 != null) {
      resp["wep-key3"] = DBusString(wepKey3!);
    }
    if (wepKeyFlags != null) {
      resp["wep-key-flags"] = DBusUint32(wepKeyFlags!);
    }
    if (wepKeyType != null) {
      resp["wep-key-type"] = DBusUint32(wepKeyType!);
    }
    if (wepTxKeyidx != null) {
      resp["wep-tx-keyidx"] = DBusUint32(wepTxKeyidx!);
    }
    return resp;
  }
}

/// See Configuration Settings spec here https://networkmanager.dev/docs/api/latest/ch01.html
Map<String, Map<String, DBusValue>> createSettings(
  NetworkManagerAccessPoint ap,
  NetworkManagerDevice device, {
  String? password,
  bool? autoconnect,
  int? autoconnectPriority,
}) {
  final connection = NMAccessPointSettingConnection.fromAccessPoint(
    ap,
    device,
    autoconnect: autoconnect,
    autoconnectPriority: autoconnectPriority,
    id: "waywing-${utf8.decode(ap.ssid)}", // allow identifying if the connections was created by us
  );
  final wireless = NMAccessPointSettingWireless.fromAccessPoint(ap);
  final resp = {
    "connection": connection.values(),
    "802-11-wireless": wireless.values(),
  };
  if (ap.rsnFlags.isNotEmpty) {
    final wirelessSecurity = NMAccessPointSettingWirelessSecurity.fromAccessPoint(ap, password);
    resp["802-11-wireless-security"] = wirelessSecurity.values();
  }
  return resp;
}
