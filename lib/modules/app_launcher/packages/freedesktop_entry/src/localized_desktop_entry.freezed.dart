// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localized_desktop_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocalizedDesktopEntry {

 DesktopEntry get desktopEntry; Map<String, String> get entries; Map<String, Map<String, String>> get actions;
/// Create a copy of LocalizedDesktopEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalizedDesktopEntryCopyWith<LocalizedDesktopEntry> get copyWith => _$LocalizedDesktopEntryCopyWithImpl<LocalizedDesktopEntry>(this as LocalizedDesktopEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalizedDesktopEntry&&(identical(other.desktopEntry, desktopEntry) || other.desktopEntry == desktopEntry)&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.actions, actions));
}


@override
int get hashCode => Object.hash(runtimeType,desktopEntry,const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(actions));

@override
String toString() {
  return 'LocalizedDesktopEntry(desktopEntry: $desktopEntry, entries: $entries, actions: $actions)';
}


}

/// @nodoc
abstract mixin class $LocalizedDesktopEntryCopyWith<$Res>  {
  factory $LocalizedDesktopEntryCopyWith(LocalizedDesktopEntry value, $Res Function(LocalizedDesktopEntry) _then) = _$LocalizedDesktopEntryCopyWithImpl;
@useResult
$Res call({
 DesktopEntry desktopEntry, Map<String, String> entries, Map<String, Map<String, String>> actions
});


$DesktopEntryCopyWith<$Res> get desktopEntry;

}
/// @nodoc
class _$LocalizedDesktopEntryCopyWithImpl<$Res>
    implements $LocalizedDesktopEntryCopyWith<$Res> {
  _$LocalizedDesktopEntryCopyWithImpl(this._self, this._then);

  final LocalizedDesktopEntry _self;
  final $Res Function(LocalizedDesktopEntry) _then;

/// Create a copy of LocalizedDesktopEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? desktopEntry = null,Object? entries = null,Object? actions = null,}) {
  return _then(_self.copyWith(
desktopEntry: null == desktopEntry ? _self.desktopEntry : desktopEntry // ignore: cast_nullable_to_non_nullable
as DesktopEntry,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, String>,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,
  ));
}
/// Create a copy of LocalizedDesktopEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DesktopEntryCopyWith<$Res> get desktopEntry {
  
  return $DesktopEntryCopyWith<$Res>(_self.desktopEntry, (value) {
    return _then(_self.copyWith(desktopEntry: value));
  });
}
}


/// Adds pattern-matching-related methods to [LocalizedDesktopEntry].
extension LocalizedDesktopEntryPatterns on LocalizedDesktopEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalizedDesktopEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalizedDesktopEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalizedDesktopEntry value)  $default,){
final _that = this;
switch (_that) {
case _LocalizedDesktopEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalizedDesktopEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LocalizedDesktopEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DesktopEntry desktopEntry,  Map<String, String> entries,  Map<String, Map<String, String>> actions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalizedDesktopEntry() when $default != null:
return $default(_that.desktopEntry,_that.entries,_that.actions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DesktopEntry desktopEntry,  Map<String, String> entries,  Map<String, Map<String, String>> actions)  $default,) {final _that = this;
switch (_that) {
case _LocalizedDesktopEntry():
return $default(_that.desktopEntry,_that.entries,_that.actions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DesktopEntry desktopEntry,  Map<String, String> entries,  Map<String, Map<String, String>> actions)?  $default,) {final _that = this;
switch (_that) {
case _LocalizedDesktopEntry() when $default != null:
return $default(_that.desktopEntry,_that.entries,_that.actions);case _:
  return null;

}
}

}

/// @nodoc


class _LocalizedDesktopEntry extends LocalizedDesktopEntry {
  const _LocalizedDesktopEntry({required this.desktopEntry, required final  Map<String, String> entries, final  Map<String, Map<String, String>> actions = const {}}): _entries = entries,_actions = actions,super._();
  

@override final  DesktopEntry desktopEntry;
 final  Map<String, String> _entries;
@override Map<String, String> get entries {
  if (_entries is EqualUnmodifiableMapView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entries);
}

 final  Map<String, Map<String, String>> _actions;
@override@JsonKey() Map<String, Map<String, String>> get actions {
  if (_actions is EqualUnmodifiableMapView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_actions);
}


/// Create a copy of LocalizedDesktopEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalizedDesktopEntryCopyWith<_LocalizedDesktopEntry> get copyWith => __$LocalizedDesktopEntryCopyWithImpl<_LocalizedDesktopEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalizedDesktopEntry&&(identical(other.desktopEntry, desktopEntry) || other.desktopEntry == desktopEntry)&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._actions, _actions));
}


@override
int get hashCode => Object.hash(runtimeType,desktopEntry,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_actions));

@override
String toString() {
  return 'LocalizedDesktopEntry(desktopEntry: $desktopEntry, entries: $entries, actions: $actions)';
}


}

/// @nodoc
abstract mixin class _$LocalizedDesktopEntryCopyWith<$Res> implements $LocalizedDesktopEntryCopyWith<$Res> {
  factory _$LocalizedDesktopEntryCopyWith(_LocalizedDesktopEntry value, $Res Function(_LocalizedDesktopEntry) _then) = __$LocalizedDesktopEntryCopyWithImpl;
@override @useResult
$Res call({
 DesktopEntry desktopEntry, Map<String, String> entries, Map<String, Map<String, String>> actions
});


@override $DesktopEntryCopyWith<$Res> get desktopEntry;

}
/// @nodoc
class __$LocalizedDesktopEntryCopyWithImpl<$Res>
    implements _$LocalizedDesktopEntryCopyWith<$Res> {
  __$LocalizedDesktopEntryCopyWithImpl(this._self, this._then);

  final _LocalizedDesktopEntry _self;
  final $Res Function(_LocalizedDesktopEntry) _then;

/// Create a copy of LocalizedDesktopEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? desktopEntry = null,Object? entries = null,Object? actions = null,}) {
  return _then(_LocalizedDesktopEntry(
desktopEntry: null == desktopEntry ? _self.desktopEntry : desktopEntry // ignore: cast_nullable_to_non_nullable
as DesktopEntry,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, String>,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,
  ));
}

/// Create a copy of LocalizedDesktopEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DesktopEntryCopyWith<$Res> get desktopEntry {
  
  return $DesktopEntryCopyWith<$Res>(_self.desktopEntry, (value) {
    return _then(_self.copyWith(desktopEntry: value));
  });
}
}

// dart format on
