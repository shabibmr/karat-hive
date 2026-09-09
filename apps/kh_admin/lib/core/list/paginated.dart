import 'package:flutter/foundation.dart';

/// Generic envelope representing a page of cursor-paginated items.
///
/// Replaces feature-specific `XxxListPage` DTOs (TR-S1-13).
@immutable
class Paginated<T> {
  const Paginated({
    required this.items,
    this.nextCursor,
    this.totalCount,
  });

  /// The items returned for the current page.
  final List<T> items;

  /// The cursor to request the subsequent page, or null if no further page exists.
  final String? nextCursor;

  /// Optional total count if the backend endpoint supplies it.
  final int? totalCount;

  /// Whether further pages exist. Derived strictly from `nextCursor != null && nextCursor.isNotEmpty`.
  bool get hasMore =>
      nextCursor != null && nextCursor!.trim().isNotEmpty;

  /// Empty page sentinel.
  const Paginated.empty()
      : items = const [],
        nextCursor = null,
        totalCount = 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Paginated<T> &&
          runtimeType == other.runtimeType &&
          nextCursor == other.nextCursor &&
          totalCount == other.totalCount &&
          listEquals(items, other.items);

  @override
  int get hashCode =>
      Object.hash(nextCursor, totalCount, Object.hashAll(items));

  @override
  String toString() =>
      'Paginated(items: ${items.length}, nextCursor: $nextCursor, totalCount: $totalCount)';
}
