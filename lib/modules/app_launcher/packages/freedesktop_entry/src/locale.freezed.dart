// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Locale {

 String get lang; String? get country; String? get encoding; String? get modifier;
/// Create a copy of Locale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocaleCopyWith<Locale> get copyWith => _$LocaleCopyWithImpl<Locale>(this as Locale, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Locale&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.country, country) || other.country == country)&&(identical(other.encoding, encoding) || other.encoding == encoding)&&(identical(other.modifier, modifier) || other.modifier == modifier));
}


@override
int get hashCode => Object.hash(runtimeType,lang,country,encoding,modifier);

@override
String toString() {
  return 'Locale(lang: $lang, country: $country, encoding: $encoding, modifier: $modifier)';
}


}

/// @nodoc
abstract mixin class $LocaleCopyWith<$Res>  {
  factory $LocaleCopyWith(Locale value, $Res Function(Locale) _then) = _$LocaleCopyWithImpl;
@useResult
$Res call({
 String lang, String? country, String? encoding, String? modifier
});




}
/// @nodoc
class _$LocaleCopyWithImpl<$Res>
    implements $LocaleCopyWith<$Res> {
  _$LocaleCopyWithImpl(this._self, this._then);

  final Locale _self;
  final $Res Function(Locale) _then;

/// Create a copy of Locale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lang = null,Object? country = freezed,Object? encoding = freezed,Object? modifier = freezed,}) {
  return _then(_self.copyWith(
lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,modifier: freezed == modifier ? _self.modifier : modifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Locale].
extension LocalePatterns on Locale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Locale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Locale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Locale value)  $default,){
final _that = this;
switch (_that) {
case _Locale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Locale value)?  $default,){
final _that = this;
switch (_that) {
case _Locale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lang,  String? country,  String? encoding,  String? modifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Locale() when $default != null:
return $default(_that.lang,_that.country,_that.encoding,_that.modifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lang,  String? country,  String? encoding,  String? modifier)  $default,) {final _that = this;
switch (_that) {
case _Locale():
return $default(_that.lang,_that.country,_that.encoding,_that.modifier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lang,  String? country,  String? encoding,  String? modifier)?  $default,) {final _that = this;
switch (_that) {
case _Locale() when $default != null:
return $default(_that.lang,_that.country,_that.encoding,_that.modifier);case _:
  return null;

}
}

}

/// @nodoc


class _Locale implements Locale {
  const _Locale({required this.lang, this.country, this.encoding, this.modifier});
  

@override final  String lang;
@override final  String? country;
@override final  String? encoding;
@override final  String? modifier;

/// Create a copy of Locale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocaleCopyWith<_Locale> get copyWith => __$LocaleCopyWithImpl<_Locale>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Locale&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.country, country) || other.country == country)&&(identical(other.encoding, encoding) || other.encoding == encoding)&&(identical(other.modifier, modifier) || other.modifier == modifier));
}


@override
int get hashCode => Object.hash(runtimeType,lang,country,encoding,modifier);

@override
String toString() {
  return 'Locale(lang: $lang, country: $country, encoding: $encoding, modifier: $modifier)';
}


}

/// @nodoc
abstract mixin class _$LocaleCopyWith<$Res> implements $LocaleCopyWith<$Res> {
  factory _$LocaleCopyWith(_Locale value, $Res Function(_Locale) _then) = __$LocaleCopyWithImpl;
@override @useResult
$Res call({
 String lang, String? country, String? encoding, String? modifier
});




}
/// @nodoc
class __$LocaleCopyWithImpl<$Res>
    implements _$LocaleCopyWith<$Res> {
  __$LocaleCopyWithImpl(this._self, this._then);

  final _Locale _self;
  final $Res Function(_Locale) _then;

/// Create a copy of Locale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lang = null,Object? country = freezed,Object? encoding = freezed,Object? modifier = freezed,}) {
  return _then(_Locale(
lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,modifier: freezed == modifier ? _self.modifier : modifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
