import 'package:waywing/core/feather.dart';
import 'package:waywing/modules/clock/clock_feather.dart';

final featherRegistry = FeatherRegistry._();

typedef FeatherConstructor = Feather Function();

/// FeatherRegistry keeps track of all feather types and can map name strings to instances
/// this also makes sure that only one instance of each Feather is constructed,
/// and that it is de-referenced when disposing it
class FeatherRegistry {
  FeatherRegistry._() {
    _registerDefaultFeathers();
  }

  final Map<String, FeatherConstructor> _registeredFeathers = {};
  final Map<String, Feather> _builtFeathers = {};

  void registerFeather(String name, FeatherConstructor constructor) {
    assert(!_registeredFeathers.containsKey(name), 'Trying to register a Feather that already exists: $name');
    _registeredFeathers[name] = constructor;
  }

  // TODO: 3 only Config should be able to access this
  Feather getFeatherByName(String name) {
    var feather = _builtFeathers[name];
    if (feather == null) {
      assert(_registeredFeathers.containsKey(name), 'Trying to get an unknown Feather by name: $name');
      feather = _registeredFeathers[name]!();
      _builtFeathers[name] = feather;
    }
    return feather;
  }

  // TODO: 3 only FeathersService should be able to access this
  void dereferenceFeather(String name) {
    assert(!_builtFeathers.containsKey(name), 'Trying to de-reference a Feather that is not currently built: $name');
  }

  void _registerDefaultFeathers() {
    registerFeather('Clock', Clock.new);
  }
}
