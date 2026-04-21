import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/glass_panel.dart';
import '../../app_shell/presentation/app_shell_navigation.dart';
import '../../app_shell/presentation/app_shell_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/models/branch.dart';
import 'branch_form_page.dart';
import 'branch_routes.dart';
import 'controllers/branch_details_provider.dart';

class BranchDetailsPage extends ConsumerWidget {
  const BranchDetailsPage({super.key, required this.branchId});

  final int branchId;

  static String pathFor(int id) => BranchRoutes.detail(id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBranch = ref.watch(branchDetailsProvider(branchId));

    return AppShellScaffold(
      title: 'Branch',
      activeSection: AppShellSection.branches,
      onSectionSelected: (section) => goAppShellSection(context, section),
      onLogout: () => ref.read(authControllerProvider).logout(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: asyncBranch.when(
          data: (branch) => _BranchBody(branch: branch),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load branch: $e')),
        ),
      ),
    );
  }
}

class _BranchBody extends ConsumerWidget {
  const _BranchBody({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final stats = branch.stats;

    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                branch.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(BranchFormPage.editPathFor(branch.id)),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            ),
          ],
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _kv('Code', branch.code ?? '—'),
                _kv('Phone', branch.phone ?? '—'),
                _kv('Email', branch.email ?? '—'),
                _kv('Address', branch.address ?? '—'),
                _kv('Status', branch.status),
                if (branch.tenant != null) _kv('Tenant', branch.tenant!.name ?? 'ID ${branch.tenant!.id}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (stats != null)
          GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational footprint',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deletion is blocked while any of these counters are above zero.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _statChip(context, 'Users', stats.usersCount),
                      _statChip(context, 'Patients', stats.patientsCount),
                      _statChip(context, 'Doctors', stats.doctorsCount),
                      _statChip(context, 'Appointments', stats.appointmentsCount),
                      _statChip(context, 'Invoices', stats.invoicesCount),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  static Widget _statChip(BuildContext context, String label, int value) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          Text('$value', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
