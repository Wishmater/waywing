import "package:flutter/material.dart";
import "package:flutter_mdi_icons/flutter_mdi_icons.dart";
import "package:human_file_size/human_file_size.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:nm/nm.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/service/nm_service.dart";
import "package:waywing/util/human_readable_bytes.dart";
import "package:waywing/widgets/icons/composed_icon.dart";
import "package:waywing/widgets/icons/symbol_icon.dart";
import "package:waywing/widgets/winged_widgets/icon_indicator.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_context_menu.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class NetworkManagerIndicator extends StatelessWidget {
  final NetworkManagerService service;
  final NetworkManagerConfig config;
  final NMServiceDevice device;
  final WingedPopoverController? popover;

  const NetworkManagerIndicator({
    required this.service,
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
            final isVertical = constraints.maxHeight > constraints.maxWidth;
            final allowIconTxRxIndicators = constraints.maxHeight >= 40;
            Widget result = NetworkIcon(
              device: device,
              type: device.deviceType,
              isConnected: isConnected,
              showTxRxIndicators:
                  allowIconTxRxIndicators &&
                  (isVertical || (!config.showDownloadIndicator && !config.showUploadIndicator)),
            );

            if (isConnected) {
              if (isVertical) {
                final padding = EdgeInsets.only(
                  top: config.showDownloadIndicator || config.showUploadIndicator ? 6 : 4,
                );
                result = Column(
                  children: [
                    result,
                    if (config.showConnectionNameIndicator) ConnectionNameWidget(device: device),
                    if (config.showThroughputIndicator)
                      ThroughputRateWidget(
                        device: device,
                        showIcon: config.showDownloadIndicator || config.showUploadIndicator,
                        padding: padding,
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                    if (config.showDownloadIndicator)
                      RxRateWidget(
                        device: device,
                        padding: padding,
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                    if (config.showUploadIndicator)
                      TxRateWidget(
                        device: device,
                        padding: padding,
                        layout: IconAndTextLayout.fromConstraints(constraints),
                      ),
                  ],
                );
              } else {
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
                              if (config.showDownloadIndicator)
                                RxRateWidget(
                                  device: device,
                                  layout: IconAndTextLayout.fromConstraints(constraints),
                                ),
                              if (config.showUploadIndicator)
                                TxRateWidget(
                                  device: device,
                                  layout: IconAndTextLayout.fromConstraints(constraints),
                                ),
                              if (config.showThroughputIndicator)
                                ThroughputRateWidget(
                                  device: device,
                                  layout: IconAndTextLayout.fromConstraints(constraints),
                                  showIcon:
                                      !allowIconTxRxIndicators ||
                                      config.showDownloadIndicator ||
                                      config.showUploadIndicator,
                                ),
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
                      if (config.showConnectionNameIndicator)
                        ConnectionNameWidget(
                          device: device,
                        ),
                      if (config.showDownloadIndicator)
                        RxRateWidget(
                          device: device,
                          layout: IconAndTextLayout.fromConstraints(constraints),
                        ),
                      if (config.showUploadIndicator)
                        TxRateWidget(
                          device: device,
                          layout: IconAndTextLayout.fromConstraints(constraints),
                        ),
                      if (config.showThroughputIndicator)
                        ThroughputRateWidget(
                          device: device,
                          layout: IconAndTextLayout.fromConstraints(constraints),
                          showIcon:
                              !allowIconTxRxIndicators || config.showDownloadIndicator || config.showUploadIndicator,
                        ),
                    ],
                  );
                }
              }
            }

            return WingedContextMenu(
              itemsBuilder: (context) {
                return [
                  WingedContextMenuItem(
                    child: Text("Hide device"),
                    onTap: (popover, _, _) {
                      service.devices.hideDevice(device);
                      return null;
                    },
                  ),
                ];
              },
              builder: (context, contextMenu, child) {
                return WingedButton(
                  onTap: popover?.isPopoverEnabled ?? false ? (_, _) => popover!.togglePopover() : null,
                  onSecondaryTap: (tapDownDetails, tapUpDetails) {
                    popover?.hidePopover();
                    popover?.hideTooltip();
                    contextMenu.togglePopover(localPosition: tapUpDetails.localPosition);
                  },
                  child: child!,
                );
              },
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
      NetworkManagerDeviceType.ethernet => WingedIcon(
        flutterIcon: SymbolsVaried.cable,
        iconNames: ["network-wired"],
        textIcon: "󰈀", // nf-md-ethernet
      ),
      NetworkManagerDeviceType.bluetooth => WingedIcon(
        flutterIcon: SymbolsVaried.bluetooth_connected,
        iconNames: ["network-bluetooth-active", "bluetooth-active", "network-bluetooth", "bluetooth"],
        textIcon: "󰂱", // nf-md-bluetooth_connect
      ),
      NetworkManagerDeviceType.vlan => WingedIcon(
        flutterIcon: SymbolsVaried.lan,
        // TODO: 3 set linux and nerdFont icons
        flutterBuilder: (context) => ComposedIcon(
          child: ComposedIcon(
            subicon: SymbolIcon(SymbolsVaried.open_jam),
            child: SymbolIcon(SymbolsVaried.lan),
          ),
        ),
      ),
      NetworkManagerDeviceType.bridge => WingedIcon(
        flutterIcon: SymbolsVaried.lan,
        // TODO: 3 set linux and nerdFont icons
      ),
      _ => WingedIcon(
        flutterIcon: SymbolsVaried.question_mark,
        iconNames: ["dialog-question"],
        textIcon: "", // nf-fa-question
        flutterBuilder: (context) => ComposedIcon(
          child: ComposedIcon(
            subicon: SymbolIcon(SymbolsVaried.question_mark),
            child: SymbolIcon(SymbolsVaried.lan),
          ),
        ),
      ),
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
      result = buildWithAp(context, accessPoint);
    } else {
      result = ValueListenableBuilder(
        valueListenable: device.activeAccessPoint,
        builder: (context, ap, _) {
          return buildWithAp(context, ap);
        },
      );
    }

    if (isConnected && showTxRxIndicators) {
      result = TxRxIndicatorOverlay(device: device, child: result);
    }

    return result;
  }

  Widget buildWithAp(BuildContext context, NMServiceAccessPoint? ap) {
    if (ap != null) {
      final color = this.color ?? Theme.of(context).iconTheme.color!;
      // TODO: 2 implement wifi signal strength at breakpoints for linux and nerdFont icons
      return WingedIcon(
        flutterIcon: SymbolsVaried.wifi,
        iconNames: ["network-wireless"],
        textIcon: "", // nf-fa-wifi
        flutterBuilder: (context) {
          return Stack(
            children: [
              SymbolIcon(SymbolsVaried.wifi, color: color.withValues(alpha: 0.25)),
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: ap.strength,
                  builder: (context, strength, child) {
                    // TODO: 2 animate changes in strength
                    return ClipPath(
                      clipper: WifiStrengthClipper(strength),
                      child: SymbolIcon(SymbolsVaried.wifi, color: color),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
    if (isConnected) {
      return WingedIcon(
        flutterIcon: SymbolsVaried.wifi,
        iconNames: ["network-wireless"],
        textIcon: "󰖩", // nf-md-wifi
        color: color,
      );
    }
    return WingedIcon(
      flutterIcon: SymbolsVaried.wifi_off,
      iconNames: ["network-wireless-off", "network-wireless"],
      textIcon: "󰖪", // nf-md-wifi_off
      color: color,
    );
  }
}

class WifiStrengthClipper extends CustomClipper<Path> {
  final double strength;

  WifiStrengthClipper(this.strength);

  @override
  getClip(Size size) {
    const curveSize = 0.25;
    const topPaddingPercent = 0.17;
    const effectiveHeightPercent = 0.65;
    final effectiveHeight = size.height * effectiveHeightPercent;
    final topPadding = size.height * topPaddingPercent;
    final strengthOffset = topPadding + effectiveHeight * (1 - strength);
    final curveOffset = size.height * curveSize;

    // Calculate control point P1 to draw a bezier curve from a to b that touches c
    final a = Offset(0, strengthOffset + curveOffset);
    final b = Offset(size.width, strengthOffset + curveOffset);
    final c = Offset(size.width * 0.5, strengthOffset);
    final p1 = Offset(
      2 * c.dx - 0.5 * a.dx - 0.5 * b.dx,
      2 * c.dy - 0.5 * a.dy - 0.5 * b.dy,
    );
    // Draw the Bezier curve
    final path = Path();
    path.moveTo(a.dx, a.dy);
    path.quadraticBezierTo(p1.dx, p1.dy, b.dx, b.dy);

    // close the shape
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, strengthOffset + curveOffset);
    return path;
  }

  @override
  bool shouldReclip(covariant WifiStrengthClipper oldClipper) {
    return strength != oldClipper.strength;
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
              // TODO: 3 maybe it's better to use ComposedIcon for this ? (more consistent)
              // also consider using Material Symbols instead of Mdi icons, need to test
              // well that it works with such small icons on all settings
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

  Widget buildUpDownIcon(BuildContext context) {
    return WingedIcon(
      flutterIcon: Mdi.swapVerticalBold,
      size: 12,
      color: Theme.of(context).textTheme.bodyMedium!.color,
    );
  }

  Widget buildUpIcon(BuildContext context) {
    return WingedIcon(
      flutterIcon: Mdi.arrowUpBold,
      size: 10,
      color: Theme.of(context).textTheme.bodyMedium!.color,
    );
  }

  Widget buildDownIcon(BuildContext context) {
    return WingedIcon(
      flutterIcon: Mdi.arrowDownBold,
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
      valueListenable: device.activeConnectionName,
      builder: (context, activeConnectionName, _) {
        if (activeConnectionName == null) return SizedBox.shrink();
        // TODO: 2 use activeConnection.status (or cues from statistics) to implement more detailed status (like connected with on internet)
        return Padding(
          padding: padding,
          child: Text(activeConnectionName),
        );
      },
    );
  }
}

class ThroughputRateWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;
  final bool showIcon;
  final IconAndTextLayout? layout;

  const ThroughputRateWidget({
    required this.device,
    this.showIcon = true,
    this.padding = const EdgeInsets.only(left: 8),
    this.layout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget? icon;
    if (showIcon) {
      icon = WingedIcon(
        flutterIcon: SymbolsVaried.swap_vert,
        // TODO: 3 ICONS set a linux icon for this
        textIcon: "󰯎", // nf-md-swap_vertical_bold
        size: Theme.of(context).textTheme.bodyMedium!.fontSize! + 1,
        color: Theme.of(context).textTheme.bodyMedium!.color,
      );
    }
    return ValueListenableBuilder(
      valueListenable: device.rxRate,
      builder: (context, rxRate, _) {
        return ValueListenableBuilder(
          valueListenable: device.txRate,
          builder: (context, txRate, _) {
            if (txRate == null && rxRate == null) return SizedBox.shrink();
            final readableBytes = humanFileSize(
              (txRate ?? 0) + (rxRate ?? 0),
              unitConversion: const BestFitDecUnitConversion(
                numeralSystem: DecimalByteNumeralSystem(),
              ),
              quantityDisplayMode: IntlQuantityDisplayMode(
                numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 2),
              ),
            );
            return IconAndTextIndicator(
              icon: icon,
              text: "$readableBytes/s",
              padding: padding,
              layout: layout,
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
  final IconAndTextLayout? layout;

  const TxRateWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    this.layout,
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

class RxRateWidget extends StatelessWidget {
  final NMServiceDevice device;
  final EdgeInsets padding;
  final IconAndTextLayout? layout;

  const RxRateWidget({
    required this.device,
    this.padding = const EdgeInsets.only(left: 6),
    this.layout,
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
