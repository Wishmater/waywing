import "package:flutter/material.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/modules/system_tray/system_tray_indicator.dart";

class SystemTrayTooltip extends StatelessWidget {
  final SystemTrayService service;
  final OrgKdeStatusNotifierItemValues item;

  const SystemTrayTooltip({
    required this.service,
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 256),
      child: ValueListenableBuilder(
        valueListenable: item.title,
        builder: (context, title, child) {
          // TODO: 3 maybe show an icon for item.category, like they do in quickshell
          return ValueListenableBuilder(
            valueListenable: item.tooltip,
            builder: (context, tooltip, child) {
              if (tooltip.title.isNotEmpty) {
                title = tooltip.title;
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: IntrinsicWidth(
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        if (tooltip.iconName.isNotEmpty || tooltip.iconData.icons.isNotEmpty)
                          RawSystemTrayIcon(path: tooltip.iconName, data: tooltip.iconData),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title),
                            if (tooltip.description.isNotEmpty)
                              Text(
                                tooltip.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
