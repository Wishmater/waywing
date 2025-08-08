import "dart:async";
import "dart:io";

import "package:fl_linux_window_manager/controller/input_region_controller.dart";
import "package:flutter/widgets.dart";
import "package:watcher/watcher.dart" as watcher;
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/util/window_utils.dart";

final _logger = mainLogger.clone(properties: [LogType("ConfigWatcher")]);

class ConfigChangeWatcher extends StatefulWidget {
  final WidgetBuilder builder;

  const ConfigChangeWatcher({required this.builder, super.key});

  @override
  State<ConfigChangeWatcher> createState() => _ConfigChangeWatcherState();
}

class _ConfigChangeWatcherState extends State<ConfigChangeWatcher> {
  void _watch() async {
    final filepath = getConfigurationFilePath();
    final w = watcher.DirectoryWatcher(getConfigurationDirectoryPath());
    w.events.listen(
      (event) {
        if (event.path == filepath) {
          if (event.type == watcher.ChangeType.REMOVE) {
            return;
          }
          _logger.trace("watch configuration file event $event");
          onConfigUpdated();
        }
      },
      onError: (e) {
        _logger.error("watching directory error $e");
      },
      cancelOnError: true,
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize feathers. This has to be done here, because we don't have a BuildContext in main()
    featherRegistry.onConfigUpdated(context);

    _watch();
  }

  Future<void> onConfigUpdated() async {
    final context = this.context; // declare local reference to please the linter
    final oldConfig = config;
    String content = defaultConfig;
    final file = File(getConfigurationFilePath());
    if (file.existsSync()) {
      content = await file.readAsString();
    } else {
      _logger.debug("configuration file not found");
    }
    await reloadConfig(content);
    if (!context.mounted) return; // something weird happened, probably the app was just closed
    final newConfig = config;

    featherRegistry.onConfigUpdated(context);
    serviceRegistry.onConfigUpdated();

    if (newConfig.barSide != oldConfig.barSide ||
        newConfig.barSize != oldConfig.barSize ||
        newConfig.exclusiveSizeLeft != oldConfig.exclusiveSizeLeft ||
        newConfig.exclusiveSizeRight != oldConfig.exclusiveSizeRight ||
        newConfig.exclusiveSizeTop != oldConfig.exclusiveSizeTop ||
        newConfig.exclusiveSizeBottom != oldConfig.exclusiveSizeBottom ||
        newConfig.barMonitor != oldConfig.barMonitor) {
      onWindowConfigUpdated();
    }

    setState(() {});
  }

  Future<void> onWindowConfigUpdated() async {
    await updateWindows();
    InputRegionController.notifyConfigChange();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
