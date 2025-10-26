import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/bar/bar_config.dart";
import "package:waywing/modules/bar/bar_widget.dart";
import "package:waywing/util/derived_value_notifier.dart";

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
      featherRegistry.awaitInitialization(e).then((_) {
        if (callbackIdentity != _activeCallbackIdentity) return;
        _initializedStartFeathers.manualNotifyListeners();
      });
    }
    for (final e in centerFeathers) {
      if (e.isInitialized) continue;
      featherRegistry.awaitInitialization(e).then((_) {
        if (callbackIdentity != _activeCallbackIdentity) return;
        _initializedCenterFeathers.manualNotifyListeners();
      });
    }
    for (final e in endFeathers) {
      if (e.isInitialized) continue;
      featherRegistry.awaitInitialization(e).then((_) {
        if (callbackIdentity != _activeCallbackIdentity) return;
        _initializedEndFeathers.manualNotifyListeners();
      });
    }
  });

  @override
  Widget buildWing(BuildContext context, EdgeInsets rerservedSpace) {
    return Bar(wing: this, reservedSpace: rerservedSpace);
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
  BarPositionedItem(this.item, this.position, [this.extraId]);

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
