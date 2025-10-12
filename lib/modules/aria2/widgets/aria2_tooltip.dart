import "package:flutter/material.dart";
import "package:human_file_size/human_file_size.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/modules/aria2/aria2_feather.dart";
import "package:waywing/util/human_readable_bytes.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class Aria2Tooltip extends StatelessWidget {
  final Aria2Feather feather;

  const Aria2Tooltip({
    required this.feather,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: IntrinsicWidth(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(
                    children: [
                      DownloadSpeedWidget(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 14)),
                      UploadSpeedWidget(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 16)),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox.shrink(),
                      SizedBox.shrink(),
                      // RxTotalWidget(device: device, padding: EdgeInsets.only(bottom: 4, right: 14)),
                      // TxTotalWidget(device: device, padding: EdgeInsets.only(bottom: 4, right: 16)),
                      // ThroughputTotalWidget(device: device, padding: EdgeInsets.only(bottom: 4)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// mirrors tx/rx rate widgets from nm feather
class DownloadSpeedWidget extends StatelessWidget {
  final Aria2Feather feather;
  final EdgeInsets padding;

  const DownloadSpeedWidget({
    required this.feather,
    this.padding = const EdgeInsets.only(left: 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: feather.service.downloadSpeed,
      builder: (context, rxRate, _) {
        final readableBytes = humanFileSize(
          rxRate,
          unitConversion: const BestFitDecUnitConversion(
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
              WingedIcon(
                flutterIcon: SymbolsVaried.arrow_downward,
                // TODO: 3 ICONS set a linux icon for this
                textIcon: "󰁅", // nf-md-arrow_down
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

// mirrors tx/rx rate widgets from nm feather
class UploadSpeedWidget extends StatelessWidget {
  final Aria2Feather feather;
  final EdgeInsets padding;

  const UploadSpeedWidget({
    required this.feather,
    this.padding = const EdgeInsets.only(left: 6),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: feather.service.uploadSpeed,
      builder: (context, txRate, _) {
        final readableBytes = humanFileSize(
          txRate,
          unitConversion: const BestFitDecUnitConversion(
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
              WingedIcon(
                flutterIcon: SymbolsVaried.arrow_upward,
                // TODO: 3 ICONS set a linux icon for this
                textIcon: "󰁝", // nf-md-arrow_up
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
