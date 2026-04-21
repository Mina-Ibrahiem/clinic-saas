import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_spacing.dart';

/// Shimmer placeholder rows for data tables and lists.
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({
    super.key,
    this.rows = 8,
    this.rowHeight = 52,
  });

  final int rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final highlight = scheme.surfaceContainerHigh.withValues(alpha: 0.9);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          for (var i = 0; i < rows; i++) ...[
            Container(
              height: rowHeight,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// KPI grid shimmer for dashboard overview.
class AppKpiGridSkeleton extends StatelessWidget {
  const AppKpiGridSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < count; i++)
          SizedBox(
            width: 250,
            height: 88,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              highlightColor: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tall block for charts / panels loading.
class AppPanelSkeleton extends StatelessWidget {
  const AppPanelSkeleton({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      highlightColor: scheme.surfaceContainerHigh.withValues(alpha: 0.85),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}
