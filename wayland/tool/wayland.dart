#!/usr/bin/env dart

// Wayland host tooling for a Flutter app using filo.
//
// `wayland/tool/wayland.dart` is the command-line entrypoint. Each command
// lives in its own file under `tool/src/commands/`; shared path, manifest,
// `.env.local` and process helpers are in `tool/src/`. The tool uses the Dart
// SDK plus `package:args`, which the app's pubspec provides.
//
// Custom devices run hooks from the app root. The app root is derived from this
// script's location (`<app>/wayland/tool/wayland.dart`), not from the current
// directory, so the tool also works when invoked manually.
//
// Run it as `dart wayland/tool/wayland.dart <command>` (not `dart run`): the
// plain form keeps the Dart VM in the process Flutter starts, which matters for
// the one-shot hooks.

import "dart:io";

import "package:args/command_runner.dart";

import "src/commands/build_release.dart";
import "src/commands/install.dart";
import "src/commands/ping.dart";
import "src/commands/post_build.dart";
import "src/commands/register_device.dart";
import "src/commands/run.dart";
import "src/commands/setup_filo.dart";
import "src/commands/uninstall.dart";
import "src/tool.dart";

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<void>(
          "dart wayland/tool/wayland.dart",
          "Wayland host tooling for a Flutter app using filo.",
        )
        ..addCommand(PingCommand())
        ..addCommand(PostBuildCommand())
        ..addCommand(InstallCommand())
        ..addCommand(UninstallCommand())
        ..addCommand(RunCommand())
        ..addCommand(BuildReleaseCommand())
        ..addCommand(SetupFiloCommand())
        ..addCommand(RegisterDeviceCommand());

  try {
    await runner.run(args);
  } on UsageException catch (error) {
    stderr.writeln("$toolName: ${error.message}");
    stderr.writeln(error.usage);
    exitCode = 64;
  } on ToolError catch (error) {
    stderr.writeln("$toolName: ${error.message}");
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln("$toolName: ${error.message}");
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln("$toolName: ${error.message}");
    exitCode = 1;
  }
}
