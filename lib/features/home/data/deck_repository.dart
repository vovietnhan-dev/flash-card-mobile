import '../../../core/api/api_client.dart';
import '../domain/deck_model.dart';

class DeckRepository {
  final ApiClient _apiClient;

  DeckRepository(this._apiClient);

  Future<List<Deck>> getDecks() async {
    final response = await _apiClient.get('/Decks');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Deck.fromJson(json)).toList();
  }

  Future<Deck> getDeck(int id) async {
    final response = await _apiClient.get('/Decks/$id');
    return Deck.fromJson(response.data);
  }

  Future<Deck> createDeck({
    required String name,
    String? description,
    String? color,
    String? icon,
    bool isPublic = false,
  }) async {
    final response = await _apiClient.post(
      '/Decks',
      data: {
        'name': name,
        'description': description,
        'color': color,
        'icon': icon,
        'isPublic': isPublic,
      },
    );
    return Deck.fromJson(response.data);
  }

  Future<Deck> updateDeck(
    int id, {
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isPublic,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (color != null) data['color'] = color;
    if (icon != null) data['icon'] = icon;
    if (isPublic != null) data['isPublic'] = isPublic;

    final response = await _apiClient.put('/Decks/$id', data: data);
    return Deck.fromJson(response.data);
  }

  Future<void> deleteDeck(int id) async {
    await _apiClient.delete('/Decks/$id');
  }
}
