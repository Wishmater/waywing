// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.login1.seat.xml

// ignore_for_file: non_constant_identifier_names, use_super_parameters

import "package:dbus/dbus.dart";

class OrgFreedesktopLogin1Seat extends DBusRemoteObject {
  OrgFreedesktopLogin1Seat(DBusClient client, String destination, DBusObjectPath path) : super(client, name: destination, path: path);

  /// Gets org.freedesktop.login1.Seat.Id
  Future<String> getId() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "Id", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.Seat.ActiveSession
  Future<List<DBusValue>> getActiveSession() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "ActiveSession", signature: DBusSignature("(so)"));
    return value.asStruct();
  }

  /// Gets org.freedesktop.login1.Seat.CanTTY
  Future<bool> getCanTTY() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "CanTTY", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Seat.CanGraphical
  Future<bool> getCanGraphical() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "CanGraphical", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Seat.Sessions
  Future<List<List<DBusValue>>> getSessions() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "Sessions", signature: DBusSignature("a(so)"));
    return value.asArray().map((child) => child.asStruct()).toList();
  }

  /// Gets org.freedesktop.login1.Seat.IdleHint
  Future<bool> getIdleHint() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "IdleHint", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.Seat.IdleSinceHint
  Future<int> getIdleSinceHint() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "IdleSinceHint", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.Seat.IdleSinceHintMonotonic
  Future<int> getIdleSinceHintMonotonic() async {
    var value = await getProperty("org.freedesktop.login1.Seat", "IdleSinceHintMonotonic", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Invokes org.freedesktop.login1.Seat.Terminate()
  Future<void> callTerminate({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Seat", "Terminate", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Seat.ActivateSession()
  Future<void> callActivateSession(String session_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Seat", "ActivateSession", [DBusString(session_id)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Seat.SwitchTo()
  Future<void> callSwitchTo(int vtnr, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Seat", "SwitchTo", [DBusUint32(vtnr)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Seat.SwitchToNext()
  Future<void> callSwitchToNext({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Seat", "SwitchToNext", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.Seat.SwitchToPrevious()
  Future<void> callSwitchToPrevious({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.Seat", "SwitchToPrevious", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
