// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object spec/StatusNotifierItem.xml

import "package:dbus/dbus.dart";
import "package:flutter/foundation.dart";

/// Signal data for org.kde.StatusNotifierItem.NewTitle.
class OrgKdeStatusNotifierItemNewTitle extends DBusSignal {
  OrgKdeStatusNotifierItemNewTitle(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierItem.NewIcon.
class OrgKdeStatusNotifierItemNewIcon extends DBusSignal {
  OrgKdeStatusNotifierItemNewIcon(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierItem.NewAttentionIcon.
class OrgKdeStatusNotifierItemNewAttentionIcon extends DBusSignal {
  OrgKdeStatusNotifierItemNewAttentionIcon(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierItem.NewOverlayIcon.
class OrgKdeStatusNotifierItemNewOverlayIcon extends DBusSignal {
  OrgKdeStatusNotifierItemNewOverlayIcon(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierItem.NewToolTip.
class OrgKdeStatusNotifierItemNewToolTip extends DBusSignal {
  OrgKdeStatusNotifierItemNewToolTip(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.kde.StatusNotifierItem.NewStatus.
class OrgKdeStatusNotifierItemNewStatus extends DBusSignal {
  String get status => values[0].asString();

  OrgKdeStatusNotifierItemNewStatus(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class OrgKdeStatusNotifierItem extends DBusRemoteObject {
  /// Stream of org.kde.StatusNotifierItem.NewTitle signals.
  late final Stream<OrgKdeStatusNotifierItemNewTitle> newTitle;
  late final ValueNotifier<String> title;

  /// Stream of org.kde.StatusNotifierItem.NewIcon signals.
  late final Stream<OrgKdeStatusNotifierItemNewIcon> newIcon;

  /// Stream of org.kde.StatusNotifierItem.NewAttentionIcon signals.
  late final Stream<OrgKdeStatusNotifierItemNewAttentionIcon> newAttentionIcon;

  /// Stream of org.kde.StatusNotifierItem.NewOverlayIcon signals.
  late final Stream<OrgKdeStatusNotifierItemNewOverlayIcon> newOverlayIcon;

  /// Stream of org.kde.StatusNotifierItem.NewToolTip signals.
  late final Stream<OrgKdeStatusNotifierItemNewToolTip> newToolTip;

  /// Stream of org.kde.StatusNotifierItem.NewStatus signals.
  late final Stream<OrgKdeStatusNotifierItemNewStatus> newStatus;

  OrgKdeStatusNotifierItem(DBusClient client, String destination, DBusObjectPath path) : super(client, name: destination, path: path) {
    newTitle = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierItem", name: "NewTitle", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewTitle(signal));
    title = ValueNotifier("");
    getTitle().then((v) => title.value = v);

    newIcon = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierItem", name: "NewIcon", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewIcon(signal));

    newAttentionIcon = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierItem", name: "NewAttentionIcon", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewAttentionIcon(signal));

    newOverlayIcon = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierItem", name: "NewOverlayIcon", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewOverlayIcon(signal));

    newToolTip = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierItem", name: "NewToolTip", signature: DBusSignature("")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewToolTip(signal));

    newStatus = DBusRemoteObjectSignalStream(object: this, interface: "org.kde.StatusNotifierItem", name: "NewStatus", signature: DBusSignature("s")).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewStatus(signal));
  }

  /// Gets org.kde.StatusNotifierItem.Category
  Future<String> getCategory() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "Category", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.Id
  Future<String> getId() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "Id", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.Title
  Future<String> getTitle() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "Title", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.Status
  Future<String> getStatus() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "Status", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.WindowId
  Future<int> getWindowId() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "WindowId", signature: DBusSignature("i"));
    return value.asInt32();
  }

  /// Gets org.kde.StatusNotifierItem.IconThemePath
  Future<String> getIconThemePath() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "IconThemePath", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.Menu
  Future<DBusObjectPath> getMenu() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "Menu", signature: DBusSignature("o"));
    return value.asObjectPath();
  }

  /// Gets org.kde.StatusNotifierItem.ItemIsMenu
  Future<bool> getItemIsMenu() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "ItemIsMenu", signature: DBusSignature("b"));
    return value.asBoolean();
  }

  /// Gets org.kde.StatusNotifierItem.IconName
  Future<String> getIconName() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "IconName", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.IconPixmap
  Future<List<List<DBusValue>>> getIconPixmap() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "IconPixmap", signature: DBusSignature("a(iiay)"));
    return value.asArray().map((child) => child.asStruct()).toList();
  }

  /// Gets org.kde.StatusNotifierItem.OverlayIconName
  Future<String> getOverlayIconName() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "OverlayIconName", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.OverlayIconPixmap
  Future<List<List<DBusValue>>> getOverlayIconPixmap() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "OverlayIconPixmap", signature: DBusSignature("a(iiay)"));
    return value.asArray().map((child) => child.asStruct()).toList();
  }

  /// Gets org.kde.StatusNotifierItem.AttentionIconName
  Future<String> getAttentionIconName() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "AttentionIconName", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.AttentionIconPixmap
  Future<List<List<DBusValue>>> getAttentionIconPixmap() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "AttentionIconPixmap", signature: DBusSignature("a(iiay)"));
    return value.asArray().map((child) => child.asStruct()).toList();
  }

  /// Gets org.kde.StatusNotifierItem.AttentionMovieName
  Future<String> getAttentionMovieName() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "AttentionMovieName", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.ToolTip
  Future<List<DBusValue>> getToolTip() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "ToolTip", signature: DBusSignature("(sa(iiay)ss)"));
    return value.asStruct();
  }

  /// Invokes org.kde.StatusNotifierItem.ContextMenu()
  Future<void> callContextMenu(int x, int y, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.kde.StatusNotifierItem", "ContextMenu", [DBusInt32(x), DBusInt32(y)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.kde.StatusNotifierItem.Activate()
  Future<void> callActivate(int x, int y, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.kde.StatusNotifierItem", "Activate", [DBusInt32(x), DBusInt32(y)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.kde.StatusNotifierItem.SecondaryActivate()
  Future<void> callSecondaryActivate(int x, int y, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.kde.StatusNotifierItem", "SecondaryActivate", [DBusInt32(x), DBusInt32(y)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.kde.StatusNotifierItem.Scroll()
  Future<void> callScroll(int delta, String orientation, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.kde.StatusNotifierItem", "Scroll", [DBusInt32(delta), DBusString(orientation)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  static (String, DBusObjectPath) splitItemStr(String item) {
    int index = -1;
    for (int i = 0; i < item.length; i++) {
      if (item.codeUnitAt(i) == "/".codeUnitAt(0)) {
        index = i;
      }
    }
    if (index == -1) {
      return (item, DBusObjectPath.unchecked("/"));
    }
    return (item.substring(0, index), DBusObjectPath(item.substring(index)));
  }
}
