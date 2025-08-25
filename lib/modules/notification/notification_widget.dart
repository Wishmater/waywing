import "dart:io";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart" hide Notification, Action, Actions;
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/spec/notifications.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "package:waywing/widgets/keyboard_focus.dart";
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
        final timer = service.server.getTimer(widget.notification.value);
        return KeyboardFocus(
          mode: KeyboardFocusMode.onDemand,
          child: MouseRegion(
            onEnter: (_) {
                timer.stop();
            },
            onExit: (_) {
                timer.start();
            },
            child: NotificationInheritedWidget(
              notification,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InputRegion(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkResponse(
                      onTap: () {
                        service.emitActivationToken(notification);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RenderTitle(notification),
                          // render summary
                          Text(notification.summary, style: theme.textTheme.titleSmall),
                          // render body
                          _RenderBody(notification),
                        ],
                      ),
                    ),
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
    final fontStyle = theme.textTheme.titleLarge;
    final fontSize = fontStyle?.fontSize;
    return Row(
      children: [
        if (notification.appIcon.isNotEmpty) ...[
          XdgIcon(
            name: notification.appIcon,
            size: fontSize?.floor(),
            iconNotFoundBuilder: () => XdgIcon(
              name: notification.appIcon,
              size: fontSize?.floor(),
            ),
          ),
          SizedBox(width: 10),
        ],
        if (notification.appIcon.isEmpty && notification.image != null) ...[
          SizedBox(
            height: fontSize,
            width: fontSize,
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
        Text(notification.appName, style: fontStyle),
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
        _RenderActions(notification.actions, notification),
      ],
    );
  }
}

class _RenderActions extends StatelessWidget {
  final Notification notification;
  final Actions actions;
  bool get identifierAreIcons => notification.hints.actionIcons;
  const _RenderActions(this.actions, this.notification);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (actions.inlineReply != null) _RenderInlineReply(actions.inlineReply!, notification),
        if (actions.defaultAction != null) _RenderAction(actions.defaultAction!, identifierAreIcons),
        ...[for (final action in actions.actions) _RenderAction(action, identifierAreIcons)],
      ],
    );
  }
}

class _RenderInlineReply extends StatelessWidget {
  final Action action;
  final Notification notification;
  const _RenderInlineReply(this.action, this.notification);

  @override
  Widget build(BuildContext context) {
    final service = NotificationServiceInheritedWidget.of(context);
    return SizedBox(
      width: 100,
      child: TextField(
        onSubmitted: (value) => service.emitNotificationReplied(notification, value),
        decoration: InputDecoration(hintText: notification.hints.inlineReplyPlaceholderText)
      ),
    );
  }
}

class _RenderAction extends StatelessWidget {
  final Action action;
  final bool identifierAreIcons;
  const _RenderAction(this.action, this.identifierAreIcons);

  @override
  Widget build(BuildContext context) {
    final service = NotificationServiceInheritedWidget.of(context);
    final notification = NotificationInheritedWidget.of(context);
    if (identifierAreIcons) {
      return MaterialButton(
        onPressed: () => service.server.emitActionInvoked(notification.id, action.key),
        child: XdgIcon(name: action.value),
      );
    } else {
      return TextButton(
        onPressed: () => service.server.emitActionInvoked(notification.id, action.key),
        child: Text(action.value),
      );
    }
  }
}
