import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pill_button.dart';

/// Key used in flutter_secure_storage to track onboarding completion.
const kOnboardingCompleteKey = 'has_seen_onboarding';

/// Premium onboarding flow — 3-slide PageView.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.psychology_rounded,
      title: 'A Safe Space',
      subtitle:
          'MindMentor is your compassionate AI companion.\n'
          'Share what\'s on your mind — no judgment, ever.',
      gradientColors: [Color(0xFF7EB6E6), Color(0xFF5A8AC1)],
    ),
    _OnboardingPageData(
      icon: Icons.insights_rounded,
      title: 'Track Your Journey',
      subtitle:
          'Log your mood daily and discover patterns.\n'
          'Beautiful insights help you understand yourself.',
      gradientColors: [Color(0xFF8BC6A5), Color(0xFF6BAF8D)],
    ),
    _OnboardingPageData(
      icon: Icons.shield_rounded,
      title: 'Always Private',
      subtitle:
          'Your data is encrypted and never shared.\n'
          'Your well-being journey stays yours alone.',
      gradientColors: [Color(0xFFF4C27F), Color(0xFFE8A87C)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: kOnboardingCompleteKey, value: 'true');

    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.calmGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // ── Skip Button ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isLastPage)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Page View ─────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return _OnboardingPage(data: page, screenSize: size);
                    },
                  ),
                ),

                // ── Dots + Button ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Dot Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? AppColors.primary
                                  : AppColors.textHint.withValues(alpha: 0.3),
                              borderRadius: AppRadius.pillBorder,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: PillButton(
                          label: isLastPage ? 'Get Started' : 'Continue',
                          gradient: AppColors.primaryGradient,
                          onPressed: _nextPage,
                          icon: isLastPage
                              ? Icons.arrow_forward_rounded
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Supporting Widgets
// ═══════════════════════════════════════════════════════════════════════════

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final Size screenSize;

  const _OnboardingPage({required this.data, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Animated Icon Container ──────────────
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradientColors,
              ),
              borderRadius: AppRadius.xlBorder,
              boxShadow: [
                BoxShadow(
                  color: data.gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(height: 48),

          // ── Title ───────────────────────────────
          Text(
            data.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // ── Subtitle ────────────────────────────
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
