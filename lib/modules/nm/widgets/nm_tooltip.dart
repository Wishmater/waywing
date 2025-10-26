import "package:flutter/material.dart";
import "package:human_file_size/human_file_size.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/widgets/nm_indicator.dart";
import "package:waywing/modules/nm/service/nm_service.dart";
import "package:waywing/util/human_readable_bytes.dart";
import "package:waywing/widgets/winged_widgets/icon_indicator.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder(
          valueListenable: device.isConnected,
          builder: (context, isConnected, _) {
            if (!isConnected) return SizedBox.shrink(); // tooltip should be disabled if !isConnected
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
                              RxRateWidget(
                                device: device,
                                padding: EdgeInsets.only(bottom: 4, right: 14),
                                layout: IconAndTextLayout.fromConstraints(constraints),
                              ),
                              TxRateWidget(
                                device: device,
                                padding: EdgeInsets.only(bottom: 4, right: 16),
                                layout: IconAndTextLayout.fromConstraints(constraints),
                              ),
                              ThroughputRateWidget(
                                device: device,
                                padding: EdgeInsets.only(bottom: 4),
                                layout: IconAndTextLayout.fromConstraints(constraints),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              RxTotalWidget(
                                device: device,
                                padding: EdgeInsets.only(bottom: 4, right: 14),
                                layout: IconAndTextLayout.fromConstraints(constraints),
                              ),
                              TxTotalWidget(
                                device: device,
                                padding: EdgeInsets.only(bottom: 4, right: 16),
                                layout: IconAndTextLayout.fromConstraints(constraints),
                              ),
                              ThroughputTotalWidget(
                                device: device,
                                padding: EdgeInsets.only(bottom: 4),
                                layout: IconAndTextLayout.fromConstraints(constraints),
                              ),
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
      },
    );
  }
}

class ThroughputTotalWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;
  final IconAndTextLayout? layout;

  const ThroughputTotalWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 8),
    this.layout,
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
              unitConversion: const BestFitDecUnitConversion(
                numeralSystem: DecimalByteNumeralSystem(),
              ),
              quantityDisplayMode: IntlQuantityDisplayMode(
                numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
              ),
            );
            return IconAndTextIndicator(
              padding: padding,
              layout: layout,
              text: readableBytes,
              icon: WingedIcon(
                flutterIcon: SymbolsVaried.swap_vertical_circle,
                // TODO: 3 ICONS set a linux icon for this
                textIcon: "󰿣", // nf-md-swap_vertical_circle
                size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
                color: Theme.of(context).textTheme.bodyMedium!.color,
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
  final IconAndTextLayout? layout;

  const TxTotalWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    this.layout,
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
          unitConversion: const BestFitDecUnitConversion(
            numeralSystem: DecimalByteNumeralSystem(),
          ),
          quantityDisplayMode: IntlQuantityDisplayMode(
            numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
          ),
        );
        return IconAndTextIndicator(
          padding: padding,
          layout: layout,
          text: readableBytes,
          icon: WingedIcon(
            flutterIcon: SymbolsVaried.arrow_circle_up,
            // TODO: 3 ICONS set a linux icon for this
            textIcon: "󰳡", // nf-md-arrow_up_circle
            size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        );
      },
    );
  }
}

class RxTotalWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;
  final IconAndTextLayout? layout;

  const RxTotalWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    this.layout,
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
          unitConversion: const BestFitDecUnitConversion(
            numeralSystem: DecimalByteNumeralSystem(),
          ),
          quantityDisplayMode: IntlQuantityDisplayMode(
            numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
          ),
        );
        return IconAndTextIndicator(
          padding: padding,
          layout: layout,
          text: readableBytes,
          icon: WingedIcon(
            flutterIcon: SymbolsVaried.arrow_circle_down,
            // TODO: 3 ICONS set a linux icon for this
            textIcon: "󰳛", // nf-md-arrow_down_circle
            size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        );
      },
    );
  }
}
