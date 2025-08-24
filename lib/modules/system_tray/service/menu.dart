import "dart:async";

import "package:dbus/dbus.dart";
import "package:flutter/cupertino.dart";
import "package:waywing/modules/system_tray/service/spec/idbus_menu.dart";

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

  static const List<String> propertyNames = [
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

  /// This is called by the applet to notify the application that it is about
  /// to show the menu under the specified item.
  ///
  /// **[id]** Which menu item represents the parent of the item about to be shown.
  ///
  /// **@returns** Whether this AboutToShow event should result in the menu being updated.
  Future<bool> aboutToShow(DBusMenuItem item) {
    return canonicalDbusmenu.callAboutToShow(item.id);
  }

  /// Notify the application an event happened on a menu item.
  Future<void> sendEvent(DBusMenuItem item, DBusMenuEventType type) {
    return canonicalDbusmenu.callEvent(
      item.id,
      switch (type) {
        DBusMenuEventType.clicked => "clicked",
        DBusMenuEventType.hovered => "hovered",
        DBusMenuEventType.opened => "opened",
        DBusMenuEventType.closed => "closed",
      },
      DBusUint32(0),
      (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
    );
  }
}

enum DBusMenuEventType { clicked, hovered, opened, closed }

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
      values[1].asArray().map((e) => e.asString()).toList(),
    );
  }
}
