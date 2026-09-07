// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_list_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VendorListPage {
  List<VendorListItem> get items => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  bool? get hasMore => throw _privateConstructorUsedError;

  /// Create a copy of VendorListPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorListPageCopyWith<VendorListPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorListPageCopyWith<$Res> {
  factory $VendorListPageCopyWith(
    VendorListPage value,
    $Res Function(VendorListPage) then,
  ) = _$VendorListPageCopyWithImpl<$Res, VendorListPage>;
  @useResult
  $Res call({List<VendorListItem> items, String? nextCursor, bool? hasMore});
}

/// @nodoc
class _$VendorListPageCopyWithImpl<$Res, $Val extends VendorListPage>
    implements $VendorListPageCopyWith<$Res> {
  _$VendorListPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorListPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<VendorListItem>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasMore: freezed == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorListPageImplCopyWith<$Res>
    implements $VendorListPageCopyWith<$Res> {
  factory _$$VendorListPageImplCopyWith(
    _$VendorListPageImpl value,
    $Res Function(_$VendorListPageImpl) then,
  ) = __$$VendorListPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<VendorListItem> items, String? nextCursor, bool? hasMore});
}

/// @nodoc
class __$$VendorListPageImplCopyWithImpl<$Res>
    extends _$VendorListPageCopyWithImpl<$Res, _$VendorListPageImpl>
    implements _$$VendorListPageImplCopyWith<$Res> {
  __$$VendorListPageImplCopyWithImpl(
    _$VendorListPageImpl _value,
    $Res Function(_$VendorListPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorListPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
  }) {
    return _then(
      _$VendorListPageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<VendorListItem>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasMore: freezed == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc

class _$VendorListPageImpl extends _VendorListPage {
  const _$VendorListPageImpl({
    required final List<VendorListItem> items,
    this.nextCursor,
    this.hasMore,
  }) : _items = items,
       super._();

  final List<VendorListItem> _items;
  @override
  List<VendorListItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextCursor;
  @override
  final bool? hasMore;

  @override
  String toString() {
    return 'VendorListPage(items: $items, nextCursor: $nextCursor, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorListPageImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nextCursor,
    hasMore,
  );

  /// Create a copy of VendorListPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorListPageImplCopyWith<_$VendorListPageImpl> get copyWith =>
      __$$VendorListPageImplCopyWithImpl<_$VendorListPageImpl>(
        this,
        _$identity,
      );
}

abstract class _VendorListPage extends VendorListPage {
  const factory _VendorListPage({
    required final List<VendorListItem> items,
    final String? nextCursor,
    final bool? hasMore,
  }) = _$VendorListPageImpl;
  const _VendorListPage._() : super._();

  @override
  List<VendorListItem> get items;
  @override
  String? get nextCursor;
  @override
  bool? get hasMore;

  /// Create a copy of VendorListPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorListPageImplCopyWith<_$VendorListPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
