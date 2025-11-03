import "package:audioplayers/audioplayers.dart";
import "package:dbus/dbus.dart";
import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:flutter/material.dart" hide Notification;
import "package:flutter/foundation.dart";
import "package:hive_ce/hive.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/notification/spec/notifications.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:tronco/tronco.dart" as tronco;
import "package:waywing/util/search_sound.dart";

class NotificationsService extends Service {
  NotificationsService._();

  late final FreedesktopNotificationsServer server;
  late final DBusClient client;
  late final ActiveNotificationsList activeNotifications;

  final ManualNotifier storedNotificationChange = ManualNotifier();

  static const String dbusName = "org.freedesktop.Notifications";

  static registerService(RegisterServiceCallback registerService) {
    registerService<NotificationsService, dynamic>(
      ServiceRegistration(
        constructor: NotificationsService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    Hive.registerAdapter(NotificationsHiveAdapter());
    await Hive.openBox<Notification>("NotificationServer");

    client = DBusClient.session();
    server = FreedesktopNotificationsServer(
      logger: logger.clone(properties: [...logger.defaultProperties, tronco.StringProperty("Server")]),
      path: DBusObjectPath("/org/freedesktop/Notifications"),
    );
    await client.registerObject(server);
    final resp = await client.requestName(
      dbusName,
      flags: {DBusRequestNameFlag.doNotQueue},
    );
    switch (resp) {
      case DBusRequestNameReply.primaryOwner:
      case DBusRequestNameReply.alreadyOwner:
        break;
      case DBusRequestNameReply.exists:
        throw Exception("could not request name $dbusName");
      case DBusRequestNameReply.inQueue:
        throw StateError("unreachable: flag doNotQueue was added");
    }
    activeNotifications = ActiveNotificationsList(server);

    server.storedNotifiactionChange.listen((_) {
      storedNotificationChange.manualNotifyListeners();
    });
  }

  @override
  Future<void> dispose() async {
    server.dispose();
    await client.close();
  }

  Future<void> emitActivationToken(Notification notification) async {
    final token = await FlLinuxWindowManager.instance.getXdgToken();
    if (token == null) {
      logger.error(
        "on emitActivationToken xdg token should never be null",
        error: "getXdgToken() returned null",
      );
      return;
    }
    await server.emitActivationToken(notification, token);
  }

  Future<void> closeNotification(Notification notification) async {
    await server.doCloseNotification(notification.id);
  }

  Future<void> emitNotificationReplied(Notification notification, String text) async {
    await server.emitSignal("org.freedesktop.Notifications", "NotificationReplied", [
      DBusUint32(notification.id),
      DBusString(text),
    ]);
  }
}

class ActiveNotificationsList {
  final ValueListenable<List<ValueNotifier<Notification>>> notifications;

  ActiveNotificationsList(FreedesktopNotificationsServer server)
    : notifications = ManualValueNotifier(
        server.activeNotifications.values.map((e) => NotificationValueNotifier(e)).toList(),
      ) {
    server.notificationChanged.listen((id) {
      for (int i = 0; i< notifications.value.length; i++) {
        final notification = notifications.value[i];
        if (notification.value.id == id) {
          final newNotification = server.activeNotifications[id];
          /// Change notification event is async, which means that when we get the event the notification
          /// could be already deleted. Having a null assert is fine must of the time... but i do managed
          /// to get an `Null check operator used on a null value` error after my laptop wake up from sleep
          if (newNotification != null) {
            notification.value = newNotification;
          } else {
            notifications.value.removeAt(i);
          }
          break;
        }
      }
    });

    server.notificationCreated.listen((notification) {
      notifications.value.add(NotificationValueNotifier(notification));
      (notifications as ManualValueNotifier).manualNotifyListeners();

      if (!(notification.hints.suppressSound ?? false)) {
        _playSound(notification);
      }
    });

    server.notificationRemoved.listen((id) {
      int index = -1;
      for (int i = 0; i < notifications.value.length; i++) {
        final notification = notifications.value[i];
        if (notification.value.id == id) {
          index = i;
          break;
        }
      }
      if (index == -1) {
        return;
      }
      notifications.value.removeAt(index);
      (notifications as ManualValueNotifier).manualNotifyListeners();
    });
  }

  Future<void> _playSound(Notification notification) async {
    final file = notification.hints.soundFile;
    final name = notification.hints.soundName;
    if (file == null && name == null) {
      return;
    }
    Source? source;
    if (file != null) {
      source = DeviceFileSource(file);
    } else if (name != null) {
      // TODO 2: get sound theme from gsetting?
      final path = await SearchSound.lookup(name);
      if (path != null) {
        source = DeviceFileSource(path);
      }
    }
    if (source == null) {
      return;
    }
    final player = AudioPlayer();
    player.play(source);
    Future.delayed(Duration(seconds: 5), player.dispose);
  }
}

class NotificationServiceInheritedWidget extends InheritedWidget {
  final NotificationsService service;

  const NotificationServiceInheritedWidget({super.key, required super.child, required this.service});

  static NotificationsService of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NotificationServiceInheritedWidget>()!.service;
  }

  @override
  bool updateShouldNotify(covariant NotificationServiceInheritedWidget oldWidget) {
    return oldWidget.service != service;
  }
}

class NotificationValueNotifier extends ValueNotifier<Notification> {
  NotificationValueNotifier(super.value);

  @override
  int get hashCode => value.id;
  @override
  bool operator ==(Object other) {
    if (other is NotificationValueNotifier) return value.id == other.value.id;
    return super == other;
  }
}
