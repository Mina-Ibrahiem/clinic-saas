import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_access.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/settings_providers.dart';
import '../../domain/models/settings_scope.dart';

class SettingsScopeBar extends ConsumerStatefulWidget {
  const SettingsScopeBar({super.key});

  @override
  ConsumerState<SettingsScopeBar> createState() => _SettingsScopeBarState();
}

class _SettingsScopeBarState extends ConsumerState<SettingsScopeBar> {
  final _tenantController = TextEditingController();
  final _branchController = TextEditingController();

  @override
  void dispose() {
    _tenantController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final scope = ref.watch(settingsScopeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings scope',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tenant-level settings apply everywhere. Branch overrides win when set for the same key. '
            'Leave branch empty to edit tenant defaults (clinic owner / super admin).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              if (user.isSuperAdmin) ...[
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _tenantController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tenant ID',
                      hintText: 'Optional',
                    ),
                  ),
                ),
              ],
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _branchController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Branch ID',
                    hintText: 'Empty = tenant',
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  final tenantId = user.isSuperAdmin ? int.tryParse(_tenantController.text.trim()) : null;
                  final branchRaw = _branchController.text.trim();
                  final branchId = branchRaw.isEmpty ? null : int.tryParse(branchRaw);

                  ref.read(settingsScopeProvider.notifier).state = SettingsScope(
                    tenantId: tenantId,
                    branchId: branchId,
                  );
                  ref.invalidate(fullSettingsProvider);
                  ref.invalidate(clinicProfileSettingsProvider);
                  ref.invalidate(invoiceSettingsProvider);
                },
                child: const Text('Apply scope'),
              ),
              TextButton(
                onPressed: () {
                  _tenantController.clear();
                  _branchController.clear();
                  ref.read(settingsScopeProvider.notifier).state = const SettingsScope();
                  ref.invalidate(fullSettingsProvider);
                  ref.invalidate(clinicProfileSettingsProvider);
                  ref.invalidate(invoiceSettingsProvider);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Active query: tenant_id=${scope.tenantId ?? '—'} · branch_id=${scope.branchId?.toString() ?? 'null (tenant-wide)'}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
