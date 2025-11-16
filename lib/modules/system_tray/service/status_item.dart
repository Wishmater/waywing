import "dart:async";

import "package:dbus/dbus.dart";
import "package:flutter/foundation.dart";
import "package:tronco/tronco.dart";
import "package:waywing/modules/system_tray/service/menu.dart";
import "package:waywing/modules/system_tray/service/spec/idbus_menu.dart";
import "package:waywing/modules/system_tray/service/spec/istatus_notifier_item.dart";

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

  const OrgKdeStatusNotifierItemToolTip.empty()
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
  late final DBusValueSignalNotifier<String> title;

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
  late final DBusValueSignalNotifier<String> status;

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
  late final DBusValueSignalNotifier<String> iconName;

  /// Carries an ARGB32 binary representation of the icon
  ///
  /// {@macro IconData}
  late final DBusValueSignalNotifier<PixmapIcons> iconPixmap;

  /// The Freedesktop-compliant name of an icon. This can be used by the visualization to
  /// indicate extra state information, for instance as an overlay for the main icon.
  late final DBusValueSignalNotifier<String> overlayIconName;

  /// ARGB32 binary representation of the overlay icon.
  ///
  /// {@macro IconData}
  late final DBusValueSignalNotifier<PixmapIcons> overlayIconPixmap;

  /// The Freedesktop-compliant name of an icon. this can be used by the visualization
  /// to indicate that the item is in RequestingAttention state.
  late final DBusValueSignalNotifier<String> attentionIconName;

  /// ARGB32 binary representation of the requesting attention icon describe in the previous paragraph.
  ///
  /// {@macro IconData}
  late final DBusValueSignalNotifier<PixmapIcons> attentionIconPixmap;

  /// An item can also specify an animation associated to the RequestingAttention state.
  /// This should be either a Freedesktop-compliant icon name or a full path.
  /// The visualization can chose between the movie or AttentionIconPixmap
  /// (or using neither of those) at its discretion.
  late final DBusValueSignalNotifier<String> attentionMovieName;

  /// Data structure that describes extra information associated to this item,
  /// that can be visualized for instance by a tooltip (or by any other mean the
  /// visualization consider appropriate
  late final DBusValueSignalNotifier<OrgKdeStatusNotifierItemToolTip> tooltip;

  /// The item only support the context menu, the visualization should prefer
  /// showing the menu or sending ContextMenu() instead of Activate
  /// (Active is a method on NotifierStatusItem)
  late final bool itemIsMenu;

  /// DBus path to an object which should implement the com.canonical.dbusmenu interface
  late final DBusObjectPath menu;

  DBusMenuValues? dbusmenu;

  final OrgKdeStatusNotifierItem statusNotifierItem;

  Future<void>? _initialized;
  bool? _initializationFailed;
  bool get failed => _initializationFailed ?? false;

  final Logger _logger;

  final String originalPath;

  OrgKdeStatusNotifierItemValues(this.statusNotifierItem, this._logger, this.originalPath) {
    _logger.debug("create OrgKdeStatusNotifierItemValues");

    title = DBusValueSignalNotifier(
      "",
      statusNotifierItem.getTitle,
      statusNotifierItem.newTitle,
      _logger,
      "Title",
    );

    iconName = DBusValueSignalNotifier(
      "",
      statusNotifierItem.getIconName,
      statusNotifierItem.newIcon,
      _logger,
      "IconName",
    );
    iconPixmap = DBusValueSignalNotifier(
      const PixmapIcons.empty(),
      () async {
        final data = await statusNotifierItem.getIconPixmap();
        return PixmapIcons.fromDBusData(data);
      },
      statusNotifierItem.newIcon,
      _logger,
      "IconPixmap",
    );

    attentionIconName = DBusValueSignalNotifier(
      "",
      statusNotifierItem.getAttentionIconName,
      statusNotifierItem.newAttentionIcon,
      _logger,
      "AttentionIconName",
    );
    attentionIconPixmap = DBusValueSignalNotifier(
      PixmapIcons.empty(),
      () async {
        final data = await statusNotifierItem.getAttentionIconPixmap();
        return PixmapIcons.fromDBusData(data);
      },
      statusNotifierItem.newAttentionIcon,
      _logger,
      "AttentionIconPixmap",
    );
    attentionMovieName = DBusValueSignalNotifier(
      "",
      statusNotifierItem.getAttentionMovieName,
      statusNotifierItem.newAttentionIcon,
      _logger,
      "AttentionMovieName",
    );

    overlayIconName = DBusValueSignalNotifier(
      "",
      statusNotifierItem.getOverlayIconName,
      statusNotifierItem.newOverlayIcon,
      _logger,
      "OverlayIconName",
    );
    overlayIconPixmap = DBusValueSignalNotifier(
      PixmapIcons.empty(),
      () async {
        final data = await statusNotifierItem.getOverlayIconPixmap();
        return PixmapIcons.fromDBusData(data);
      },
      statusNotifierItem.newOverlayIcon,
      _logger,
      "OverlayIconPixmap",
    );

    tooltip = DBusValueSignalNotifier(
      OrgKdeStatusNotifierItemToolTip.empty(),
      () async {
        final data = await statusNotifierItem.getToolTip();
        return OrgKdeStatusNotifierItemToolTip.fromDBusData(data);
      },
      statusNotifierItem.newToolTip,
      _logger,
      "Tooltip",
    );

    status = DBusValueSignalNotifier("", statusNotifierItem.getStatus, statusNotifierItem.newStatus, _logger, "Status");
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
        dbusmenu = DBusMenuValues(obj, _logger);
      }),
    ];
    _initialized = futures.wait
        .timeout(Duration(milliseconds: 200))
        .then((v) {
          _initializationFailed = false;
          return v;
        })
        .onError((e, st) {
          _logger.error("initialization failed", error: e, stackTrace: st);
          _initializationFailed = true;
          return [];
        });
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

  Future<void> primaryActivate() {
    return statusNotifierItem.callActivate(0, 0);
  }

  Future<void> secondaryActivate() {
    return statusNotifierItem.callSecondaryActivate(0, 0);
  }
}

class DBusValueSignalNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  @override
  T get value => _value;
  T _value;

  final FutureOr<T> Function() callback;

  late final StreamSubscription<DBusSignal> subscription;

  DBusValueSignalNotifier(
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
        logger.trace("[$debugLabel] recieve new value $_value");
        notifyListeners();
      } on DBusUnknownPropertyException catch (e) {
        logger.debug("[$debugLabel] Error calling method: ", error: e);
      } on DBusInvalidArgsException catch (e) {
        logger.debug("[$debugLabel] Error calling method: ", error: e);
      } catch (e, st) {
        logger.error(
          "[$debugLabel] Error calling method. Canceling subscrption, value will recieve no more updates",
          error: e,
          stackTrace: st,
        );
        subscription.cancel();
      }
    });

    Future.sync(callback)
        .then((newValue) {
          if (_value != newValue) {
            _value = newValue;
            logger.trace("[$debugLabel] recieve new value $_value");
            notifyListeners();
          }
        })
        .onError((e, st) {
          if (e is DBusUnknownPropertyException || e is DBusInvalidArgsException) {
            logger.debug("[$debugLabel] Error calling method: ", error: e);
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
