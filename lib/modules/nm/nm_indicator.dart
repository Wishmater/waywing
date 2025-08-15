import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:nm/nm.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/widgets/winged_button.dart";
import "package:waywing/widgets/winged_popover.dart";

class NetworkManagerIndicator extends StatelessWidget {
  final NetworkManagerConfig config;
  final NMServiceDevice device;
  final WingedPopoverController? popover;

  const NetworkManagerIndicator({
    required this.config,
    required this.device,
    required this.popover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.isConnected,
      builder: (context, isConnected, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            Widget result = NetworkIcon(
              device: device,
              type: device.deviceType,
              isConnected: isConnected,
            );
            final isVertical = constraints.maxHeight > constraints.maxWidth;
            if (isVertical && !isConnected) {
              // TODO: 1 add connected network icon and statistics if enabled in config
            }
            return WingedButton(
              onTap: popover?.isPopoverEnabled ?? false ? () => popover!.togglePopover() : null,
              child: result,
            );
          },
        );
      },
    );
  }
}

class NetworkIcon extends StatelessWidget {
  final NMServiceDevice device;
  final NetworkManagerDeviceType type;
  final bool isConnected;

  const NetworkIcon({
    required this.device,
    required this.type,
    required this.isConnected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      NetworkManagerDeviceType.wifi => isConnected ? Icon(Icons.wifi) : Icon(Icons.wifi_off),
      NetworkManagerDeviceType.ethernet => Icon(MaterialCommunityIcons.ethernet),
      NetworkManagerDeviceType.bluetooth => Icon(Icons.bluetooth_connected),
      NetworkManagerDeviceType.vlan => Icon(Icons.lan),
      NetworkManagerDeviceType.bridge => Icon(MaterialCommunityIcons.network_outline),
      _ => Icon(Icons.question_mark),
    };
  }
}
