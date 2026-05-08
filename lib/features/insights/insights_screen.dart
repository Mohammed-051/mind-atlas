import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../mood/mood_provider.dart';

/// Monthly calendar view rendering mood markers from historical data.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() => _focusedMonth = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthlyMoods = ref.watch(
      monthlyMoodsProvider(_focusedMonth),
    );

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Month Selector ──────────────────────────
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Calendar Grid ───────────────────────────
            monthlyMoods.when(
              data: (moods) => _CalendarGrid(
                month: _focusedMonth,
                moods: moods,
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (e, _) => Center(
                child: Text('Error loading moods: $e'),
              ),
            ),

            const SizedBox(height: 24),

            // ── Mood Summary ────────────────────────────
            monthlyMoods.when(
              data: (moods) => _MoodSummary(moods: moods),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // ── Legend ──────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Legend',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _LegendItem(
                        emoji: '😄',
                        label: 'Great',
                        color: AppColors.moodGreat,
                      ),
                      _LegendItem(
                        emoji: '😊',
                        label: 'Good',
                        color: AppColors.moodGood,
                      ),
                      _LegendItem(
                        emoji: '😐',
                        label: 'Okay',
                        color: AppColors.moodOkay,
                      ),
                      _LegendItem(
                        emoji: '😟',
                        label: 'Bad',
                        color: AppColors.moodBad,
                      ),
                      _LegendItem(
                        emoji: '😢',
                        label: 'Awful',
                        color: AppColors.moodAwful,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final List<MoodLog> moods;

  const _CalendarGrid({required this.month, required this.moods});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    // Build map: day -> best mood
    final dayMoods = <int, MoodLog>{};
    for (final m in moods) {
      final day = m.loggedAt.day;
      if (!dayMoods.containsKey(day) || m.score > dayMoods[day]!.score) {
        dayMoods[day] = m;
      }
    }

    final today = DateTime.now();
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar cells
          ...List.generate(6, (week) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dow) {
                  final dayIndex = week * 7 + dow - startWeekday + 1;
                  if (dayIndex < 1 || dayIndex > daysInMonth) {
                    return const SizedBox(width: 36, height: 36);
                  }

                  final moodLog = dayMoods[dayIndex];
                  final isToday = isCurrentMonth && dayIndex == today.day;

                  return _DayCell(
                    day: dayIndex,
                    moodLog: moodLog,
                    isToday: isToday,
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final MoodLog? moodLog;
  final bool isToday;

  const _DayCell({
    required this.day,
    this.moodLog,
    required this.isToday,
  });

  Color _moodColor(String label) {
    switch (label) {
      case 'great': return AppColors.moodGreat;
      case 'good': return AppColors.moodGood;
      case 'okay': return AppColors.moodOkay;
      case 'bad': return AppColors.moodBad;
      case 'awful': return AppColors.moodAwful;
      default: return AppColors.surfaceVariant;
    }
  }

  String _moodEmoji(String label) {
    switch (label) {
      case 'great': return '😄';
      case 'good': return '😊';
      case 'okay': return '😐';
      case 'bad': return '😟';
      case 'awful': return '😢';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMood = moodLog != null;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: hasMood
            ? _moodColor(moodLog!.moodLabel).withValues(alpha: 0.2)
            : isToday
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
      ),
      child: Center(
        child: hasMood
            ? Text(
                _moodEmoji(moodLog!.moodLabel),
                style: const TextStyle(fontSize: 16),
              )
            : Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _MoodSummary extends StatelessWidget {
  final List<MoodLog> moods;
  const _MoodSummary({required this.moods});

  @override
  Widget build(BuildContext context) {
    if (moods.isEmpty) {
      return GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No mood data for this month',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final avg = moods.map((m) => m.score).reduce((a, b) => a + b) /
        moods.length;
    final count = moods.length;

    String avgLabel;
    String avgEmoji;
    if (avg >= 4.5) {
      avgLabel = 'Great';
      avgEmoji = '😄';
    } else if (avg >= 3.5) {
      avgLabel = 'Good';
      avgEmoji = '😊';
    } else if (avg >= 2.5) {
      avgLabel = 'Okay';
      avgEmoji = '😐';
    } else if (avg >= 1.5) {
      avgLabel = 'Bad';
      avgEmoji = '😟';
    } else {
      avgLabel = 'Awful';
      avgEmoji = '😢';
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.lgBorder,
            ),
            child: Center(
              child: Text(avgEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Mood: $avgLabel',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$count entries this month • ${avg.toStringAsFixed(1)}/5.0',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _LegendItem({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
