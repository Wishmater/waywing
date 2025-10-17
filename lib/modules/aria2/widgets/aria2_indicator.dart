import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/modules/aria2/aria2_feather.dart";
import "package:waywing/modules/aria2/widgets/aria2_tooltip.dart";
import "package:waywing/widgets/winged_widgets/icon_indicator.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class Aria2Indicator extends StatelessWidget {
  final Aria2Feather feather;
  Aria2Config get config => feather.config;

  const Aria2Indicator({
    required this.feather,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxHeight > constraints.maxWidth;
        Widget result = WingedIcon(
          flutterIcon: SymbolsVaried.cloud,
          // TODO: 1 get better icons for aria2
        );

        final padding = isVertical
            ? const EdgeInsets.only(top: 6) //
            : const EdgeInsets.only(left: 6);
        result = Flex(
          direction: isVertical ? Axis.vertical : Axis.horizontal,
          children: [
            result,
            if (config.showActiveCount)
              ActiveCount(
                feather: feather,
                padding: padding,
                layout: IconAndTextLayout.fromConstraints(constraints),
              ),
            if (config.showWaitingCount)
              WaitingCount(
                feather: feather,
                padding: padding,
                layout: IconAndTextLayout.fromConstraints(constraints),
              ),
            if (config.showStoppedCount)
              StoppedCount(
                feather: feather,
                padding: padding,
                layout: IconAndTextLayout.fromConstraints(constraints),
              ),
            if (config.showDownloadSpeed)
              DownloadSpeedWidget(
                feather: feather,
                padding: padding,
                layout: IconAndTextLayout.fromConstraints(constraints),
              ),
            if (config.showUploadSpeed)
              UploadSpeedWidget(
                feather: feather,
                padding: padding,
                layout: IconAndTextLayout.fromConstraints(constraints),
              ),
          ],
        );

        return WingedButton(
          onTap: null,
          child: result,
        );
      },
    );
  }
}
