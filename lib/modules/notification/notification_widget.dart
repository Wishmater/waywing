import "dart:io";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart" hide Notification, Action, Actions;
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/spec/notifications.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "package:xdg_icons/xdg_icons.dart";
import "package:flutter_html/flutter_html.dart";

class NotificationsWidget extends StatefulWidget {
  final NotificationService service;

  const NotificationsWidget({super.key, required this.service});

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  @override
  Widget build(BuildContext context) {
    return NotificationServiceInheritedWidget(
      service: widget.service,
      child: ValueListenableBuilder(
        valueListenable: widget.service.notifications.notifications,
        builder: (context, notifications, _) {
          final children = [for (final noti in notifications) _NotificationWidget(noti)];
          return Column(spacing: 5, children: children);
        },
      ),
    );
  }
}

class NotificationInheritedWidget extends InheritedWidget {
  final Notification notification;

  const NotificationInheritedWidget(this.notification, {super.key, required super.child});

  static Notification of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NotificationInheritedWidget>()!.notification;
  }

  @override
  bool updateShouldNotify(covariant NotificationInheritedWidget oldWidget) {
    return oldWidget.notification != notification;
  }
}

class _NotificationWidget extends StatefulWidget {
  final ValueNotifier<Notification> notification;
  const _NotificationWidget(this.notification);

  @override
  State<StatefulWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = NotificationServiceInheritedWidget.of(context);

    return ValueListenableBuilder(
      valueListenable: widget.notification,
      builder: (context, notification, _) {
        return NotificationInheritedWidget(
          notification,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InputRegion(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkResponse(
                  onTap: () {
                    service.emitActivationToken(notification.id);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RenderTitle(notification),
                      // render summary
                      Text(notification.summary, style: theme.textTheme.titleLarge),
                      // render body
                      _RenderBody(notification),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RenderTitle extends StatelessWidget {
  final Notification notification;
  const _RenderTitle(this.notification);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (notification.appIcon.isNotEmpty) ...[
          XdgIcon(
            name: notification.appIcon,
            size: theme.textTheme.headlineSmall?.fontSize?.floor(),
            iconNotFoundBuilder: () => XdgIcon(
              name: notification.appIcon,
              theme: "breeze-dark",
              size: theme.textTheme.headlineSmall?.fontSize?.floor(),
            ),
          ),
          SizedBox(width: 10),
        ],
        if (notification.appIcon.isEmpty && notification.image != null) ...[
          SizedBox(
            height: theme.textTheme.headlineSmall?.fontSize,
            width: theme.textTheme.headlineSmall?.fontSize,
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: switch (notification.image!) {
                NotificationImageData image => FutureBuilder(
                  future: image.image,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return SizedBox.shrink();
                    }
                    return RawImage(image: snapshot.data!);
                  },
                ),
                NotificationImagePath imagePath => Image.file(File(imagePath.path)),
              },
            ),
          ),
        ],
        Text(notification.appName, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}

class _RenderBody extends StatelessWidget {
  final Notification notification;
  const _RenderBody(this.notification);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(
          data: notification.body.replaceAll("\n", "\n<br/>\n"),
          onlyRenderTheseTags: {"html", "body", "br", "a", "b", "img", "u", "i"},
        ),
        // only use the image as part of the body when the notification appIcon is not empty
        if (notification.appIcon.isNotEmpty && notification.image != null) ...[
          switch (notification.image!) {
            NotificationImageData image => FutureBuilder(
              future: image.image,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return SizedBox.shrink();
                }
                return RawImage(image: snapshot.data!);
              },
            ),
            NotificationImagePath imagePath => Image.file(File(imagePath.path)),
          },
        ],
        _RenderActions(notification.actions),
      ],
    );
  }
}

class _RenderActions extends StatelessWidget {
  final Actions actions;
  const _RenderActions(this.actions);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (actions.defaultAction != null) _RenderAction(actions.defaultAction!),
        ...[for (final action in actions.actions) _RenderAction(action)],
      ],
    );
  }
}

class _RenderAction extends StatelessWidget {
  final Action action;
  const _RenderAction(this.action);

  @override
  Widget build(BuildContext context) {
    final service = NotificationServiceInheritedWidget.of(context);
    final notification = NotificationInheritedWidget.of(context);
    return TextButton(
      onPressed: () => service.server.emitActionInvoked(notification.id, action.key),
      child: Text(action.value),
    );
  }
}
