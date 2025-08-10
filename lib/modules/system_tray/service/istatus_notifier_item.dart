import "dart:async";

import "package:dbus/dbus.dart";
import "package:flutter/foundation.dart";
import "package:tronco/tronco.dart";
import "package:waywing/modules/system_tray/service/idbus_menu.dart";

/// Signal data for org.kde.StatusNotifierItem.NewTitle.
class OrgKdeStatusNotifierItemNewTitle extends DBusSignal {
  OrgKdeStatusNotifierItemNewTitle(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.kde.StatusNotifierItem.NewIcon.
class OrgKdeStatusNotifierItemNewIcon extends DBusSignal {
  OrgKdeStatusNotifierItemNewIcon(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.kde.StatusNotifierItem.NewAttentionIcon.
class OrgKdeStatusNotifierItemNewAttentionIcon extends DBusSignal {
  OrgKdeStatusNotifierItemNewAttentionIcon(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.kde.StatusNotifierItem.NewOverlayIcon.
class OrgKdeStatusNotifierItemNewOverlayIcon extends DBusSignal {
  OrgKdeStatusNotifierItemNewOverlayIcon(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.kde.StatusNotifierItem.NewToolTip.
class OrgKdeStatusNotifierItemNewToolTip extends DBusSignal {
  OrgKdeStatusNotifierItemNewToolTip(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.kde.StatusNotifierItem.NewStatus.
class OrgKdeStatusNotifierItemNewStatus extends DBusSignal {
  String get status => values[0].asString();

  OrgKdeStatusNotifierItemNewStatus(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

class OrgKdeStatusNotifierItem extends DBusRemoteObject {
  /// Stream of org.kde.StatusNotifierItem.NewTitle signals.
  late final Stream<OrgKdeStatusNotifierItemNewTitle> newTitle;

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

  OrgKdeStatusNotifierItem(DBusClient client, String destination, DBusObjectPath path)
    : super(client, name: destination, path: path) {
    newTitle = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.kde.StatusNotifierItem",
      name: "NewTitle",
      signature: DBusSignature(""),
    ).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewTitle(signal));

    newIcon = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.kde.StatusNotifierItem",
      name: "NewIcon",
      signature: DBusSignature(""),
    ).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewIcon(signal));

    newAttentionIcon = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.kde.StatusNotifierItem",
      name: "NewAttentionIcon",
      signature: DBusSignature(""),
    ).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewAttentionIcon(signal));

    newOverlayIcon = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.kde.StatusNotifierItem",
      name: "NewOverlayIcon",
      signature: DBusSignature(""),
    ).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewOverlayIcon(signal));

    newToolTip = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.kde.StatusNotifierItem",
      name: "NewToolTip",
      signature: DBusSignature(""),
    ).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewToolTip(signal));

    newStatus = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.kde.StatusNotifierItem",
      name: "NewStatus",
      signature: DBusSignature("s"),
    ).asBroadcastStream().map((signal) => OrgKdeStatusNotifierItemNewStatus(signal));
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
    var value = await getProperty(
      "org.kde.StatusNotifierItem",
      "OverlayIconPixmap",
      signature: DBusSignature("a(iiay)"),
    );
    return value.asArray().map((child) => child.asStruct()).toList();
  }

  /// Gets org.kde.StatusNotifierItem.AttentionIconName
  Future<String> getAttentionIconName() async {
    var value = await getProperty("org.kde.StatusNotifierItem", "AttentionIconName", signature: DBusSignature("s"));
    return value.asString();
  }

  /// Gets org.kde.StatusNotifierItem.AttentionIconPixmap
  Future<List<List<DBusValue>>> getAttentionIconPixmap() async {
    var value = await getProperty(
      "org.kde.StatusNotifierItem",
      "AttentionIconPixmap",
      signature: DBusSignature("a(iiay)"),
    );
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
  ///
  /// Asks the status notifier item to show a context menu, this is typically a consequence of user input,
  /// such as mouse right click over the graphical representation of the item.
  ///
  /// The x and y parameters are in screen coordinates and is to be considered an hint to the item about
  /// where to show the context menu.
  Future<void> callContextMenu(
    int x,
    int y, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      "org.kde.StatusNotifierItem",
      "ContextMenu",
      [DBusInt32(x), DBusInt32(y)],
      replySignature: DBusSignature(""),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes org.kde.StatusNotifierItem.Activate()
  ///
  /// Asks the status notifier item for activation, this is typically a consequence of user input,
  /// such as mouse left click over the graphical representation of the item. The application will
  /// perform any task is considered appropriate as an activation request.
  ///
  /// the x and y parameters are in screen coordinates and is to be considered an hint to the item
  /// where to show eventual windows (if any).
  Future<void> callActivate(
    int x,
    int y, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      "org.kde.StatusNotifierItem",
      "Activate",
      [DBusInt32(x), DBusInt32(y)],
      replySignature: DBusSignature(""),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes org.kde.StatusNotifierItem.SecondaryActivate()
  ///
  /// Is to be considered a secondary and less important form of activation compared to Activate.
  /// This is typically a consequence of user input, such as mouse middle click over the graphical
  /// representation of the item. The application will perform any task is considered appropriate
  /// as an activation request.
  ///
  /// the x and y parameters are in screen coordinates and is to be considered an hint to the item
  /// where to show eventual windows (if any).
  Future<void> callSecondaryActivate(
    int x,
    int y, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      "org.kde.StatusNotifierItem",
      "SecondaryActivate",
      [DBusInt32(x), DBusInt32(y)],
      replySignature: DBusSignature(""),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes org.kde.StatusNotifierItem.Scroll()
  ///
  /// The user asked for a scroll action. This is caused from input such as mouse wheel over the
  /// graphical representation of the item.
  ///
  /// The delta parameter represent the amount of scroll, the orientation parameter represent the
  /// horizontal or vertical orientation of the scroll request and its legal values are horizontal and vertical.
  Future<void> callScroll(
    int delta,
    String orientation, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      "org.kde.StatusNotifierItem",
      "Scroll",
      [DBusInt32(delta), DBusString(orientation)],
      replySignature: DBusSignature(""),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  static (String, DBusObjectPath) splitItemStr(String item) {
    int index = -1;
    for (int i = 0; i < item.length; i++) {
      if (item.codeUnitAt(i) == "/".codeUnitAt(0)) {
        index = i;
        break;
      }
    }
    if (index == -1) {
      return (item, DBusObjectPath.unchecked("/"));
    }
    return (item.substring(0, index), DBusObjectPath(item.substring(index)));
  }
}

class Pixmap {
  final int width;
  final int height;
  final Iterable<int> data;

  const Pixmap(this.width, this.height, this.data);
  const Pixmap.empty() : width = 0, height = 0, data = const [];

  factory Pixmap.fromDBusData(List<DBusValue> values) {
    return Pixmap(values[0].asInt32(), values[1].asInt32(), values[2].asByteArray());
  }
}

class PixmapIcons {
  final List<Pixmap> icons;

  const PixmapIcons(this.icons);
  const PixmapIcons.empty() : icons = const [];

  factory PixmapIcons.fromDBusData(List<List<DBusValue>> values) {
    final response = PixmapIcons([]);
    for (final value in values) {
      response.icons.add(Pixmap.fromDBusData(value));
    }
    return response;
  }

  @override
  bool operator ==(covariant PixmapIcons other) {
    return icons == other.icons;
  }

  @override
  int get hashCode => icons.hashCode;
}

class OrgKdeStatusNotifierItemToolTip {
  /// Tooltip title
  final String title;

  /// Descriptive text for this tooltip. It can contain also a subset of the HTML markup language
  final String description;

  /// Freedesktop-compliant name for an icon.
  final String iconName;

  /// icon image data
  final PixmapIcons iconData;

  const OrgKdeStatusNotifierItemToolTip({
    required this.title,
    required this.description,
    required this.iconName,
    required this.iconData,
  });

  const OrgKdeStatusNotifierItemToolTip.emtpy()
    : title = "",
      description = "",
      iconName = "",
      iconData = const PixmapIcons.empty();

  factory OrgKdeStatusNotifierItemToolTip.fromDBusData(List<DBusValue> values) {
    return OrgKdeStatusNotifierItemToolTip(
      iconName: values[0].asString(),
      iconData: PixmapIcons.fromDBusData(values[1].asArray().map((e) => e.asArray()).toList()),
      title: values[2].asString(),
      description: values[3].asString(),
    );
  }
}

/// {@template IconData}
/// Icon data can be transferred over the bus by a particular serialization of their data,
/// capable of representing multiple resolutions of the same image or a brief aimation of images
/// of the same size.
///
/// Icons are transferred in an array of raw image data structures of dbus signature a(iiay)
/// whith each one describing the width, height, and image data respectively.
/// The data is represented in ARGB32 format and is in the network byte order,
/// to make easy the communication over the network between little and big endian machines.
/// {@endtemplate}

class OrgKdeStatusNotifierItemValues {
  /// It's a name that should be unique for this application and consistent between sessions,
  /// such as the application name itself.
  late final String id;

  /// It's a name that describes the application, it can be more descriptive than Id.
  late final DBusValueNotifier<String> title;

  /// Describes the status of this item or of the associated application.
  ///
  /// The allowed values for the Status property are:
  ///
  /// Passive: The item doesn't convey important information to the user,
  /// it can be considered an "idle" status and is likely that visualizations
  /// will chose to hide it.
  ///
  /// Active: The item is active, is more important that the item will be shown
  /// in some way to the user.
  ///
  /// NeedsAttention: The item carries really important information for the user,
  /// such as battery charge running out and is wants to incentive the direct user
  /// intervention. Visualizations should emphasize in some way the items with
  /// NeedsAttention status.
  late final DBusValueNotifier<String> status;

  /// Describes the category of this item.
  ///
  /// The allowed values for the Category property are:
  ///
  /// ApplicationStatus: The item describes the status of a generic application,
  /// for instance the current state of a media player. In the case where the category
  /// of the item can not be known, such as when the item is being proxied from another
  /// incompatible or emu system, ApplicationStatus can be used a sensible default fallback.
  ///
  /// Communications: The item describes the status of communication oriented applications,
  /// like an instant messenger or an email client.
  ///
  /// SystemServices: The item describes services of the system not seen as a stand alone
  /// application by the user, such as an indicator for the activity of a disk indexing service.
  ///
  /// Hardware: The item describes the state and control of a particular hardware, such as an
  /// indicator of the battery charge or sound card volume control.
  late final String category;

  /// It's the windowing-system dependent identifier for a window,
  /// the application can chose one of its windows to be available through
  /// this property or just set 0 if it's not interested.
  late final int windowsId;

  /// The StatusNotifierItem can carry an icon that can be used by the visualization to
  /// identify the item.
  ///
  /// An icon can either be identified by its Freedesktop-compliant icon name,
  /// carried by this property of by the icon data itself, carried by the property IconPixmap.
  /// Visualizations are encouraged to prefer icon names over icon pixmaps if both are available
  late final DBusValueNotifier<String> iconName;

  /// Carries an ARGB32 binary representation of the icon
  ///
  /// {@macro IconData}
  late final DBusValueNotifier<PixmapIcons> iconPixmap;

  /// The Freedesktop-compliant name of an icon. This can be used by the visualization to
  /// indicate extra state information, for instance as an overlay for the main icon.
  late final DBusValueNotifier<String> overlayIconName;

  /// ARGB32 binary representation of the overlay icon.
  ///
  /// {@macro IconData}
  late final DBusValueNotifier<PixmapIcons> overlayIconPixmap;

  /// The Freedesktop-compliant name of an icon. this can be used by the visualization
  /// to indicate that the item is in RequestingAttention state.
  late final DBusValueNotifier<String> attentionIconName;

  /// ARGB32 binary representation of the requesting attention icon describe in the previous paragraph.
  ///
  /// {@macro IconData}
  late final DBusValueNotifier<PixmapIcons> attentionIconPixmap;

  /// An item can also specify an animation associated to the RequestingAttention state.
  /// This should be either a Freedesktop-compliant icon name or a full path.
  /// The visualization can chose between the movie or AttentionIconPixmap
  /// (or using neither of those) at its discretion.
  late final DBusValueNotifier<String> attentionMovieName;

  /// Data structure that describes extra information associated to this item,
  /// that can be visualized for instance by a tooltip (or by any other mean the
  /// visualization consider appropriate
  late final DBusValueNotifier<OrgKdeStatusNotifierItemToolTip> tooltip;

  /// The item only support the context menu, the visualization should prefer
  /// showing the menu or sending ContextMenu() instead of Activate
  /// (Active is a method on NotifierStatusItem)
  late final bool itemIsMenu;

  /// DBus path to an object which should implement the com.canonical.dbusmenu interface
  late final DBusObjectPath menu;

  DBusMenuValues? dbusmenu;

  final OrgKdeStatusNotifierItem statusNotifierItem;

  Future<void>? _initialized;

  OrgKdeStatusNotifierItemValues(this.statusNotifierItem, Logger logger) {
    title = DBusValueNotifier("", statusNotifierItem.getTitle, statusNotifierItem.newTitle, logger);

    iconName = DBusValueNotifier(
      "",
      statusNotifierItem.getIconName,
      statusNotifierItem.newIcon,
      logger,
    );
    iconPixmap = DBusValueNotifier(
      PixmapIcons.empty(),
      () async {
        final data = await statusNotifierItem.getIconPixmap();
        return PixmapIcons.fromDBusData(data);
      },
      statusNotifierItem.newIcon,
      logger,
    );

    attentionIconName = DBusValueNotifier(
      "",
      statusNotifierItem.getAttentionIconName,
      statusNotifierItem.newAttentionIcon,
      logger,
    );
    attentionIconPixmap = DBusValueNotifier(
      PixmapIcons.empty(),
      () async {
        final data = await statusNotifierItem.getAttentionIconPixmap();
        return PixmapIcons.fromDBusData(data);
      },
      statusNotifierItem.newAttentionIcon,
      logger,
    );
    attentionMovieName = DBusValueNotifier(
      "",
      statusNotifierItem.getAttentionMovieName,
      statusNotifierItem.newAttentionIcon,
      logger,
    );

    overlayIconName = DBusValueNotifier(
      "",
      statusNotifierItem.getOverlayIconName,
      statusNotifierItem.newOverlayIcon,
      logger,
    );
    overlayIconPixmap = DBusValueNotifier(
      PixmapIcons.empty(),
      () async {
        final data = await statusNotifierItem.getOverlayIconPixmap();
        return PixmapIcons.fromDBusData(data);
      },
      statusNotifierItem.newOverlayIcon,
      logger,
    );

    tooltip = DBusValueNotifier(
      OrgKdeStatusNotifierItemToolTip.emtpy(),
      () async {
        final data = await statusNotifierItem.getToolTip();
        return OrgKdeStatusNotifierItemToolTip.fromDBusData(data);
      },
      statusNotifierItem.newToolTip,
      logger,
    );

    status = DBusValueNotifier(
      "",
      statusNotifierItem.getStatus,
      statusNotifierItem.newToolTip,
      logger,
    );
    initFields();
  }

  Future<void> initFields() async {
    if (_initialized != null) {
      return _initialized;
    }
    final futures = [
      statusNotifierItem.getId().then((v) => id = v).onError((_, _) => id = ""),
      statusNotifierItem.getCategory().then((v) => category = v).onError((_, _) => category = "ApplicationStatus"),
      statusNotifierItem.getWindowId().then((v) => windowsId = v).onError((_, _) => windowsId = 0),
      statusNotifierItem.getItemIsMenu().then((v) => itemIsMenu = v).onError((_, _) => itemIsMenu = false),
      statusNotifierItem.getMenu().then((v) => menu = v).onError((_, _) => menu = DBusObjectPath.unchecked("")).then((
        v,
      ) {
        final obj = ComCanonicalDbusmenu(statusNotifierItem.client, statusNotifierItem.name, path: v);
        dbusmenu = DBusMenuValues(obj);
      }),
    ];
    _initialized = Future.wait(futures);
  }

  void dispose() {
    title.dispose();
    iconName.dispose();
    iconPixmap.dispose();
    attentionIconName.dispose();
    attentionIconPixmap.dispose();
    attentionMovieName.dispose();
    overlayIconName.dispose();
    overlayIconPixmap.dispose();
    tooltip.dispose();
    status.dispose();
    dbusmenu?.dispose();
  }
}

class DBusValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  @override
  T get value => _value;
  T _value;

  final FutureOr<T> Function() callback;

  late final StreamSubscription<DBusSignal> subscription;

  DBusValueNotifier(
    this._value,
    this.callback,
    Stream<DBusSignal> signalStream,
    Logger logger, [
    String debugLabel = "",
  ]) {
    subscription = signalStream.listen((_) async {
      try {
        final newValue = await callback();
        _value = newValue;
        notifyListeners();
      } on DBusUnknownPropertyException catch (e) {
        logger.warning("[$debugLabel] Error calling method: ", error: e);
      } on DBusInvalidArgsException catch (e) {
        logger.warning("[$debugLabel] Error calling method: ", error: e);
      } catch (e, st) {
        logger.error("[$debugLabel] Error calling method: ", error: e, stackTrace: st);
      }
    });

    Future.sync(callback)
        .then((newValue) {
          if (_value != newValue) {
            _value = newValue;
            notifyListeners();
          }
        })
        .onError((e, st) {
          if (e is DBusUnknownPropertyException || e is DBusInvalidArgsException) {
            logger.warning("[$debugLabel] Error calling method: ", error: e);
          } else {
            logger.error("[$debugLabel] Error calling method: ", error: e, stackTrace: st);
          }
        });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
