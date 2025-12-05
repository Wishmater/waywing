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
import "package:waywing/widgets/winged_widgets/winged_modal.dart";

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
                  child: WingedModal(
                    fixedDestinationAnchor: null,
                    builder: (context, modal, child) {
                      return WingedButton(
                        containedInkWell: true,
                        onTap: (_, _) {
                          // Show confirmation dialog before deleting
                          modal.showPopover();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 2,
                          children: [
                            WingedIcon(flutterIcon: Icons.delete, iconNames: ["delete"]),
                            Text("Clear notifications"),
                          ],
                        ),
                      );
                    },
                    dialogBuilder: (context, modal, _, _) {
                      return IntrinsicWidth(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Are you sure you want to delete all notifications?"),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                spacing: 8,
                                children: [
                                  WingedButton(
                                    autofocus: true,
                                    containedInkWell: true,
                                    padding: EdgeInsets.symmetric(horizontal: 24),
                                    onTap: (_, _) => modal.hidePopover(),
                                    child: Text("Cancel"),
                                  ),
                                  WingedButton(
                                    containedInkWell: true,
                                    padding: EdgeInsets.symmetric(horizontal: 24),
                                    color: Theme.of(context).colorScheme.errorContainer,
                                    child: Text("Clear"),
                                    onTap: (_, _) {
                                      service.closeAllNotifications();
                                      modal.hidePopover();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
          onTap: (_, _) => service.closeNotification(widget.notification),
          child: WingedIcon(
            flutterIcon: Icons.delete,
            iconNames: ["delete"],
          ),
        ),
      ],
    );
  }
}
