import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Step progress indicator for the capture workflow.
/// Implements [PreferredSizeWidget] so it can be used as [AppBar.bottom].
class StepIndicator extends StatelessWidget implements PreferredSizeWidget {
  const StepIndicator({super.key, required this.currentStep});

  /// 0 = Foto, 1 = Preview, 2 = Análisis, 3 = Publicar
  final int currentStep;

  static const _steps = [
    (icon: Icons.camera_alt_rounded, label: 'Foto'),
    (icon: Icons.image_search_rounded, label: 'Preview'),
    (icon: Icons.auto_awesome_rounded, label: 'Análisis'),
    (icon: Icons.rocket_launch_rounded, label: 'Publicar'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Row(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            _StepDot(
              icon: _steps[i].icon,
              label: _steps[i].label,
              state: i < currentStep
                  ? _StepState.completed
                  : i == currentStep
                      ? _StepState.current
                      : _StepState.future,
            ),
            if (i < _steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: i < currentStep ? AppColors.success : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

enum _StepState { completed, current, future }

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.icon,
    required this.label,
    required this.state,
  });

  final IconData icon;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == _StepState.completed;
    final isCurrent = state == _StepState.current;

    final bgColor = isCompleted
        ? AppColors.successLight
        : isCurrent
            ? AppColors.primary
            : AppColors.surface;

    final iconColor = isCompleted
        ? AppColors.success
        : isCurrent
            ? Colors.white
            : AppColors.textMuted;

    final borderColor = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.primary
            : AppColors.border;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            size: 15,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.primary : AppColors.textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
