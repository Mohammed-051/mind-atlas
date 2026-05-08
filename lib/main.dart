import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

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
