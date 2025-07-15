import 'package:fl_linux_window_manager/controller/input_region_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:waywing/core/feather_service.dart';
import 'package:waywing/core/config.dart';
import 'package:waywing/util/window_utils.dart';

class ConfigChangeWatcher extends StatefulWidget {
  final Widget child;

  const ConfigChangeWatcher({required this.child, super.key});

  @override
  State<ConfigChangeWatcher> createState() => _ConfigChangeWatcherState();
}

class _ConfigChangeWatcherState extends State<ConfigChangeWatcher> {
  @override
  void initState() {
    super.initState();

    // Initialize feathers. This has to be done here, because we don't have a BuildContext in main()
    feathers.onConfigUpdated(context);

    // TODO: 2 listen to config file, and call onConfigUpdated
  }

  @override
  void didUpdateWidget(covariant ConfigChangeWatcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    // hack to always update hardcoded config on hot reload
    onConfigUpdated(doSetState: false); // TODO: 2 remove this once reading user config is implemented
  }

  Future<void> onConfigUpdated({bool doSetState = true}) async {
    final context = this.context; // declare local reference to please the linter
    final oldConfig = config;
    await reloadConfig();
    if (!context.mounted) return; // something weird happened, probably the app was just closed
    final newConfig = config;

    feathers.onConfigUpdated(context);

    if (newConfig.barSide != oldConfig.barSide ||
        newConfig.barWidth != oldConfig.barWidth ||
        newConfig.exclusiveSizeLeft != oldConfig.exclusiveSizeLeft ||
        newConfig.exclusiveSizeRight != oldConfig.exclusiveSizeRight ||
        newConfig.exclusiveSizeTop != oldConfig.exclusiveSizeTop ||
        newConfig.exclusiveSizeBottom != oldConfig.exclusiveSizeBottom) {
      onWindowConfigUpdated();
    }

    if (doSetState) {
      setState(() {});
    }
  }

  Future<void> onWindowConfigUpdated() async {
    await updateEdgeWindows();
    InputRegionController.notifyConfigChange();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
