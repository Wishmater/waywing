import "package:audioplayers/audioplayers.dart";
import "package:dbus/dbus.dart";
import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:flutter/material.dart" hide Notification;
import "package:flutter/foundation.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/notification/spec/notifications.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:tronco/tronco.dart" as tronco;
import "package:waywing/util/search_sound.dart";

class NotificationsService extends Service {
  NotificationsService._();

  late final OrgFreedesktopNotifications server;
  late final DBusClient client;
  late final NotificationsList notifications;

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
    client = DBusClient.session();
    server = OrgFreedesktopNotifications(
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
    notifications = NotificationsList(server);
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

class NotificationsList {
  late final ValueListenable<List<ValueNotifier<Notification>>> notifications;

  NotificationsList(OrgFreedesktopNotifications server) {
    notifications = ManualValueNotifier(
      server.activeNotifications.values.map((e) => NotificationValueNotifier(e)).toList(),
    );

    server.notificationChanged.listen((id) {
      for (final notification in notifications.value) {
        if (notification.value.id == id) {
          notification.value = server.activeNotifications[id]!;
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
    // TODO: 1 fix gstreamer error in nix when playing any audio
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
