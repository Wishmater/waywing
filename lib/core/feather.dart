import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:path/path.dart" as path;
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

/// Every "component" added to waywing needs to implement this class.
/// Here, it will define any services init/cleanup it needs
/// And also define the UI elements it provides
abstract class Feather<Conf> {
  @protected
  late Logger logger;
  late Conf config;

  String get name;

  Directory? _dataDir;
  /// Feathear directory where any kind of runtime data can be set
  Directory get dataDir {
    if (_dataDir == null) {
      _dataDir = Directory(path.join(mainDataHomeDir.path, "feather", name));
      _dataDir!.createSync(recursive: true);
    }
    return _dataDir!;
  }

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

  ValueListenable<List<FeatherComponent>> get components;

  onConfigUpdated(Conf oldConfig) {}
}

@immutable
class FeatherComponent {
  final IndicatorsBuilder? buildIndicators;
  final ValueListenable<bool> isIndicatorsVisible;
  final ValueListenable<bool> isIndicatorsEnabled;

  final WidgetBuilder? buildPopover;
  final ValueListenable<bool> isPopoverEnabled;

  final WidgetBuilder? buildTooltip;
  final ValueListenable<bool> isTooltipEnabled;

  FeatherComponent({
    this.buildIndicators,
    ValueListenable<bool>? isIndicatorVisible,
    ValueListenable<bool>? isIndicatorEnabled,
    this.buildPopover,
    ValueListenable<bool>? isPopoverEnabled,
    this.buildTooltip,
    ValueListenable<bool>? isTooltipEnabled,
  }) : isIndicatorsEnabled = isIndicatorEnabled ?? DummyValueNotifier(true),
       isIndicatorsVisible = isIndicatorVisible ?? DummyValueNotifier(buildIndicators != null),

       isPopoverEnabled = isPopoverEnabled ?? DummyValueNotifier(buildPopover != null),
       isTooltipEnabled = isTooltipEnabled ?? DummyValueNotifier(buildTooltip != null);
}

typedef IndicatorsBuilder =
    List<Widget> Function(
      BuildContext context,
      WingedPopoverController? popover,
    );
