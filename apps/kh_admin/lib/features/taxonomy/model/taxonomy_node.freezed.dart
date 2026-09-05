// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxonomy_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaxonomyNode _$TaxonomyNodeFromJson(Map<String, dynamic> json) {
  return _TaxonomyNode.fromJson(json);
}

/// @nodoc
mixin _$TaxonomyNode {
  String get id => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<TaxonomyNode> get children => throw _privateConstructorUsedError;

  /// Serializes this TaxonomyNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaxonomyNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxonomyNodeCopyWith<TaxonomyNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxonomyNodeCopyWith<$Res> {
  factory $TaxonomyNodeCopyWith(
    TaxonomyNode value,
    $Res Function(TaxonomyNode) then,
  ) = _$TaxonomyNodeCopyWithImpl<$Res, TaxonomyNode>;
  @useResult
  $Res call({
    String id,
    String? parentId,
    String nameEn,
    String nameAr,
    String? icon,
    int displayOrder,
    bool isActive,
    List<TaxonomyNode> children,
  });
}

/// @nodoc
class _$TaxonomyNodeCopyWithImpl<$Res, $Val extends TaxonomyNode>
    implements $TaxonomyNodeCopyWith<$Res> {
  _$TaxonomyNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxonomyNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? icon = freezed,
    Object? displayOrder = null,
    Object? isActive = null,
    Object? children = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameEn: null == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String,
            nameAr: null == nameAr
                ? _value.nameAr
                : nameAr // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            children: null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<TaxonomyNode>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaxonomyNodeImplCopyWith<$Res>
    implements $TaxonomyNodeCopyWith<$Res> {
  factory _$$TaxonomyNodeImplCopyWith(
    _$TaxonomyNodeImpl value,
    $Res Function(_$TaxonomyNodeImpl) then,
  ) = __$$TaxonomyNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? parentId,
    String nameEn,
    String nameAr,
    String? icon,
    int displayOrder,
    bool isActive,
    List<TaxonomyNode> children,
  });
}

/// @nodoc
class __$$TaxonomyNodeImplCopyWithImpl<$Res>
    extends _$TaxonomyNodeCopyWithImpl<$Res, _$TaxonomyNodeImpl>
    implements _$$TaxonomyNodeImplCopyWith<$Res> {
  __$$TaxonomyNodeImplCopyWithImpl(
    _$TaxonomyNodeImpl _value,
    $Res Function(_$TaxonomyNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxonomyNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? icon = freezed,
    Object? displayOrder = null,
    Object? isActive = null,
    Object? children = null,
  }) {
    return _then(
      _$TaxonomyNodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameEn: null == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String,
        nameAr: null == nameAr
            ? _value.nameAr
            : nameAr // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<TaxonomyNode>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaxonomyNodeImpl implements _TaxonomyNode {
  const _$TaxonomyNodeImpl({
    required this.id,
    this.parentId,
    required this.nameEn,
    required this.nameAr,
    this.icon,
    this.displayOrder = 0,
    this.isActive = true,
    final List<TaxonomyNode> children = const <TaxonomyNode>[],
  }) : _children = children;

  factory _$TaxonomyNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaxonomyNodeImplFromJson(json);

  @override
  final String id;
  @override
  final String? parentId;
  @override
  final String nameEn;
  @override
  final String nameAr;
  @override
  final String? icon;
  @override
  @JsonKey()
  final int displayOrder;
  @override
  @JsonKey()
  final bool isActive;
  final List<TaxonomyNode> _children;
  @override
  @JsonKey()
  List<TaxonomyNode> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  String toString() {
    return 'TaxonomyNode(id: $id, parentId: $parentId, nameEn: $nameEn, nameAr: $nameAr, icon: $icon, displayOrder: $displayOrder, isActive: $isActive, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxonomyNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    parentId,
    nameEn,
    nameAr,
    icon,
    displayOrder,
    isActive,
    const DeepCollectionEquality().hash(_children),
  );

  /// Create a copy of TaxonomyNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxonomyNodeImplCopyWith<_$TaxonomyNodeImpl> get copyWith =>
      __$$TaxonomyNodeImplCopyWithImpl<_$TaxonomyNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaxonomyNodeImplToJson(this);
  }
}

abstract class _TaxonomyNode implements TaxonomyNode {
  const factory _TaxonomyNode({
    required final String id,
    final String? parentId,
    required final String nameEn,
    required final String nameAr,
    final String? icon,
    final int displayOrder,
    final bool isActive,
    final List<TaxonomyNode> children,
  }) = _$TaxonomyNodeImpl;

  factory _TaxonomyNode.fromJson(Map<String, dynamic> json) =
      _$TaxonomyNodeImpl.fromJson;

  @override
  String get id;
  @override
  String? get parentId;
  @override
  String get nameEn;
  @override
  String get nameAr;
  @override
  String? get icon;
  @override
  int get displayOrder;
  @override
  bool get isActive;
  @override
  List<TaxonomyNode> get children;

  /// Create a copy of TaxonomyNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxonomyNodeImplCopyWith<_$TaxonomyNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
