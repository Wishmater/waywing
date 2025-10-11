import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:path/path.dart" as path;
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

/// Every "component" added to waywing needs to implement this class.
/// Here, it will define any services init/cleanup it needs
/// And also define the UI elements it provides
abstract class Feather<Conf> implements ServiceConsumer {
  @protected
  late Logger logger;
  late Conf config;
  late String uniqueId;

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
  bool operator ==(Object other) => other is Feather && name == other.name && uniqueId == other.uniqueId;
  @override
  int get hashCode => Object.hash(Feather, name, uniqueId);
  @override
  String toString() => "Feather($name) - $uniqueId";

  Map<String, WaywingAction>? get actions => null;

  /// Initialize all services/fields needed inside this function.
  /// Make sure the future doesn't return until initialization is done,
  /// so you can use services/fields in the widget builders without fear.
  /// Widgets won't be built until initialization is done.
  Future<void> init(BuildContext context) async {}
  bool isInitialized = false;
  bool hasInitializationError = false;

  /// Remove can't receive context, because on application exit context can be dirty and thus unusable
  /// Context shouldn't be necessary to run cleanup code
  Future<void> dispose() async {}

  ValueListenable<List<FeatherComponent>> get components;

  void onConfigUpdated(Conf oldConfig) {}

  String get actionsPath => prettyUniqueId;

  String get prettyUniqueId {
    final prettyUniqueId = uniqueId.replaceAll("[0]", "");
    return prettyUniqueId.replaceAll("[", "").replaceAll("]", "");
  }
}

@immutable
class FeatherComponent {
  final IndicatorsBuilder? buildIndicators;
  final ValueListenable<bool> isIndicatorsEnabled;

  final WidgetBuilder? buildPopover;
  final ValueListenable<bool> isPopoverEnabled;

  final WidgetBuilder? buildTooltip;
  final ValueListenable<bool> isTooltipEnabled;

  final String? uniqueIdentifier;

  FeatherComponent({
    this.buildIndicators,
    ValueListenable<bool>? isIndicatorEnabled,
    this.buildPopover,
    ValueListenable<bool>? isPopoverEnabled,
    this.buildTooltip,
    ValueListenable<bool>? isTooltipEnabled,
    this.uniqueIdentifier,
  }) : isIndicatorsEnabled = isIndicatorEnabled ?? DummyValueNotifier(buildIndicators != null),
       isPopoverEnabled = isPopoverEnabled ?? DummyValueNotifier(buildPopover != null),
       isTooltipEnabled = isTooltipEnabled ?? DummyValueNotifier(buildTooltip != null);

  @override
  int get hashCode => uniqueIdentifier.hashCode;

  @override
  bool operator ==(Object other) {
    return other is FeatherComponent && other.uniqueIdentifier == uniqueIdentifier;
  }
}

typedef IndicatorsBuilder =
    List<Widget> Function(
      BuildContext context,
      WingedPopoverController? popover,
    );
