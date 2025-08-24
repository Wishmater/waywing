import "dart:async";

import "package:dbus/dbus.dart";
import "package:tronco/tronco.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "dart:ui" as ui;

import "package:waywing/util/logger.dart";

enum NotificationsCloseReason {
  expired(1),
  user(2),
  dbus(3),
  undefined(4);

  final int value;
  const NotificationsCloseReason(this.value);
}

sealed class NotificationImage {
  const NotificationImage();
}

class NotificationImageData extends NotificationImage {
  final NotificationHintImage data;

  Future<ui.Image> get image => data.image;

  const NotificationImageData(this.data);
}

class NotificationImagePath extends NotificationImage {
  final String path;

  const NotificationImagePath(this.path);
}

int _idGenerator = 0;

class Notification {
  /// Unique identifier for the notification.
  /// Clients use this ID to update, close, or reference a specific notification.
  final int id;

  /// This is the optional name of the application sending the notification.
  /// This should be the application's formal name, rather than some sort of ID.
  /// An example would be "FredApp E-Mail Client," rather than "fredapp-email-client." .
  final String appName;

  /// Icon to render
  String appIcon;

  /// Image to display
  NotificationImage? image;

  /// This is a single line overview of the notification.
  ///
  /// For instance, "You have mail" or "A friend has come online".
  /// It should generally not be longer than 40 characters, though this is not a requirement,
  /// and server implementations should word wrap if necessary.
  ///
  /// The summary must be encoded using UTF-8.
  final String summary;

  /// This is a multi-line body of text. Each line is a paragraph, server implementations
  /// are free to word wrap them as they see fit.
  ///
  /// The body may contain simple markup as specified in Markup. It must be encoded using UTF-8.
  ///
  /// If the body is omitted, just the summary is displayed.
  final String body;

  /// The actions send a request message back to the notification client when invoked.
  /// This functionality may not be implemented by the notification server, conforming clients
  /// should check if it is available before using it (see the GetCapabilities message in Protocol).
  /// An implementation is free to ignore any requested by the client.
  /// As an example one possible rendering of actions would be as buttons in the notification popup.
  ///
  /// Actions are sent over as a list of pairs. Each even element in the list (starting at index 0)
  /// represents the identifier for the action. Each odd element in the list is the localized
  /// string that will be displayed to the user.
  ///
  /// The default action (usually invoked by clicking the notification) should have a key named
  /// "default". The name can be anything, though implementations are free not to display it.
  final Actions actions;

  /// Hints are a way to provide extra data to a notification server that the server may
  /// be able to make use of.
  final NotificationHints hints;

  /// The timestamp (in milliseconds since epoch) when the notification was created.
  final int timestampMs;

  /// The timeout time in milliseconds since the display of the notification at which the notification
  /// should automatically close.
  ///
  /// If -1, the notification's expiration time is dependent on the notification server's settings,
  /// and may vary for the type of notification.
  ///
  /// If 0, the notification never expires.
  final int timeout;

  /// For low and normal urgencies, server implementations may display the notifications how they choose.
  /// They should, however, have a sane expiration timeout dependent on the urgency level.
  ///
  /// Critical notifications should not automatically expire, as they are things that the
  /// user will most likely want to know about.
  NotificationUrgency get urgency => hints.urgency;

  Notification._({
    required this.id,
    required this.timestampMs,
    required this.appName,
    required this.appIcon,
    required this.image,
    required this.summary,
    required this.body,
    required this.actions,
    required this.hints,
    required this.timeout,
  });

  Notification({
    required this.appName,
    required this.appIcon,
    required this.image,
    required this.summary,
    required this.body,
    required this.actions,
    required this.hints,
    required this.timeout,
  }) : timestampMs = DateTime.now().millisecondsSinceEpoch,
       id = _idGenerator++;

  Notification copyWith({
    String? appName,
    String? appIcon,
    NotificationImage? image,
    String? summary,
    String? body,
    Actions? actions,
    NotificationHints? hints,
    int? timeout,
    int? timestampMs,
  }) {
    return Notification._(
      id: id,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      image: image ?? this.image,
      actions: actions ?? this.actions,
      hints: hints ?? this.hints,
      timeout: timeout ?? this.timeout,
      timestampMs: timestampMs ?? this.timestampMs,
    );
  }

  @override
  bool operator ==(covariant Notification other) {
    if (identical(this, other)) return true;

    return appName == other.appName &&
        appIcon == other.appIcon &&
        summary == other.summary &&
        body == other.body &&
        image == other.image &&
        actions == other.actions &&
        hints == other.hints &&
        timeout == other.timeout &&
        timestampMs == other.timestampMs;
  }

  @override
  int get hashCode => Object.hashAll([
    appName,
    appIcon,
    summary,
    body,
    image,
    actions,
    hints,
    timeout,
    timestampMs,
  ]);
}

/// Main Notification object that expose an org.freedesktop.Notifications dbus interface
///
/// Also this object manage all notifications
class OrgFreedesktopNotifications extends DBusObject {
  final Logger logger;

  final Map<int, Notification> activeNotifications;
  final Map<String, int> synchronousIds;
  final Map<int, Timer> _timers;

  final StreamController<Notification> _notificationCreated;
  late Stream<Notification> notificationCreated;
  final StreamController<int> _notificationChanged;
  late final Stream<int> notificationChanged;
  final StreamController<int> _notificationRemoved;
  late final Stream<int> notificationRemoved;

  /// Creates a new object to expose on [path].
  OrgFreedesktopNotifications({
    required this.logger,
    DBusObjectPath path = const DBusObjectPath.unchecked("/"),
  }) : activeNotifications = {},
       synchronousIds = {},
       _timers = {},
       _notificationCreated = StreamController(),
       _notificationChanged = StreamController(),
       _notificationRemoved = StreamController(),
       super(path) {
    notificationCreated = _notificationCreated.stream.asBroadcastStream();
    notificationChanged = _notificationChanged.stream.asBroadcastStream();
    notificationRemoved = _notificationRemoved.stream.asBroadcastStream();
  }

  void dispose() {
    _notificationCreated.close();
    _notificationRemoved.close();
    _notificationChanged.close();
    _timers.forEach((k, v) => v.cancel());
    _timers.clear();
  }

  void addOrReplaceNotification(Notification notification) {
    bool contains = activeNotifications.containsKey(notification.id);
    activeNotifications[notification.id] = notification;

    bool isSynchronous = notification.hints.synchronous?.isNotEmpty == true;
    if (isSynchronous) {
      synchronousIds[notification.hints.synchronous!] = notification.id;
    }

    if (contains) {
      _notificationChanged.add(notification.id);
    } else {
      _notificationCreated.add(notification);
    }

    _timers[notification.id]?.cancel();
    if (notification.timeout > 0) {
      final id = notification.id;
      _timers[id] = Timer(
        Duration(milliseconds: notification.timeout),
        () => removeNotification(id, NotificationsCloseReason.expired),
      );
    }
  }

  void removeNotification(int id, NotificationsCloseReason reason) {
    final removed = activeNotifications.remove(id);
    if (removed != null) {
      if (removed.hints.synchronous?.isNotEmpty == true) {
        synchronousIds.remove(removed.hints.synchronous!);
      }
      _notificationRemoved.add(id);
      emitNotificationClosed(id, reason.value);
    }
    _timers.remove(id)?.cancel();
  }

  /// Implementation of org.freedesktop.Notifications.GetCapabilities()
  Future<DBusMethodResponse> doGetCapabilities() async {
    return DBusMethodSuccessResponse([
      DBusArray.string([
        /// Supports using icons instead of text for displaying actions.
        /// Using icons for actions must be enabled on a per-notification
        /// basis using the "action-icons" hint.
        "action-icons",

        /// The server will provide the specified actions to the user.
        /// Even if this cap is missing, actions may still be specified by the client,
        /// however the server is free to ignore them.
        "actions",

        /// Supports body text. Some implementations may only show the
        /// summary (for instance, onscreen displays, marquee/scrollers)
        "body",

        /// The server supports hyperlinks in the notifications.
        "body-hyperlinks",

        /// The server supports images in the notifications.
        "body-images",

        /// Supports markup in the body text. If marked up text is sent
        /// to a server that does not give this cap, the markup will show
        /// through as regular text so must be stripped clientside.
        "body-markup",

        /// The server will render an animation of all the frames in a given image array.
        /// The client may still specify multiple frames even if this cap and/or
        /// "icon-static" is missing, however the server is free to ignore them and use
        /// only the primary frame.
        // "icon-multi",

        /// Supports display of exactly 1 frame of any given image array. This value is
        /// mutually exclusive with "icon-multi", it is a protocol
        /// error for the server to specify both.
        "icon-static",

        /// The server supports persistence of notifications. Notifications will be
        /// retained until they are acknowledged or removed by the user or recalled
        /// by the sender. The presence of this capability allows clients to depend
        /// on the server to ensure a notification is seen and eliminate the need
        /// for the client to display a reminding function (such as a status icon) of its own.
        "persistence",

        /// The server supports sounds on notifications. If returned, the server
        /// must support the "sound-file" and "suppress-sound" hints.
        ///
        /// TODO: MISSING
        "sound",

        /// The server supports text input.
        ///
        /// Applications may use this feature to recieve a text response from the user without
        /// the user opening the app
        "inline-reply",

        /// Notifications with the same (non-empty) stack tag and the same appid will replace
        /// each-other so only the newest one is visible.
        ///
        /// This can be useful for example in volume or brightness notifications where you only
        /// want one of the same type visible.
        ///
        /// The stack tag can be set by the client with the 'synchronous', 'private-synchronous'
        /// 'x-canonical-private-synchronous' or the 'x-dunst-stack-tag' hints.
        "synchronous",
        "private-synchronous",
        "x-canonical-private-synchronous",
        "x-dunst-stack-tag",
      ]),
    ]);
  }

  /// Implementation of org.freedesktop.Notifications.Notify()
  ///
  /// Sends a notification to the notification server.
  /// If replaces_id is 0, the return value is a UINT32 that represent the notification.
  /// It is unique, and will not be reused unless a MAXINT number of notifications have been generated.
  /// An acceptable implementation may just use an incrementing counter for the ID.
  /// The returned ID is always greater than zero. Servers must make sure not to return
  /// zero as an ID.
  ///
  /// If replaces_id is not 0, the returned value is the same value as replaces_id.
  Future<DBusMethodResponse> doNotify(
    String app_name,
    int replaces_id,
    String app_icon,
    String summary,
    String body,
    List<String> actions,
    Map<String, DBusValue> hints,
    int expire_timeout,
  ) async {
    final sublogger = logger.create(
      Level.trace,
      "notify replace_id: $replaces_id app_name: $app_name app_icon: $app_icon",
    );
    final parsedHints = NotificationHints(client!, hints);
    final parsedActions = Actions(actions);
    sublogger?.add("hints: $parsedHints");
    sublogger?.add("actions: $parsedActions");
    sublogger?.add(
      "unparsed hints: ${hints.map((k, v) => MapEntry(k, !v.signature.value.contains("a") ? v : DBusString("AAA")))}",
    );
    sublogger?.end();

    NotificationImage? image;
    if (parsedHints.imageData != null) {
      image = NotificationImageData(parsedHints.imageData!);
    } else if (parsedHints.imagePath != null) {
      image = NotificationImagePath(parsedHints.imagePath!);
    }

    if (expire_timeout <= 0) {
      expire_timeout = switch (parsedHints.urgency) {
        NotificationUrgency.low => 3 * 1000, // TODO get default time from configuration
        NotificationUrgency.normal => 5 * 1000, // TODO get default time from configuration
        NotificationUrgency.critical => 0,
      };
    }

    Notification? notification;
    if (replaces_id > 0) {
      notification = activeNotifications[replaces_id]?.copyWith(
        timestampMs: DateTime.now().millisecondsSinceEpoch,
        actions: parsedActions,
        appName: app_name,
        appIcon: app_icon,
        image: image,
        summary: summary,
        body: body,
        hints: parsedHints,
        timeout: expire_timeout,
      );
      if (notification == null) {
        return DBusMethodErrorResponse.failed("replaces_id not found");
      }
    } else if (parsedHints.synchronous?.isNotEmpty == true) {
      final id = synchronousIds[parsedHints.synchronous!];

      if (id != null) {
        notification = activeNotifications[id]!.copyWith(
          timestampMs: DateTime.now().millisecondsSinceEpoch,
          actions: parsedActions,
          appName: app_name,
          appIcon: app_icon,
          image: image,
          summary: summary,
          body: body,
          hints: parsedHints,
          timeout: expire_timeout,
        );
      } else {
        notification = Notification(
          actions: parsedActions,
          appName: app_name,
          appIcon: app_icon,
          image: image,
          summary: summary,
          body: body,
          hints: parsedHints,
          timeout: expire_timeout,
        );
      }
    }
    notification ??= Notification(
      actions: parsedActions,
      appName: app_name,
      appIcon: app_icon,
      image: image,
      summary: summary,
      body: body,
      hints: parsedHints,
      timeout: expire_timeout,
    );
    addOrReplaceNotification(notification);

    return DBusMethodSuccessResponse([DBusUint32(notification.id)]);
  }

  /// Implementation of org.freedesktop.Notifications.CloseNotification()
  ///
  /// Causes a notification to be forcefully closed and removed from the user's view.
  ///
  /// It can be used, for example, in the event that what the notification pertains to
  /// is no longer relevant, or to cancel a notification with no expiration time.
  ///
  /// The NotificationClosed signal is emitted by this method.
  ///
  /// If the notification no longer exists, an empty D-BUS Error message is sent back.
  Future<DBusMethodResponse> doCloseNotification(int id) async {
    removeNotification(id, NotificationsCloseReason.dbus);
    return DBusMethodSuccessResponse([]);
  }

  /// Implementation of org.freedesktop.Notifications.GetServerInformation()
  ///
  /// This message returns the information on the server.
  /// Specifically:
  /// - name. The product name of the server.
  /// - vendor. The vendor name. For example, "KDE," "GNOME," "freedesktop.org," or "Microsoft."
  /// - version. The server's version number.
  /// - spec_version. The specification version the server is compliant with.
  Future<DBusMethodResponse> doGetServerInformation() async {
    return DBusMethodSuccessResponse([
      DBusString("waywing"),
      DBusString("waywing"),
      DBusString("0.0.1"),
      DBusString("1.3"),
    ]);
  }

  /// Emits signal org.freedesktop.Notifications.NotificationClosed
  ///
  /// A completed notification is one that has timed out, or has been dismissed by the user.
  ///
  /// Params
  /// - id: The ID of the notification that was closed
  /// - reason:
  ///   - 1 The notification expired.
  ///   - 2 The notification was dismissed by the user.
  ///   - 3 The notification was closed by a call to CloseNotification.
  ///   - 4 Undefined/reserved reasons.
  ///
  /// The ID specified in the signal is invalidated before the signal is sent and may not be
  /// used in any further communications with the server.
  Future<void> emitNotificationClosed(int id, int reason) async {
    await emitSignal("org.freedesktop.Notifications", "NotificationClosed", [DBusUint32(id), DBusUint32(reason)]);
  }

  /// Emits signal org.freedesktop.Notifications.ActionInvoked
  ///
  /// This signal is emitted when one of the following occurs:
  /// - The user performs some global "invoking" action upon a notification.
  ///   For instance, clicking somewhere on the notification itself.
  /// - The user invokes a specific action as specified in the original Notify request. For example,
  ///   clicking on an action button.
  ///
  /// Params
  /// - id: The ID of the notification emitting the ActionInvoked signal.
  /// - action_key: The key of the action invoked. These match the keys sent over in the list of
  ///   actions.
  Future<void> emitActionInvoked(int id, String action_key) async {
    await emitSignal("org.freedesktop.Notifications", "ActionInvoked", [DBusUint32(id), DBusString(action_key)]);
  }

  /// Emits signal org.freedesktop.Notifications.ActivationToken
  ///
  /// This signal can be emitted before a ActionInvoked signal. It carries an activation token
  /// that can be used to activate a toplevel.
  ///
  /// Params
  /// - id: The ID of the notification emitting the ActionInvoked signal.
  /// - activation_token: An activation token. This can be either an X11-style startup ID
  ///   (see Startup notification protocol) or a Wayland xdg-activation token.
  Future<void> emitActivationToken(Notification notification, String activation_token) async {
    notification.hints.application
        ?.callActivate({"activation-token": DBusString(activation_token)})
        .catchError((e, st) {});

    await emitSignal("org.freedesktop.Notifications", "ActivationToken", [
      DBusUint32(notification.id),
      DBusString(activation_token),
    ]);
  }

  /// Emits signal org.freedesktop.Notifications.NotificationReplied
  ///
  /// To be used by the non-standard "inline-reply" capability
  Future<void> emitNotificationReplied(int id, String text) async {
    await emitSignal("org.freedesktop.Notifications", "NotificationReplied", [DBusUint32(id), DBusString(text)]);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        "org.freedesktop.Notifications",
        methods: [
          DBusIntrospectMethod(
            "GetCapabilities",
            args: [DBusIntrospectArgument(DBusSignature("as"), DBusArgumentDirection.out, name: "result")],
          ),
          DBusIntrospectMethod(
            "Notify",
            args: [
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.in_, name: "app_name"),
              DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.in_, name: "replaces_id"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.in_, name: "app_icon"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.in_, name: "summary"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.in_, name: "body"),
              DBusIntrospectArgument(DBusSignature("as"), DBusArgumentDirection.in_, name: "actions"),
              DBusIntrospectArgument(DBusSignature("a{sv}"), DBusArgumentDirection.in_, name: "hints"),
              DBusIntrospectArgument(DBusSignature("i"), DBusArgumentDirection.in_, name: "expire_timeout"),
              DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.out, name: "result"),
            ],
          ),
          DBusIntrospectMethod(
            "CloseNotification",
            args: [DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.in_, name: "id")],
          ),
          DBusIntrospectMethod(
            "GetServerInformation",
            args: [
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out, name: "name"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out, name: "vendor"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out, name: "version"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out, name: "spec_version"),
            ],
          ),
        ],
        signals: [
          DBusIntrospectSignal(
            "NotificationClosed",
            args: [
              DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.out, name: "id"),
              DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.out, name: "reason"),
            ],
          ),
          DBusIntrospectSignal(
            "ActionInvoked",
            args: [
              DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.out, name: "id"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out, name: "action_key"),
            ],
          ),
          DBusIntrospectSignal(
            "ActivationToken",
            args: [
              DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.out, name: "id"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out, name: "activation_token"),
            ],
          ),
          DBusIntrospectSignal(
            "NotificationReplied",
            args: [
              DBusIntrospectArgument(DBusSignature("u"), DBusArgumentDirection.out, name: "id"),
              DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out, name: "text"),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == "org.freedesktop.Notifications") {
      if (methodCall.name == "GetCapabilities") {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doGetCapabilities();
      } else if (methodCall.name == "Notify") {
        if (methodCall.signature != DBusSignature("susssasa{sv}i")) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doNotify(
          methodCall.values[0].asString(),
          methodCall.values[1].asUint32(),
          methodCall.values[2].asString(),
          methodCall.values[3].asString(),
          methodCall.values[4].asString(),
          methodCall.values[5].asStringArray().toList(),
          methodCall.values[6].asStringVariantDict(),
          methodCall.values[7].asInt32(),
        );
      } else if (methodCall.name == "CloseNotification") {
        if (methodCall.signature != DBusSignature("u")) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doCloseNotification(methodCall.values[0].asUint32());
      } else if (methodCall.name == "GetServerInformation") {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doGetServerInformation();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == "org.freedesktop.Notifications") {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == "org.freedesktop.Notifications") {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }
}
