// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object spec/DBusMenu.xml

import "package:dbus/dbus.dart";

/// Signal data for com.canonical.dbusmenu.ItemsPropertiesUpdated.
class ComCanonicalDbusmenuItemsPropertiesUpdated extends DBusSignal {
  List<List<DBusValue>> get updatedProps => values[0].asArray().map((child) => child.asStruct()).toList();
  List<List<DBusValue>> get removedProps => values[1].asArray().map((child) => child.asStruct()).toList();

  ComCanonicalDbusmenuItemsPropertiesUpdated(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for com.canonical.dbusmenu.LayoutUpdated.
class ComCanonicalDbusmenuLayoutUpdated extends DBusSignal {
  int get revision => values[0].asUint32();
  int get parent => values[1].asInt32();

  ComCanonicalDbusmenuLayoutUpdated(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for com.canonical.dbusmenu.ItemActivationRequested.
class ComCanonicalDbusmenuItemActivationRequested extends DBusSignal {
  int get id => values[0].asInt32();
  int get timestamp => values[1].asUint32();

  ComCanonicalDbusmenuItemActivationRequested(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class ComCanonicalDbusmenu extends DBusRemoteObject {
  /// Stream of com.canonical.dbusmenu.ItemsPropertiesUpdated signals.
  late final Stream<ComCanonicalDbusmenuItemsPropertiesUpdated> itemsPropertiesUpdated;

  /// Stream of com.canonical.dbusmenu.LayoutUpdated signals.
  late final Stream<ComCanonicalDbusmenuLayoutUpdated> layoutUpdated;

  /// Stream of com.canonical.dbusmenu.ItemActivationRequested signals.
  late final Stream<ComCanonicalDbusmenuItemActivationRequested> itemActivationRequested;

  ComCanonicalDbusmenu(DBusClient client, String destination, {DBusObjectPath path = const DBusObjectPath.unchecked("/")}) : super(client, name: destination, path: path) {
    itemsPropertiesUpdated = DBusRemoteObjectSignalStream(object: this, interface: "com.canonical.dbusmenu", name: "ItemsPropertiesUpdated", signature: DBusSignature("a(ia{sv})a(ias)")).asBroadcastStream().map((signal) => ComCanonicalDbusmenuItemsPropertiesUpdated(signal));

    layoutUpdated = DBusRemoteObjectSignalStream(object: this, interface: "com.canonical.dbusmenu", name: "LayoutUpdated", signature: DBusSignature("ui")).asBroadcastStream().map((signal) => ComCanonicalDbusmenuLayoutUpdated(signal));

    itemActivationRequested = DBusRemoteObjectSignalStream(object: this, interface: "com.canonical.dbusmenu", name: "ItemActivationRequested", signature: DBusSignature("iu")).asBroadcastStream().map((signal) => ComCanonicalDbusmenuItemActivationRequested(signal));
  }

  /// Gets com.canonical.dbusmenu.Version
  Future<int> getVersion() async {
    var value = await getProperty("com.canonical.dbusmenu", "Version", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets com.canonical.dbusmenu.TextDirection
  Future<String> getTextDirection() async {
    var value = await getProperty("com.canonical.dbusmenu", "TextDirection", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets com.canonical.dbusmenu.Status
  Future<String> getStatus() async {
    var value = await getProperty("com.canonical.dbusmenu", "Status", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets com.canonical.dbusmenu.IconThemePath
  Future<List<String>> getIconThemePath() async {
    var value = await getProperty("com.canonical.dbusmenu", "IconThemePath", signature: DBusSignature("as"));
    return value.asStringArray().toList();
  }

  /// Invokes com.canonical.dbusmenu.GetLayout()
  Future<List<DBusValue>> callGetLayout(int parentId, int recursionDepth, List<String> propertyNames, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("com.canonical.dbusmenu", "GetLayout", [DBusInt32(parentId), DBusInt32(recursionDepth), DBusArray.string(propertyNames)], replySignature: DBusSignature("u(ia{sv}av)"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Invokes com.canonical.dbusmenu.GetGroupProperties()
  Future<List<List<DBusValue>>> callGetGroupProperties(List<int> ids, List<String> propertyNames, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("com.canonical.dbusmenu", "GetGroupProperties", [DBusArray.int32(ids), DBusArray.string(propertyNames)], replySignature: DBusSignature("a(ia{sv})"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes com.canonical.dbusmenu.GetProperty()
  Future<DBusValue> callGetProperty(int id, String name, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("com.canonical.dbusmenu", "GetProperty", [DBusInt32(id), DBusString(name)], replySignature: DBusSignature("v"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asVariant();
  }

  /// Invokes com.canonical.dbusmenu.Event()
  Future<void> callEvent(int id, String eventId, DBusValue data, int timestamp, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("com.canonical.dbusmenu", "Event", [DBusInt32(id), DBusString(eventId), DBusVariant(data), DBusUint32(timestamp)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes com.canonical.dbusmenu.EventGroup()
  Future<List<int>> callEventGroup(List<List<DBusValue>> events, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("com.canonical.dbusmenu", "EventGroup", [DBusArray(DBusSignature("(isvu)"), events.map((child) => DBusStruct(child)))], replySignature: DBusSignature("ai"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asInt32Array().toList();
  }

  /// Invokes com.canonical.dbusmenu.AboutToShow()
  Future<bool> callAboutToShow(int id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("com.canonical.dbusmenu", "AboutToShow", [DBusInt32(id)], replySignature: DBusSignature("b"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asBoolean();
  }

  /// Invokes com.canonical.dbusmenu.AboutToShowGroup()
  Future<List<DBusValue>> callAboutToShowGroup(List<int> ids, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod("com.canonical.dbusmenu", "AboutToShowGroup", [DBusArray.int32(ids)], replySignature: DBusSignature("aiai"), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }
}
