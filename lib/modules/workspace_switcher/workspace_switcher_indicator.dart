import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:waywing/services/compositors/compositor.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

class WorkspaceSwitcherIndicator extends StatefulWidget {
  final CompositorService service;

  const WorkspaceSwitcherIndicator({super.key, required this.service});

  @override
  State<WorkspaceSwitcherIndicator> createState() => _WorkspaceSwitcherIndicatorState();
}

class _WorkspaceSwitcherIndicatorState extends State<WorkspaceSwitcherIndicator> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ValueListenableBuilder(
        valueListenable: widget.service.workspaces,
        builder: (context, workspaces, _) {
          final workspacesSorted = workspaces.workspaces.sortedBy((e) => e.position);
          return Row(
            children: [
              for (final workspace in workspacesSorted)
                _WorkspaceWidget(
                  workspace,
                  workspaces.focused.any((e) => e.$2.id == workspace.id),
                  widget.service,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkspaceWidget extends StatelessWidget {
  final CompositorWorkspace workspace;
  final bool isCurrent;
  final CompositorService service;

  const _WorkspaceWidget(this.workspace, this.isCurrent, this.service);

  void changeWorkspace() {
    service.switchWorkspace(workspace);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WingedButton(
      color: isCurrent ? theme.colorScheme.primaryContainer : null,
      onTap: (_, _) => changeWorkspace(),
      child: Text(workspace.name),
    );
  }
}
