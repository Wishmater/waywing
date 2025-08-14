import "package:flutter/material.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/widgets/winged_button.dart";
import "package:waywing/widgets/winged_popover.dart";

class NetworkManagerIndicator extends StatefulWidget {
  final NetworkManagerConfig config;
  final NetworkManagerService service;
  final WingedPopoverController popover;

  const NetworkManagerIndicator({
    required this.config,
    required this.service,
    required this.popover,
    super.key,
  });

  @override
  State<NetworkManagerIndicator> createState() => _NetworkManagerIndicatorState();
}

class _NetworkManagerIndicatorState extends State<NetworkManagerIndicator> {
  @override
  Widget build(BuildContext context) {
    return WingedButton(
      onTap: () => widget.popover.togglePopover(),
      child: Placeholder(),
    );
  }
}
