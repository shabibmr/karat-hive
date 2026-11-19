import 'package:flutter/foundation.dart';

/// Decodes a successful API payload into a domain/DTO value.
typedef ApiDecoder<T> = T Function(Object? payload);

@immutable
class ApiCollection<T> {
  const ApiCollection({
    required this.items,
    this.nextCursor,
    this.totalCount,
  });

  final List<T> items;
  final String? nextCursor;
  final int? totalCount;
}
