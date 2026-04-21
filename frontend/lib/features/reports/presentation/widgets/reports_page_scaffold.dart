import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../app_shell/presentation/app_shell_navigation.dart';
import '../../../app_shell/presentation/app_shell_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../report_routes.dart';
import 'reports_top_nav.dart';

class ReportsPageScaffold extends ConsumerWidget {
  const ReportsPageScaffold({
    super.key,
    required this.title,
    required this.activeType,
    required this.child,
    this.onExport,
  });

  final String title;
  final ReportType activeType;
  final Widget child;
  /// Optional CSV/export action (placeholder until backend export exists).
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppShellScaffold(
      title: l10n.reportsShellTitle,
      activeSection: AppShellSection.reports,
      onSectionSelected: (section) => goAppShellSection(context, section),
      onLogout: () => ref.read(authControllerProvider).logout(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (onExport != null)
                  IconButton.filledTonal(
                    tooltip: l10n.commonExportCsvSoon,
                    onPressed: onExport,
                    icon: const Icon(Icons.download_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ReportsTopNav(activeType: activeType),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
