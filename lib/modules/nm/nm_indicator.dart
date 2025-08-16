import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:human_file_size/human_file_size.dart";
import "package:intl/intl.dart";
import "package:nm/nm.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/util/human_readable_bytes.dart";
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
              showTxRxIndicators:
                  !config.showThroughputIndicator && !config.showDownloadIndicator && !config.showUploadIndicator,
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

// TODO: 1 implement activity download/upload indicator to the bottomRight of icon
class NetworkIcon extends StatelessWidget {
  final NMServiceDevice device;
  final NetworkManagerDeviceType type;
  final bool isConnected;
  final bool showTxRxIndicators;

  const NetworkIcon({
    required this.device,
    required this.type,
    required this.isConnected,
    this.showTxRxIndicators = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (type == NetworkManagerDeviceType.wifi) {
      return WifiIcon(
        device: device as NMServiceWifiDevice,
        accessPoint: null,
        type: type,
        isConnected: isConnected,
        showTxRxIndicators: showTxRxIndicators,
      );
    }

    // TODO: 3 implement icons for other network types
    Widget result = switch (type) {
      NetworkManagerDeviceType.ethernet => Icon(MaterialCommunityIcons.ethernet),
      NetworkManagerDeviceType.bluetooth => Icon(Icons.bluetooth_connected),
      NetworkManagerDeviceType.vlan => Icon(Icons.lan),
      NetworkManagerDeviceType.bridge => Icon(MaterialCommunityIcons.network_outline),
      _ => Icon(Icons.question_mark),
    };

    if (isConnected && showTxRxIndicators) {
      result = TxRxIndicatorOverlay(device: device, child: result);
    }

    return result;
  }
}

class WifiIcon extends StatelessWidget {
  final NMServiceWifiDevice device;
  final NMServiceAccessPoint? accessPoint;
  final NetworkManagerDeviceType type;
  final bool isConnected;
  final bool showTxRxIndicators;
  final Color? color;

  const WifiIcon({
    required this.device,
    required this.accessPoint,
    required this.type,
    required this.isConnected,
    this.showTxRxIndicators = false,
    this.color,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    Widget result;
    if (accessPoint != null) {
      result = buildWithAp(accessPoint);
    } else {
      result = ValueListenableBuilder(
        valueListenable: device.activeAccessPoint,
        builder: (context, ap, _) {
          return buildWithAp(ap);
        },
      );
    }

    if (isConnected && showTxRxIndicators) {
      result = TxRxIndicatorOverlay(device: device, child: result);
    }

    return result;
  }

  Widget buildWithAp(NMServiceAccessPoint? ap) {
    if (ap != null) {
      // TODO: 1 implement wifi strength in icon
      return Icon(Icons.wifi, color: color);
    }
    if (isConnected) {
      return Icon(Icons.wifi, color: color);
    }
    return Icon(Icons.wifi_off, color: color);
  }
}

class TxRxIndicatorOverlay extends StatelessWidget {
  final NMServiceDevice device;
  final Widget child;

  const TxRxIndicatorOverlay({
    required this.device,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.rxRate,
      child: child,
      builder: (context, rxRate, child) {
        return ValueListenableBuilder(
          valueListenable: device.txRate,
          child: child,
          builder: (context, txRate, child) {
            // TODO: 2 add fast animation here ?
            Widget? extraIcon;
            if (txRate != null && txRate > 0 && rxRate != null && rxRate > 0) {
              final ratio = rxRate / txRate;
              if (ratio > 100) {
                extraIcon = buildDownIcon(context);
              } else if (ratio < 0.01) {
                extraIcon = buildUpIcon(context);
              } else {
                extraIcon = buildUpDownIcon(context);
              }
            } else if (rxRate != null && rxRate > 0) {
              extraIcon = buildDownIcon(context);
            } else if (txRate != null && txRate > 0) {
              extraIcon = buildUpIcon(context);
            }
            if (extraIcon == null) {
              return child!;
            } else {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  child!,
                  Positioned(
                    bottom: 0,
                    right: 0,
                    height: 0,
                    width: 0,
                    child: OverflowBox(
                      alignment: Alignment.center,
                      maxHeight: double.infinity,
                      maxWidth: double.infinity,
                      child: extraIcon,
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Icon buildUpDownIcon(BuildContext context) {
    return Icon(
      MaterialCommunityIcons.swap_vertical_bold,
      size: 12,
      color: Theme.of(context).textTheme.bodyMedium!.color,
    );
  }

  Icon buildUpIcon(BuildContext context) {
    return Icon(
      MaterialCommunityIcons.arrow_up_bold,
      size: 10,
      color: Theme.of(context).textTheme.bodyMedium!.color,
    );
  }

  Icon buildDownIcon(BuildContext context) {
    return Icon(
      MaterialCommunityIcons.arrow_down_bold,
      size: 10,
      color: Theme.of(context).textTheme.bodyMedium!.color,
    );
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
              unitConversion: const UnitConversion.bestFit(
                numeralSystem: DecimalByteNumeralSystem(),
              ),
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
                    color: Theme.of(context).textTheme.bodyMedium!.color,
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
          unitConversion: const UnitConversion.bestFit(
            numeralSystem: DecimalByteNumeralSystem(),
          ),
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
                color: Theme.of(context).textTheme.bodyMedium!.color,
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
          unitConversion: const UnitConversion.bestFit(
            numeralSystem: DecimalByteNumeralSystem(),
          ),
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
                color: Theme.of(context).textTheme.bodyMedium!.color,
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
