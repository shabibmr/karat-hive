import 'moderation_enums.dart';

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
    };
  }
}
