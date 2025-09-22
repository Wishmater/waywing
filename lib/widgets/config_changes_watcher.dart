import "dart:async";
import "dart:io";

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
    while(true) {
      final w = watcher.DirectoryWatcher(File(filepath).parent.path);
      _logger.trace("watching directory for configuration reset ${w.path}");
      final completer = Completer<()>();
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
        onDone: () async {
          _logger.debug("watching directory end");
          completer.complete(());
        },
        cancelOnError: false,
      );
      await completer.future;
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize feathers. This has to be done here, because we don't have a BuildContext in main()
    featherRegistry.onConfigUpdated(context);
    mainConfig.exclusiveSize.addListener(updateWindows);
    updateWindows();

    _watch();
  }

  Future<void> onConfigUpdated() async {
    final context = this.context; // declare local reference to please the linter
    final oldConfig = mainConfig;
    String content = defaultConfig;
    final file = File(getConfigurationFilePath());
    if (file.existsSync()) {
      content = await file.readAsString();
    } else {
      _logger.debug("configuration file not found");
    }
    await reloadConfig(content);
    if (!context.mounted) return; // something weird happened, probably the app was just closed
    final newConfig = mainConfig;

    featherRegistry.onConfigUpdated(context);
    serviceRegistry.onConfigUpdated();

    if (newConfig.exclusiveSize.value != oldConfig.exclusiveSize.value || newConfig.monitor != oldConfig.monitor) {
      updateWindows();
    }
    oldConfig.exclusiveSize.removeListener(updateWindows);
    newConfig.exclusiveSize.addListener(updateWindows);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
