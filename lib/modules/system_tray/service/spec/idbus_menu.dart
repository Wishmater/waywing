// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object spec/DBusMenu.xml

// ignore_for_file: use_super_parameters, unintended_html_in_doc_comment

import "dart:async";

import "package:dbus/dbus.dart";

/// Signal data for com.canonical.dbusmenu.ItemsPropertiesUpdated.
///
/// {@template ItemsPropertiesUpdated}
/// Triggered when there are lots of property updates across many items
/// so they all get grouped into a single dbus message. The format is
/// the ID of the item with a hashtable of names and values for those
/// properties.
/// {@endtemplate}
class ComCanonicalDbusmenuItemsPropertiesUpdated extends DBusSignal {
  List<List<DBusValue>> get updatedProps => values[0].asArray().map((child) => child.asStruct()).toList();
  List<List<DBusValue>> get removedProps => values[1].asArray().map((child) => child.asStruct()).toList();

  ComCanonicalDbusmenuItemsPropertiesUpdated(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for com.canonical.dbusmenu.LayoutUpdated.
///
/// {@template LayoutUpdated}
/// Triggered by the application to notify display of a layout update, up to revision
/// {@endtemplate}
class ComCanonicalDbusmenuLayoutUpdated extends DBusSignal {
  /// The revision of the layout that we're currently on
  int get revision => values[0].asUint32();

  /// If the layout update is only of a subtree, this is the
  /// parent item for the entries that have changed. It is zero if
  /// the whole layout should be considered invalid.
  int get parent => values[1].asInt32();

  ComCanonicalDbusmenuLayoutUpdated(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for com.canonical.dbusmenu.ItemActivationRequested.
///
/// {@template ItemActivationRequested}
/// The server is requesting that all clients displaying this
/// menu open it to the user.  This would be for things like
/// hotkeys that when the user presses them the menu should
/// open and display itself to the user.
/// {@endtemplate}
class ComCanonicalDbusmenuItemActivationRequested extends DBusSignal {
  /// ID of the menu that should be activated
  int get id => values[0].asInt32();

  /// The time that the event occured
  int get timestamp => values[1].asUint32();

  ComCanonicalDbusmenuItemActivationRequested(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

class ComCanonicalDbusmenu extends DBusRemoteObject {
  /// Stream of com.canonical.dbusmenu.ItemsPropertiesUpdated signals.
  ///
  /// {@macro ItemsPropertiesUpdated}
  late final Stream<ComCanonicalDbusmenuItemsPropertiesUpdated> itemsPropertiesUpdated;

  /// Stream of com.canonical.dbusmenu.LayoutUpdated signals.
  ///
  /// {@macro LayoutUpdated}
  late final Stream<ComCanonicalDbusmenuLayoutUpdated> layoutUpdated;

  /// Stream of com.canonical.dbusmenu.ItemActivationRequested signals.
  ///
  /// {@macro ItemActivationRequested}
  late final Stream<ComCanonicalDbusmenuItemActivationRequested> itemActivationRequested;

  ComCanonicalDbusmenu(
    DBusClient client,
    String destination, {
    DBusObjectPath path = const DBusObjectPath.unchecked("/"),
  }) : super(client, name: destination, path: path) {
    itemsPropertiesUpdated = DBusRemoteObjectSignalStream(
      object: this,
      interface: "com.canonical.dbusmenu",
      name: "ItemsPropertiesUpdated",
      signature: DBusSignature("a(ia{sv})a(ias)"),
    ).asBroadcastStream().map((signal) => ComCanonicalDbusmenuItemsPropertiesUpdated(signal));

    layoutUpdated = DBusRemoteObjectSignalStream(
      object: this,
      interface: "com.canonical.dbusmenu",
      name: "LayoutUpdated",
      signature: DBusSignature("ui"),
    ).asBroadcastStream().map((signal) => ComCanonicalDbusmenuLayoutUpdated(signal));

    itemActivationRequested = DBusRemoteObjectSignalStream(
      object: this,
      interface: "com.canonical.dbusmenu",
      name: "ItemActivationRequested",
      signature: DBusSignature("iu"),
    ).asBroadcastStream().map((signal) => ComCanonicalDbusmenuItemActivationRequested(signal));
  }

  /// Gets com.canonical.dbusmenu.Version
  ///
  /// Provides the version of the DBusmenu API that this API is implementing.
  Future<int> getVersion() async {
    var value = await getProperty("com.canonical.dbusmenu", "Version", signature: DBusSignature("u"));
    return value.asUint32();
  }

  /// Gets com.canonical.dbusmenu.TextDirection
  ///
  /// Represents the way the text direction of the application. This
  /// allows the server to handle mismatches intelligently. For left-to-right
  /// the string is "ltr" for right-to-left it is "rtl".
  Future<String> getTextDirection() async {
    var value = await getProperty("com.canonical.dbusmenu", "TextDirection", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets com.canonical.dbusmenu.Status
  ///
  /// Tells if the menus are in a normal state or they believe that they
  /// could use some attention. Cases for showing them would be if help
  /// were referring to them or they accessors were being highlighted.
  /// This property can have two values: "normal" in almost all cases and
  /// "notice" when they should have a higher priority to be shown.
  Future<String> getStatus() async {
    var value = await getProperty("com.canonical.dbusmenu", "Status", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets com.canonical.dbusmenu.IconThemePath
  ///
  /// A list of directories that should be used for finding icons using
  /// the icon naming spec.  Idealy there should only be one for the icon
  /// theme, but additional ones are often added by applications for
  /// app specific icons.
  Future<List<String>> getIconThemePath() async {
    var value = await getProperty("com.canonical.dbusmenu", "IconThemePath", signature: DBusSignature("as"));
    return value.asStringArray().toList();
  }

  /// Invokes com.canonical.dbusmenu.GetLayout()
  ///
  /// Provides the layout and propertiers that are attached to the entries
  /// that are in the layout. It only gives the items that are children
  /// of the item that is specified with [parentId]. It will return all of the
  /// properties or specific ones depending of the value in a propertyNames.
  ///
  /// The format is recursive, where the second 'v' is in the same format
  /// as the original 'a(ia{sv}av)'. Its content depends on the value
  /// of [recursionDepth].
  ///
  /// **[parentId]** The ID of the parent node for the layout. For
  /// grabbing the layout from the root node use zero
  ///
  /// **[recursionDepth]** The amount of levels of recursion to use. This affects the
  ///   content of the second variant array.
  ///   - -1: deliver all the items under the @a parentId.
  ///   - 0: no recursion, the array will be empty.
  ///   - n: array will contains items up to 'n' level depth.
  ///
  /// **[propertyNames]** The list of item properties we are
  ///	  interested in. If there are no entries in the list all of
  ///	  the properties will be sent.
  ///
  /// **@returns**
  ///
  ///   _revision_: The revision number of the layout. For matching
  ///	  with layoutUpdated signals.
  ///
  ///   _layout_: The layout, as a recursive structure.
  Future<List<DBusValue>> callGetLayout(
    int parentId,
    int recursionDepth,
    List<String> propertyNames, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "com.canonical.dbusmenu",
      "GetLayout",
      [DBusInt32(parentId), DBusInt32(recursionDepth), DBusArray.string(propertyNames)],
      replySignature: DBusSignature("u(ia{sv}av)"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Invokes com.canonical.dbusmenu.GetGroupProperties()
  ///
  /// Returns a list of items where each item is represented as a struct following
  /// this format:
  /// id: unsigned the item id
  /// properties: map(string => variant) the requested item properties
  ///
  /// **[ids]** A list of ids that we should be finding the properties
  /// on. If the list is empty, all menu items should be sent.
  ///
  /// **[propertyNames]** The list of item properties we are
  /// interested in. If there are no entries in the list all of
  /// the properties will be sent.
  Future<List<List<DBusValue>>> callGetGroupProperties(
    List<int> ids,
    List<String> propertyNames, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "com.canonical.dbusmenu",
      "GetGroupProperties",
      [DBusArray.int32(ids), DBusArray.string(propertyNames)],
      replySignature: DBusSignature("a(ia{sv})"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes com.canonical.dbusmenu.GetProperty()
  ///
  /// Get a signal property on a single item. This is not useful if you're
  /// going to implement this interface, it should only be used if you're
  /// debugging via a commandline tool.
  Future<DBusValue> callGetProperty(
    int id,
    String name, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "com.canonical.dbusmenu",
      "GetProperty",
      [DBusInt32(id), DBusString(name)],
      replySignature: DBusSignature("v"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asVariant();
  }

  /// Invokes com.canonical.dbusmenu.Event()
  ///
  /// This is called by the applet to notify the application an event happened on a
  /// menu item.
  ///
  /// **[id]** the id of the item which received the event
  ///
  /// **[eventId]** the type of event. Can be "clicked", "hovered", "opened", "closed"
  /// or a vendor specific event  can be added by prefixing them with "x-<vendor>-"
  ///
  /// **[data]** event-specific data
  ///
  /// **[timestamp]** The time that the event occured if available or the time the message was sent if not
  Future<void> callEvent(
    int id,
    String eventId,
    DBusValue data,
    int timestamp, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      "com.canonical.dbusmenu",
      "Event",
      [DBusInt32(id), DBusString(eventId), DBusVariant(data), DBusUint32(timestamp)],
      replySignature: DBusSignature(""),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes com.canonical.dbusmenu.EventGroup()
  ///
  /// Used to pass a set of events as a single message for possibily several
  /// different menuitems. This is done to optimize DBus traffic.
  ///
  /// **[events]** An array of all the events that should be passed. This tuple should
  /// match the parameters of the 'Event' signal. Which is roughly:
  /// id, eventID, data and timestamp.
  ///
  /// **@returns** I list of menuitem IDs that couldn't be found. If none of the ones
  /// in the list can be found, a DBus error is returned.
  Future<List<int>> callEventGroup(
    List<List<DBusValue>> events, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "com.canonical.dbusmenu",
      "EventGroup",
      [DBusArray(DBusSignature("(isvu)"), events.map((child) => DBusStruct(child)))],
      replySignature: DBusSignature("ai"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asInt32Array().toList();
  }

  /// Invokes com.canonical.dbusmenu.AboutToShow()
  ///
  /// This is called by the applet to notify the application that it is about
  /// to show the menu under the specified item.
  ///
  /// **[id]** Which menu item represents the parent of the item about to be shown.
  ///
  /// **@returns** Whether this AboutToShow event should result in the menu being updated.
  Future<bool> callAboutToShow(int id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod(
      "com.canonical.dbusmenu",
      "AboutToShow",
      [DBusInt32(id)],
      replySignature: DBusSignature("b"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asBoolean();
  }

  /// Invokes com.canonical.dbusmenu.AboutToShowGroup()
  ///
  /// A function to tell several menus being shown that they are about to
  /// be shown to the user. This is likely only useful for programitc purposes
  /// so while the return values are returned, in general, the singular function
  /// should be used in most user interacation scenarios.
  ///
  /// **[ids]** The IDs of the menu items who's submenus are being shown.
  ///
  /// **@returns**
  ///
  /// updatesNeeded: The IDs of the menus that need updates. Note: if no update information
  /// is needed the DBus message should set the no reply flag.
  ///
  /// idErrors: I list of menuitem IDs that couldn't be found. If none of the ones
  /// in the list can be found, a DBus error is returned.
  Future<List<DBusValue>> callAboutToShowGroup(
    List<int> ids, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "com.canonical.dbusmenu",
      "AboutToShowGroup",
      [DBusArray.int32(ids)],
      replySignature: DBusSignature("aiai"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }
}
