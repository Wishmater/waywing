import "package:audioplayers/audioplayers.dart";
import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
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

part "notification_service.config.dart";

class NotificationsService extends Service<NotificationsServiceConfig> {
  NotificationsService._();

  late final ValueNotifier<NotificationsStatus> status = ValueNotifier(NotificationsStatus.active);
  late final FreedesktopNotificationsServer server;
  late final DBusClient client;
  late final ActiveNotificationsList activeNotifications;

  final ManualNotifier storedNotificationChange = ManualNotifier();

  static const String dbusName = "org.freedesktop.Notifications";

  static registerService(RegisterServiceCallback registerService) {
    registerService<NotificationsService, NotificationsServiceConfig>(
      ServiceRegistration(
        constructor: NotificationsService._,
        schemaBuilder: () => NotificationsServiceConfig.schema,
        configBuilder: NotificationsServiceConfig.fromBlock,
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
    activeNotifications = ActiveNotificationsList(this, server);

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

  late final Map<String, DateTime> _lastAppSound = {};
  Future<void> playSound(Notification notification) async {
    if (status.value != NotificationsStatus.active) {
      return;
    }
    Source? source;
    if (notification.hints.soundFile case final file?) {
      source = DeviceFileSource(file);
    } else if (notification.hints.soundName case final name?) {
      // TODO: 3 get sound theme from gsetting?
      final path = await SearchSound.lookup(name);
      if (path != null) {
        source = DeviceFileSource(path);
      }
    } else if (config.soundDefaultFilename case final file?) {
      source = DeviceFileSource(file);
    }
    if (source == null) {
      return;
    }
    if (_lastAppSound[notification.appName] case final lastSound?) {
      if (DateTime.now().difference(lastSound) < config.soundCooldown) {
        // this line makes it so that if the app keeps spamming notifications in an interval
        // leess than config.cooldown, the sound will never be played again
        _lastAppSound[notification.appName] = DateTime.now();
        return;
      }
    }
    // TODO: 3 should we use something other than .appName to identify app?
    _lastAppSound[notification.appName] = DateTime.now();
    // TODO: 3 maybe we should have a persistant AudioPlayer instance and avoid playing multiple sounds at once
    final player = AudioPlayer();
    await player.setVolume(config.soundVolumeFloat);
    await player.play(source);
    await player.onPlayerComplete.first;
    await player.dispose();
  }
}

class ActiveNotificationsList {
  final NotificationsService service;
  final ValueListenable<List<ValueNotifier<Notification>>> notifications;

  ActiveNotificationsList(this.service, FreedesktopNotificationsServer server)
    : notifications = ManualValueNotifier(
        server.activeNotifications.values.map((e) => NotificationValueNotifier(e)).toList(),
      ) {
    server.notificationChanged.listen((id) {
      for (int i = 0; i < notifications.value.length; i++) {
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
        service.playSound(notification);
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

enum NotificationsStatus {
  active,
  silenced,
  dnd, // do not disturb
}

@Config()
mixin NotificationsServiceConfigBase on NotificationsServiceConfigI {
  // https://notificationsounds.com/
  static const _soundDefaultFilename = StringField(nullable: true);

  static const _soundCooldown = DurationField(defaultTo: Duration(minutes: 1));

  static const _soundVolume = IntegerNumberField(defaultTo: 100);
  late final soundVolumeFloat = soundVolume / 100;
}
