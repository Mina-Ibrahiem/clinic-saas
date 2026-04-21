import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/smart_reference_field.dart';
import '../domain/models/invoice.dart';
import '../domain/models/invoice_upsert_payload.dart';
import 'controllers/invoice_details_provider.dart';
import 'controllers/invoice_form_controller.dart';

class InvoiceFormPage extends ConsumerStatefulWidget {
  const InvoiceFormPage({
    super.key,
    this.invoiceId,
  });

  final int? invoiceId;

  static const createPath = '/invoices/new';
  static String editPathFor(int id) => '/invoices/$id/edit';

  @override
  ConsumerState<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends ConsumerState<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _discount = TextEditingController(text: '0');
  final _tax = TextEditingController(text: '0');

  int? _patientId;
  int? _appointmentId;
  int? _branchId;
  String? _patientLabel;
  String? _appointmentLabel;
  String? _branchLabel;

  DateTime _issuedAt = DateTime.now();
  DateTime? _dueAt;
  String? _status;

  final List<_InvoiceItemDraft> _items = [
    _InvoiceItemDraft(),
  ];

  bool _seededFromExisting = false;

  bool get _isEdit => widget.invoiceId != null;

  @override
  void dispose() {
    _discount.dispose();
    _tax.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _seedFromInvoice(Invoice invoice) {
    if (_seededFromExisting) return;

    _patientId = invoice.patientId;
    _appointmentId = invoice.appointmentId;
    _branchId = invoice.branchId;
    _patientLabel = invoice.patient?.label;
    _appointmentLabel = invoice.appointment != null
        ? '#${invoice.appointment!.id} · ${invoice.appointment!.label}'
        : (invoice.appointmentId != null ? 'Appointment #${invoice.appointmentId}' : null);
    _branchLabel = invoice.branch?.label;

    _discount.text = invoice.discount.toStringAsFixed(2);
    _tax.text = invoice.tax.toStringAsFixed(2);
    _issuedAt = invoice.issuedAt;
    _dueAt = invoice.dueAt;
    _status = invoice.status;

    for (final item in _items) {
      item.dispose();
    }
    _items
      ..clear()
      ..addAll(
        invoice.items.isNotEmpty
            ? invoice.items.map((item) {
                return _InvoiceItemDraft(
                  serviceId: item.serviceId,
                  serviceLabel: item.service?.label,
                  description: item.description ?? item.service?.label ?? '',
                  quantity: item.quantity.toString(),
                  unitPrice: item.unitPrice.toStringAsFixed(2),
                );
              })
            : [_InvoiceItemDraft()],
      );

    _seededFromExisting = true;
  }

  Future<void> _pickIssuedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _issuedAt = picked;
      if (_dueAt != null && _dueAt!.isBefore(picked)) {
        _dueAt = picked;
      }
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? _issuedAt,
      firstDate: _issuedAt,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _dueAt = picked);
  }

  void _addItem() {
    setState(() => _items.add(_InvoiceItemDraft()));
  }

  void _removeItem(int index) {
    if (_items.length == 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient is required.')),
      );
      return;
    }

    final parsedItems = <InvoiceUpsertItemPayload>[];
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final quantity = int.tryParse(item.quantityController.text.trim());
      final unitPrice = double.tryParse(item.unitPriceController.text.trim());
      if (quantity == null || quantity <= 0 || unitPrice == null || unitPrice < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid quantity/unit price at item ${i + 1}.')),
        );
        return;
      }

      parsedItems.add(
        InvoiceUpsertItemPayload(
          serviceId: item.serviceId,
          description: item.descriptionController.text,
          quantity: quantity,
          unitPrice: unitPrice,
        ),
      );
    }

    if (parsedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one invoice item is required.')),
      );
      return;
    }

    final payload = InvoiceUpsertPayload(
      patientId: _patientId!,
      appointmentId: _appointmentId,
      branchId: _branchId,
      issuedAt: _issuedAt,
      dueAt: _dueAt,
      discount: double.tryParse(_discount.text.trim()) ?? 0,
      tax: double.tryParse(_tax.text.trim()) ?? 0,
      status: _status,
      items: parsedItems,
    );

    final controller = ref.read(invoiceFormControllerProvider);
    final invoice = _isEdit
        ? await controller.update(
            invoiceId: widget.invoiceId!,
            payload: payload,
          )
        : await controller.create(payload);

    if (!mounted) return;
    if (invoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Failed to save invoice.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_isEdit ? 'Invoice updated.' : 'Invoice created.'),
      ),
    );
    context.go('/invoices');
  }

  @override
  Widget build(BuildContext context) {
    final formController = ref.watch(invoiceFormControllerProvider);
    final editState = _isEdit ? ref.watch(invoiceDetailsProvider(widget.invoiceId!)) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit invoice' : 'Create invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isEdit
          ? editState!.when(
              data: (invoice) {
                _seedFromInvoice(invoice);
                return _buildForm(formController.submitting);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load invoice.\n$error')),
            )
          : _buildForm(formController.submitting),
    );
  }

  Widget _buildForm(bool submitting) {
    final currency = NumberFormat.currency(symbol: 'AED ');
    final dateFormat = DateFormat('yyyy-MM-dd');
    final subtotal = _items.fold<double>(0, (sum, item) {
      final quantity = int.tryParse(item.quantityController.text.trim()) ?? 0;
      final unitPrice = double.tryParse(item.unitPriceController.text.trim()) ?? 0;
      return sum + (quantity * unitPrice);
    });
    final discount = double.tryParse(_discount.text.trim()) ?? 0;
    final tax = double.tryParse(_tax.text.trim()) ?? 0;
    final total = (subtotal - discount) + tax;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const AppSectionHeader(
              title: 'Parties',
              subtitle: 'Link patient, optional appointment, and branch using search.',
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SmartReferenceField(
                  entity: ReferenceEntity.patient,
                  label: 'Patient',
                  value: _patientId,
                  selectedLabel: _patientLabel,
                  requiredField: true,
                  enabled: !submitting,
                  onChanged: (id) => setState(() {
                    _patientId = id;
                    _patientLabel = null;
                  }),
                ),
                SmartReferenceField(
                  entity: ReferenceEntity.appointment,
                  label: 'Appointment',
                  value: _appointmentId,
                  selectedLabel: _appointmentLabel,
                  enabled: !submitting,
                  width: 300,
                  onChanged: (id) => setState(() {
                    _appointmentId = id;
                    _appointmentLabel = null;
                  }),
                ),
                SmartReferenceField(
                  entity: ReferenceEntity.branch,
                  label: 'Branch',
                  value: _branchId,
                  selectedLabel: _branchLabel,
                  enabled: !submitting,
                  onChanged: (id) => setState(() {
                    _branchId = id;
                    _branchLabel = null;
                  }),
                ),
                _numericField(_discount, 'Discount'),
                _numericField(_tax, 'Tax'),
              ],
            ),
            const SizedBox(height: 16),
            const AppSectionHeader(title: 'Dates & status'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 260,
                  child: InkWell(
                    onTap: submitting ? null : _pickIssuedDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Issued at',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(dateFormat.format(_issuedAt)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: InkWell(
                    onTap: submitting ? null : _pickDueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due at',
                        suffixIcon: Icon(Icons.event_available_outlined),
                      ),
                      child: Text(_dueAt != null ? dateFormat.format(_dueAt!) : '-'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Not set')),
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                      DropdownMenuItem(value: 'partially_paid', child: Text('Partially paid')),
                      DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: submitting ? null : (value) => setState(() => _status = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Line items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: submitting ? null : _addItem,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < _items.length; index++) ...[
              _InvoiceItemEditor(
                index: index + 1,
                draft: _items[index],
                enabled: !submitting,
                onRemove: submitting ? null : () => _removeItem(index),
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _summaryCard('Subtotal', currency.format(subtotal)),
                _summaryCard('Discount', currency.format(discount)),
                _summaryCard('Tax', currency.format(tax)),
                _summaryCard('Estimated total', currency.format(total > 0 ? total : 0), emphasized: true),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: submitting ? null : _submit,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(submitting ? 'Saving…' : (_isEdit ? 'Update invoice' : 'Create invoice')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numericField(TextEditingController controller, String label) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final raw = (value ?? '').trim();
          if (raw.isEmpty) return null;
          final parsed = double.tryParse(raw);
          if (parsed == null) return '$label must be numeric.';
          if (parsed < 0) return '$label cannot be negative.';
          return null;
        },
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _summaryCard(String title, String value, {bool emphasized = false}) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: emphasized ? scheme.primary : null,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InvoiceItemEditor extends ConsumerWidget {
  const _InvoiceItemEditor({
    required this.index,
    required this.draft,
    required this.enabled,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _InvoiceItemDraft draft;
  final bool enabled;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Item $index',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (onRemove != null)
                IconButton(
                  tooltip: 'Remove item',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SmartReferenceField(
                entity: ReferenceEntity.service,
                label: 'Service',
                value: draft.serviceId,
                selectedLabel: draft.serviceLabel,
                enabled: enabled,
                width: 240,
                onChanged: (id) {
                  draft.serviceId = id;
                  draft.serviceLabel = null;
                  onChanged();
                },
              ),
              _field(
                draft.descriptionController,
                'Description',
                required: true,
                enabled: enabled,
              ),
              _field(
                draft.quantityController,
                'Quantity',
                keyboardType: TextInputType.number,
                required: true,
                enabled: enabled,
              ),
              _field(
                draft.unitPriceController,
                'Unit price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                required: true,
                enabled: enabled,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final raw = (value ?? '').trim();
          if (required && raw.isEmpty) return '$label is required.';
          if (label == 'Quantity' && raw.isNotEmpty) {
            final quantity = int.tryParse(raw);
            if (quantity == null || quantity <= 0) return 'Quantity must be greater than 0.';
          }
          if (label == 'Unit price' && raw.isNotEmpty) {
            final amount = double.tryParse(raw);
            if (amount == null || amount < 0) return 'Unit price must be valid.';
          }
          return null;
        },
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

class _InvoiceItemDraft {
  _InvoiceItemDraft({
    this.serviceId,
    this.serviceLabel,
    String description = '',
    String quantity = '1',
    String unitPrice = '0',
  })  : descriptionController = TextEditingController(text: description),
        quantityController = TextEditingController(text: quantity),
        unitPriceController = TextEditingController(text: unitPrice);

  int? serviceId;
  String? serviceLabel;
  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}
