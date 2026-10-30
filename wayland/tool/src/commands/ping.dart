import 'dart:io';

import '../tool.dart';

class PingCommand extends ToolCommand {
  @override
  String get name => 'ping';

  @override
  String get description => 'Check that the app can run on this Wayland host.';

  @override
  String get invocation => 'dart wayland/tool/wayland.dart ping';

  @override
  bool get takesArguments => false;

  @override
  void run() {
    final problems = <String>[];
    if (!File('${tool.paths.waylandDir}/build.zig').existsSync()) {
      problems.add('wayland/build.zig not found');
    }
    if ((Platform.environment['WAYLAND_DISPLAY'] ?? '').isEmpty) {
      problems.add('WAYLAND_DISPLAY is not set');
    }
    if ((Platform.environment['XDG_RUNTIME_DIR'] ?? '').isEmpty) {
      problems.add('XDG_RUNTIME_DIR is not set');
    }
    if (problems.isEmpty) return;
    for (final problem in problems) {
      stderr.writeln('$toolName: $problem');
    }
    exitCode = 1;
  }
}
