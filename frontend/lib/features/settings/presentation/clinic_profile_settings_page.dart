import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_access.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/settings_repository.dart';
import '../domain/models/settings_models.dart';
import 'controllers/settings_providers.dart';
import 'settings_routes.dart';
import 'widgets/settings_page_scaffold.dart';

class ClinicProfileSettingsPage extends ConsumerWidget {
  const ClinicProfileSettingsPage({super.key});

  static const routePath = SettingsRoutes.clinicProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicProfileSettingsProvider);
    final user = ref.watch(authControllerProvider).user;
    final canEdit = user.canManageSettings;

    return SettingsPageScaffold(
      title: 'Clinic profile',
      activeSection: SettingsSection.clinicProfile,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (res) => _ClinicForm(
          initial: res.clinicProfile,
          canEdit: canEdit,
          onSave: canEdit
              ? (values) async {
                  final repo = ref.read(settingsRepositoryProvider);
                  final scope = ref.read(settingsScopeProvider);
                  await repo.updateClinicProfile(
                    scope: scope,
                    payload: values.toUpdateJson(),
                  );
                  ref.invalidate(clinicProfileSettingsProvider);
                  ref.invalidate(fullSettingsProvider);
                }
              : null,
        ),
      ),
    );
  }
}

class _ClinicForm extends StatefulWidget {
  const _ClinicForm({
    required this.initial,
    required this.canEdit,
    required this.onSave,
  });

  final ClinicProfileSettingsValues initial;
  final bool canEdit;
  final Future<void> Function(ClinicProfileSettingsValues values)? onSave;

  @override
  State<_ClinicForm> createState() => _ClinicFormState();
}

class _ClinicFormState extends State<_ClinicForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial.clinicName ?? '');
  late final _phone = TextEditingController(text: widget.initial.clinicPhone ?? '');
  late final _email = TextEditingController(text: widget.initial.clinicEmail ?? '');
  late final _address = TextEditingController(text: widget.initial.clinicAddress ?? '');
  late final _timezone = TextEditingController(text: widget.initial.timezone ?? '');
  late final _currency = TextEditingController(text: widget.initial.currency ?? '');
  late final _logo = TextEditingController(text: widget.initial.brandingLogoUrl ?? '');
  late final _color = TextEditingController(text: widget.initial.brandingPrimaryColor ?? '');
  bool _saving = false;

  @override
  void didUpdateWidget(covariant _ClinicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final o = oldWidget.initial;
    final n = widget.initial;
    if (o.clinicName != n.clinicName ||
        o.clinicPhone != n.clinicPhone ||
        o.clinicEmail != n.clinicEmail ||
        o.clinicAddress != n.clinicAddress ||
        o.timezone != n.timezone ||
        o.currency != n.currency ||
        o.brandingLogoUrl != n.brandingLogoUrl ||
        o.brandingPrimaryColor != n.brandingPrimaryColor) {
      _name.text = n.clinicName ?? '';
      _phone.text = n.clinicPhone ?? '';
      _email.text = n.clinicEmail ?? '';
      _address.text = n.clinicAddress ?? '';
      _timezone.text = n.timezone ?? '';
      _currency.text = n.currency ?? '';
      _logo.text = n.brandingLogoUrl ?? '';
      _color.text = n.brandingPrimaryColor ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _timezone.dispose();
    _currency.dispose();
    _logo.dispose();
    _color.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || widget.onSave == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSave!(
        ClinicProfileSettingsValues(
          clinicName: _name.text.trim().isEmpty ? null : _name.text.trim(),
          clinicPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          clinicEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
          clinicAddress: _address.text.trim().isEmpty ? null : _address.text.trim(),
          timezone: _timezone.text.trim().isEmpty ? null : _timezone.text.trim(),
          currency: _currency.text.trim().isEmpty ? null : _currency.text.trim().toUpperCase(),
          brandingLogoUrl: _logo.text.trim().isEmpty ? null : _logo.text.trim(),
          brandingPrimaryColor: _color.text.trim().isEmpty ? null : _color.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clinic profile saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Text(
            'Brand & contact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'These keys overlap with General settings but include branding fields used across the app shell.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Clinic name'),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Clinic phone'),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Clinic email'),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Clinic address'),
            maxLines: 2,
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _timezone,
            decoration: const InputDecoration(labelText: 'Timezone'),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            maxLength: 3,
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 20),
          Text('Branding', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _logo,
            decoration: const InputDecoration(
              labelText: 'Logo URL',
              hintText: 'https://…',
            ),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _color,
            decoration: const InputDecoration(
              labelText: 'Primary color',
              hintText: '#2563EB or hex',
            ),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 24),
          if (widget.canEdit)
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save clinic profile'),
            ),
        ],
      ),
    );
  }
}
