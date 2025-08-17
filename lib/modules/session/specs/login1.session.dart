// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.login1.session.xml

// ignore_for_file: non_constant_identifier_names, use_super_parameters

import "dart:io";
import "package:dbus/dbus.dart";

/// Signal data for org.freedesktop.login1.Session.PauseDevice.
class OrgFreedesktopLogin1SessionPauseDevice extends DBusSignal {
  int get major => values[0].asUint32();
  int get minor => values[1].asUint32();
  String get type => values[2].asString();

  OrgFreedesktopLogin1SessionPauseDevice(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Session.ResumeDevice.
class OrgFreedesktopLogin1SessionResumeDevice extends DBusSignal {
  int get major => values[0].asUint32();
  int get minor => values[1].asUint32();
  ResourceHandle get fd => values[2].asUnixFd();

  OrgFreedesktopLogin1SessionResumeDevice(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Session.Lock.
class OrgFreedesktopLogin1SessionLock extends DBusSignal {
  OrgFreedesktopLogin1SessionLock(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.login1.Session.Unlock.
class OrgFreedesktopLogin1SessionUnlock extends DBusSignal {
  OrgFreedesktopLogin1SessionUnlock(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class OrgFreedesktopLogin1Session extends DBusRemoteObject {
  /// Stream of org.freedesktop.login1.Session.PauseDevice signals.
  late final Stream<OrgFreedesktopLogin1SessionPauseDevice> pauseDevice;

  /// Stream of org.freedesktop.login1.Session.ResumeDevice signals.
  late final Stream<OrgFreedesktopLogin1SessionResumeDevice> resumeDevice;

  /// Stream of org.freedesktop.login1.Session.Lock signals.
  late final Stream<OrgFreedesktopLogin1SessionLock> lock;

  /// Stream of org.freedesktop.login1.Session.Unlock signals.
  late final Stream<OrgFreedesktopLogin1SessionUnlock> unlock;

  OrgFreedesktopLogin1Session(DBusClient client, String destination, DBusObjectPath path) : super(client, name: destination, path: path) {
    pauseDevice = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Session", name: "PauseDevice", signature: DBusSignature("uus")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1SessionPauseDevice(signal));

    resumeDevice = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Session", name: "ResumeDevice", signature: DBusSignature("uuh")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1SessionResumeDevice(signal));

    lock = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Session", name: "Lock", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1SessionLock(signal));

    unlock = DBusRemoteObjectSignalStream(object: this, interface: "org.freedesktop.login1.Session", name: "Unlock", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgFreedesktopLogin1SessionUnlock(signal));
  }

  /// Gets org.freedesktop.login1.Session.Id
  Future<String> getId() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Id", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.User
  Future<List<DBusValue>> getUser() async {
    var value = await getProperty("org.freedesktop.login1.Session", "User", signature: DBusSignature("(uo)"));
    return value.asStruct();
  }

  /// Gets org.freedesktop.login1.Session.Name
  Future<String> getName() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Name", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Timestamp
  Future<int> getTimestamp() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Timestamp", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Session.TimestampMonotonic
  Future<int> getTimestampMonotonic() async {
    var value = await getProperty("org.freedesktop.login1.Session", "TimestampMonotonic", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Session.VTNr
  Future<int> getVTNr() async {
    var value = await getProperty("org.freedesktop.login1.Session", "VTNr", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets org.freedesktop.login1.Session.Seat
  Future<List<DBusValue>> getSeat() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Seat", signature: DBusSignature("(so)"));
    return value.asStruct();
  }

  /// Gets org.freedesktop.login1.Session.TTY
  Future<String> getTTY() async {
    var value = await getProperty("org.freedesktop.login1.Session", "TTY", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Display
  Future<String> getDisplay() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Display", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Remote
  Future<bool> getRemote() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Remote", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Session.RemoteHost
  Future<String> getRemoteHost() async {
    var value = await getProperty("org.freedesktop.login1.Session", "RemoteHost", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.RemoteUser
  Future<String> getRemoteUser() async {
    var value = await getProperty("org.freedesktop.login1.Session", "RemoteUser", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Service
  Future<String> getService() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Service", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Desktop
  Future<String> getDesktop() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Desktop", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Scope
  Future<String> getScope() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Scope", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Leader
  Future<int> getLeader() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Leader", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets org.freedesktop.login1.Session.Audit
  Future<int> getAudit() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Audit", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets org.freedesktop.login1.Session.Type
  Future<String> getType() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Type", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Class
  Future<String> getClass() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Class", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.Active
  Future<bool> getActive() async {
    var value = await getProperty("org.freedesktop.login1.Session", "Active", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Session.State
  Future<String> getState() async {
    var value = await getProperty("org.freedesktop.login1.Session", "State", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Session.IdleHint
  Future<bool> getIdleHint() async {
    var value = await getProperty("org.freedesktop.login1.Session", "IdleHint", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Session.IdleSinceHint
  Future<int> getIdleSinceHint() async {
    var value = await getProperty("org.freedesktop.login1.Session", "IdleSinceHint", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Session.IdleSinceHintMonotonic
  Future<int> getIdleSinceHintMonotonic() async {
    var value = await getProperty("org.freedesktop.login1.Session", "IdleSinceHintMonotonic", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Session.CanIdle
  Future<bool> getCanIdle() async {
    var value = await getProperty("org.freedesktop.login1.Session", "CanIdle", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Session.CanLock
  Future<bool> getCanLock() async {
    var value = await getProperty("org.freedesktop.login1.Session", "CanLock", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Session.LockedHint
  Future<bool> getLockedHint() async {
    var value = await getProperty("org.freedesktop.login1.Session", "LockedHint", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Invokes org.freedesktop.login1.Session.Terminate()
  Future<void> callTerminate({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "Terminate", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.Activate()
  Future<void> callActivate({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "Activate", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.Lock()
  Future<void> callLock({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "Lock", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.Unlock()
  Future<void> callUnlock({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "Unlock", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.SetIdleHint()
  Future<void> callSetIdleHint(bool idle, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "SetIdleHint", [DBusBoolean(idle)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.SetLockedHint()
  Future<void> callSetLockedHint(bool locked, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "SetLockedHint", [DBusBoolean(locked)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.Kill()
  Future<void> callKill(String whom, int signal_number, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "Kill", [DBusString(whom), DBusInt32(signal_number)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.TakeControl()
  Future<void> callTakeControl(bool force, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "TakeControl", [DBusBoolean(force)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.ReleaseControl()
  Future<void> callReleaseControl({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "ReleaseControl", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.SetType()
  Future<void> callSetType(String type, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "SetType", [DBusString(type)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.SetClass()
  Future<void> callSetClass(String cls, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "SetClass", [DBusString(cls)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.SetDisplay()
  Future<void> callSetDisplay(String display, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "SetDisplay", [DBusString(display)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.SetTTY()
  Future<void> callSetTTY(ResourceHandle tty_fd, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "SetTTY", [DBusUnixFd(tty_fd)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.TakeDevice()
  Future<List<DBusValue>> callTakeDevice(int major, int minor, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("org.freedesktop.login1.Session", "TakeDevice", [DBusUint32(major), DBusUint32(minor)], replySignature: DBusSignature("hb"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes org.freedesktop.login1.Session.ReleaseDevice()
  Future<void> callReleaseDevice(int major, int minor, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "ReleaseDevice", [DBusUint32(major), DBusUint32(minor)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.PauseDeviceComplete()
  Future<void> callPauseDeviceComplete(int major, int minor, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "PauseDeviceComplete", [DBusUint32(major), DBusUint32(minor)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Session.SetBrightness()
  Future<void> callSetBrightness(String subsystem, String name, int brightness, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Session", "SetBrightness", [DBusString(subsystem), DBusString(name), DBusUint32(brightness)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
