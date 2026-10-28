import "dart:io";

import "../tool.dart";

class PostBuildCommand extends ToolCommand {
  @override
  String get name => "post-build";

  @override
  String get description =>
      "Build the debug host and record the build manifest.";

  @override
  String get invocation =>
      "dart wayland/tool/wayland.dart post-build <appName> <localPath> "
      "<buildMode> <icuDataPath> <engineRevision>";

  @override
  Future<void> run() async {
    final args = argResults!.rest;
    expectCount(args, 5);
    final appName = args[0];
    final localPath = args[1].isEmpty ? null : args[1];
    final buildMode = args[2];
    // args[4] (engineRevision) is accepted for future packaging steps; the
    // host does not need it.
    final icuDataPath = args[3].isEmpty ? null : args[3];

    // Custom devices only invoke this hook for debug builds. Fail clearly
    // instead of silently producing a debug host and a release-less manifest
    // if Flutter ever starts calling it with another mode.
    if (buildMode != "debug") {
      throw ToolError(
        "Flutter custom devices only support debug builds; use "
        '"dart wayland/tool/wayland.dart build-release" for a release build',
      );
    }

    await runInherited(
      "zig",
      ["build", "-Doptimize=Debug", "-Dapp-name=$appName"],
      workingDirectory: tool.paths.waylandDir,
      missingMessage: "zig is not on PATH",
    );

    final host = File("${tool.paths.hostDir}/$appName");
    if (!host.existsSync()) {
      throw ToolError("zig build did not create ${host.path}");
    }

    final manifest = tool.resolveLaunch(
      appName: appName,
      localPath: localPath,
      icuOverride: icuDataPath,
    );
    writeJson(tool.paths.launchBuildFile, manifest);
    stdout.writeln("$toolName: wrote ${tool.paths.launchBuildFile}");
  }
}
