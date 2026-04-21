import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/doctor.dart';
import '../domain/models/doctor_upsert_payload.dart';
import 'controllers/doctor_details_provider.dart';
import 'controllers/doctor_form_controller.dart';

class DoctorFormPage extends ConsumerStatefulWidget {
  const DoctorFormPage({
    super.key,
    this.doctorId,
  });

  final int? doctorId;

  static const createPath = '/doctors/new';
  static String editPathFor(int id) => '/doctors/$id/edit';

  @override
  ConsumerState<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends ConsumerState<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _userId = TextEditingController();
  final _doctorCode = TextEditingController();
  final _fullName = TextEditingController();
  final _specialization = TextEditingController();
  final _licenseNumber = TextEditingController();
  final _consultationFee = TextEditingController();
  final _bio = TextEditingController();
  final _branchId = TextEditingController();
  String? _status;
  bool _seededFromExisting = false;

  bool get _isEdit => widget.doctorId != null;

  @override
  void dispose() {
    _userId.dispose();
    _doctorCode.dispose();
    _fullName.dispose();
    _specialization.dispose();
    _licenseNumber.dispose();
    _consultationFee.dispose();
    _bio.dispose();
    _branchId.dispose();
    super.dispose();
  }

  void _seedFromDoctor(Doctor doctor) {
    if (_seededFromExisting) return;
    _userId.text = doctor.userId?.toString() ?? '';
    _doctorCode.text = doctor.doctorCode ?? '';
    _fullName.text = doctor.fullName;
    _specialization.text = doctor.specialization;
    _licenseNumber.text = doctor.licenseNumber ?? '';
    _consultationFee.text = doctor.consultationFee?.toStringAsFixed(2) ?? '';
    _bio.text = doctor.bio ?? '';
    _branchId.text = doctor.branchId?.toString() ?? '';
    _status = doctor.status;
    _seededFromExisting = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = DoctorUpsertPayload(
      userId: int.tryParse(_userId.text.trim()),
      doctorCode: _doctorCode.text,
      fullName: _fullName.text,
      specialization: _specialization.text,
      licenseNumber: _licenseNumber.text,
      consultationFee: double.tryParse(_consultationFee.text.trim()),
      bio: _bio.text,
      status: _status,
      branchId: int.tryParse(_branchId.text.trim()),
    );

    final controller = ref.read(doctorFormControllerProvider);
    final doctor = _isEdit
        ? await controller.update(doctorId: widget.doctorId!, payload: payload)
        : await controller.create(payload);

    if (!mounted) return;
    if (doctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Failed to save doctor.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Doctor updated.' : 'Doctor created.')),
    );
    context.go('/doctors');
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(doctorFormControllerProvider);
    final editState = _isEdit ? ref.watch(doctorDetailsProvider(widget.doctorId!)) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Doctor' : 'Create Doctor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isEdit
          ? editState!.when(
              data: (doctor) {
                _seedFromDoctor(doctor);
                return _buildForm(controller.submitting);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load doctor.\n$error')),
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
                _field(_userId, 'User ID', numeric: true),
                _field(_doctorCode, 'Doctor code'),
                _field(_fullName, 'Full name', required: true),
                _field(_specialization, 'Specialization', required: true),
                _field(_licenseNumber, 'License number'),
                _field(_consultationFee, 'Consultation fee', numeric: true, decimal: true),
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
              controller: _bio,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Bio'),
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
              label: Text(submitting ? 'Saving...' : (_isEdit ? 'Update doctor' : 'Create doctor')),
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
