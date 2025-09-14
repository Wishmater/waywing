import "dart:io";

import "package:flutter/material.dart" hide Notification, Action, Actions;
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/notification/notification_config.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/spec/notifications.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/motion_layout/motion_column.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/icons/text_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:xdg_icons/xdg_icons.dart";
import "package:flutter_html/flutter_html.dart";

class NotificationsWidget extends StatefulWidget {
  final NotificationsConfig config;
  final NotificationsService service;

  const NotificationsWidget({super.key, required this.service, required this.config});

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();

  static const spacing = 16;
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  @override
  Widget build(BuildContext context) {
    return NotificationServiceInheritedWidget(
      service: widget.service,
      child: ValueListenableBuilder(
        valueListenable: widget.service.notifications.notifications,
        builder: (context, notifications, _) {
          final scrollController = ScrollController();
          return FocusScope(
            // TODO: 2 STYLE flutter scrollbars are very ugly. Come up with a custom solution everywhere
            // TODO: 2 this has a bug where if the mouse falls in between notifications, the focus removed from
            // waywing, because InputRegions are declared in each notification widget. This causes scrolling to
            // be weird. Ideally we enable a big Input region only when scrolling? This probably requires making
            // a better scrollbar.
            child: Scrollbar(
              controller: scrollController,
              child: ScrollOpacityGradient(
                scrollController: scrollController,
                maxSize: 64,
                child: SingleChildScrollView(
                  controller: scrollController,
                  // TODO: 1 this is doing a weird thing where if 3 notifications with the same duration are
                  // added at the same time, the last one will be removed before the 2nd. The bug is on our side,
                  // because it is removed correctly in the service.
                  child: MotionColumn(
                    motion: mainConfig.motions.expressive.spatial.slow,
                    mainAxisSize: MainAxisSize.min,
                    data: List<ValueNotifier<Notification>>.from(notifications),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    itemBuilder: (context, noti) {
                      Widget result = _NotificationWidget(noti, widget.config);
                      // TODO: 2 should we enable variable notif width, at least as an option ?
                      // result = Align(
                      //   alignment: widget.config.alignment,
                      //   child: IntrinsicWidth(
                      //     child: ConstrainedBox(
                      //       constraints: BoxConstraints(
                      //         minWidth: 256,
                      //         // maxWidth: 256 * 1.5, // redundant because it's already specified above
                      //       ),
                      //       child: _NotificationWidget(noti),
                      //     ),
                      //   ),
                      // );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: NotificationsWidget.spacing / 2),
                        child: result,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationWidget extends StatefulWidget {
  final ValueNotifier<Notification> notification;
  final NotificationsConfig config;
  const _NotificationWidget(this.notification, this.config);

  @override
  State<StatefulWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget> with SingleTickerProviderStateMixin {
  ValueNotifier<bool> isHovered = ValueNotifier(false);

  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = NotificationServiceInheritedWidget.of(context);
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: widget.notification,
      builder: (context, notification, _) {
        final timer = service.server.getTimer(widget.notification.value);
        final urgencyColor = switch (notification.urgency) {
          NotificationUrgency.low => theme.colorScheme.surfaceBright,
          NotificationUrgency.normal => theme.colorScheme.primary,
          NotificationUrgency.critical => theme.colorScheme.onError,
        };
        final surfaceColor = switch (notification.urgency) {
          NotificationUrgency.normal => theme.colorScheme.surface,
          _ => Color.lerp(theme.colorScheme.surface, urgencyColor, 0.1),
        };
        return FocusTraversalGroup(
          child: KeyboardFocus(
            mode: KeyboardFocusMode.onDemand,
            child: MouseRegion(
              onEnter: (_) {
                timer?.stop();
                isHovered.value = true;
              },
              onExit: (_) {
                timer?.start();
                isHovered.value = false;
              },
              child: WingedContainer(
                color: surfaceColor,
                shape: RoundedRectangleBorder(
                  // TODO: 2 STYLE this should take the border radius from theme, oncesthat is decided
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // TODO: 2 STYLE should this also use WingedButton? or maybe separate WingedInkWell and use that?
                    Positioned.fill(
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (isExpanded) {
                            await service.emitActivationToken(notification);
                            await service.closeNotification(notification);
                          } else {
                            _toggleExpansion();
                          }
                        },
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (timer != null && widget.config.showProgressBar)
                          ListenableBuilder(
                            listenable: timer,
                            builder: (context, _) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: LinearProgressIndicator(
                                  backgroundColor: surfaceColor,
                                  color: urgencyColor,
                                  value: timer.percentageCompleted,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              );
                            },
                          ),
                        _NotificationTitle(
                          notification,
                          isHovered,
                          isExpanded,
                          onToggleExpand: _toggleExpansion,
                        ),
                        SizedBox(height: 4),
                        _AnimatedNotificationContent(
                          animation: _heightAnimation,
                          fadeAnimation: _fadeAnimation,
                          notification: notification,
                          isExpanded: isExpanded,
                        ),
                      ],
                    ),
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

class _AnimatedNotificationContent extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> fadeAnimation;
  final Notification notification;
  final bool isExpanded;

  const _AnimatedNotificationContent({
    required this.animation,
    required this.fadeAnimation,
    required this.notification,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationBody(notification),
            _NotificationActions(notification.actions, notification),
          ],
        ),
      ),
    );
  }
}

class _NotificationTitle extends StatelessWidget {
  final Notification notification;
  final ValueNotifier<bool> isHovered;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _NotificationTitle(
    this.notification,
    this.isHovered,
    this.isExpanded, {
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = NotificationServiceInheritedWidget.of(context);
    final effectiveIconSize = TextIcon.getIconEffectiveSize(context);
    String title, subtitle;
    // TODO: 2 should date/time format setting be global?
    // TODO: 2 improve the way this date is rendered, maybe with relative time,
    // and include day (maybe also relative to today or just show if not today)
    final timeFormat = DateFormat.Hms();
    final dateTime = DateTime.fromMillisecondsSinceEpoch(notification.timestampMs);
    if (notification.summary.isNotEmpty) {
      title = notification.summary;
      subtitle = "${notification.appName} - ${timeFormat.format(dateTime)}";
    } else {
      title = notification.appName;
      subtitle = timeFormat.format(dateTime);
    }
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: IntrinsicHeight(
        child: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    // TODO: 1 migrate to WingedIcon
                    if (notification.appIcon.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: IgnorePointer(
                          child: XdgIcon(
                            name: notification.appIcon,
                            // TODO: 3 if icon is passed but not found, shouldn't it fall back to using notification.image?
                            iconNotFoundBuilder: () => SizedBox.shrink(),
                          ),
                        ),
                      ),
                    if (notification.appIcon.isEmpty && notification.image != null)
                      // TODO: 2 should we render images larger? test with sending an image with telegram
                      SizedBox(
                        width: effectiveIconSize,
                        height: effectiveIconSize,
                        child: IgnorePointer(
                          child: switch (notification.image!) {
                            NotificationImageData image => FutureBuilder(
                              future: image.image,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
                                  return SizedBox.shrink();
                                }
                                return RawImage(image: snapshot.data!);
                              },
                            ),
                            NotificationImagePath imagePath => Image.file(File(imagePath.path)),
                          },
                        ),
                      ),
                    Expanded(
                      child: IgnorePointer(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(bottom: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium!.copyWith(
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: theme.textTheme.labelMedium!.copyWith(
                                  height: 1,
                                  color: Color.alphaBlend(
                                    theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                    theme.colorScheme.surface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: isHovered,
              builder: (context, isHovered, child) {
                return SingleMotionBuilder(
                  motion: mainConfig.motions.standard.effects.normal,
                  value: isHovered ? 1 : 0,
                  builder: (context, motionValue, child) {
                    return ExcludeFocus(
                      child: Opacity(
                        opacity: motionValue.clamp(0, 1),
                        child: child!,
                      ),
                    );
                  },
                  child: child!,
                );
              },
              child: Row(
                spacing: 2,
                children: [
                  if (notification.body.isNotEmpty || notification.actions.actions.isNotEmpty)
                    ExcludeFocusTraversal(
                      child: WingedButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: effectiveIconSize * 1.33,
                          height: effectiveIconSize * 1.33,
                        ),
                        onTap: onToggleExpand,
                        child: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: effectiveIconSize * 0.8,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                  ExcludeFocusTraversal(
                    child: WingedButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: effectiveIconSize * 1.33,
                        height: effectiveIconSize * 1.33,
                      ),
                      onTap: () => service.closeNotification(notification),
                      child: Icon(
                        Icons.close,
                        size: effectiveIconSize * 0.8,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ),
                  child: WingedIcon(
                    flutterIcon: SymbolsVaried.close,
                    iconNames: ["window-close"],
                    textIcon: "󰖭", // nf-md-window_close
                    size: effectiveIconSize * 0.8,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  onTap: () => service.closeNotification(notification),
                ),
              ),
            ),
            SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  final Notification notification;
  const _NotificationBody(this.notification);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (notification.body.isNotEmpty)
            IgnorePointer(
              child: Html(
                data: notification.body.replaceAll("\n", "\n<br/>\n"),
                onlyRenderTheseTags: {"html", "body", "br", "a", "b", "img", "u", "i"},
              ),
            ),
          // only use the image as part of the body when the notification appIcon is not empty
          if (notification.appIcon.isNotEmpty && notification.image != null) ...[
            IgnorePointer(
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
          ],
        ],
      ),
    );
  }
}

class _NotificationActions extends StatelessWidget {
  final Notification notification;
  final Actions actions;
  bool get identifierAreIcons => notification.hints.actionIcons;
  const _NotificationActions(this.actions, this.notification);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: actions.inlineReply == null ? 8 : 4,
          left: 12,
          right: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (actions.inlineReply != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _NotificationInlineReply(actions.inlineReply!, notification),
                ),
              ),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.end,
                runAlignment: WrapAlignment.end,
                children: [
                  if (actions.defaultAction != null) //
                    _NotificationAction(notification, actions.defaultAction!, false),
                  for (final action in actions.actions) //
                    _NotificationAction(notification, action, identifierAreIcons),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationInlineReply extends StatelessWidget {
  final Action action;
  final Notification notification;
  const _NotificationInlineReply(this.action, this.notification);

  @override
  Widget build(BuildContext context) {
    final service = NotificationServiceInheritedWidget.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 128, maxWidth: 256, minHeight: 30, maxHeight: 30),
        child: TextField(
          onSubmitted: (value) => service.emitNotificationReplied(notification, value),
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.only(bottom: 16),
            label: Text(
              notification.hints.inlineReplyPlaceholderText ?? "Reply",
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            labelStyle: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationAction extends StatelessWidget {
  final Action action;
  final Notification notification;
  final bool identifierAreIcons;
  const _NotificationAction(this.notification, this.action, this.identifierAreIcons);

  @override
  Widget build(BuildContext context) {
    final service = NotificationServiceInheritedWidget.of(context);
    if (identifierAreIcons) {
      // TODO: 2 STYLE this should use WingedButton
      return TextButton(
        onPressed: () => service.server.emitActionInvoked(notification.id, action.key),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            WingedIcon(iconNames: [action.key]),
            Text(action.value),
          ],
        ),
      );
    } else {
      // TODO: 2 STYLE this should use WingedButton
      return TextButton(
        onPressed: () => service.server.emitActionInvoked(notification.id, action.key),
        child: Text(action.value),
      );
    }
  }
}
