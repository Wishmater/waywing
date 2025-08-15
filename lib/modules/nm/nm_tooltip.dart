import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:waywing/modules/nm/nm_config.dart";
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
    final ratesNumberFormatter = NumberFormat.decimalPatternDigits(decimalDigits: 2);
    return ValueListenableBuilder(
      valueListenable: device.activeConnection,
      builder: (context, activeConnection, _) {
        if (activeConnection == null) return SizedBox.shrink();
        return IntrinsicHeight(
          child: IntrinsicWidth(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // TODO: 1 make this prettier
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${activeConnection.id} (${device.deviceType.name})"),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: device.rxRate,
                        builder: (context, rxRate, _) {
                          if (rxRate == null) return SizedBox.shrink();
                          return Text("dw: ${ratesNumberFormatter.format(rxRate)}");
                        },
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ValueListenableBuilder(
                        valueListenable: device.txRate,
                        builder: (context, txRate, _) {
                          if (txRate == null) return SizedBox.shrink();
                          return Text("up: ${ratesNumberFormatter.format(txRate)}");
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: device.rxBytes,
                        builder: (context, rxBytes, _) {
                          if (rxBytes == null) return SizedBox.shrink();
                          return Text("total dw: ${ratesNumberFormatter.format(rxBytes)}");
                        },
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ValueListenableBuilder(
                        valueListenable: device.txBytes,
                        builder: (context, txBytes, _) {
                          if (txBytes == null) return SizedBox.shrink();
                          return Text("total up: ${ratesNumberFormatter.format(txBytes)}");
                        },
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
