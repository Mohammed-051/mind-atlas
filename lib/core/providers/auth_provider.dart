import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_reporter.dart';
import 'supabase_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Auth State Model
// ═══════════════════════════════════════════════════════════════════════════

/// Immutable state representing the current authentication status.
class AppAuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AppAuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AppAuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AppAuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Auth Notifier
// ═══════════════════════════════════════════════════════════════════════════

/// Manages authentication state and operations.
///
/// Listens to Supabase [onAuthStateChange] for reactive updates and
/// exposes [signIn], [signUp], and [signOut] methods.
class AuthNotifier extends StateNotifier<AppAuthState> {
  final Ref _ref;
  late final StreamSubscription<AuthState> _authSubscription;

  AuthNotifier(this._ref) : super(const AppAuthState()) {
    // Seed with current session user
    final currentUser = _ref.read(supabaseClientProvider).auth.currentUser;
    if (currentUser != null) {
      state = AppAuthState(user: currentUser);
    }

    // Listen to auth state changes
    _authSubscription = _ref
        .read(supabaseClientProvider)
        .auth
        .onAuthStateChange
        .listen((data) {
      final event = data.event;
      final session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          state = AppAuthState(user: session?.user);
          break;
        case AuthChangeEvent.signedOut:
          state = const AppAuthState();
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  /// Sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final client = _ref.read(supabaseClientProvider);
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      // State is updated by the stream listener
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyAuthError(e),
      );
    } catch (e, st) {
      ErrorReporter.captureException(e, stackTrace: st, context: 'auth.signIn');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Register a new user with email and password.
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final client = _ref.read(supabaseClientProvider);
      await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: displayName != null ? {'display_name': displayName.trim()} : null,
      );
      // State is updated by the stream listener
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyAuthError(e),
      );
    } catch (e, st) {
      ErrorReporter.captureException(e, stackTrace: st, context: 'auth.signUp');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final client = _ref.read(supabaseClientProvider);
      await client.auth.signOut();
      state = const AppAuthState();
    } catch (e, st) {
      ErrorReporter.captureException(e, stackTrace: st, context: 'auth.signOut');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out. Please try again.',
      );
    }
  }

  /// Clear any displayed error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Map Supabase AuthException to user-friendly messages.
  String _friendlyAuthError(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please check your email and confirm your account.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('weak password') || msg.contains('password')) {
      return 'Password must be at least 6 characters.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Network error. Please check your connection.';
    }

    debugPrint('Auth error: ${e.message}');
    return e.message;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════════════

/// Global auth state provider.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref);
});

/// Convenience provider: is the user currently authenticated?
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});
