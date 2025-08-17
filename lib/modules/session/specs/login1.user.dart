// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object org.freedesktop.login1.user.xml

// ignore_for_file: non_constant_identifier_names, use_super_parameters

import "package:dbus/dbus.dart";

class OrgFreedesktopLogin1User extends DBusRemoteObject {
  OrgFreedesktopLogin1User(DBusClient client, String destination, DBusObjectPath path) : super(client, name: destination, path: path);

  /// Gets org.freedesktop.login1.User.UID
  Future<int> getUID() async {
    var value = await getProperty("org.freedesktop.login1.User", "UID", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets org.freedesktop.login1.User.GID
  Future<int> getGID() async {
    var value = await getProperty("org.freedesktop.login1.User", "GID", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets org.freedesktop.login1.User.Name
  Future<String> getName() async {
    var value = await getProperty("org.freedesktop.login1.User", "Name", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.User.Timestamp
  Future<int> getTimestamp() async {
    var value = await getProperty("org.freedesktop.login1.User", "Timestamp", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.User.TimestampMonotonic
  Future<int> getTimestampMonotonic() async {
    var value = await getProperty("org.freedesktop.login1.User", "TimestampMonotonic", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.User.RuntimePath
  Future<String> getRuntimePath() async {
    var value = await getProperty("org.freedesktop.login1.User", "RuntimePath", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.User.Service
  Future<String> getService() async {
    var value = await getProperty("org.freedesktop.login1.User", "Service", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.User.Slice
  Future<String> getSlice() async {
    var value = await getProperty("org.freedesktop.login1.User", "Slice", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.User.Display
  Future<List<DBusValue>> getDisplay() async {
    var value = await getProperty("org.freedesktop.login1.User", "Display", signature: DBusSignature("(so)"));
    return value.asStruct();
  }

  /// Gets org.freedesktop.login1.User.State
  Future<String> getState() async {
    var value = await getProperty("org.freedesktop.login1.User", "State", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.freedesktop.login1.User.Sessions
  Future<List<List<DBusValue>>> getSessions() async {
    var value = await getProperty("org.freedesktop.login1.User", "Sessions", signature: DBusSignature("a(so)"));
    return value.asArray().map((child) => child.asStruct()).toList();
  }

  /// Gets org.freedesktop.login1.User.IdleHint
  Future<bool> getIdleHint() async {
    var value = await getProperty("org.freedesktop.login1.User", "IdleHint", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.login1.User.IdleSinceHint
  Future<int> getIdleSinceHint() async {
    var value = await getProperty("org.freedesktop.login1.User", "IdleSinceHint", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.User.IdleSinceHintMonotonic
  Future<int> getIdleSinceHintMonotonic() async {
    var value = await getProperty("org.freedesktop.login1.User", "IdleSinceHintMonotonic", signature: DBusSignature("t"));
    return value.asUint64();
  }

  /// Gets org.freedesktop.login1.User.Linger
  Future<bool> getLinger() async {
    var value = await getProperty("org.freedesktop.login1.User", "Linger", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Invokes org.freedesktop.login1.User.Terminate()
  Future<void> callTerminate({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.User", "Terminate", [], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.login1.User.Kill()
  Future<void> callKill(int signal_number, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.login1.User", "Kill", [DBusInt32(signal_number)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
