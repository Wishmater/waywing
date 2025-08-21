import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart" hide Notification;
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/spec/notifications.dart";
import "package:xdg_icons/xdg_icons.dart";

class NotificationsWidget extends StatefulWidget {
  final NotificationService service;

  const NotificationsWidget({super.key, required this.service});

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.service.notifications.notifications,
      builder: (context, notifications, _) {
        final children = [for (final noti in notifications) _NotificationWidget(widget.service, noti)];
        return Column(spacing: 5, children: children);
      },
    );
  }
}

class _NotificationWidget extends StatefulWidget {
  final NotificationService service;
  final ValueNotifier<Notification> notification;
  const _NotificationWidget(this.service, this.notification);

  @override
  State<StatefulWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.notification,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            color:Colors.black.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InputRegion(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkResponse(
                onTap: () {
                  widget.service.emitActivationToken(value.id);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (value.appIcon.isNotEmpty) XdgIcon(name: value.appIcon, size: 20),
                        if (value.appIcon.isNotEmpty) SizedBox(width: 10),
                        Text(value.appName),
                      ],
                    ),
                    Text(value.summary),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
