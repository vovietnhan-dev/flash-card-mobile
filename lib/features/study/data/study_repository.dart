import '../../../core/api/api_client.dart';
import '../domain/study_session_model.dart';
import '../domain/review_quality.dart';
import '../../deck/domain/flashcard_model.dart';

class StudyRepository {
  final ApiClient _apiClient;

  StudyRepository(this._apiClient);

  /// Lấy danh sách thẻ cần ôn
  Future<DueCardsResponse> getDueCards({int? deckId, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (deckId != null) params['deckId'] = deckId;

    final response = await _apiClient.get(
      '/Study/due',
      queryParameters: params,
    );
    return DueCardsResponse.fromJson(response.data);
  }

  /// Bắt đầu phiên học
  Future<StudySession> startSession({int? deckId}) async {
    final response = await _apiClient.post(
      '/Study/session/start',
      data: {'deckId': deckId},
    );
    return StudySession.fromJson(response.data);
  }

  /// Kết thúc phiên học
  Future<StudySession> endSession(int sessionId) async {
    final response = await _apiClient.post('/Study/session/$sessionId/end');
    return StudySession.fromJson(response.data);
  }

  /// Submit review cho một flashcard
  Future<CardReview> submitReview({
    required int flashcardId,
    required ReviewQuality quality,
    required int timeTakenSeconds,
    int? studySessionId,
  }) async {
    final response = await _apiClient.post(
      '/Study/review',
      data: {
        'flashcardId': flashcardId,
        'quality': quality.index,
        'timeTakenSeconds': timeTakenSeconds,
        'studySessionId': studySessionId,
      },
    );
    return CardReview.fromJson(response.data);
  }
}

class DueCardsResponse {
  final List<Flashcard> cards;
  final int totalDue;

  DueCardsResponse({required this.cards, required this.totalDue});

  factory DueCardsResponse.fromJson(Map<String, dynamic> json) {
    return DueCardsResponse(
      cards: (json['cards'] as List<dynamic>)
          .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDue: json['totalDue'] as int,
    );
  }
}

class CardReview {
  final int id;
  final DateTime reviewedAt;
  final ReviewQuality quality;
  final Duration timeTaken;
  final int flashcardId;
  final int newInterval;
  final double newEaseFactor;

  CardReview({
    required this.id,
    required this.reviewedAt,
    required this.quality,
    required this.timeTaken,
    required this.flashcardId,
    required this.newInterval,
    required this.newEaseFactor,
  });

  factory CardReview.fromJson(Map<String, dynamic> json) {
    return CardReview(
      id: json['id'] as int,
      reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      quality: ReviewQuality.values[json['quality'] as int],
      timeTaken: _parseDuration(json['timeTaken'] as String),
      flashcardId: json['flashcardId'] as int,
      newInterval: json['newInterval'] as int,
      newEaseFactor: (json['newEaseFactor'] as num).toDouble(),
    );
  }

  static Duration _parseDuration(String duration) {
    final parts = duration.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2].split('.')[0]),
    );
  }
}
