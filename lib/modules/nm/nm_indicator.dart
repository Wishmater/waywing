import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:human_file_size/human_file_size.dart";
import "package:intl/intl.dart";
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
            if (!isVertical && isConnected) {
              if (constraints.maxHeight >= 56) {
                result = Row(
                  children: [
                    result,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (config.showConnectionNameIndicator) ConnectionNameWidget(device: device),
                        Row(
                          children: [
                            if (config.showDownloadIndicator) RxRateWidget(device: device),
                            if (config.showUploadIndicator) TxRateWidget(device: device),
                            if (config.showThroughputIndicator) ThroughputRateWidget(device: device),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                result = Row(
                  children: [
                    result,
                    if (config.showConnectionNameIndicator) ConnectionNameWidget(device: device),
                    if (config.showDownloadIndicator) RxRateWidget(device: device),
                    if (config.showUploadIndicator) TxRateWidget(device: device),
                    if (config.showThroughputIndicator) ThroughputRateWidget(device: device),
                  ],
                );
              }
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

class ConnectionNameWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;

  const ConnectionNameWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.activeConnection,
      builder: (context, activeConnection, _) {
        if (activeConnection == null) return SizedBox.shrink();
        return Padding(
          padding: padding,
          child: Text(activeConnection.id),
        );
      },
    );
  }
}

class ThroughputRateWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;

  const ThroughputRateWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 8),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.rxRate,
      builder: (context, rxRate, _) {
        return ValueListenableBuilder(
          valueListenable: device.txRate,
          builder: (context, txRate, _) {
            if (txRate == null && rxRate == null) return SizedBox.shrink();
            final readableBytes = humanFileSize(
              (txRate ?? 0) + (rxRate ?? 0),
              quantityDisplayMode: IntlQuantityDisplayMode(
                numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
              ),
            );
            return Padding(
              padding: padding,
              child: Row(
                children: [
                  Icon(
                    MaterialCommunityIcons.swap_vertical_bold,
                    size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 4,
                  ),
                  SizedBox(width: 1),
                  Text("$readableBytes/s"),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TxRateWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;

  const TxRateWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.txRate,
      builder: (context, txRate, _) {
        if (txRate == null) return SizedBox.shrink();
        final readableBytes = humanFileSize(
          txRate,
          quantityDisplayMode: IntlQuantityDisplayMode(
            numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
          ),
        );
        return Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(
                MaterialCommunityIcons.arrow_up_bold,
                size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
              ),
              SizedBox(width: 2),
              Text("$readableBytes/s"),
            ],
          ),
        );
      },
    );
  }
}

class RxRateWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;

  const RxRateWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.rxRate,
      builder: (context, rxRate, _) {
        if (rxRate == null) return SizedBox.shrink();
        final readableBytes = humanFileSize(
          rxRate,
          quantityDisplayMode: IntlQuantityDisplayMode(
            numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
          ),
        );
        return Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(
                MaterialCommunityIcons.arrow_down_bold,
                size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
              ),
              SizedBox(width: 2),
              Text("$readableBytes/s"),
            ],
          ),
        );
      },
    );
  }
}
