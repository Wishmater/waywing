import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/widgets/winged_popover.dart";

/// Every "component" added to waywing needs to implement this class.
/// Here, it will define any services init/cleanup it needs
/// And also define the UI elements it provides
abstract class Feather<Conf> {
  late Logger logger;
  late Conf config;

  String get name;

  @override
  bool operator ==(Object other) => other is Feather && name == other.name;
  @override
  int get hashCode => Object.hash(Feather, name);
  @override
  String toString() => "Feather($name)";

  /// Initialize all services/fields needed inside this function.
  /// Make sure the future doesn't return until initialization is done,
  /// so you can use services/fields in the widget builders without fear.
  /// Widgets won't be built until initialization is done.
  Future<void> init(BuildContext context) async {}

  /// Remove can't receive context, because on application exit context can be dirty and thus unusable
  /// Context shouldn't be necessary to run cleanup code
  Future<void> dispose() async {}

  List<FeatherComponent> get components;

  onConfigUpdated(Conf oldConfig) {}
}

@immutable
class FeatherComponent {
  final IndicatorsBuilder? buildIndicators;
  final ValueNotifier<bool> isIndicatorsVisible;
  final ValueNotifier<bool> isIndicatorsEnabled;

  final WidgetBuilder? buildPopover;
  final ValueNotifier<bool> isPopoverEnabled;

  final WidgetBuilder? buildTooltip;
  final ValueNotifier<bool> isTooltipEnabled;

  FeatherComponent({
    this.buildIndicators,
    bool? isIndicatorVisible,
    bool isIndicatorEnabled = true,
    this.buildPopover,
    bool? isPopoverEnabled,
    this.buildTooltip,
    bool? isTooltipEnabled,
  }) : isIndicatorsVisible = ValueNotifier(isIndicatorVisible ?? buildIndicators != null),
       isIndicatorsEnabled = ValueNotifier(isIndicatorEnabled),
       isPopoverEnabled = ValueNotifier(isPopoverEnabled ?? buildPopover != null),
       isTooltipEnabled = ValueNotifier(isTooltipEnabled ?? buildTooltip != null);
}

typedef IndicatorsBuilder =
    List<Widget> Function(
      BuildContext context,
      WingedPopoverController? popover,
      WingedPopoverController? tooltip,
    );
