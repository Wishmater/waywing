// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object spec/StatusNotifierWatcher.xml

import "package:dbus/dbus.dart";

/// Signal data for org.kde.StatusNotifierWatcher.StatusNotifierItemRegistered.
class OrgKdeStatusNotifierWatcherStatusNotifierItemRegistered extends DBusSignal {
  String get arg_0 => values[0].asString();

  OrgKdeStatusNotifierWatcherStatusNotifierItemRegistered(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierWatcher.StatusNotifierItemUnregistered.
class OrgKdeStatusNotifierWatcherStatusNotifierItemUnregistered extends DBusSignal {
  String get arg_0 => values[0].asString();

  OrgKdeStatusNotifierWatcherStatusNotifierItemUnregistered(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierWatcher.StatusNotifierHostRegistered.
class OrgKdeStatusNotifierWatcherStatusNotifierHostRegistered extends DBusSignal {
  OrgKdeStatusNotifierWatcherStatusNotifierHostRegistered(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierWatcher.StatusNotifierHostUnregistered.
class OrgKdeStatusNotifierWatcherStatusNotifierHostUnregistered extends DBusSignal {
  OrgKdeStatusNotifierWatcherStatusNotifierHostUnregistered(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class OrgKdeStatusNotifierWatcher extends DBusRemoteObject {
  /// Stream of org.kde.StatusNotifierWatcher.StatusNotifierItemRegistered signals.
  late final Stream<OrgKdeStatusNotifierWatcherStatusNotifierItemRegistered> statusNotifierItemRegistered;

  /// Stream of org.kde.StatusNotifierWatcher.StatusNotifierItemUnregistered signals.
  late final Stream<OrgKdeStatusNotifierWatcherStatusNotifierItemUnregistered> statusNotifierItemUnregistered;

  /// Stream of org.kde.StatusNotifierWatcher.StatusNotifierHostRegistered signals.
  late final Stream<OrgKdeStatusNotifierWatcherStatusNotifierHostRegistered> statusNotifierHostRegistered;

  /// Stream of org.kde.StatusNotifierWatcher.StatusNotifierHostUnregistered signals.
  late final Stream<OrgKdeStatusNotifierWatcherStatusNotifierHostUnregistered> statusNotifierHostUnregistered;

  OrgKdeStatusNotifierWatcher(DBusClient client, String destination, DBusObjectPath path) : super(client, name: destination, path: path) {
    statusNotifierItemRegistered = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierWatcher", name: "StatusNotifierItemRegistered", signature: DBusSignature("s")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierWatcherStatusNotifierItemRegistered(signal));

    statusNotifierItemUnregistered = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierWatcher", name: "StatusNotifierItemUnregistered", signature: DBusSignature("s")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierWatcherStatusNotifierItemUnregistered(signal));

    statusNotifierHostRegistered = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierWatcher", name: "StatusNotifierHostRegistered", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierWatcherStatusNotifierHostRegistered(signal));

    statusNotifierHostUnregistered = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierWatcher", name: "StatusNotifierHostUnregistered", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierWatcherStatusNotifierHostUnregistered(signal));
  }

  /// Gets org.kde.StatusNotifierWatcher.RegisteredStatusNotifierItems
  Future<List<String>> getRegisteredStatusNotifierItems() async {
    var value = await getProperty("org.kde.StatusNotifierWatcher", "RegisteredStatusNotifierItems", signature: DBusSignature("as"));
    return value.asStringArray().toList();
  }

  /// Gets org.kde.StatusNotifierWatcher.IsStatusNotifierHostRegistered
  Future<bool> getIsStatusNotifierHostRegistered() async {
    var value = await getProperty("org.kde.StatusNotifierWatcher", "IsStatusNotifierHostRegistered", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.kde.StatusNotifierWatcher.ProtocolVersion
  Future<int> getProtocolVersion() async {
    var value = await getProperty("org.kde.StatusNotifierWatcher", "ProtocolVersion", signature: DBusSignature("i"));
    return value.asInt32();
  }

  /// Invokes org.kde.StatusNotifierWatcher.RegisterStatusNotifierItem()
  Future<void> callRegisterStatusNotifierItem(String service, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.kde.StatusNotifierWatcher", "RegisterStatusNotifierItem", [DBusString(service)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.kde.StatusNotifierWatcher.RegisterStatusNotifierHost()
  Future<void> callRegisterStatusNotifierHost(String service, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.kde.StatusNotifierWatcher", "RegisterStatusNotifierHost", [DBusString(service)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
