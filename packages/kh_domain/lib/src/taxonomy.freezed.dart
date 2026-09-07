// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxonomy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaxonomyNode {

 String get id; String get nameEn; String get nameAr; List<TaxonomyNode> get children;
/// Create a copy of TaxonomyNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxonomyNodeCopyWith<TaxonomyNode> get copyWith => _$TaxonomyNodeCopyWithImpl<TaxonomyNode>(this as TaxonomyNode, _$identity);

  /// Serializes this TaxonomyNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxonomyNode&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameAr,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'TaxonomyNode(id: $id, nameEn: $nameEn, nameAr: $nameAr, children: $children)';
}


}

/// @nodoc
abstract mixin class $TaxonomyNodeCopyWith<$Res>  {
  factory $TaxonomyNodeCopyWith(TaxonomyNode value, $Res Function(TaxonomyNode) _then) = _$TaxonomyNodeCopyWithImpl;
@useResult
$Res call({
 String id, String nameEn, String nameAr, List<TaxonomyNode> children
});




}
/// @nodoc
class _$TaxonomyNodeCopyWithImpl<$Res>
    implements $TaxonomyNodeCopyWith<$Res> {
  _$TaxonomyNodeCopyWithImpl(this._self, this._then);

  final TaxonomyNode _self;
  final $Res Function(TaxonomyNode) _then;

/// Create a copy of TaxonomyNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameEn = null,Object? nameAr = null,Object? children = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<TaxonomyNode>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxonomyNode].
extension TaxonomyNodePatterns on TaxonomyNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxonomyNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxonomyNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxonomyNode value)  $default,){
final _that = this;
switch (_that) {
case _TaxonomyNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxonomyNode value)?  $default,){
final _that = this;
switch (_that) {
case _TaxonomyNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameEn,  String nameAr,  List<TaxonomyNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxonomyNode() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameAr,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameEn,  String nameAr,  List<TaxonomyNode> children)  $default,) {final _that = this;
switch (_that) {
case _TaxonomyNode():
return $default(_that.id,_that.nameEn,_that.nameAr,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameEn,  String nameAr,  List<TaxonomyNode> children)?  $default,) {final _that = this;
switch (_that) {
case _TaxonomyNode() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameAr,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaxonomyNode extends TaxonomyNode {
  const _TaxonomyNode({required this.id, required this.nameEn, required this.nameAr, final  List<TaxonomyNode> children = const <TaxonomyNode>[]}): _children = children,super._();
  factory _TaxonomyNode.fromJson(Map<String, dynamic> json) => _$TaxonomyNodeFromJson(json);

@override final  String id;
@override final  String nameEn;
@override final  String nameAr;
 final  List<TaxonomyNode> _children;
@override@JsonKey() List<TaxonomyNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of TaxonomyNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxonomyNodeCopyWith<_TaxonomyNode> get copyWith => __$TaxonomyNodeCopyWithImpl<_TaxonomyNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaxonomyNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxonomyNode&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameAr,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'TaxonomyNode(id: $id, nameEn: $nameEn, nameAr: $nameAr, children: $children)';
}


}

/// @nodoc
abstract mixin class _$TaxonomyNodeCopyWith<$Res> implements $TaxonomyNodeCopyWith<$Res> {
  factory _$TaxonomyNodeCopyWith(_TaxonomyNode value, $Res Function(_TaxonomyNode) _then) = __$TaxonomyNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameEn, String nameAr, List<TaxonomyNode> children
});




}
/// @nodoc
class __$TaxonomyNodeCopyWithImpl<$Res>
    implements _$TaxonomyNodeCopyWith<$Res> {
  __$TaxonomyNodeCopyWithImpl(this._self, this._then);

  final _TaxonomyNode _self;
  final $Res Function(_TaxonomyNode) _then;

/// Create a copy of TaxonomyNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameEn = null,Object? nameAr = null,Object? children = null,}) {
  return _then(_TaxonomyNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<TaxonomyNode>,
  ));
}


}

// dart format on
