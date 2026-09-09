import 'package:kh_admin/features/moderation/model/moderation_enums.dart';

class ModerationFilters {
  const ModerationFilters({
    this.state = ReviewState.pendingModeration,
    this.authorType,
    this.query = '',
  });

  final ReviewState? state;
  final AuthorType? authorType;
  final String query;

  ModerationFilters copyWith({
    ReviewState? state,
    bool clearState = false,
    AuthorType? authorType,
    bool clearAuthorType = false,
    String? query,
  }) {
    return ModerationFilters(
      state: clearState ? null : (state ?? this.state),
      authorType: clearAuthorType ? null : (authorType ?? this.authorType),
      query: query ?? this.query,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (state != null) 'state': state!.wireValue,
      if (authorType != null) 'authorType': authorType!.wireValue,
      if (query.trim().isNotEmpty) 'q': query.trim(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationFilters &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          authorType == other.authorType &&
          query == other.query;

  @override
  int get hashCode => Object.hash(state, authorType, query);

  @override
  String toString() =>
      'ModerationFilters(state: $state, authorType: $authorType, query: $query)';
}
