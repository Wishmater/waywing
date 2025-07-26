import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart' as watcher;

import 'package:fl_linux_window_manager/controller/input_region_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:waywing/core/feather_registry.dart';
import 'package:waywing/core/config.dart';
import 'package:waywing/util/window_utils.dart';

// TODO: 1 move most of this shit to a config util file

String _defaultConfig = '''
  seedColor = "#0000ff"
  animationDuration = 250ms
  barSide = "top"
  barSize = 64
  barMarginLeft = barSize
  barMarginRight = barSize
  barRadiusInCross = barSize * 0.5
  barRadiusInMain = barSize * 0.5 * 0.67
  barRadiusOutCross = barSize * 0.5
  barRadiusOutMain = barSize * 0.5 * 1.5
''';

String getConfigurationFilePath() {
  final configDir = Platform.environment['XDG_CONFIG_HOME'] ?? expandEnvironmentVariables(r'$HOME/.config');
  return path.joinAll([configDir, 'waywing', 'config']);
}

String getConfigurationDirectoryPath() {
  final configDir = Platform.environment['XDG_CONFIG_HOME'] ?? expandEnvironmentVariables(r'$HOME/.config');
  return path.joinAll([configDir, 'waywing']);
}

String getConfigurationString() {
  final file = File(getConfigurationFilePath());
  if (file.existsSync()) {
    return file.readAsStringSync();
  } else {
    return _defaultConfig;
  }
}

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
          print('WATCH CONFIGURATION FILE EVENT $event');
          onConfigUpdated();
        }
      },
      onError: (e) {
        print('WATCHING DIRECTORY ERROR $e');
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
    String content = _defaultConfig;
    final file = File(getConfigurationFilePath());
    if (file.existsSync()) {
      content = await file.readAsString();
    } else {
      print('CONFIGURATION FILE NOT FOUND');
    }
    await reloadConfig(content);
    if (!context.mounted) return; // something weird happened, probably the app was just closed
    final newConfig = config;

    featherRegistry.onConfigUpdated(context);

    if (newConfig.barSide != oldConfig.barSide ||
        newConfig.barSize != oldConfig.barSize ||
        newConfig.exclusiveSizeLeft != oldConfig.exclusiveSizeLeft ||
        newConfig.exclusiveSizeRight != oldConfig.exclusiveSizeRight ||
        newConfig.exclusiveSizeTop != oldConfig.exclusiveSizeTop ||
        newConfig.exclusiveSizeBottom != oldConfig.exclusiveSizeBottom) {
      onWindowConfigUpdated();
    }

    setState(() {});
  }

  Future<void> onWindowConfigUpdated() async {
    await updateEdgeWindows();
    InputRegionController.notifyConfigChange();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

// Only if the dollar sign does not have a backslash before it.
final _unescapedVariables = RegExp(r'(?<!\\)\$([a-zA-Z_]+[a-zA-Z0-9_]*)');

/// Resolves environment variables. Replaces all $VARS with their value.
String expandEnvironmentVariables(String path) {
  return path.replaceAllMapped(_unescapedVariables, (Match match) {
    String env = match[1]!;
    return Platform.environment[env] ?? '';
  });
}
