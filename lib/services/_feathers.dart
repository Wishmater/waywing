import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:waywing/models/_feather.dart';
import 'package:waywing/util/config.dart';

final feathers = Feathers();

class Feathers {
  final Set<Feather> _all = {}; // TODO: 3 find an easy way to make this unmodifyable from the outside
  late final UnmodifiableSetView<Feather> all = UnmodifiableSetView(_all);

  final Map<Feather, Future<void>> _initFutures = {};

  // TODO: 1 find a modular way to have multiple "containers" (Wings?).
  // Bar is an example of a Wing, there could be others like a Widgets panel or an OSD.
  // Each Wing needs to manage its Feathers and its config (somehow).
  // Feathers probably also need to still be added to the global Feathers service for init/dispose control.

  /// Adds the feather to the provided inner list, and to the all likst, and runs init() on it.
  /// Returns the Future from calling init() on the feather.
  Future<void> _add(BuildContext context, Feather feather) async {
    assert(!all.contains(feather), 'Trying to add a feather that is already in Feathers.all');
    _all.add(feather);
    final initFuture = feather.init(context);
    _initFutures[feather] = initFuture;
    return initFuture;
  }

  /// Adds the feather to the list and runs dispose() on it.
  /// Returns the Future from calling dispose() on the feather.
  Future<void> _remove(Feather feather) async {
    assert(all.contains(feather), 'Trying to remove a feather that is not in Feathers.all');
    _all.remove(feather);
    _initFutures.remove(feather);
    // TODO: 1 current dispose mechanism is bad: the reference is not cleared, si memory is not freed.
    // Besides, if it is re-initialized after being disposed, it will probably break.
    // Singleton instances should be cleared when disposed.
    return feather.dispose();
  }

  /// Check all feathers currently in config against those already registered in this servcice.
  /// Dispose and remove those no longer in config; add and initialize new ones.
  void onConfigUpdated(BuildContext context) {
    final configFeathers = <Feather>{
      ...config.barStartFeathers,
      ...config.barCenterFeathers,
      ...config.barEndFeathers,
    };
    updateFeathers(context, configFeathers);
  }

  void updateFeathers(BuildContext context, Iterable<Feather> configFeathers) {
    removeOldFeathersNotInNewConfig(configFeathers);
    addNewFeathersNotInOldConfig(context, configFeathers);
  }

  void removeOldFeathersNotInNewConfig(Iterable<Feather> configFeathers) {
    final toRemove = <Feather>[]; // hack to avoid concurrent modification error
    for (final old in all) {
      if (!configFeathers.contains(old)) {
        toRemove.add(old);
      }
    }
    for (final e in toRemove) {
      _remove(e);
    }
  }

  void addNewFeathersNotInOldConfig(BuildContext context, Iterable<Feather> configFeathers) {
    for (final ne in configFeathers) {
      if (!all.contains(ne)) {
        _add(context, ne);
      }
    }
  }
}
