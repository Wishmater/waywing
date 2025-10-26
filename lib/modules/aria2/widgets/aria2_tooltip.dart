import "package:flutter/material.dart";
import "package:human_file_size/human_file_size.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/modules/aria2/aria2_feather.dart";
import "package:waywing/util/human_readable_bytes.dart";
import "package:waywing/widgets/icons/symbol_icon.dart";
import "package:waywing/widgets/winged_widgets/icon_indicator.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class Aria2Tooltip extends StatelessWidget {
  final Aria2Feather feather;

  const Aria2Tooltip({
    required this.feather,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return IntrinsicHeight(
          child: IntrinsicWidth(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: 2 extending on the color-coding idea, maybe those with zero could be transparent (or like divider-color)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO: 2 maybe these should be color-coded (success, warning, etc.) probably needs theme colors refactor
                      ActiveCount(
                        feather: feather,
                        padding: EdgeInsets.only(bottom: 4, right: 14),
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                      WaitingCount(
                        feather: feather,
                        padding: EdgeInsets.only(bottom: 4, right: 14),
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                      StoppedCount(
                        feather: feather,
                        padding: EdgeInsets.only(bottom: 4, right: 16),
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DownloadSpeedWidget(
                        feather: feather,
                        padding: EdgeInsets.only(bottom: 4, right: 14),
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                      UploadSpeedWidget(
                        feather: feather,
                        padding: EdgeInsets.only(bottom: 4, right: 16),
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                    ],
                  ),
                  // TODO: 3 maybe make this a table to align elements, can't do that easily because there is different count and flutter table doesn't support colSpan
                  // Table(
                  //   defaultColumnWidth: const IntrinsicColumnWidth(),
                  //   children: [
                  //     TableRow(
                  //       children: [
                  //         ActiveCount(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 14)),
                  //         WaitingCount(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 16)),
                  //         StoppedCount(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 16)),
                  //       ],
                  //     ),
                  //     TableRow(
                  //       children: [
                  //         DownloadSpeedWidget(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 14)),
                  //         UploadSpeedWidget(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 16)),
                  //         // ThroughputSpeedWidget(feather: feather, padding: EdgeInsets.only(bottom: 4, right: 16)),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ActiveCount extends StatelessWidget {
  final Aria2Feather feather;
  final EdgeInsets padding;
  final IconAndTextLayout? layout;

  const ActiveCount({
    required this.feather,
    this.padding = EdgeInsets.zero,
    this.layout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: feather.service.numActive,
      builder: (context, value, _) {
        return IconAndTextIndicator(
          padding: padding,
          layout: layout,
          text: "$value",
          tooltip: "Active",
          icon: SizedBox(
            width: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
            child: SymbolIcon(
              SymbolsVaried.circle,
              size: Theme.of(context).textTheme.bodyMedium!.fontSize!,
              color: Theme.of(context).colorScheme.primary,
              fill: 1,
            ),
          ),
        );
      },
    );
  }
}

class WaitingCount extends StatelessWidget {
  final Aria2Feather feather;
  final EdgeInsets padding;
  final IconAndTextLayout? layout;

  const WaitingCount({
    required this.feather,
    this.padding = EdgeInsets.zero,
    this.layout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: feather.service.numWaiting,
      builder: (context, value, _) {
        return IconAndTextIndicator(
          padding: padding,
          layout: layout,
          text: "$value",
          tooltip: "Waiting",
          icon: WingedIcon(
            flutterIcon: SymbolsVaried.timer,
            // TODO: 3 ICONS set a linux and font icon for this
            size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        );
      },
    );
  }
}

class StoppedCount extends StatelessWidget {
  final Aria2Feather feather;
  final EdgeInsets padding;
  final IconAndTextLayout? layout;

  const StoppedCount({
    required this.feather,
    this.padding = EdgeInsets.zero,
    this.layout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: feather.service.numStopped,
      builder: (context, value, _) {
        return IconAndTextIndicator(
          padding: padding,
          layout: layout,
          text: "$value",
          tooltip: "Stopped",
          icon: WingedIcon(
            flutterIcon: SymbolsVaried.stop_circle,
            // TODO: 3 ICONS set a linux and font icon for this
            size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        );
      },
    );
  }
}

// mirrors tx/rx rate widgets from nm feather
class DownloadSpeedWidget extends StatelessWidget {
  final Aria2Feather feather;
  final EdgeInsets padding;
  final IconAndTextLayout? layout;

  const DownloadSpeedWidget({
    required this.feather,
    this.padding = EdgeInsets.zero,
    this.layout,
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
        return IconAndTextIndicator(
          padding: padding,
          layout: layout,
          text: "$readableBytes/s",
          icon: WingedIcon(
            flutterIcon: SymbolsVaried.arrow_downward,
            // TODO: 3 ICONS set a linux icon for this
            textIcon: "󰁅", // nf-md-arrow_down
            size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
            color: Theme.of(context).textTheme.bodyMedium!.color,
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
  final IconAndTextLayout? layout;

  const UploadSpeedWidget({
    required this.feather,
    this.padding = EdgeInsets.zero,
    this.layout,
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
        return IconAndTextIndicator(
          padding: padding,
          layout: layout,
          text: "$readableBytes/s",
          icon: WingedIcon(
            flutterIcon: SymbolsVaried.arrow_upward,
            // TODO: 3 ICONS set a linux icon for this
            textIcon: "󰁝", // nf-md-arrow_up
            size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        );
      },
    );
  }
}

// class ThroughputSpeedWidget extends StatelessWidget {
//   final Aria2Feather feather;
//   final EdgeInsets padding;
//
//   const ThroughputSpeedWidget({
//     required this.feather,
//     this.padding = const EdgeInsets.only(left: 6),
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: DerivedValueNotifier(
//         dependencies: [feather.service.uploadSpeed, feather.service.downloadSpeed],
//         derive: () => feather.service.uploadSpeed.value + feather.service.downloadSpeed.value,
//       ),
//       builder: (context, txRate, _) {
//         final readableBytes = humanFileSize(
//           txRate,
//           unitConversion: const BestFitDecUnitConversion(
//             numeralSystem: DecimalByteNumeralSystem(),
//           ),
//           quantityDisplayMode: IntlQuantityDisplayMode(
//             numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
//           ),
//         );
//         return Padding(
//           padding: padding,
//           child: Text.rich(
//             TextSpan(
//               children: [
//                 WidgetSpan(
//                   child: WingedIcon(
//                     flutterIcon: SymbolsVaried.swap_vert,
//                     // TODO: 3 ICONS set a linux icon for this
//                     textIcon: "󰯎", // nf-md-swap_vertical_bold
//                     size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
//                     color: Theme.of(context).textTheme.bodyMedium!.color,
//                   ),
//                 ),
//                 WidgetSpan(child: SizedBox(width: 2)),
//                 TextSpan(text: "$readableBytes/s"),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
