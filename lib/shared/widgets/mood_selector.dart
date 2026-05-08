import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mood emoji widget data model.
class MoodOption {
  final int score;
  final String label;
  final String emoji;
  final Color color;

  const MoodOption({
    required this.score,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

/// Predefined mood options.
const List<MoodOption> moodOptions = [
  MoodOption(score: 1, label: 'Awful', emoji: '😢', color: AppColors.moodAwful),
  MoodOption(score: 2, label: 'Bad', emoji: '😟', color: AppColors.moodBad),
  MoodOption(score: 3, label: 'Okay', emoji: '😐', color: AppColors.moodOkay),
  MoodOption(score: 4, label: 'Good', emoji: '😊', color: AppColors.moodGood),
  MoodOption(score: 5, label: 'Great', emoji: '😄', color: AppColors.moodGreat),
];

/// Interactive mood selector with animated pill-shaped emoji buttons.
class MoodSelector extends StatefulWidget {
  final int? selectedScore;
  final ValueChanged<MoodOption> onMoodSelected;

  const MoodSelector({
    super.key,
    this.selectedScore,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with TickerProviderStateMixin {
  final Map<int, AnimationController> _controllers = {};
  final Map<int, Animation<double>> _scaleAnimations = {};

  @override
  void initState() {
    super.initState();
    for (final mood in moodOptions) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      _controllers[mood.score] = controller;
      _scaleAnimations[mood.score] = Tween<double>(begin: 1.0, end: 1.15)
          .animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSelect(MoodOption mood) {
    // Reset all
    for (final entry in _controllers.entries) {
      if (entry.key != mood.score) {
        entry.value.reverse();
      }
    }
    // Animate selected
    _controllers[mood.score]?.forward();
    widget.onMoodSelected(mood);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moodOptions.map((mood) {
        final isSelected = widget.selectedScore == mood.score;
        return GestureDetector(
          onTap: () => _onSelect(mood),
          child: AnimatedBuilder(
            animation: _scaleAnimations[mood.score]!,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimations[mood.score]!.value,
              child: child,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? mood.color.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(
                  color: isSelected
                      ? mood.color.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected ? AppShadows.colorShadow(mood.color) : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mood.emoji,
                    style: TextStyle(fontSize: isSelected ? 36 : 30),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mood.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? mood.color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// AnimatedBuilder helper using AnimatedWidget pattern.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
