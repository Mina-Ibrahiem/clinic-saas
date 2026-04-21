import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/service.dart';
import '../domain/models/service_upsert_payload.dart';
import 'controllers/service_details_provider.dart';
import 'controllers/service_form_controller.dart';

class ServiceFormPage extends ConsumerStatefulWidget {
  const ServiceFormPage({
    super.key,
    this.serviceId,
  });

  final int? serviceId;

  static const createPath = '/services/new';
  static String editPathFor(int id) => '/services/$id/edit';

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _branchId = TextEditingController();
  String? _status;
  bool _seededFromExisting = false;

  bool get _isEdit => widget.serviceId != null;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _price.dispose();
    _duration.dispose();
    _branchId.dispose();
    super.dispose();
  }

  void _seedFromService(Service service) {
    if (_seededFromExisting) return;
    _name.text = service.name;
    _code.text = service.code ?? '';
    _description.text = service.description ?? '';
    _price.text = service.price.toStringAsFixed(2);
    _duration.text = service.durationMinutes?.toString() ?? '';
    _branchId.text = service.branchId?.toString() ?? '';
    _status = service.status;
    _seededFromExisting = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_price.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price is required and must be numeric.')),
      );
      return;
    }

    final payload = ServiceUpsertPayload(
      name: _name.text,
      code: _code.text,
      description: _description.text,
      price: price,
      durationMinutes: int.tryParse(_duration.text.trim()),
      status: _status,
      branchId: int.tryParse(_branchId.text.trim()),
    );

    final controller = ref.read(serviceFormControllerProvider);
    final service = _isEdit
        ? await controller.update(serviceId: widget.serviceId!, payload: payload)
        : await controller.create(payload);

    if (!mounted) return;
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Failed to save service.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Service updated.' : 'Service created.')),
    );
    context.go('/services');
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(serviceFormControllerProvider);
    final editState = _isEdit ? ref.watch(serviceDetailsProvider(widget.serviceId!)) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Service' : 'Create Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isEdit
          ? editState!.when(
              data: (service) {
                _seedFromService(service);
                return _buildForm(controller.submitting);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load service.\n$error')),
            )
          : _buildForm(controller.submitting),
    );
  }

  Widget _buildForm(bool submitting) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 14,
              children: [
                _field(_name, 'Name', required: true),
                _field(_code, 'Code'),
                _field(_price, 'Price', required: true, numeric: true, decimal: true),
                _field(_duration, 'Duration minutes', numeric: true),
                _field(_branchId, 'Branch ID', numeric: true),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Not set')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: submitting ? null : (value) => setState(() => _status = value),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description'),
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
              label: Text(submitting ? 'Saving...' : (_isEdit ? 'Update service' : 'Create service')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool numeric = false,
    bool decimal = false,
  }) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? TextInputType.numberWithOptions(decimal: decimal)
            : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final raw = (value ?? '').trim();
          if (required && raw.isEmpty) return '$label is required.';
          if (numeric && raw.isNotEmpty) {
            if (decimal) {
              if (double.tryParse(raw) == null) return '$label must be numeric.';
            } else {
              if (int.tryParse(raw) == null) return '$label must be an integer.';
            }
          }
          return null;
        },
      ),
    );
  }
}
