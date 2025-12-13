import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/bar/bar_config.dart";
import "package:waywing/modules/bar/bar_widget.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

class BarWing extends Wing<BarConfig> {
  BarWing._();

  static void registerFeather(RegisterFeatherCallback<BarWing, BarConfig> registerFeather) {
    registerFeather(
      "Bar",
      FeatherRegistration(
        constructor: BarWing._,
        schemaBuilder: () => BarConfig.schema,
        configBuilder: BarConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Bar";

  @override
  late final Map<String, WaywingAction>? actions = {
    "showPopover": WaywingAction(
      'Show popover for a feather. Requires query param "feather".',
      (request, _) => _executePopoverAction(request, (controller) => controller.showPopover()),
    ),
    "hidePopover": WaywingAction(
      'Hide popover for a feather. Requires query param "feather".',
      (request, _) => _executePopoverAction(request, (controller) => controller.hidePopover()),
    ),
    "togglePopover": WaywingAction(
      'Toggle popover visibility for a feather. Requires query param "feather".',
      (request, _) => _executePopoverAction(request, (controller) => controller.togglePopover()),
    ),
    "showTooltip": WaywingAction(
      'Show tooltip for a feather. Requires query param "feather".',
      (request, _) => _executePopoverAction(request, (controller) => controller.showTooltip(showDelay: Duration.zero)),
    ),
    "hideTooltip": WaywingAction(
      'Hide tooltip for a feather. Requires query param "feather".',
      (request, _) => _executePopoverAction(request, (controller) => controller.hideTooltip(hideDelay: Duration.zero)),
    ),
    "toggleTooltip": WaywingAction(
      'Toggle tooltip visibility for a feather. Requires query param "feather".',
      (request, _) => _executePopoverAction(request, (controller) => controller.toggleTooltip(showDelay: Duration.zero)),
    ),
  };
  WaywingResponse _executePopoverAction(
    WaywingRequest request,
    void Function(WingedPopoverController controller) action,
  ) {
    final requestedFeather = request.path.queryParameters["feather"];
    if (requestedFeather == null) {
      return WaywingResponse(400, 'Missing required query param: "feather"');
    }
    final prefix = "$prettyUniqueId.";
    for (final e in allFeathersInitialized.value) {
      var featherUniqueId = e.item.prettyUniqueId.replaceFirst(prefix, "");
      featherUniqueId = featherUniqueId.replaceAll(".", "/");
      if (featherUniqueId == requestedFeather) {
        // TODO: 3 if the feather has multiple indicators, this will silently default to the last, i think ?
        if (e.popoverController == null) {
          return WaywingResponse(
            422,
            "The requested feather doesn't have a registered popover controller. "
            "It may not declare a popover, or it maybe it isn't done initializing yet.",
          );
        }
        action(e.popoverController!);
        return WaywingResponse.ok();
      }
    }
    return WaywingResponse(404, 'Requested feather "$requestedFeather" not found inside bar');
  }

  late List<Feather> startFeathers = config.start?.getFeatherInstances("$uniqueId.Start") ?? [];
  late List<Feather> centerFeathers = config.center?.getFeatherInstances("$uniqueId.Center") ?? [];
  late List<Feather> endFeathers = config.end?.getFeatherInstances("$uniqueId.End") ?? [];

  ValueListenable<List<Feather>> get initializedStartFeathers => _initializedStartFeathers;
  late final LazyManualValueNotifier<List<Feather>> _initializedStartFeathers = LazyManualValueNotifier(() {
    _feathersInitializationNotifier.value; // make sure it re-builds lazily if necessary
    return startFeathers.where((e) => e.isInitialized && !e.hasInitializationError).toList();
  });
  ValueListenable<List<Feather>> get initializedCenterFeathers => _initializedCenterFeathers;
  late final LazyManualValueNotifier<List<Feather>> _initializedCenterFeathers = LazyManualValueNotifier(() {
    _feathersInitializationNotifier.value; // make sure it re-builds lazily if necessary
    return centerFeathers.where((e) => e.isInitialized && !e.hasInitializationError).toList();
  });
  ValueListenable<List<Feather>> get initializedEndFeathers => _initializedEndFeathers;
  late final LazyManualValueNotifier<List<Feather>> _initializedEndFeathers = LazyManualValueNotifier(() {
    _feathersInitializationNotifier.value; // make sure it re-builds lazily if necessary
    return endFeathers.where((e) => e.isInitialized && !e.hasInitializationError).toList();
  });

  ValueListenable<List<BarPositionedItem<Feather>>> get allFeathersInitialized => _allFeathersInitialized;
  late final _allFeathersInitialized = LazyValueNotifier(
    dependencies: [_initializedStartFeathers, _initializedCenterFeathers, _initializedEndFeathers],
    derive: () {
      return [
        ...initializedStartFeathers.value.map((e) => BarPositionedItem(e, BarPosition.start)),
        ...initializedCenterFeathers.value.map((e) => BarPositionedItem(e, BarPosition.center)),
        ...initializedEndFeathers.value.map((e) => BarPositionedItem(e, BarPosition.end)),
      ];
    },
  );

  @override
  List<Feather> getFeathers() => [
    ...startFeathers,
    ...centerFeathers,
    ...endFeathers,
  ];

  void updateFeathers() {
    startFeathers = config.start?.getFeatherInstances("$uniqueId.Start") ?? [];
    centerFeathers = config.center?.getFeatherInstances("$uniqueId.Center") ?? [];
    endFeathers = config.end?.getFeatherInstances("$uniqueId.End") ?? [];
    // hack to allow feather initialization to finish before we reload feathers
    Future.delayed(Duration(microseconds: 1)).then((_) {
      _feathersInitializationNotifier.manualNotifyListeners();
      _initializedStartFeathers.manualNotifyListeners();
      _initializedCenterFeathers.manualNotifyListeners();
      _initializedEndFeathers.manualNotifyListeners();
    });
  }

  /// An object that identifies the currently active callbacks. Used to avoid
  /// calling setState from stale callbacks, e.g. after disposal of this state,
  /// or after widget reconfiguration to a new Future.
  Object? _activeCallbackIdentity;
  late final _feathersInitializationNotifier = LazyManualValueNotifier(() {
    final callbackIdentity = Object();
    _activeCallbackIdentity = callbackIdentity;
    for (final e in startFeathers) {
      if (e.isInitialized) continue;
      featherRegistry
          .awaitInitialization(e)
          .then((_) {
            if (callbackIdentity != _activeCallbackIdentity) return;
            _initializedStartFeathers.manualNotifyListeners();
          })
          .catchError((_) => null);
    }
    for (final e in centerFeathers) {
      if (e.isInitialized) continue;
      featherRegistry
          .awaitInitialization(e)
          .then((_) {
            if (callbackIdentity != _activeCallbackIdentity) return;
            _initializedCenterFeathers.manualNotifyListeners();
          })
          .catchError((_) => null);
    }
    for (final e in endFeathers) {
      if (e.isInitialized) continue;
      featherRegistry
          .awaitInitialization(e)
          .then((_) {
            if (callbackIdentity != _activeCallbackIdentity) return;
            _initializedEndFeathers.manualNotifyListeners();
          })
          .catchError((_) => null);
    }
  });

  @override
  Widget buildWing(BuildContext context, EdgeInsets rerservedSpace) {
    return BarSwitcher(wing: this, reservedSpace: rerservedSpace);
  }

  @override
  ValueListenable<EdgeInsets> get exclusiveSize => _exclusiveSize;
  late final LazyManualValueNotifier<EdgeInsets> _exclusiveSize = LazyManualValueNotifier(
    () => EdgeInsets.fromLTRB(
      config.exclusiveSizeLeft,
      config.exclusiveSizeTop,
      config.exclusiveSizeRight,
      config.exclusiveSizeBottom,
    ),
  );

  @override
  onConfigUpdated(BarConfig oldConfig) {
    _exclusiveSize.manualNotifyListeners();
    updateFeathers();
  }
}

enum BarPosition { start, center, end }

class BarPositionedItem<T> {
  final T item;
  final BarPosition position;
  final String? extraId;
  final BarPositionedItem? parent;

  BarPositionedItem(
    this.item,
    this.position, {
    this.extraId,
    this.parent,
    this.popoverController,
  });

  WingedPopoverController? popoverController;
  BarPositionedItem get root => parent == null ? this : parent!.root;

  @override
  String toString() {
    return "BarPositionedItem($item, $position)";
  }

  @override
  bool operator ==(Object other) {
    return other is BarPositionedItem && item == other.item && position == other.position && extraId == other.extraId;
  }

  @override
  int get hashCode => Object.hash(item, position, extraId);
}
