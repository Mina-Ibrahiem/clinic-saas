import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_access.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/settings_repository.dart';
import '../domain/models/settings_models.dart';
import 'controllers/settings_providers.dart';
import 'settings_routes.dart';
import 'widgets/settings_page_scaffold.dart';

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  static const routePath = SettingsRoutes.general;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(fullSettingsProvider);
    final user = ref.watch(authControllerProvider).user;
    final canEdit = user.canManageSettings;

    return SettingsPageScaffold(
      title: 'General',
      activeSection: SettingsSection.general,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (bundle) => _GeneralForm(
          initial: bundle.general,
          canEdit: canEdit,
          onSave: canEdit
              ? (values) async {
                  final repo = ref.read(settingsRepositoryProvider);
                  final scope = ref.read(settingsScopeProvider);
                  await repo.updateFull(
                    scope: scope,
                    settings: values.toSettingsMap(),
                  );
                  ref.invalidate(fullSettingsProvider);
                  ref.invalidate(clinicProfileSettingsProvider);
                  ref.invalidate(invoiceSettingsProvider);
                }
              : null,
        ),
      ),
    );
  }
}

class _GeneralForm extends StatefulWidget {
  const _GeneralForm({
    required this.initial,
    required this.canEdit,
    required this.onSave,
  });

  final GeneralSettingsValues initial;
  final bool canEdit;
  final Future<void> Function(GeneralSettingsValues values)? onSave;

  @override
  State<_GeneralForm> createState() => _GeneralFormState();
}

class _GeneralFormState extends State<_GeneralForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial.clinicName ?? '');
  late final _phone = TextEditingController(text: widget.initial.clinicPhone ?? '');
  late final _email = TextEditingController(text: widget.initial.clinicEmail ?? '');
  late final _address = TextEditingController(text: widget.initial.clinicAddress ?? '');
  late final _timezone = TextEditingController(text: widget.initial.timezone ?? '');
  late final _currency = TextEditingController(text: widget.initial.currency ?? '');
  bool _saving = false;

  @override
  void didUpdateWidget(covariant _GeneralForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    void sync() {
      _name.text = widget.initial.clinicName ?? '';
      _phone.text = widget.initial.clinicPhone ?? '';
      _email.text = widget.initial.clinicEmail ?? '';
      _address.text = widget.initial.clinicAddress ?? '';
      _timezone.text = widget.initial.timezone ?? '';
      _currency.text = widget.initial.currency ?? '';
    }

    final o = oldWidget.initial;
    final n = widget.initial;
    if (o.clinicName != n.clinicName ||
        o.clinicPhone != n.clinicPhone ||
        o.clinicEmail != n.clinicEmail ||
        o.clinicAddress != n.clinicAddress ||
        o.timezone != n.timezone ||
        o.currency != n.currency) {
      sync();
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
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || widget.onSave == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSave!(
        GeneralSettingsValues(
          clinicName: _name.text.trim().isEmpty ? null : _name.text.trim(),
          clinicPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          clinicEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
          clinicAddress: _address.text.trim().isEmpty ? null : _address.text.trim(),
          timezone: _timezone.text.trim().isEmpty ? null : _timezone.text.trim(),
          currency: _currency.text.trim().isEmpty ? null : _currency.text.trim().toUpperCase(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('General settings saved.')));
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
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Text(
            'Identity & locale',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
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
            decoration: const InputDecoration(
              labelText: 'Timezone',
              hintText: 'e.g. Asia/Dubai',
            ),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _currency,
            decoration: const InputDecoration(
              labelText: 'Currency code',
              hintText: '3 letters, e.g. AED',
            ),
            enabled: widget.canEdit,
            maxLength: 3,
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
                  : const Text('Save general settings'),
            ),
        ],
      ),
    );
  }
}
