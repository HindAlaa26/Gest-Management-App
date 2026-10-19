import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

enum TimelineStepState { reached, current, pending, cancelled }

class TimelineStep {
  const TimelineStep({
    required this.title,
    required this.caption,
    required this.state,
    this.time,
  });

  final String title;
  final String caption;
  final TimelineStepState state;
  final String? time;
}

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.steps});

  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});

  final TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pending = step.state == TimelineStepState.pending;
    final cancelled = step.state == TimelineStepState.cancelled;
    final lineColor = step.state == TimelineStepState.reached
        ? AppColors.teal
        : const Color(0xFFE2E8F0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _Dot(state: step.state),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: pending
                          ? AppColors.muted
                          : cancelled
                              ? AppColors.error
                              : AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (step.caption.isNotEmpty)
                    Text(
                      step.caption,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            step.time ?? (pending ? 'Pending' : ''),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state});

  final TimelineStepState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case TimelineStepState.reached:
        return _circle(
          color: AppColors.teal,
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        );
      case TimelineStepState.cancelled:
        return _circle(
          color: AppColors.error,
          child: const Icon(Icons.close, color: Colors.white, size: 14),
        );
      case TimelineStepState.current:
        return _circle(
          color: Colors.white,
          border: AppColors.teal,
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case TimelineStepState.pending:
        return _circle(color: Colors.white, border: const Color(0xFFCBD5E1));
    }
  }

  Widget _circle({required Color color, Color? border, Widget? child}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: border == null ? null : Border.all(color: border, width: 2),
      ),
      child: child,
    );
  }
}
