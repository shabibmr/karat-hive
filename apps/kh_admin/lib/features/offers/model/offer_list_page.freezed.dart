// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_list_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OfferListPage {
  List<OfferListItem> get items => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  bool? get hasMore => throw _privateConstructorUsedError;
  int? get totalCount => throw _privateConstructorUsedError;

  /// Create a copy of OfferListPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfferListPageCopyWith<OfferListPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferListPageCopyWith<$Res> {
  factory $OfferListPageCopyWith(
    OfferListPage value,
    $Res Function(OfferListPage) then,
  ) = _$OfferListPageCopyWithImpl<$Res, OfferListPage>;
  @useResult
  $Res call({
    List<OfferListItem> items,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
  });
}

/// @nodoc
class _$OfferListPageCopyWithImpl<$Res, $Val extends OfferListPage>
    implements $OfferListPageCopyWith<$Res> {
  _$OfferListPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfferListPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
    Object? totalCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OfferListItem>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasMore: freezed == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool?,
            totalCount: freezed == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OfferListPageImplCopyWith<$Res>
    implements $OfferListPageCopyWith<$Res> {
  factory _$$OfferListPageImplCopyWith(
    _$OfferListPageImpl value,
    $Res Function(_$OfferListPageImpl) then,
  ) = __$$OfferListPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<OfferListItem> items,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
  });
}

/// @nodoc
class __$$OfferListPageImplCopyWithImpl<$Res>
    extends _$OfferListPageCopyWithImpl<$Res, _$OfferListPageImpl>
    implements _$$OfferListPageImplCopyWith<$Res> {
  __$$OfferListPageImplCopyWithImpl(
    _$OfferListPageImpl _value,
    $Res Function(_$OfferListPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OfferListPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
    Object? totalCount = freezed,
  }) {
    return _then(
      _$OfferListPageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OfferListItem>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasMore: freezed == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool?,
        totalCount: freezed == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$OfferListPageImpl extends _OfferListPage {
  const _$OfferListPageImpl({
    required final List<OfferListItem> items,
    this.nextCursor,
    this.hasMore,
    this.totalCount,
  }) : _items = items,
       super._();

  final List<OfferListItem> _items;
  @override
  List<OfferListItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextCursor;
  @override
  final bool? hasMore;
  @override
  final int? totalCount;

  @override
  String toString() {
    return 'OfferListPage(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferListPageImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nextCursor,
    hasMore,
    totalCount,
  );

  /// Create a copy of OfferListPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferListPageImplCopyWith<_$OfferListPageImpl> get copyWith =>
      __$$OfferListPageImplCopyWithImpl<_$OfferListPageImpl>(this, _$identity);
}

abstract class _OfferListPage extends OfferListPage {
  const factory _OfferListPage({
    required final List<OfferListItem> items,
    final String? nextCursor,
    final bool? hasMore,
    final int? totalCount,
  }) = _$OfferListPageImpl;
  const _OfferListPage._() : super._();

  @override
  List<OfferListItem> get items;
  @override
  String? get nextCursor;
  @override
  bool? get hasMore;
  @override
  int? get totalCount;

  /// Create a copy of OfferListPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferListPageImplCopyWith<_$OfferListPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
