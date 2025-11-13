import '../../../core/api/api_client.dart';
import '../domain/flashcard_model.dart';

enum FlashcardStatus {
  all(0),
  unstudied(1),
  studying(2),
  mastered(3);

  final int value;
  const FlashcardStatus(this.value);
}

class SearchFlashcardsRequest {
  final String? searchTerm;
  final int? deckId;
  final FlashcardStatus? status;

  SearchFlashcardsRequest({this.searchTerm, this.deckId, this.status});

  Map<String, dynamic> toJson() {
    return {
      if (searchTerm != null && searchTerm!.isNotEmpty) 'searchTerm': searchTerm,
      if (deckId != null) 'deckId': deckId,
      if (status != null) 'status': status!.value,
    };
  }
}

class SearchFlashcardsResponse {
  final List<Flashcard> flashcards;
  final int totalCount;
  final int unstudiedCount;
  final int studyingCount;
  final int masteredCount;

  SearchFlashcardsResponse({
    required this.flashcards,
    required this.totalCount,
    required this.unstudiedCount,
    required this.studyingCount,
    required this.masteredCount,
  });

  factory SearchFlashcardsResponse.fromJson(Map<String, dynamic> json) {
    return SearchFlashcardsResponse(
      flashcards: (json['flashcards'] as List).map((item) => Flashcard.fromJson(item)).toList(),
      totalCount: json['totalCount'] as int,
      unstudiedCount: json['unstudiedCount'] as int,
      studyingCount: json['studyingCount'] as int,
      masteredCount: json['masteredCount'] as int,
    );
  }
}

class FlashcardRepository {
  final ApiClient _apiClient;

  FlashcardRepository(this._apiClient);

  Future<List<Flashcard>> getFlashcards(int deckId) async {
    final response = await _apiClient.get('/Flashcards/deck/$deckId');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Flashcard.fromJson(json)).toList();
  }

  Future<Flashcard> getFlashcard(int id) async {
    final response = await _apiClient.get('/Flashcards/$id');
    return Flashcard.fromJson(response.data);
  }

  Future<Flashcard> createFlashcard({
    required int deckId,
    required String front,
    required String back,
    String? hint,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final response = await _apiClient.post(
      '/Flashcards',
      data: {'deckId': deckId, 'front': front, 'back': back, 'hint': hint, 'imageUrl': imageUrl, 'audioUrl': audioUrl},
    );
    return Flashcard.fromJson(response.data);
  }

  Future<Flashcard> updateFlashcard(
    int id, {
    String? front,
    String? back,
    String? hint,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final data = <String, dynamic>{};
    if (front != null) data['front'] = front;
    if (back != null) data['back'] = back;
    if (hint != null) data['hint'] = hint;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (audioUrl != null) data['audioUrl'] = audioUrl;

    final response = await _apiClient.put('/Flashcards/$id', data: data);
    return Flashcard.fromJson(response.data);
  }

  Future<void> deleteFlashcard(int id) async {
    await _apiClient.delete('/Flashcards/$id');
  }

  Future<SearchFlashcardsResponse> searchFlashcards(SearchFlashcardsRequest request) async {
    final response = await _apiClient.post('/Flashcards/search', data: request.toJson());
    return SearchFlashcardsResponse.fromJson(response.data);
  }
}
