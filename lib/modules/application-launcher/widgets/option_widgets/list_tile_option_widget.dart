import "package:flutter/material.dart";
import "package:waywing/modules/application-launcher/models/application.dart";
import "package:waywing/modules/application-launcher/widgets/searchopts.dart";
import "package:xdg_icons/xdg_icons.dart";

class ListTileOptionWidget extends StatelessWidget {
  final Application app;
  final SearchOptionsRenderConfig config;
  final VoidCallback onTap;

  const ListTileOptionWidget({
    required this.app,
    required this.config,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: app.icon != null ? XdgIcon(name: app.icon!) : SizedBox(width: 35),
      title: Text(
        app.name,
        style: theme.textTheme.bodyLarge,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      onTap: onTap,
      subtitle: app.comment != null
          ? Text(
              app.comment!,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: theme.textTheme.bodySmall,
            )
          : SizedBox.shrink(),
      enabled: true,
      tileColor: Colors.transparent,
    );
  }
}
