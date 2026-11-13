import 'package:go_router/go_router.dart';

import '../features/chapters/chapters_screen.dart';
import '../features/home/main_menu_screen.dart';
import '../features/home/splash_screen.dart';
import '../features/settings/credits_screen.dart';
import '../features/settings/settings_screen.dart';

/// Named routes for the app shell. Feature routes (room, puzzle, inventory,
/// journal, hints) are registered in their own phase once those screens exist.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String menu = '/menu';
  static const String chapters = '/chapters';
  static const String settings = '/settings';
  static const String credits = '/credits';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.menu,
        name: 'menu',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.chapters,
        name: 'chapters',
        builder: (context, state) => const ChaptersScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.credits,
        name: 'credits',
        builder: (context, state) => const CreditsScreen(),
      ),
    ],
  );
}
