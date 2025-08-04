import "dart:async";
import "dart:convert";

import "package:dartx/dartx_io.dart";
import "package:dbus/dbus.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:nm/nm.dart";

class NetworkManagerService extends Service {
  late Logger logger;
  final NetworkManagerClient client;

  NetworkManagerService._() : client = NetworkManagerClient();

  static registerService(RegisterServiceCallback registerService) {
    registerService<NetworkManagerService>(NetworkManagerService._);
  }

  @override
  Future<void> dispose() async {
    await client.close();
    await logger.destroy();
  }

  @override
  Future<void> init(Logger logger) async {
    this.logger = logger;
    await client.connect();
  }

  NetworkManagerDevice? getWirelessDevice() {
    // TODO what happens if there is more than one wifi device
    final device = client.devices.firstOrNullWhere((e) => e.deviceType == NetworkManagerDeviceType.wifi);
    return device;
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
        }
        logger.error("client.activateConnection", error: e, stackTrace: st);
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
        final psk = security["psk"]; // TODO this could be other value???
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
    logger.debug("Disconnecting device: ${device.interface}");
    await device.disconnect();
  }
}

enum ConnectResponse {
  needsPassword,
  success,
}
