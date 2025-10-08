import "dart:io";

import "package:flutter/material.dart";
import "package:waywing/modules/command_palette/user_command_service.dart";
import "package:waywing/widgets/searchopts/searchopts.dart";

/// TODO design a way to pass arguments to the command
class CommandPaletteWidget extends StatefulWidget {
  final List<UserCommand> commands;
  final void Function() close;

  const CommandPaletteWidget({required this.commands, required this.close});

  @override
  State<CommandPaletteWidget> createState() => CommandPaletteWidgetState();
}

class CommandPaletteWidgetState extends State<CommandPaletteWidget> {
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode(debugLabel: "launcher");
    focusNode.requestFocus();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchOptions(
      options: Option.from(widget.commands, UserCommandOption.from),
      renderOption: _renderOption,
      onSelected: _run,
      // showScrollBar: widget.config.showScrollBar,
      // height: widget.config.height.toDouble(),
      height: 400.0,
      // width: widget.config.width.toDouble(),
      focusNode: focusNode,
    );
  }

  void _run(UserCommand command) {
    Process.start(
      command.program,
      ["-c", command.path],
      includeParentEnvironment: true,
      mode: ProcessStartMode.detached,
    );
    widget.close();
  }

  Widget _renderOption(BuildContext context, UserCommand command, SearchOptionsRenderConfig config) {
    return ListTileOptionWidget(
      command: command,
      config: config,
      onTap: () => _run(command),
    );
  }
}

class UserCommandOption extends Option<UserCommand> {
  final UserCommand command;
  const UserCommandOption(this.command);

  @override
  UserCommand get object => command;

  @override
  int get identifier => command.hashCode;

  @override
  String get primaryValue => command.name;

  @override
  String get secondaryValue => command.description ?? "";

  factory UserCommandOption.from(UserCommand app) {
    return UserCommandOption(app);
  }
}

class ListTileOptionWidget extends StatelessWidget {
  final UserCommand command;
  final SearchOptionsRenderConfig config;
  final VoidCallback onTap;

  const ListTileOptionWidget({
    required this.command,
    required this.config,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      // leading: app.icon != null ? _RenderIcon(icon: app.icon!, iconSize: iconSize) : SizedBox(width: 35),
      title: Text(
        command.name,
        style: theme.textTheme.bodyLarge,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      onTap: onTap,
      subtitle: command.description != null
          ? Text(
              command.description!,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: theme.textTheme.bodySmall,
            )
          : null,
      enabled: true,
      tileColor: Colors.transparent,
    );
  }
}
