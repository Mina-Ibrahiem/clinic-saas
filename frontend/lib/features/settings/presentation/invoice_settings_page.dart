import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_access.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/settings_repository.dart';
import '../domain/models/settings_models.dart';
import 'controllers/settings_providers.dart';
import 'settings_routes.dart';
import 'widgets/settings_page_scaffold.dart';

class InvoiceSettingsPage extends ConsumerWidget {
  const InvoiceSettingsPage({super.key});

  static const routePath = SettingsRoutes.invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(invoiceSettingsProvider);
    final user = ref.watch(authControllerProvider).user;
    final canEdit = user.canManageSettings;

    return SettingsPageScaffold(
      title: 'Invoice',
      activeSection: SettingsSection.invoice,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (res) => _InvoiceForm(
          initial: res.invoice,
          canEdit: canEdit,
          onSave: canEdit
              ? (values) async {
                  final repo = ref.read(settingsRepositoryProvider);
                  final scope = ref.read(settingsScopeProvider);
                  await repo.updateInvoice(
                    scope: scope,
                    payload: values.toUpdateJson(),
                  );
                  ref.invalidate(invoiceSettingsProvider);
                  ref.invalidate(fullSettingsProvider);
                }
              : null,
        ),
      ),
    );
  }
}

class _InvoiceForm extends StatefulWidget {
  const _InvoiceForm({
    required this.initial,
    required this.canEdit,
    required this.onSave,
  });

  final InvoiceSettingsValues initial;
  final bool canEdit;
  final Future<void> Function(InvoiceSettingsValues values)? onSave;

  @override
  State<_InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<_InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final _prefix = TextEditingController(text: widget.initial.invoicePrefix ?? '');
  late final _dueDays = TextEditingController(text: widget.initial.invoiceDueDays?.toString() ?? '');
  late final _tax = TextEditingController(
    text: widget.initial.taxDefault != null ? widget.initial.taxDefault!.toStringAsFixed(2) : '',
  );
  late final _footer = TextEditingController(text: widget.initial.invoiceFooter ?? '');
  bool _saving = false;

  @override
  void didUpdateWidget(covariant _InvoiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final o = oldWidget.initial;
    final n = widget.initial;
    if (o.invoicePrefix != n.invoicePrefix ||
        o.invoiceDueDays != n.invoiceDueDays ||
        o.taxDefault != n.taxDefault ||
        o.invoiceFooter != n.invoiceFooter) {
      _prefix.text = n.invoicePrefix ?? '';
      _dueDays.text = n.invoiceDueDays?.toString() ?? '';
      _tax.text = n.taxDefault != null ? n.taxDefault!.toStringAsFixed(2) : '';
      _footer.text = n.invoiceFooter ?? '';
    }
  }

  @override
  void dispose() {
    _prefix.dispose();
    _dueDays.dispose();
    _tax.dispose();
    _footer.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || widget.onSave == null) return;
    setState(() => _saving = true);
    try {
      final due = int.tryParse(_dueDays.text.trim());
      final tax = double.tryParse(_tax.text.trim());
      await widget.onSave!(
        InvoiceSettingsValues(
          invoicePrefix: _prefix.text.trim().isEmpty ? null : _prefix.text.trim(),
          invoiceDueDays: due,
          taxDefault: tax,
          invoiceFooter: _footer.text.trim().isEmpty ? null : _footer.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice settings saved.')));
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
            'Defaults for new invoices',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prefix,
            decoration: const InputDecoration(
              labelText: 'Invoice prefix',
              hintText: 'INV',
            ),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dueDays,
            decoration: const InputDecoration(labelText: 'Due days'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tax,
            decoration: const InputDecoration(
              labelText: 'Default tax %',
              hintText: '0 – 100',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: widget.canEdit,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _footer,
            decoration: const InputDecoration(
              labelText: 'Invoice footer',
              hintText: 'Legal note shown on PDFs / emails',
            ),
            maxLines: 3,
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
                  : const Text('Save invoice settings'),
            ),
        ],
      ),
    );
  }
}
