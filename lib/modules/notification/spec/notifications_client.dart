import "package:dbus/dbus.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/spec/notifications.dart";

class NotificationsClient {
  final Map<int, _NotificationData> _activeNotifications;
  final _ClientNotificationsObject _dbusObject;

  static NotificationsClient? _instance;
  static NotificationsClient get instance {
    _instance ??= NotificationsClient._();
    return _instance!;
  }

  NotificationsClient._()
    : _dbusObject = _ClientNotificationsObject(
        DBusClient.session(),
        NotificationsService.dbusName,
        NotificationsService.dbusPath,
      ),
      _activeNotifications = {} {
    _dbusObject.actionInvoked.listen((v) {
      _activeNotifications[v.id]?.callback?.call(ClientNotificationEventActionInvoke(v.actionKey));
    });
    _dbusObject.activationToken.listen((v) {
      _activeNotifications[v.id]?.callback?.call(ClientNotificationEventActivationToken(v.activationToken));
    });
    _dbusObject.notificationReplied.listen((v) {
      _activeNotifications[v.id]?.callback?.call(ClientNotificationEventReplied(v.text));
    });
    _dbusObject.notificationClosed.listen((v) {
      _activeNotifications
          .remove(v.id)
          ?.callback
          ?.call(
            ClientNotificationEventClose(NotificationsCloseReason.fromInt(v.reason)),
          );
    });
  }

  Future<Notification> notify(Notification notification, NotificationCallback? listenToEvents) async {
    final response = await _dbusObject.callNotify(
      notification.appName,
      notification.id,
      notification.appIcon,
      notification.summary,
      notification.body,
      notification.actions.serialize(),
      notification.hints.serialize(),
      notification.timeout,
    );
    final notificationNew = notification.copyWith(id: response);
    _activeNotifications[notificationNew.id] = _NotificationData(notificationNew, listenToEvents);

    // remove notification on timeout
    if (notification.timeout > 0) {
      final id = notification.id;
      Future.delayed(Duration(milliseconds: notification.timeout)).then((_) {
        _activeNotifications.remove(id);
      });
    }

    return notificationNew;
  }

  Future<void> close(Notification notification) async {
    await _dbusObject.callCloseNotification(notification.id);
    _activeNotifications
        .remove(notification.id)
        ?.callback
        ?.call(ClientNotificationEventClose(NotificationsCloseReason.dbus));
  }
}

sealed class ClientNotificationEvent {}

class ClientNotificationEventClose extends ClientNotificationEvent {
  NotificationsCloseReason reason;

  ClientNotificationEventClose(this.reason);
}

class ClientNotificationEventActionInvoke extends ClientNotificationEvent {
  final String actionKey;

  ClientNotificationEventActionInvoke(this.actionKey);
}

class ClientNotificationEventActivationToken extends ClientNotificationEvent {
  final String activationToken;

  ClientNotificationEventActivationToken(this.activationToken);
}

class ClientNotificationEventReplied extends ClientNotificationEvent {
  final String text;

  ClientNotificationEventReplied(this.text);
}

class _NotificationData {
  final Notification notification;
  final NotificationCallback? callback;

  _NotificationData(this.notification, this.callback);
}

typedef NotificationCallback = void Function(ClientNotificationEvent);

// --------------------- DBus code generation ---------------------

/// Signal data for org.freedesktop.Notifications.NotificationClosed.
class _ClientNotificationsNotificationClosed extends DBusSignal {
  int get id => values[0].asUint32();
  int get reason => values[1].asUint32();

  _ClientNotificationsNotificationClosed(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.freedesktop.Notifications.ActionInvoked.
class _ClientNotificationsActionInvoked extends DBusSignal {
  int get id => values[0].asUint32();
  String get actionKey => values[1].asString();

  _ClientNotificationsActionInvoked(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.freedesktop.Notifications.ActivationToken.
class _ClientNotificationsActivationToken extends DBusSignal {
  int get id => values[0].asUint32();
  String get activationToken => values[1].asString();

  _ClientNotificationsActivationToken(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

/// Signal data for org.freedesktop.Notifications.NotificationReplied.
class _ClientNotificationsNotificationReplied extends DBusSignal {
  int get id => values[0].asUint32();
  String get text => values[1].asString();

  _ClientNotificationsNotificationReplied(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
}

class _ClientNotificationsObject extends DBusRemoteObject {
  /// Stream of org.freedesktop.Notifications.NotificationClosed signals.
  late final Stream<_ClientNotificationsNotificationClosed> notificationClosed;

  /// Stream of org.freedesktop.Notifications.ActionInvoked signals.
  late final Stream<_ClientNotificationsActionInvoked> actionInvoked;

  /// Stream of org.freedesktop.Notifications.ActivationToken signals.
  late final Stream<_ClientNotificationsActivationToken> activationToken;

  /// Stream of org.freedesktop.Notifications.NotificationReplied signals.
  late final Stream<_ClientNotificationsNotificationReplied> notificationReplied;

  _ClientNotificationsObject(super.client, String destination, DBusObjectPath path)
    : super(name: destination, path: path) {
    notificationClosed = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.freedesktop.Notifications",
      name: "NotificationClosed",
      signature: DBusSignature("uu"),
    ).asBroadcastStream().map((signal) => _ClientNotificationsNotificationClosed(signal));

    actionInvoked = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.freedesktop.Notifications",
      name: "ActionInvoked",
      signature: DBusSignature("us"),
    ).asBroadcastStream().map((signal) => _ClientNotificationsActionInvoked(signal));

    activationToken = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.freedesktop.Notifications",
      name: "ActivationToken",
      signature: DBusSignature("us"),
    ).asBroadcastStream().map((signal) => _ClientNotificationsActivationToken(signal));

    notificationReplied = DBusRemoteObjectSignalStream(
      object: this,
      interface: "org.freedesktop.Notifications",
      name: "NotificationReplied",
      signature: DBusSignature("us"),
    ).asBroadcastStream().map((signal) => _ClientNotificationsNotificationReplied(signal));
  }

  /// Invokes org.freedesktop.Notifications.GetCapabilities()
  Future<List<String>> callGetCapabilities({
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "org.freedesktop.Notifications",
      "GetCapabilities",
      [],
      replySignature: DBusSignature("as"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asStringArray().toList();
  }

  /// Invokes org.freedesktop.Notifications.Notify()
  Future<int> callNotify(
    String appName,
    int replacesId,
    String appIcon,
    String summary,
    String body,
    List<String> actions,
    Map<String, DBusValue> hints,
    int expireTimeout, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "org.freedesktop.Notifications",
      "Notify",
      [
        DBusString(appName),
        DBusUint32(replacesId),
        DBusString(appIcon),
        DBusString(summary),
        DBusString(body),
        DBusArray.string(actions),
        DBusDict.stringVariant(hints),
        DBusInt32(expireTimeout),
      ],
      replySignature: DBusSignature("u"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asUint32();
  }

  /// Invokes org.freedesktop.Notifications.CloseNotification()
  Future<void> callCloseNotification(
    int id, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      "org.freedesktop.Notifications",
      "CloseNotification",
      [DBusUint32(id)],
      replySignature: DBusSignature(""),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes org.freedesktop.Notifications.GetServerInformation()
  Future<List<DBusValue>> callGetServerInformation({
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    var result = await callMethod(
      "org.freedesktop.Notifications",
      "GetServerInformation",
      [],
      replySignature: DBusSignature("ssss"),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }
}
