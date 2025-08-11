// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object spec/DBusMenu.xml

// ignore_for_file: use_super_parameters, unintended_html_in_doc_comment

import "dart:async";

import "package:dbus/dbus.dart";
import "package:flutter/widgets.dart";

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

class DBusMenuItemProperties {
  /// Can be one of:
  ///   - "standard": an item which can be clicked to trigger an action or show another menu
  ///   - "separator": a separator
  ///   - Vendor specific types can be added by prefixing them with "x-<vendor>-"
  ///
  /// @defautl "standard"
  String type;

  /// Text of the item, except that:
  /// - two consecutive underscore characters "__" are displayed as a
  /// single underscore,
  /// - any remaining underscore characters are not displayed at all,
  /// - the first of those remaining underscore characters (unless it is
  /// the last character in the string) indicates that the following
  /// character is the access key.
  ///
  /// @defautl ""
  String label;

  /// Whether the item can be activated or not.
  ///
  /// @defautl true
  bool enabled;

  /// True if the item is visible in the menu.
  ///
  /// @defautl true
  bool visible;

  /// Icon name of the item, following the freedesktop.org icon spec.
  ///
  /// @defautl ""
  String iconName; // icon-name

  /// PNG data of the icon.
  ///
  /// @defautl []
  List<int> iconData; // icon-data

  /// The shortcut of the item. Each array represents the key press
  /// in the list of keypresses. Each list of strings contains a list of
  /// modifiers and then the key that is used. The modifier strings
  /// allowed are: "Control", "Alt", "Shift" and "Super".
  ///
  /// - A simple shortcut like Ctrl+S is represented as:
  ///   [["Control", "S"]]
  /// - A complex shortcut like Ctrl+Q, Alt+X is represented as:
  ///   [["Control", "Q"], ["Alt", "X"]]</td>
  ///
  /// @defautl []
  List<String> shortcuts;

  /// If the item can be toggled, this property should be set to:
  /// - "checkmark": Item is an independent togglable item
  /// - "radio": Item is part of a group where only one item can be
  ///   toggled at a time
  /// - "": Item cannot be toggled
  ///
  /// @defautl ""
  String toggleType; // toggle-type

  /// Describe the current state of a "togglable" item. Can be one of:
  /// - 0 = off
  /// - 1 = on
  /// - anything else = indeterminate
  ///
  /// Note:
  /// The implementation does not itself handle ensuring that only one
  /// item in a radio group is set to "on", or that a group does not have
  /// "on" and "indeterminate" items simultaneously; maintaining this
  /// policy is up to the toolkit wrappers.
  ///
  /// @defautl -1
  int toggleState; // toggle-state

  /// If the menu item has children this property should be set to "submenu".
  ///
  /// @defautl ""
  String childrenDisplay;

  /// How the menuitem feels the information it's displaying to the
  /// user should be presented.
  /// - "normal" a standard menu item
  /// - "informative" providing additional information to the user
  /// - "warning" looking at potentially harmful results
  /// - "alert" something bad could potentially happen
  ///
  /// @defautl "normal"
  String disposition;

  static List<String> propertyNames = [
    "type",
    "label",
    "enabled",
    "visible",
    "icon-name",
    "icon-data",
    "shortcuts",
    "toggle-type",
    "toggle-state",
    "children-display",
    "disposition",
  ];

  DBusMenuItemProperties({
    String? type,
    String? label,
    bool? enabled,
    bool? visible,
    String? iconName,
    List<int>? iconData,
    List<String>? shortcuts,
    String? toggleType,
    int? toggleState,
    String? childrenDisplay,
    String? disposition,
  }) : type = type ?? "standard",
       label = label ?? "",
       enabled = enabled ?? true,
       visible = visible ?? true,
       iconName = iconName ?? "",
       iconData = iconData ?? [],
       shortcuts = shortcuts ?? [],
       toggleType = toggleType ?? "",
       toggleState = toggleState ?? -1,
       childrenDisplay = childrenDisplay ?? "",
       disposition = disposition ?? "normal";

  factory DBusMenuItemProperties.fromDBus(DBusDict map) {
    return DBusMenuItemProperties(
      type: (map.children[DBusString("type")] as DBusVariant?)?.value.asString(),
      label: (map.children[DBusString("label")] as DBusVariant?)?.value.asString(),
      enabled: (map.children[DBusString("enabled")] as DBusVariant?)?.value.asBoolean(),
      visible: (map.children[DBusString("visible")] as DBusVariant?)?.value.asBoolean(),
      iconName: (map.children[DBusString("icon-name")] as DBusVariant?)?.value.asString(),
      iconData: (map.children[DBusString("icon-data")] as DBusVariant?)?.value.asByteArray().toList(),
      shortcuts: (map.children[DBusString("shortcuts")] as DBusVariant?)?.value
          .asArray()
          .map((e) => e.asString())
          .toList(),
      toggleType: (map.children[DBusString("toggle-type")] as DBusVariant?)?.value.asString(),
      toggleState: (map.children[DBusString("toggle-state")] as DBusVariant?)?.value.asInt32(),
      childrenDisplay: (map.children[DBusString("children-display")] as DBusVariant?)?.value.asString(),
      disposition: (map.children[DBusString("disposition")] as DBusVariant?)?.value.asString(),
    );
  }

  void merge(DBusMenuItemProperties toMerge) {
    type = toMerge.type != "" ? toMerge.type : type;
    label = toMerge.label != "" ? toMerge.label : label;
    enabled = toMerge.enabled != true ? toMerge.enabled : enabled;
    visible = toMerge.visible != true ? toMerge.visible : visible;
    iconName = toMerge.iconName != "" ? toMerge.iconName : iconName;
    iconData = toMerge.iconData.isNotEmpty ? toMerge.iconData : iconData;
    shortcuts = toMerge.shortcuts.isNotEmpty ? toMerge.shortcuts : shortcuts;
    toggleType = toMerge.toggleType != "" ? toMerge.toggleType : toggleType;
    toggleState = toMerge.toggleState != -1 ? toMerge.toggleState : toggleState;
    childrenDisplay = toMerge.childrenDisplay != "" ? toMerge.childrenDisplay : childrenDisplay;
    disposition = toMerge.disposition != "" ? toMerge.disposition : disposition;
  }

  void remove(List<String> remove) {
    for (final toRemove in remove) {
      switch (toRemove) {
        case "type":
          type = "";
        case "label":
          label = "";
        case "enabled":
          enabled = true;
        case "visible":
          visible = true;
        case "icon-name":
          iconName = "";
        case "icon-data":
          iconData = [];
        case "shortcuts":
          shortcuts = [];
        case "toggle-type":
          toggleType = "";
        case "toggle-state":
          toggleState = -1;
        case "children-display":
          childrenDisplay = "";
        case "disposition":
          disposition = "";
      }
    }
  }
}

/// Represent an item in the tree of items that represent a layout
class DBusMenuItem extends ChangeNotifier {
  /// item menu identifier
  int id;

  /// Item properties as defined in com.canonical.dbusmenu spec
  DBusMenuItemProperties properties;

  /// Submenu that this item can have
  List<DBusMenuItem> submenu;

  DBusMenuItem(this.id, this.properties, this.submenu);

  DBusMenuItem.fromDBus(List<DBusValue> values)
    : id = values[0].asInt32(),
      properties = DBusMenuItemProperties.fromDBus(values[1] as DBusDict),
      submenu = [for (final e in values[2].asArray()) DBusMenuItem.fromDBus((e as DBusVariant).value.asStruct())];

  DBusMenuItem.empty() : id = 0, properties = DBusMenuItemProperties(), submenu = [];

  DBusMenuItem? find(int id) {
    if (this.id == id) {
      return this;
    }
    for (final child in submenu) {
      final resp = child.find(id);
      if (resp != null) {
        return resp;
      }
    }
    return null;
  }

  void replace(DBusMenuItem newItem) {
    id = newItem.id;
    properties = newItem.properties;
    for (final child in submenu) {
      child.dispose();
    }
    submenu = newItem.submenu;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final child in submenu) {
      child.dispose();
    }
    super.dispose();
  }
}

class DBusMenuValues {
  /// Represents the way the text direction of the application. This
  /// allows the server to handle mismatches intelligently. For left-to-right
  /// the string is "ltr" for right-to-left it is "rtl".
  late final String textDirection;

  /// Provides the version of the DBusmenu API that this API is implementing.
  late final String version;

  /// Tells if the menus are in a normal state or they believe that they
  /// could use some attention. Cases for showing them would be if help
  /// were referring to them or they accessors were being highlighted.
  /// This property can have two values: "normal" in almost all cases and
  /// "notice" when they should have a higher priority to be shown.
  late final String status;

  /// A list of directories that should be used for finding icons using
  /// the icon naming spec.  Idealy there should only be one for the icon
  /// theme, but additional ones are often added by applications for
  /// app specific icons.
  late final List<String> iconThemePaths;

  /// The menu to show. This is a tree shaped data.
  /// [DBusMenuItem] extends ChangeNotifier so the user can listen to
  /// each of the node efficiently
  final DBusMenuItem layout;

  /// allow us to know if there was a missing update
  int _revision = 0;

  late final StreamSubscription _streamSubslayoutUpdated;
  late final StreamSubscription _streamSubsItemsPropertiesUpdated;

  /// DBus object implementing the com.canonical.dbusmenu
  final ComCanonicalDbusmenu canonicalDbusmenu;

  DBusMenuValues(this.canonicalDbusmenu) : layout = DBusMenuItem.empty() {
    canonicalDbusmenu.callGetLayout(0, -1, DBusMenuItemProperties.propertyNames).then((response) {
      _revision = response[0].asUint32();
      final newSubMenu = DBusMenuItem.fromDBus(response[1].asStruct());
      layout.replace(newSubMenu);
    });

    _streamSubslayoutUpdated = canonicalDbusmenu.layoutUpdated.listen((v) async {
      final revision = v.revision;
      int parentId = v.parent;

      if (revision != _revision && revision != _revision + 1) {
        // We miss an update or something funny happen.. refetch the complete layout
        parentId = 0;
      }
      DBusMenuItem? parentMenu = layout.find(parentId);
      if (parentMenu == null) {
        // node refered by the process was not found wich likely means we are out of sync..
        // refetch the complete layout
        parentId = 0;
        parentMenu = layout;
      }
      List<DBusValue> response;
      try {
        response = await canonicalDbusmenu.callGetLayout(
          parentId,
          -1,
          DBusMenuItemProperties.propertyNames,
        );
      } catch (e) {
        if (parentId != 0) {
          parentId = 0;
          response = await canonicalDbusmenu.callGetLayout(
            parentId,
            -1,
            DBusMenuItemProperties.propertyNames,
          );
        } else {
          rethrow;
        }
      }
      final newRevision = response[0].asUint32();
      _revision = newRevision;
      final newSubMenu = DBusMenuItem.fromDBus(response[1].asStruct());
      parentMenu.replace(newSubMenu);
    });

    _streamSubsItemsPropertiesUpdated = canonicalDbusmenu.itemsPropertiesUpdated.listen((v) {
      final removed = v.removedProps.map((e) => _RemovedProps.fromDBus(e)).toList();
      final updated = v.updatedProps.map((e) => _UpdatedProps.fromDBus(e)).toList();

      for (final remove in removed) {
        layout.find(remove.id)?.properties.remove(remove.props);
      }
      for (final update in updated) {
        layout.find(update.id)?.properties.merge(update.properties);
      }
    });
  }

  void dispose() {
    _streamSubslayoutUpdated.cancel();
    _streamSubsItemsPropertiesUpdated.cancel();
    layout.dispose();
  }
}

class _UpdatedProps {
  final int id;
  final DBusMenuItemProperties properties;

  _UpdatedProps(this.id, this.properties);

  factory _UpdatedProps.fromDBus(List<DBusValue> values) {
    return _UpdatedProps(
      values[0].asInt32(),
      DBusMenuItemProperties.fromDBus(values[1] as DBusDict),
    );
  }
}

class _RemovedProps {
  final int id;
  final List<String> props;
  const _RemovedProps(this.id, this.props);

  factory _RemovedProps.fromDBus(List<DBusValue> values) {
    return _RemovedProps(
      values[0].asInt32(),
      values[0].asArray().map((e) => e.asString()).toList(),
    );
  }
}
