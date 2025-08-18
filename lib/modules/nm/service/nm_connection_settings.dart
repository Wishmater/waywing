import "dart:convert";

import "package:dbus/dbus.dart";
import "package:nm/nm.dart";

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
