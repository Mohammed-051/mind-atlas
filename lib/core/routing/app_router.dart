import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/mood/home_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/insights/insights_screen.dart';
import '../../features/emergency/emergency_screen.dart';
import '../../shared/widgets/app_shell.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GoRouter ↔ Supabase Auth Bridge
// ═══════════════════════════════════════════════════════════════════════════

/// Converts the Supabase auth stream into a [ChangeNotifier] so GoRouter
/// can reactively re-evaluate its redirect logic on auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Onboarding State
// ═══════════════════════════════════════════════════════════════════════════

/// Tracks whether the user has completed onboarding.
/// Loaded at startup and updated when onboarding is completed.
class OnboardingStatusNotifier extends StateNotifier<bool> {
  OnboardingStatusNotifier() : super(false) {
    _load();
  }

  final _storage = const FlutterSecureStorage();

  Future<void> _load() async {
    final value = await _storage.read(key: kOnboardingCompleteKey);
    if (mounted) {
      state = value == 'true';
    }
  }

  Future<void> complete() async {
    await _storage.write(key: kOnboardingCompleteKey, value: 'true');
    if (mounted) {
      state = true;
    }
  }
}

final onboardingStatusProvider =
    StateNotifierProvider<OnboardingStatusNotifier, bool>((ref) {
      return OnboardingStatusNotifier();
    });

// ═══════════════════════════════════════════════════════════════════════════
// Router Configuration
// ═══════════════════════════════════════════════════════════════════════════

/// Routes that do NOT require authentication.
const _publicPaths = {'/login', '/register', '/onboarding', '/emergency'};

/// MindMentor navigation with auth + onboarding redirect guards.
final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Watch onboarding state — triggers router refresh when it changes
  final hasSeenOnboarding = ref.watch(onboardingStatusProvider);
  final isGuest = ref.watch(guestModeProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,

    // Re-evaluate redirects whenever auth state changes
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),

    // ── Auth + Onboarding Redirect Guard ─────────────────────
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isLoggedInOrGuest = isLoggedIn || isGuest;
      final currentPath = state.uri.path;

      // Emergency is ALWAYS accessible — critical safety feature
      if (currentPath == '/emergency') return null;

      // Check onboarding status
      final seenOnboarding = hasSeenOnboarding;

      // First-time user: redirect to onboarding
      if (!seenOnboarding &&
          !isLoggedInOrGuest &&
          currentPath != '/onboarding') {
        return '/onboarding';
      }

      // Not logged in → force to login (unless already on a public page)
      if (!isLoggedInOrGuest && !_publicPaths.contains(currentPath)) {
        return '/login';
      }

      // Logged in/guest but on auth/onboarding pages → redirect to home
      if (isLoggedInOrGuest &&
          (currentPath == '/login' ||
              currentPath == '/register' ||
              currentPath == '/onboarding')) {
        return '/';
      }

      return null; // No redirect needed
    },

    routes: [
      // ── Onboarding Route ───────────────────────────────────
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Auth Routes (No Bottom Nav) ────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Protected Shell Route (Bottom Nav) ─────────────────
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ChatScreen()),
          ),
          GoRoute(
            path: '/insights',
            name: 'insights',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InsightsScreen()),
          ),
        ],
      ),

      // ── Emergency Route (Full Screen, Always Accessible) ───
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const EmergencyScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
