import "dart:io";

import "package:flutter/material.dart";
import "package:waywing/modules/application-launcher/application_service.dart";
import "package:waywing/modules/application-launcher/application.dart";
import "package:waywing/modules/application-launcher/launcher_config.dart";
import "package:waywing/widgets/searchopts/searchopts.dart";
import "package:xdg_icons/xdg_icons.dart";

class LauncherWidget extends StatefulWidget {
  final List<Application> applications;
  final ApplicationService service;
  final LauncherConfig config;

  const LauncherWidget({
    super.key,
    required this.service,
    required this.applications,
    required this.config,
  });

  @override
  State<LauncherWidget> createState() => _LauncherWidgetState();
}

class _LauncherWidgetState extends State<LauncherWidget> {
  @override
  Widget build(BuildContext context) {
    return SearchOptions(
      options: Option.from(widget.applications, ApplicationOption.from),
      renderOption: _renderOption,
      onSelected: widget.service.run,
      showScrollBar: widget.config.showScrollBar,
      height: widget.config.height.toDouble(),
      width: widget.config.width.toDouble(),
    );
  }

  Widget _renderOption(BuildContext context, Application app, SearchOptionsRenderConfig config) {
    return ListTileOptionWidget(
      app: app,
      config: config,
      onTap: () => widget.service.run(app),
    );
  }
}

class ApplicationOption extends Option<Application> {
  final Application app;
  const ApplicationOption(this.app);

  @override
  Application get object => app;

  @override
  String get value => app.name;

  factory ApplicationOption.from(Application app) {
    return ApplicationOption(app);
  }
}

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
      leading: app.icon != null ? _RenderIcon(icon: app.icon!) : SizedBox(width: 35),
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

class _RenderIcon extends StatelessWidget {
  final String icon;
  const _RenderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon.startsWith("/")) {
      final size = XdgIconTheme.of(context).size;
      return Image.file(File(icon), height: size?.toDouble(), width: size?.toDouble());
    }
    return XdgIcon(name: icon);
  }
}
