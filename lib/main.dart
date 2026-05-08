import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

/// Sentry DSN — injected at build time via `--dart-define=SENTRY_DSN=...`.
/// If empty, Sentry is disabled (safe for local development).
const _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase — must complete before app runs
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Launch with or without Sentry based on DSN availability
  if (_sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        options.tracesSampleRate = 0.3;
        options.environment =
            const String.fromEnvironment('ENV', defaultValue: 'production');
        options.sendDefaultPii = false; // Privacy-first
        options.attachScreenshot = true;
        options.enableAutoPerformanceTracing = true;
      },
      appRunner: () => _runApp(),
    );
  } else {
    _runApp();
  }
}

void _runApp() {
  runApp(
    const ProviderScope(
      child: MindMentorApp(),
    ),
  );
}

/// Root application widget.
///
/// Uses [ConsumerWidget] so the router can be read from Riverpod,
/// ensuring auth-aware redirects are properly wired.
/// Supports system-adaptive light/dark theming.
class MindMentorApp extends ConsumerWidget {
  const MindMentorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Adapt system UI overlay to match current brightness
    final brightness = MediaQuery.platformBrightnessOf(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'MindMentor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
