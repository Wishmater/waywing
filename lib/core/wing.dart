import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/util/derived_value_notifier.dart";

/// Similar to a feather, but instead of depending on a parent to layout its widgets,
/// it has the responsibility to place itself and its widgets directly on the screen.
/// Similarly to feathers, it has its own service dependencies, logging, and config.
abstract class Wing<Conf> extends Feather<Conf> {
  @override
  bool operator ==(Object other) => other is Wing && name == other.name && uniqueId == other.uniqueId;
  @override
  int get hashCode => Object.hash(Wing, name, uniqueId);
  @override
  String toString() => "Wing($name) - $uniqueId";

  /// This should return a Positioned widget. It will be added to a stack that spans the whole screen.
  Widget buildWing(BuildContext context, EdgeInsets rerservedSpace);

  /// Used by the featherRegistry to initialize feathers. If the wing fails to report a feather,
  /// it probebly won't be initialized properly.
  /// The received reservedSpace is the sum of exclusiveSize of Wings layed out before this one.
  /// The wings are layed out in the order they are declared in the config.
  List<Feather> getFeathers() => [];

  /// exclusiveSize reserved by this Wing. This will be passed to wings layed out before this one.
  ValueListenable<EdgeInsets> get exclusiveSize => DummyValueNotifier(EdgeInsets.zero);

  // this is optional on wings
  @override
  ValueListenable<List<FeatherComponent>> get components => DummyValueNotifier([]);
}
