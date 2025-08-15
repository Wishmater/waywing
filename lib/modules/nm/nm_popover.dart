import "package:flutter/material.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/nm_service.dart";

class NetworkManagerPopover extends StatelessWidget {
  final NetworkManagerConfig config;
  final NMServiceDevice device;

  const NetworkManagerPopover({
    required this.config,
    required this.device,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
