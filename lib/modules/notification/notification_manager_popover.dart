import "package:flutter/foundation.dart";
import "package:flutter/material.dart" hide Notification;
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/notification_widget.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class NotificationManagerPopover extends StatelessWidget {
  const NotificationManagerPopover({super.key, required this.service});

  final NotificationsService service;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 256,
        maxWidth: 384,
        maxHeight: 512,
      ),
      child: NotificationServiceInheritedWidget(
        service: service,
        child: ListenableBuilder(
          listenable: service.storedNotificationChange,
          builder: (context, _) {
            final notifications = service.server.storedNotifications.values.toList();
            if (notifications.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "No notifications yet",
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: [
                // Delete All button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: WingedButton(
                    containedInkWell: true,
                    onTapDown: (_) {
                      // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _ConfirmationDialog(service);
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2,
                      children: [
                        WingedIcon(flutterIcon: Icons.delete, iconNames: ["delete"]),
                        Text("Clear notifications"),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    child: ScrollOpacityGradient(
                      scrollController: scrollController,
                      maxSize: 32,
                      child: ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return _NotificationWidget(notifications[index]);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationWidget extends StatefulWidget {
  final Notification notification;

  const _NotificationWidget(this.notification);

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget> with SingleTickerProviderStateMixin {
  bool isExpanded = true;
  late ValueListenable<bool> isHovered;
  late BoundedSingleMotionController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = BoundedSingleMotionController(
      motion: mainConfig.motions.expressive.spatial.normal,
      vsync: this,
      initialValue: isExpanded ? 1 : 0,
    );
    isHovered = DummyValueNotifier(false);
  }

  @override
  Widget build(BuildContext context) {
    final service = NotificationServiceInheritedWidget.of(context);
    return Row(
      children: [
        Expanded(
          child: NotificationTile(
            notification: widget.notification,
            onToggleExpand: () {},
            isExpanded: isExpanded,
            animation: _animationController,
            isHovered: isHovered,
            showActions: false,
          ),
        ),
        WingedButton(
          onTapUp: (_) => service.closeNotification(widget.notification),
          child: WingedIcon(
            flutterIcon: Icons.delete,
            iconNames: ["delete"],
          ),
        ),
      ],
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  final NotificationsService service;

  const _ConfirmationDialog(this.service);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Clear notifications"),
      content: Text("Are you sure you want to delete all notifications?"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 2,
          children: [
            WingedButton(
              containedInkWell: true,
              constraints: BoxConstraints(maxWidth: 90),
              onTapUp: (_) => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            WingedButton(
              containedInkWell: true,
              constraints: BoxConstraints(maxWidth: 90),
              onTapUp: (_) {
                service.closeAllNotifications();
                Navigator.of(context).pop();
              },
              color: Theme.of(context).colorScheme.error.withAlpha(80),
              child: Text("Clear"),
            ),
          ],
        ),
      ],
    );
  }
}
