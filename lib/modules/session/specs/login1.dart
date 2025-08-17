// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.login1.xml

// ignore_for_file: non_constant_identifier_names, use_super_parameters

import "dart:io";
import "package:dbus/dbus.dart";

/// Signal data for org.freedesktop.login1.Manager.SecureAttentionKey.
class OrgFreedesktopLogin1ManagerSecureAttentionKey extends DBusSignal {
  String get seat_id => values[0].asString();
  DBusObjectPath get object_path => values[1].asObjectPath();

  OrgFreedesktopLogin1ManagerSecureAttentionKey(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.SessionNew.
class OrgFreedesktopLogin1ManagerSessionNew extends DBusSignal {
  String get session_id => values[0].asString();
  DBusObjectPath get object_path => values[1].asObjectPath();

  OrgFreedesktopLogin1ManagerSessionNew(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.SessionRemoved.
class OrgFreedesktopLogin1ManagerSessionRemoved extends DBusSignal {
  String get session_id => values[0].asString();
  DBusObjectPath get object_path => values[1].asObjectPath();

  OrgFreedesktopLogin1ManagerSessionRemoved(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.UserNew.
class OrgFreedesktopLogin1ManagerUserNew extends DBusSignal {
  int get uid => values[0].asUint32();
  DBusObjectPath get object_path => values[1].asObjectPath();

  OrgFreedesktopLogin1ManagerUserNew(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.UserRemoved.
class OrgFreedesktopLogin1ManagerUserRemoved extends DBusSignal {
  int get uid => values[0].asUint32();
  DBusObjectPath get object_path => values[1].asObjectPath();

  OrgFreedesktopLogin1ManagerUserRemoved(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.SeatNew.
class OrgFreedesktopLogin1ManagerSeatNew extends DBusSignal {
  String get seat_id => values[0].asString();
  DBusObjectPath get object_path => values[1].asObjectPath();

  OrgFreedesktopLogin1ManagerSeatNew(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.SeatRemoved.
class OrgFreedesktopLogin1ManagerSeatRemoved extends DBusSignal {
  String get seat_id => values[0].asString();
  DBusObjectPath get object_path => values[1].asObjectPath();

  OrgFreedesktopLogin1ManagerSeatRemoved(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.PrepareForShutdown.
class OrgFreedesktopLogin1ManagerPrepareForShutdown extends DBusSignal {
  bool get start => values[0].asBoolean();

  OrgFreedesktopLogin1ManagerPrepareForShutdown(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.PrepareForShutdownWithMetadata.
class OrgFreedesktopLogin1ManagerPrepareForShutdownWithMetadata extends DBusSignal {
  bool get start => values[0].asBoolean();
  Map<String, DBusValue> get metadata => values[1].asStringVariantDict();

  OrgFreedesktopLogin1ManagerPrepareForShutdownWithMetadata(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Manager.PrepareForSleep.
class OrgFreedesktopLogin1ManagerPrepareForSleep extends DBusSignal {
  bool get start => values[0].asBoolean();

  OrgFreedesktopLogin1ManagerPrepareForSleep(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class OrgFreedesktopLogin1Manager extends DBusRemoteObject {
  /// Stream of org.freedesktop.login1.Manager.SecureAttentionKey signals.
  late final Stream<OrgFreedesktopLogin1ManagerSecureAttentionKey> secureAttentionKey;

  /// Stream of org.freedesktop.login1.Manager.SessionNew signals.
  late final Stream<OrgFreedesktopLogin1ManagerSessionNew> sessionNew;

  /// Stream of org.freedesktop.login1.Manager.SessionRemoved signals.
  late final Stream<OrgFreedesktopLogin1ManagerSessionRemoved> sessionRemoved;

  /// Stream of org.freedesktop.login1.Manager.UserNew signals.
  late final Stream<OrgFreedesktopLogin1ManagerUserNew> userNew;

  /// Stream of org.freedesktop.login1.Manager.UserRemoved signals.
  late final Stream<OrgFreedesktopLogin1ManagerUserRemoved> userRemoved;

  /// Stream of org.freedesktop.login1.Manager.SeatNew signals.
  late final Stream<OrgFreedesktopLogin1ManagerSeatNew> seatNew;

  /// Stream of org.freedesktop.login1.Manager.SeatRemoved signals.
  late final Stream<OrgFreedesktopLogin1ManagerSeatRemoved> seatRemoved;

  /// Stream of org.freedesktop.login1.Manager.PrepareForShutdown signals.
  late final Stream<OrgFreedesktopLogin1ManagerPrepareForShutdown> prepareForShutdown;

  /// Stream of org.freedesktop.login1.Manager.PrepareForShutdownWithMetadata signals.
  late final Stream<OrgFreedesktopLogin1ManagerPrepareForShutdownWithMetadata> prepareForShutdownWithMetadata;

  /// Stream of org.freedesktop.login1.Manager.PrepareForSleep signals.
  late final Stream<OrgFreedesktopLogin1ManagerPrepareForSleep> prepareForSleep;

  OrgFreedesktopLogin1Manager(DBusClient client, String destination, DBusObjectPath path) : super(client, name: destination, path: path) {
    secureAttentionKey = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "SecureAttentionKey", signature: DBusSignature("so")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerSecureAttentionKey(signal));

    sessionNew = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "SessionNew", signature: DBusSignature("so")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerSessionNew(signal));

    sessionRemoved = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "SessionRemoved", signature: DBusSignature("so")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerSessionRemoved(signal));

    userNew = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "UserNew", signature: DBusSignature("uo")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerUserNew(signal));

    userRemoved = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "UserRemoved", signature: DBusSignature("uo")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerUserRemoved(signal));

    seatNew = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "SeatNew", signature: DBusSignature("so")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerSeatNew(signal));

    seatRemoved = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "SeatRemoved", signature: DBusSignature("so")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerSeatRemoved(signal));

    prepareForShutdown = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "PrepareForShutdown", signature: DBusSignature("b")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerPrepareForShutdown(signal));

    prepareForShutdownWithMetadata = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "PrepareForShutdownWithMetadata", signature: DBusSignature("ba{sv}")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerPrepareForShutdownWithMetadata(signal));

    prepareForSleep = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Manager", name: "PrepareForSleep", signature: DBusSignature("b")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1ManagerPrepareForSleep(signal));
  }

  /// Gets org.freedesktop.login1.Manager.EnableWallMessages
  Future<bool> getEnableWallMessages() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "EnableWallMessages", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Sets org.freedesktop.login1.Manager.EnableWallMessages
  Future<void> setEnableWallMessages (bool value) async {
    await setProperty("org.freedesktop.login1.Manager", "EnableWallMessages", DBusBoolean(value));
  }

  /// Gets org.freedesktop.login1.Manager.WallMessage
  Future<String> getWallMessage() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "WallMessage", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Sets org.freedesktop.login1.Manager.WallMessage
  Future<void> setWallMessage (String value) async {
    await setProperty("org.freedesktop.login1.Manager", "WallMessage", DBusString(value));
  }

  /// Gets org.freedesktop.login1.Manager.NAutoVTs
  Future<int> getNAutoVTs() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "NAutoVTs", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets org.freedesktop.login1.Manager.KillOnlyUsers
  Future<List<String>> getKillOnlyUsers() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "KillOnlyUsers", signature: DBusSignature("as"));
    return value.asStringArray().toList();
  }

  /// Gets org.freedesktop.login1.Manager.KillExcludeUsers
  Future<List<String>> getKillExcludeUsers() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "KillExcludeUsers", signature: DBusSignature("as"));
    return value.asStringArray().toList();
  }

  /// Gets org.freedesktop.login1.Manager.KillUserProcesses
  Future<bool> getKillUserProcesses() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "KillUserProcesses", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.RebootParameter
  Future<String> getRebootParameter() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "RebootParameter", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.RebootToFirmwareSetup
  Future<bool> getRebootToFirmwareSetup() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "RebootToFirmwareSetup", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.RebootToBootLoaderMenu
  Future<int> getRebootToBootLoaderMenu() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "RebootToBootLoaderMenu", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.RebootToBootLoaderEntry
  Future<String> getRebootToBootLoaderEntry() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "RebootToBootLoaderEntry", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.BootLoaderEntries
  Future<List<String>> getBootLoaderEntries() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "BootLoaderEntries", signature: DBusSignature("as"));
    return value.asStringArray().toList();
  }

  /// Gets org.freedesktop.login1.Manager.IdleHint
  Future<bool> getIdleHint() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "IdleHint", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.IdleSinceHint
  Future<int> getIdleSinceHint() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "IdleSinceHint", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.IdleSinceHintMonotonic
  Future<int> getIdleSinceHintMonotonic() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "IdleSinceHintMonotonic", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.BlockInhibited
  Future<String> getBlockInhibited() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "BlockInhibited", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.BlockWeakInhibited
  Future<String> getBlockWeakInhibited() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "BlockWeakInhibited", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.DelayInhibited
  Future<String> getDelayInhibited() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "DelayInhibited", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.InhibitDelayMaxUSec
  Future<int> getInhibitDelayMaxUSec() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "InhibitDelayMaxUSec", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.UserStopDelayUSec
  Future<int> getUserStopDelayUSec() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "UserStopDelayUSec", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.SleepOperation
  Future<List<String>> getSleepOperation() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "SleepOperation", signature: DBusSignature("as"));
    return value.asStringArray().toList();
  }

  /// Gets org.freedesktop.login1.Manager.HandlePowerKey
  Future<String> getHandlePowerKey() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandlePowerKey", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandlePowerKeyLongPress
  Future<String> getHandlePowerKeyLongPress() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandlePowerKeyLongPress", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleRebootKey
  Future<String> getHandleRebootKey() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleRebootKey", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleRebootKeyLongPress
  Future<String> getHandleRebootKeyLongPress() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleRebootKeyLongPress", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleSuspendKey
  Future<String> getHandleSuspendKey() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleSuspendKey", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleSuspendKeyLongPress
  Future<String> getHandleSuspendKeyLongPress() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleSuspendKeyLongPress", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleHibernateKey
  Future<String> getHandleHibernateKey() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleHibernateKey", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleHibernateKeyLongPress
  Future<String> getHandleHibernateKeyLongPress() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleHibernateKeyLongPress", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleLidSwitch
  Future<String> getHandleLidSwitch() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleLidSwitch", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleLidSwitchExternalPower
  Future<String> getHandleLidSwitchExternalPower() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleLidSwitchExternalPower", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleLidSwitchDocked
  Future<String> getHandleLidSwitchDocked() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleLidSwitchDocked", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HandleSecureAttentionKey
  Future<String> getHandleSecureAttentionKey() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HandleSecureAttentionKey", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.HoldoffTimeoutUSec
  Future<int> getHoldoffTimeoutUSec() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "HoldoffTimeoutUSec", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.IdleAction
  Future<String> getIdleAction() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "IdleAction", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.IdleActionUSec
  Future<int> getIdleActionUSec() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "IdleActionUSec", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.PreparingForShutdown
  Future<bool> getPreparingForShutdown() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "PreparingForShutdown", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.PreparingForShutdownWithMetadata
  Future<Map<String, DBusValue>> getPreparingForShutdownWithMetadata() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "PreparingForShutdownWithMetadata", signature: DBusSignature("a{sv}"));
    return value.asStringVariantDict();
  }

  /// Gets org.freedesktop.login1.Manager.PreparingForSleep
  Future<bool> getPreparingForSleep() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "PreparingForSleep", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.ScheduledShutdown
  Future<List<DBusValue>> getScheduledShutdown() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "ScheduledShutdown", signature: DBusSignature("(st)"));
    return value.asStruct();
  }

  /// Gets org.freedesktop.login1.Manager.DesignatedMaintenanceTime
  Future<String> getDesignatedMaintenanceTime() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "DesignatedMaintenanceTime", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Manager.Docked
  Future<bool> getDocked() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "Docked", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.LidClosed
  Future<bool> getLidClosed() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "LidClosed", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.OnExternalPower
  Future<bool> getOnExternalPower() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "OnExternalPower", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.RemoveIPC
  Future<bool> getRemoveIPC() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "RemoveIPC", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Manager.RuntimeDirectorySize
  Future<int> getRuntimeDirectorySize() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "RuntimeDirectorySize", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.RuntimeDirectoryInodesMax
  Future<int> getRuntimeDirectoryInodesMax() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "RuntimeDirectoryInodesMax", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.InhibitorsMax
  Future<int> getInhibitorsMax() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "InhibitorsMax", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.NCurrentInhibitors
  Future<int> getNCurrentInhibitors() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "NCurrentInhibitors", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.SessionsMax
  Future<int> getSessionsMax() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "SessionsMax", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.NCurrentSessions
  Future<int> getNCurrentSessions() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "NCurrentSessions", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Manager.StopIdleSessionUSec
  Future<int> getStopIdleSessionUSec() async {
    var value = await getProperty("org.freedesktop.login1.Manager", "StopIdleSessionUSec", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Invokes org.freedesktop.login1.Manager.GetSession()
  Future<DBusObjectPath> callGetSession(String session_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "GetSession", [DBusString(session_id)], replySignature: DBusSignature("o"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.login1.Manager.GetSessionByPID()
  Future<DBusObjectPath> callGetSessionByPID(int pid, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "GetSessionByPID", [DBusUint32(pid)], replySignature: DBusSignature("o"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.login1.Manager.GetUser()
  Future<DBusObjectPath> callGetUser(int uid, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "GetUser", [DBusUint32(uid)], replySignature: DBusSignature("o"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.login1.Manager.GetUserByPID()
  Future<DBusObjectPath> callGetUserByPID(int pid, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "GetUserByPID", [DBusUint32(pid)], replySignature: DBusSignature("o"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.login1.Manager.GetSeat()
  Future<DBusObjectPath> callGetSeat(String seat_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "GetSeat", [DBusString(seat_id)], replySignature: DBusSignature("o"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.login1.Manager.ListSessions()
  Future<List<List<DBusValue>>> callListSessions({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "ListSessions", [], replySignature: DBusSignature("a(susso)"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes org.freedesktop.login1.Manager.ListSessionsEx()
  Future<List<List<DBusValue>>> callListSessionsEx({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "ListSessionsEx", [], replySignature: DBusSignature("a(sussussbto)"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes org.freedesktop.login1.Manager.ListUsers()
  Future<List<List<DBusValue>>> callListUsers({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "ListUsers", [], replySignature: DBusSignature("a(uso)"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes org.freedesktop.login1.Manager.ListSeats()
  Future<List<List<DBusValue>>> callListSeats({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "ListSeats", [], replySignature: DBusSignature("a(so)"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes org.freedesktop.login1.Manager.ListInhibitors()
  Future<List<List<DBusValue>>> callListInhibitors({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "ListInhibitors", [], replySignature: DBusSignature("a(ssssuu)"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes org.freedesktop.login1.Manager.CreateSession()
  Future<List<DBusValue>> callCreateSession(int uid, int pid, String service, String type, String cls, String desktop, String seat_id, int vtnr, String tty, String display, bool remote, String remote_user, String remote_host, List<List<DBusValue>> properties, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CreateSession", [DBusUint32(uid), DBusUint32(pid), DBusString(service), DBusString(type), DBusString(cls), DBusString(desktop), DBusString(seat_id), DBusUint32(vtnr), DBusString(tty), DBusString(display), DBusBoolean(remote), DBusString(remote_user), DBusString(remote_host), DBusArray(DBusSignature("(sv)"), properties.map((child) => DBusStruct(child)))], replySignature: DBusSignature("soshusub"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.login1.Manager.CreateSessionWithPIDFD()
  Future<List<DBusValue>> callCreateSessionWithPIDFD(int uid, ResourceHandle pidfd, String service, String type, String cls, String desktop, String seat_id, int vtnr, String tty, String display, bool remote, String remote_user, String remote_host, int flags, List<List<DBusValue>> properties, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CreateSessionWithPIDFD", [DBusUint32(uid), DBusUnixFd(pidfd), DBusString(service), DBusString(type), DBusString(cls), DBusString(desktop), DBusString(seat_id), DBusUint32(vtnr), DBusString(tty), DBusString(display), DBusBoolean(remote), DBusString(remote_user), DBusString(remote_host), DBusUint64(flags), DBusArray(DBusSignature("(sv)"), properties.map((child) => DBusStruct(child)))], replySignature: DBusSignature("soshusub"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.login1.Manager.ReleaseSession()
  Future<void> callReleaseSession(String session_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "ReleaseSession", [DBusString(session_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.ActivateSession()
  Future<void> callActivateSession(String session_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "ActivateSession", [DBusString(session_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.ActivateSessionOnSeat()
  Future<void> callActivateSessionOnSeat(String session_id, String seat_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "ActivateSessionOnSeat", [DBusString(session_id), DBusString(seat_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.LockSession()
  Future<void> callLockSession(String session_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "LockSession", [DBusString(session_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.UnlockSession()
  Future<void> callUnlockSession(String session_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "UnlockSession", [DBusString(session_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.LockSessions()
  Future<void> callLockSessions({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "LockSessions", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.UnlockSessions()
  Future<void> callUnlockSessions({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "UnlockSessions", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.KillSession()
  Future<void> callKillSession(String session_id, String whom, int signal_number, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "KillSession", [DBusString(session_id), DBusString(whom), DBusInt32(signal_number)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.KillUser()
  Future<void> callKillUser(int uid, int signal_number, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "KillUser", [DBusUint32(uid), DBusInt32(signal_number)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.TerminateSession()
  Future<void> callTerminateSession(String session_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "TerminateSession", [DBusString(session_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.TerminateUser()
  Future<void> callTerminateUser(int uid, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "TerminateUser", [DBusUint32(uid)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.TerminateSeat()
  Future<void> callTerminateSeat(String seat_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "TerminateSeat", [DBusString(seat_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.SetUserLinger()
  Future<void> callSetUserLinger(int uid, bool enable, bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SetUserLinger", [DBusUint32(uid), DBusBoolean(enable), DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.AttachDevice()
  Future<void> callAttachDevice(String seat_id, String sysfs_path, bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "AttachDevice", [DBusString(seat_id), DBusString(sysfs_path), DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.FlushDevices()
  Future<void> callFlushDevices(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "FlushDevices", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.PowerOff()
  Future<void> callPowerOff(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "PowerOff", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.PowerOffWithFlags()
  Future<void> callPowerOffWithFlags(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "PowerOffWithFlags", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.Reboot()
  Future<void> callReboot(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "Reboot", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.RebootWithFlags()
  Future<void> callRebootWithFlags(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "RebootWithFlags", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.Halt()
  Future<void> callHalt(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "Halt", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.HaltWithFlags()
  Future<void> callHaltWithFlags(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "HaltWithFlags", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.Suspend()
  Future<void> callSuspend(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "Suspend", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.SuspendWithFlags()
  Future<void> callSuspendWithFlags(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SuspendWithFlags", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.Hibernate()
  Future<void> callHibernate(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "Hibernate", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.HibernateWithFlags()
  Future<void> callHibernateWithFlags(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "HibernateWithFlags", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.HybridSleep()
  Future<void> callHybridSleep(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "HybridSleep", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.HybridSleepWithFlags()
  Future<void> callHybridSleepWithFlags(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "HybridSleepWithFlags", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.SuspendThenHibernate()
  Future<void> callSuspendThenHibernate(bool interactive, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SuspendThenHibernate", [DBusBoolean(interactive)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.SuspendThenHibernateWithFlags()
  Future<void> callSuspendThenHibernateWithFlags(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SuspendThenHibernateWithFlags", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.Sleep()
  Future<void> callSleep(int flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "Sleep", [DBusUint64(flags)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.CanPowerOff()
  Future<String> callCanPowerOff({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanPowerOff", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.CanReboot()
  Future<String> callCanReboot({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanReboot", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.CanHalt()
  Future<String> callCanHalt({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanHalt", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.CanSuspend()
  Future<String> callCanSuspend({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanSuspend", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.CanHibernate()
  Future<String> callCanHibernate({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanHibernate", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.CanHybridSleep()
  Future<String> callCanHybridSleep({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanHybridSleep", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.CanSuspendThenHibernate()
  Future<String> callCanSuspendThenHibernate({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanSuspendThenHibernate", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.CanSleep()
  Future<String> callCanSleep({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanSleep", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.ScheduleShutdown()
  Future<void> callScheduleShutdown(String type, int usec, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "ScheduleShutdown", [DBusString(type), DBusUint64(usec)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.CancelScheduledShutdown()
  Future<bool> callCancelScheduledShutdown({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CancelScheduledShutdown", [], replySignature: DBusSignature("b"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asBoolean();
  }

  /// Invokes org.freedesktop.login1.Manager.Inhibit()
  Future<ResourceHandle> callInhibit(String what, String who, String why, String mode, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "Inhibit", [DBusString(what), DBusString(who), DBusString(why), DBusString(mode)], replySignature: DBusSignature("h"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asUnixFd();
  }

  /// Invokes org.freedesktop.login1.Manager.CanRebootParameter()
  Future<String> callCanRebootParameter({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanRebootParameter", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.SetRebootParameter()
  Future<void> callSetRebootParameter(String parameter, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SetRebootParameter", [DBusString(parameter)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.CanRebootToFirmwareSetup()
  Future<String> callCanRebootToFirmwareSetup({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanRebootToFirmwareSetup", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.SetRebootToFirmwareSetup()
  Future<void> callSetRebootToFirmwareSetup(bool enable, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SetRebootToFirmwareSetup", [DBusBoolean(enable)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.CanRebootToBootLoaderMenu()
  Future<String> callCanRebootToBootLoaderMenu({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanRebootToBootLoaderMenu", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.SetRebootToBootLoaderMenu()
  Future<void> callSetRebootToBootLoaderMenu(int timeout, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SetRebootToBootLoaderMenu", [DBusUint64(timeout)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.CanRebootToBootLoaderEntry()
  Future<String> callCanRebootToBootLoaderEntry({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Manager", "CanRebootToBootLoaderEntry", [], replySignature: DBusSignature("s"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.login1.Manager.SetRebootToBootLoaderEntry()
  Future<void> callSetRebootToBootLoaderEntry(String boot_loader_entry, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SetRebootToBootLoaderEntry", [DBusString(boot_loader_entry)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Manager.SetWallMessage()
  Future<void> callSetWallMessage(String wall_message, bool enable, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Manager", "SetWallMessage", [DBusString(wall_message), DBusBoolean(enable)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
