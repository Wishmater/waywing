// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'desktop_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DesktopEntry {

/// Entries from `[Desktop Entry]`.
 Map<String, Entry> get entries;/// Actions with their entries.
/// A section named `[Desktop Action xyz]` has key `xyz`.
 Map<String, Map<String, Entry>> get actions;/// The desktop file ID.
 String? get id;
/// Create a copy of DesktopEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DesktopEntryCopyWith<DesktopEntry> get copyWith => _$DesktopEntryCopyWithImpl<DesktopEntry>(this as DesktopEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DesktopEntry&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(actions),id);

@override
String toString() {
  return 'DesktopEntry(entries: $entries, actions: $actions, id: $id)';
}


}

/// @nodoc
abstract mixin class $DesktopEntryCopyWith<$Res>  {
  factory $DesktopEntryCopyWith(DesktopEntry value, $Res Function(DesktopEntry) _then) = _$DesktopEntryCopyWithImpl;
@useResult
$Res call({
 Map<String, Entry> entries, Map<String, Map<String, Entry>> actions, String? id
});




}
/// @nodoc
class _$DesktopEntryCopyWithImpl<$Res>
    implements $DesktopEntryCopyWith<$Res> {
  _$DesktopEntryCopyWithImpl(this._self, this._then);

  final DesktopEntry _self;
  final $Res Function(DesktopEntry) _then;

/// Create a copy of DesktopEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? actions = null,Object? id = freezed,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, Entry>,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, Entry>>,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DesktopEntry].
extension DesktopEntryPatterns on DesktopEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DesktopEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DesktopEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DesktopEntry value)  $default,){
final _that = this;
switch (_that) {
case _DesktopEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DesktopEntry value)?  $default,){
final _that = this;
switch (_that) {
case _DesktopEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Entry> entries,  Map<String, Map<String, Entry>> actions,  String? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DesktopEntry() when $default != null:
return $default(_that.entries,_that.actions,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Entry> entries,  Map<String, Map<String, Entry>> actions,  String? id)  $default,) {final _that = this;
switch (_that) {
case _DesktopEntry():
return $default(_that.entries,_that.actions,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Entry> entries,  Map<String, Map<String, Entry>> actions,  String? id)?  $default,) {final _that = this;
switch (_that) {
case _DesktopEntry() when $default != null:
return $default(_that.entries,_that.actions,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _DesktopEntry extends DesktopEntry {
  const _DesktopEntry({required final  Map<String, Entry> entries, final  Map<String, Map<String, Entry>> actions = const {}, this.id = null}): _entries = entries,_actions = actions,super._();
  

/// Entries from `[Desktop Entry]`.
 final  Map<String, Entry> _entries;
/// Entries from `[Desktop Entry]`.
@override Map<String, Entry> get entries {
  if (_entries is EqualUnmodifiableMapView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entries);
}

/// Actions with their entries.
/// A section named `[Desktop Action xyz]` has key `xyz`.
 final  Map<String, Map<String, Entry>> _actions;
/// Actions with their entries.
/// A section named `[Desktop Action xyz]` has key `xyz`.
@override@JsonKey() Map<String, Map<String, Entry>> get actions {
  if (_actions is EqualUnmodifiableMapView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_actions);
}

/// The desktop file ID.
@override@JsonKey() final  String? id;

/// Create a copy of DesktopEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DesktopEntryCopyWith<_DesktopEntry> get copyWith => __$DesktopEntryCopyWithImpl<_DesktopEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DesktopEntry&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_actions),id);

@override
String toString() {
  return 'DesktopEntry(entries: $entries, actions: $actions, id: $id)';
}


}

/// @nodoc
abstract mixin class _$DesktopEntryCopyWith<$Res> implements $DesktopEntryCopyWith<$Res> {
  factory _$DesktopEntryCopyWith(_DesktopEntry value, $Res Function(_DesktopEntry) _then) = __$DesktopEntryCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Entry> entries, Map<String, Map<String, Entry>> actions, String? id
});




}
/// @nodoc
class __$DesktopEntryCopyWithImpl<$Res>
    implements _$DesktopEntryCopyWith<$Res> {
  __$DesktopEntryCopyWithImpl(this._self, this._then);

  final _DesktopEntry _self;
  final $Res Function(_DesktopEntry) _then;

/// Create a copy of DesktopEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? actions = null,Object? id = freezed,}) {
  return _then(_DesktopEntry(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, Entry>,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, Entry>>,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
