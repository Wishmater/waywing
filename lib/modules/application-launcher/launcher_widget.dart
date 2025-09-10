import "package:flutter/material.dart";
import "package:waywing/modules/application-launcher/application_service.dart";
import "package:waywing/modules/application-launcher/models/application.dart";
import "./widgets/option_widgets/list_tile_option_widget.dart";
import "package:waywing/modules/application-launcher/widgets/searchopts.dart";

class LauncherWidget extends StatefulWidget {
  final List<Application> applications;
  final ApplicationService service;

  const LauncherWidget({super.key, required this.service, required this.applications});

  @override
  State<LauncherWidget> createState() => LauncherState();
}

class LauncherState extends State<LauncherWidget> {
  @override
  Widget build(BuildContext context) {
    // return Container(color: Colors.blue, height: 400, width: 400, child: TextFormField());
    return SearchOptions(
      options: Option.from(widget.applications, ApplicationOption.from),
      renderOption: _renderOption,
      onSelected: widget.service.run,
    );
  }

  Widget _renderOption(BuildContext context, Application app, SearchOptionsRenderConfig config) {
    return ListTileOptionWidget(
      app: app,
      config: config,
      onTap:  () => widget.service.run(app),
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

class SearchApplication extends StatelessWidget {
  final List<Application> apps;
  final ApplicationService service;
  const SearchApplication({super.key, required this.service, required this.apps});

  @override
  Widget build(BuildContext context) {
    return SearchOptions(
      options: Option.from(apps, ApplicationOption.from),
      renderOption: _renderOption,
      onSelected: service.run,
    );
  }

  Widget _renderOption(BuildContext context, Application app, SearchOptionsRenderConfig config) {
    return ListTileOptionWidget(
      app: app,
      config: config,
      onTap:  () => service.run(app),
    );
  }
}
