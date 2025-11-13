import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/enhanced_login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/deck/presentation/flashcard_list_screen.dart';
import '../../features/study/presentation/study_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const EnhancedLoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/deck/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final name = state.uri.queryParameters['name'] ?? 'Bộ thẻ';
        return FlashcardListScreen(deckId: id, deckName: name);
      },
    ),
    GoRoute(
      path: '/study/:deckId',
      builder: (context, state) {
        final deckId = int.parse(state.pathParameters['deckId']!);
        final name = state.uri.queryParameters['name'] ?? 'Học tập';
        return StudyScreen(deckId: deckId, deckName: name);
      },
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);
