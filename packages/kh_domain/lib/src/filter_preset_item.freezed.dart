// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_preset_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FilterPresetItem {

 String get id; String get name; Map<String, dynamic> get filters; DateTime get createdAt;
/// Create a copy of FilterPresetItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterPresetItemCopyWith<FilterPresetItem> get copyWith => _$FilterPresetItemCopyWithImpl<FilterPresetItem>(this as FilterPresetItem, _$identity);

  /// Serializes this FilterPresetItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterPresetItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.filters, filters)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(filters),createdAt);

@override
String toString() {
  return 'FilterPresetItem(id: $id, name: $name, filters: $filters, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FilterPresetItemCopyWith<$Res>  {
  factory $FilterPresetItemCopyWith(FilterPresetItem value, $Res Function(FilterPresetItem) _then) = _$FilterPresetItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, Map<String, dynamic> filters, DateTime createdAt
});




}
/// @nodoc
class _$FilterPresetItemCopyWithImpl<$Res>
    implements $FilterPresetItemCopyWith<$Res> {
  _$FilterPresetItemCopyWithImpl(this._self, this._then);

  final FilterPresetItem _self;
  final $Res Function(FilterPresetItem) _then;

/// Create a copy of FilterPresetItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? filters = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FilterPresetItem].
extension FilterPresetItemPatterns on FilterPresetItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilterPresetItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilterPresetItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilterPresetItem value)  $default,){
final _that = this;
switch (_that) {
case _FilterPresetItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilterPresetItem value)?  $default,){
final _that = this;
switch (_that) {
case _FilterPresetItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Map<String, dynamic> filters,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilterPresetItem() when $default != null:
return $default(_that.id,_that.name,_that.filters,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Map<String, dynamic> filters,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FilterPresetItem():
return $default(_that.id,_that.name,_that.filters,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Map<String, dynamic> filters,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FilterPresetItem() when $default != null:
return $default(_that.id,_that.name,_that.filters,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FilterPresetItem implements FilterPresetItem {
  const _FilterPresetItem({required this.id, required this.name, final  Map<String, dynamic> filters = const <String, dynamic>{}, required this.createdAt}): _filters = filters;
  factory _FilterPresetItem.fromJson(Map<String, dynamic> json) => _$FilterPresetItemFromJson(json);

@override final  String id;
@override final  String name;
 final  Map<String, dynamic> _filters;
@override@JsonKey() Map<String, dynamic> get filters {
  if (_filters is EqualUnmodifiableMapView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_filters);
}

@override final  DateTime createdAt;

/// Create a copy of FilterPresetItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterPresetItemCopyWith<_FilterPresetItem> get copyWith => __$FilterPresetItemCopyWithImpl<_FilterPresetItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterPresetItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterPresetItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._filters, _filters)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_filters),createdAt);

@override
String toString() {
  return 'FilterPresetItem(id: $id, name: $name, filters: $filters, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FilterPresetItemCopyWith<$Res> implements $FilterPresetItemCopyWith<$Res> {
  factory _$FilterPresetItemCopyWith(_FilterPresetItem value, $Res Function(_FilterPresetItem) _then) = __$FilterPresetItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Map<String, dynamic> filters, DateTime createdAt
});




}
/// @nodoc
class __$FilterPresetItemCopyWithImpl<$Res>
    implements _$FilterPresetItemCopyWith<$Res> {
  __$FilterPresetItemCopyWithImpl(this._self, this._then);

  final _FilterPresetItem _self;
  final $Res Function(_FilterPresetItem) _then;

/// Create a copy of FilterPresetItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? filters = null,Object? createdAt = null,}) {
  return _then(_FilterPresetItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
