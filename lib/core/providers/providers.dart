import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/home/data/deck_repository.dart';
import '../../features/home/domain/deck_model.dart';
import '../../features/deck/data/flashcard_repository.dart';
import '../../features/deck/domain/flashcard_model.dart';
import '../../features/study/data/study_repository.dart';
import '../../features/study/domain/study_session_model.dart';
import '../../features/stats/data/statistics_repository.dart';
import '../../features/stats/domain/statistics_models.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Auth Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(apiClientProvider)));

final currentUserProvider = StateProvider<User?>((ref) => null);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// Deck Providers
final deckRepositoryProvider = Provider<DeckRepository>((ref) => DeckRepository(ref.watch(apiClientProvider)));

final decksProvider = FutureProvider<List<Deck>>((ref) async {
  final repository = ref.watch(deckRepositoryProvider);
  final decks = await repository.getDecks();

  // Keep alive with auto-dispose after 5 minutes of no listeners
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    link.close();
  });

  return decks;
});

final deckProvider = FutureProvider.family<Deck, int>((ref, id) async {
  final repository = ref.watch(deckRepositoryProvider);
  return repository.getDeck(id);
});

// Flashcard Providers
final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FlashcardRepository(ref.watch(apiClientProvider)),
);

final flashcardsProvider = FutureProvider.family<List<Flashcard>, int>((ref, deckId) async {
  final repository = ref.watch(flashcardRepositoryProvider);
  return repository.getFlashcards(deckId);
});

final flashcardProvider = FutureProvider.family<Flashcard, int>((ref, id) async {
  final repository = ref.watch(flashcardRepositoryProvider);
  return repository.getFlashcard(id);
});

// Study Providers
final studyRepositoryProvider = Provider<StudyRepository>((ref) => StudyRepository(ref.watch(apiClientProvider)));

final dueCardsProvider = FutureProvider.family<DueCardsResponse, int?>((ref, deckId) async {
  final repository = ref.watch(studyRepositoryProvider);
  return repository.getDueCards(deckId: deckId);
});

// Study Session State Provider
final currentStudySessionProvider = StateProvider<StudySession?>((ref) => null);

// Statistics Providers
final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => StatisticsRepository(ref.watch(apiClientProvider)),
);

final overallStatsProvider = FutureProvider<OverallStats>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final stats = await repository.getOverview();

  // Keep alive with auto-dispose after 5 minutes
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    link.close();
  });

  return stats;
});

final dailyStatsProvider = FutureProvider.family<List<DailyStats>, int>((ref, days) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getDailyStats(days: days);
});

final userProgressProvider = FutureProvider<UserProgress>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getUserProgress();
});

final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final settings = await repository.getUserSettings();

  // Keep alive with auto-dispose after 5 minutes
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    link.close();
  });

  return settings;
});
