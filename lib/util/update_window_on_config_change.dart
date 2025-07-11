import 'package:fl_linux_window_manager/controller/input_region_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:waywing/util/config.dart';
import 'package:waywing/util/window_utils.dart';

class UpdateWindowOnConfigChange extends StatefulWidget {
  final Config config;
  final Widget child;

  const UpdateWindowOnConfigChange({
    required this.config,
    required this.child,
    super.key,
  });

  @override
  State<UpdateWindowOnConfigChange> createState() => _UpdateWindowOnConfigChangeState();
}

class _UpdateWindowOnConfigChangeState extends State<UpdateWindowOnConfigChange> {
  @override
  void didUpdateWidget(covariant UpdateWindowOnConfigChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.barSide != oldWidget.config.barSide || widget.config.barWidth != oldWidget.config.barWidth) {
      onRelevantConfigUpdate();
    }
  }

  Future<void> onRelevantConfigUpdate() async {
    await updateMainWindow();
    InputRegionController.notifyConfigChange();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
