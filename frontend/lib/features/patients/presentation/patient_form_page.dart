import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../domain/models/patient.dart';
import '../domain/models/patient_upsert_payload.dart';
import 'controllers/patient_details_provider.dart';
import 'controllers/patient_form_controller.dart';

class PatientFormPage extends ConsumerStatefulWidget {
  const PatientFormPage({
    super.key,
    this.patientId,
  });

  final int? patientId;

  static const createPath = '/patients/new';
  static String editPathFor(int id) => '/patients/$id/edit';

  @override
  ConsumerState<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends ConsumerState<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _bloodGroup = TextEditingController();
  final _allergies = TextEditingController();
  final _medicalNotes = TextEditingController();
  final _branchId = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _status;
  bool _seededFromExisting = false;

  bool get _isEdit => widget.patientId != null;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    _bloodGroup.dispose();
    _allergies.dispose();
    _medicalNotes.dispose();
    _branchId.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _dateOfBirth = picked);
  }

  void _seedFromPatient(Patient patient) {
    if (_seededFromExisting) return;
    _fullName.text = patient.fullName;
    _phone.text = patient.phone;
    _email.text = patient.email ?? '';
    _address.text = patient.address ?? '';
    _emergencyName.text = patient.emergencyContactName ?? '';
    _emergencyPhone.text = patient.emergencyContactPhone ?? '';
    _bloodGroup.text = patient.bloodGroup ?? '';
    _allergies.text = patient.allergies ?? '';
    _medicalNotes.text = patient.medicalNotes ?? '';
    _branchId.text = patient.branchId?.toString() ?? '';
    _gender = patient.gender;
    _status = patient.status;
    _dateOfBirth = patient.dateOfBirth;
    _seededFromExisting = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = PatientUpsertPayload(
      fullName: _fullName.text,
      phone: _phone.text,
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      email: _email.text,
      address: _address.text,
      emergencyContactName: _emergencyName.text,
      emergencyContactPhone: _emergencyPhone.text,
      bloodGroup: _bloodGroup.text,
      allergies: _allergies.text,
      medicalNotes: _medicalNotes.text,
      status: _status,
      branchId: int.tryParse(_branchId.text.trim()),
    );

    final controller = ref.read(patientFormControllerProvider);
    final patient = _isEdit
        ? await controller.update(
            patientId: widget.patientId!,
            payload: payload,
          )
        : await controller.create(payload);
    if (!mounted) return;

    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Failed to save patient.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Patient updated.' : 'Patient created.')),
    );
    context.go('/patients');
  }

  @override
  Widget build(BuildContext context) {
    final formController = ref.watch(patientFormControllerProvider);
    final editingState = _isEdit ? ref.watch(patientDetailsProvider(widget.patientId!)) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Patient' : 'Create Patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isEdit
          ? editingState!.when(
              data: (patient) {
                _seedFromPatient(patient);
                return _buildForm(formController.submitting);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load patient.\n$error')),
            )
          : _buildForm(formController.submitting),
    );
  }

  Widget _buildForm(bool submitting) {
    final format = DateFormat('yyyy-MM-dd');

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
                _field(_fullName, 'Full name', required: true),
                _field(_phone, 'Phone', required: true, keyboardType: TextInputType.phone),
                _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
                _field(_address, 'Address'),
                _field(_emergencyName, 'Emergency contact name'),
                _field(_emergencyPhone, 'Emergency contact phone', keyboardType: TextInputType.phone),
                _field(_bloodGroup, 'Blood group'),
                _field(_allergies, 'Allergies'),
                _field(_branchId, 'Branch ID', keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Not set')),
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                      DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
                    ],
                    onChanged: submitting ? null : (value) => setState(() => _gender = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: submitting ? null : _pickDob,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of birth',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_dateOfBirth != null ? format.format(_dateOfBirth!) : '-'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _medicalNotes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Medical notes'),
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
              label: Text(submitting ? 'Saving...' : (_isEdit ? 'Update patient' : 'Create patient')),
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
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final raw = (value ?? '').trim();
          if (required && raw.isEmpty) {
            return '$label is required.';
          }
          if (label == 'Email' && raw.isNotEmpty && !raw.contains('@')) {
            return 'Enter a valid email.';
          }
          return null;
        },
      ),
    );
  }
}
