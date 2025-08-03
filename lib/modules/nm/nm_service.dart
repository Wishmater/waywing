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

  Future<void> connect(
    NetworkManagerDevice device,
    NetworkManagerAccessPoint ap, {
    bool autoconnect = false,
  }) async {
    final connSettings = await _searchForConnection(device, ap);
    if (connSettings != null) {
      logger.debug("Activating connection: ${device.interface} ${utf8.decode(ap.ssid)}");

      final pass = await _getSavedWifiPsk(device, ap, connSettings);
      if (pass != null){}

      await client.activateConnection(device: device, accessPoint: ap, connection: connSettings);
    } else {
      logger.debug("Creating and activating connection: ${device.interface} ${utf8.decode(ap.ssid)}");
      final conn = await client.addAndActivateConnection(device: device, accessPoint: ap);
    }
  }

  Future<String?> _getSavedWifiPsk(
    NetworkManagerDevice device,
    NetworkManagerAccessPoint accessPoint,
    NetworkManagerSettingsConnection connSettings,
  ) async {
    final settings = await connSettings.getSettings();
    final type = settings["connection"]?["type"];
    final securityName = type != null ? "${type.asString()}-security" : "802-11-wireless-security";
    final secrets = await connSettings.getSecrets(securityName);
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

  Future<NetworkManagerSettingsConnection?> _searchForConnection(
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
        return conn;
      }
    }
    return null;
  }

  Future<void> disconnect(NetworkManagerDevice device) async {
    logger.debug("Disconnecting device: ${device.interface}");
    await device.disconnect();
  }
}
