import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../auth/domain/auth_access.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/models/settings_models.dart';
import 'controllers/settings_providers.dart';
import 'settings_routes.dart';
import 'widgets/settings_page_scaffold.dart';

class SettingsOverviewPage extends ConsumerWidget {
  const SettingsOverviewPage({super.key});

  static const routePath = SettingsRoutes.overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(fullSettingsProvider);
    final user = ref.watch(authControllerProvider).user;
    final canEdit = user.canManageSettings;

    return SettingsPageScaffold(
      title: l10n.settingsNavOverview,
      activeSection: SettingsSection.overview,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.commonError}: $e')),
        data: (bundle) => _OverviewBody(bundle: bundle, canEdit: canEdit),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.bundle, required this.canEdit});

  final SettingsBundle bundle;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    Widget card({
      required String title,
      required String subtitle,
      required IconData icon,
      required String path,
    }) {
      return GlassPanel(
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 32, color: scheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      );
    }

    final g = bundle.general;
    final c = bundle.clinicProfile;
    final i = bundle.invoice;

    return ListView(
      children: [
        Text(
          l10n.settingsShellTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Tenant ${bundle.scope.tenantId}'
          '${bundle.scope.branchId != null ? ' · Branch ${bundle.scope.branchId}' : ' · Tenant-wide defaults'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (!canEdit)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'View-only: you need settings.manage to edit.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.tertiary),
            ),
          ),
        const SizedBox(height: 12),
        card(
          title: l10n.settingsNavGeneral,
          subtitle: '${g.clinicName ?? 'Clinic'} · ${g.currency ?? 'AED'} · ${g.timezone ?? 'Asia/Dubai'}',
          icon: Icons.tune_rounded,
          path: SettingsRoutes.general,
        ),
        const SizedBox(height: 12),
        card(
          title: l10n.settingsNavClinicProfile,
          subtitle: '${c.clinicEmail ?? 'Email'} · branding & colors',
          icon: Icons.business_rounded,
          path: SettingsRoutes.clinicProfile,
        ),
        const SizedBox(height: 12),
        card(
          title: l10n.settingsNavInvoice,
          subtitle: '${i.invoicePrefix ?? 'INV'} · due ${i.invoiceDueDays ?? 7}d · tax ${i.taxDefault ?? 0}%',
          icon: Icons.receipt_long_rounded,
          path: SettingsRoutes.invoice,
        ),
      ],
    );
  }
}
