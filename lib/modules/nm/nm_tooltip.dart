import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:human_file_size/human_file_size.dart";
import "package:intl/intl.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/nm_indicator.dart";
import "package:waywing/modules/nm/nm_service.dart";

class NetworkManagerTooltip extends StatelessWidget {
  final NetworkManagerConfig config;
  final NMServiceDevice device;

  const NetworkManagerTooltip({
    required this.config,
    required this.device,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.activeConnection,
      builder: (context, activeConnection, _) {
        if (activeConnection == null) return SizedBox.shrink();
        return IntrinsicHeight(
          child: IntrinsicWidth(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConnectionNameWidget(device: device, padding: EdgeInsets.zero),
                      SizedBox(width: 10),
                      Text("(${device.deviceType.name})"),
                    ],
                  ),
                  SizedBox(height: 4),
                  Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      TableRow(
                        children: [
                          RxRateWidget(device: device, padding: EdgeInsets.only(bottom: 4, right: 14)),
                          TxRateWidget(device: device, padding: EdgeInsets.only(bottom: 4, right: 16)),
                          ThroughputRateWidget(device: device, padding: EdgeInsets.only(bottom: 4)),
                        ],
                      ),
                      TableRow(
                        children: [
                          RxTotalWidget(device: device, padding: EdgeInsets.only(bottom: 4, right: 14)),
                          TxTotalWidget(device: device, padding: EdgeInsets.only(bottom: 4, right: 16)),
                          ThroughputTotalWidget(device: device, padding: EdgeInsets.only(bottom: 4)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ThroughputTotalWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;

  const ThroughputTotalWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 8),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.rxBytes,
      builder: (context, rxBytes, _) {
        return ValueListenableBuilder(
          valueListenable: device.txBytes,
          builder: (context, txBytes, _) {
            if (txBytes == null && rxBytes == null) return SizedBox.shrink();
            final readableBytes = humanFileSize(
              (txBytes ?? 0) + (rxBytes ?? 0),
              quantityDisplayMode: IntlQuantityDisplayMode(
                numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
              ),
            );
            return Padding(
              padding: padding,
              child: Row(
                children: [
                  Icon(
                    MaterialCommunityIcons.swap_vertical_circle,
                    size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 6,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  SizedBox(width: 1),
                  Text(readableBytes),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TxTotalWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;

  const TxTotalWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.txBytes,
      builder: (context, txBytes, _) {
        if (txBytes == null) return SizedBox.shrink();
        final readableBytes = humanFileSize(
          txBytes,
          quantityDisplayMode: IntlQuantityDisplayMode(
            numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
          ),
        );
        return Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(
                MaterialCommunityIcons.arrow_up_circle,
                size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 3,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              SizedBox(width: 2),
              Text(readableBytes),
            ],
          ),
        );
      },
    );
  }
}

class RxTotalWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;

  const RxTotalWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: device.rxBytes,
      builder: (context, rxBytes, _) {
        if (rxBytes == null) return SizedBox.shrink();
        final readableBytes = humanFileSize(
          rxBytes,
          quantityDisplayMode: IntlQuantityDisplayMode(
            numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
          ),
        );
        return Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(
                MaterialCommunityIcons.arrow_down_circle,
                size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 3,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              SizedBox(width: 2),
              Text(readableBytes),
            ],
          ),
        );
      },
    );
  }
}
