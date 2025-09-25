import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:waywing/modules/workspace_switcher/workspace_switcher_provider.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";

class WorkspaceSwitcherIndicator extends StatefulWidget {
  final IWorkspaceSwitcherProvider provider;

  const WorkspaceSwitcherIndicator({super.key, required this.provider});

  @override
  State<WorkspaceSwitcherIndicator> createState() => _WorkspaceSwitcherIndicatorState();
}

class _WorkspaceSwitcherIndicatorState extends State<WorkspaceSwitcherIndicator> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.provider.current,
      builder: (context, current, _) {
        return ValueListenableBuilder(
          valueListenable: widget.provider.workspaces,
          builder: (context, workspaces, _) {
            return Row(
              children: [
                for (final workspace in workspaces)
                  _WorkspaceWidget(
                    workspace,
                    workspace.id == current.id,
                    widget.provider,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WorkspaceWidget extends StatelessWidget {
  final Workspace workspace;
  final bool isCurrent;
  final IWorkspaceSwitcherProvider provider;

  const _WorkspaceWidget(this.workspace, this.isCurrent, this.provider);

  void changeWorkspace() {
    provider.changeWorkspace(workspace);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WingedButton(
      color: isCurrent ? theme.colorScheme.primaryContainer : null,
      onTap: changeWorkspace,
      child: Text(workspace.name),
    );
    // if (isCurrent) {
    //   return Padding(
    //     padding: const EdgeInsets.only(left: 8.0, right: 8.0),
    //     child: Text("[${workspace.name}]"),
    //   );
    // } else {
    //   return Padding(
    //     padding: const EdgeInsets.only(left: 8.0, right: 8.0),
    //     child: Text("${workspace.name}"),
    //   );
    // }
  }
}
