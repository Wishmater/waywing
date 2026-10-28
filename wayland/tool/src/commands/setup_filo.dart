import '../tool.dart';

class SetupFiloCommand extends ToolCommand {
  @override
  String get name => 'setup-filo';

  @override
  String get description => 'Fetch the filo Zig dependency and pin its hash.';

  @override
  String get invocation =>
      'dart wayland/tool/wayland.dart setup-filo <filo-package-url>';

  @override
  Future<void> run() async {
    final args = argResults!.rest;
    expectCount(args, 1);
    await runInherited(
      'zig',
      ['fetch', '--save=filo', args[0]],
      workingDirectory: tool.paths.waylandDir,
      missingMessage: 'zig is not on PATH',
    );
  }
}
