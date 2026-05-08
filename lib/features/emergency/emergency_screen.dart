import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/pill_button.dart';

/// Emergency 988 Crisis Intervention Screen.
///
/// Shown immediately when crisis keywords are detected in chat.
/// Provides direct access to 988 Suicide & Crisis Lifeline.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _call988() async {
    final uri = Uri.parse('tel:988');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _text988() async {
    final uri = Uri.parse('sms:988');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Close button ────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Crisis Header ───────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.emergencyLight,
                  borderRadius: AppRadius.xlBorder,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.emergency,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'You\'re Not Alone',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We care about your safety. Please reach out '
                'to trained crisis counselors who are available '
                '24/7 to help you.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // ── 988 Hotline Card ────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(24),
                shadow: AppShadows.medium,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emergency,
                        borderRadius: AppRadius.pillBorder,
                      ),
                      child: const Text(
                        '988',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Suicide & Crisis Lifeline',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Free, confidential, 24/7',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: 'Call 988',
                            icon: Icons.phone_rounded,
                            backgroundColor: AppColors.emergency,
                            onPressed: _call988,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PillButton(
                            label: 'Text 988',
                            icon: Icons.message_rounded,
                            isOutlined: true,
                            backgroundColor: AppColors.emergency,
                            onPressed: _text988,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Crisis Text Line ────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: const Icon(
                        Icons.textsms_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crisis Text Line',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Text HOME to 741741',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(text: '741741'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Number copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Safety Reminders ────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(20),
                color: AppColors.warmCream,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          color: AppColors.accent,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Safety Reminders',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SafetyTip(
                      text: 'You deserve support and help',
                    ),
                    _SafetyTip(
                      text: 'This feeling is temporary',
                    ),
                    _SafetyTip(
                      text: 'Reaching out takes courage',
                    ),
                    _SafetyTip(
                      text: 'You matter to people around you',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyTip extends StatelessWidget {
  final String text;
  const _SafetyTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 12),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
