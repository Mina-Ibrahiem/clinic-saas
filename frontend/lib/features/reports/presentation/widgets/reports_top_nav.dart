import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../report_routes.dart';

class ReportsTopNav extends StatelessWidget {
  const ReportsTopNav({
    super.key,
    required this.activeType,
  });

  final ReportType activeType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in ReportType.values)
          ChoiceChip(
            label: Text(reportLabel(l10n, type)),
            selected: activeType == type,
            onSelected: (_) => context.go(reportPath(type)),
          ),
      ],
    );
  }
}
