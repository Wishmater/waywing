import "package:flutter/material.dart";
import "package:waywing/modules/workspace_switcher/workspace_switcher_provider.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

class WorkspaceSwitcherIndicator extends StatefulWidget {
  final IWorkspaceSwitcherProvider provider;

  const WorkspaceSwitcherIndicator({super.key, required this.provider});

  @override
  State<WorkspaceSwitcherIndicator> createState() => _WorkspaceSwitcherIndicatorState();
}

class _WorkspaceSwitcherIndicatorState extends State<WorkspaceSwitcherIndicator> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ValueListenableBuilder(
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
      ),
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
  }
}
