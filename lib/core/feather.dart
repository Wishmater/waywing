import 'package:flutter/material.dart';

/// Every "component" added to waywing needs to implement this class.
/// Here, it will define any services init/cleanup it needs
/// And also define the UI elements it provides
abstract class Feather {
  String get name;

  @override
  bool operator ==(Object other) => other is Feather && name == other.name;
  @override
  int get hashCode => Object.hash(Feather, name);
  @override
  String toString() => 'Feather($name)';

  /// Initialize all services/fields needed inside this function.
  /// Make sure the future doesn't return until initialization is done,
  /// so you can use services/fields in the widget builders without fear.
  /// Widgets won't be built until initialization is done.
  Future<void> init(BuildContext context) async {}

  // TODO: 1 how to support this case: the feather spins up a service on init(),
  // but when dispoisng the feather, others might be depending on that same service,
  // how do we know if noone else depends on the service, so we can safely dispose it.
  // Should services inherit a base class that keeps track of dependant feathers?

  /// Remove can't receive context, because on application exit context can be dirty and thus unusable
  /// Context shouldn't be necessary to run cleanup code
  Future<void> dispose() async {}

  Widget? buildCompactWidget(BuildContext context) => null;

  Widget? buildTooltipWidget(BuildContext context) => null;

  Widget? buildExpandedWidget(BuildContext context) => null;
}

typedef OptionalWidgetBuilder = Widget? Function(BuildContext context);
