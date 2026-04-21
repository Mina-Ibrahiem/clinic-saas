import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/smart_reference_field.dart';
import '../domain/models/appointment.dart';
import '../domain/models/appointment_upsert_payload.dart';
import 'controllers/appointment_details_provider.dart';
import 'controllers/appointment_form_controller.dart';

class AppointmentFormPage extends ConsumerStatefulWidget {
  const AppointmentFormPage({
    super.key,
    this.appointmentId,
  });

  final int? appointmentId;

  static const createPath = '/appointments/new';
  static String editPathFor(int id) => '/appointments/$id/edit';

  @override
  ConsumerState<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends ConsumerState<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  int? _patientId;
  int? _doctorId;
  int? _serviceId;
  int? _branchId;
  String? _patientLabel;
  String? _doctorLabel;
  String? _serviceLabel;
  String? _branchLabel;

  final _notes = TextEditingController();

  DateTime? _appointmentDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _status;
  bool _seededFromExisting = false;

  bool get _isEdit => widget.appointmentId != null;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _seedFromAppointment(Appointment appointment) {
    if (_seededFromExisting) return;
    _patientId = appointment.patientId;
    _doctorId = appointment.doctorId;
    _serviceId = appointment.serviceId;
    _branchId = appointment.branchId;
    _patientLabel = appointment.patient?.label;
    _doctorLabel = appointment.doctor?.label;
    _serviceLabel = appointment.service?.label;
    _branchLabel = appointment.branch?.label;
    _notes.text = appointment.notes ?? '';
    _appointmentDate = appointment.appointmentDate;
    _startTime = _parseTime(appointment.startTime);
    _endTime = _parseTime(appointment.endTime);
    _status = appointment.status;
    _seededFromExisting = true;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => _appointmentDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() => _endTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_patientId == null || _doctorId == null || _appointmentDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient, doctor, date and time are required.')),
      );
      return;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    final payload = AppointmentUpsertPayload(
      patientId: _patientId!,
      doctorId: _doctorId!,
      serviceId: _serviceId,
      branchId: _branchId,
      appointmentDate: _appointmentDate!,
      startTime: _formatTime(_startTime!),
      endTime: _formatTime(_endTime!),
      status: _status,
      notes: _notes.text,
    );

    final controller = ref.read(appointmentFormControllerProvider);
    final appointment = _isEdit
        ? await controller.update(
            appointmentId: widget.appointmentId!,
            payload: payload,
          )
        : await controller.create(payload);
    if (!mounted) return;

    if (appointment == null) {
      final backendMessage = controller.errorMessage ?? 'Failed to save appointment.';
      final friendly = backendMessage.toLowerCase().contains('overlap')
          ? 'Time conflict detected. Please choose a different schedule slot.'
          : backendMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendly)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_isEdit ? 'Appointment updated.' : 'Appointment created.'),
      ),
    );
    context.go('/appointments');
  }

  @override
  Widget build(BuildContext context) {
    final formController = ref.watch(appointmentFormControllerProvider);
    final editingState = _isEdit ? ref.watch(appointmentDetailsProvider(widget.appointmentId!)) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit appointment' : 'Schedule appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isEdit
          ? editingState!.when(
              data: (appointment) {
                _seedFromAppointment(appointment);
                return _buildForm(formController.submitting);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load appointment.\n$error')),
            )
          : _buildForm(formController.submitting),
    );
  }

  Widget _buildForm(bool submitting) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(
              title: 'People & service',
              subtitle: 'Search by name or code — no manual IDs.',
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
                  entity: ReferenceEntity.doctor,
                  label: 'Doctor',
                  value: _doctorId,
                  selectedLabel: _doctorLabel,
                  requiredField: true,
                  enabled: !submitting,
                  onChanged: (id) => setState(() {
                    _doctorId = id;
                    _doctorLabel = null;
                  }),
                ),
                SmartReferenceField(
                  entity: ReferenceEntity.service,
                  label: 'Service',
                  value: _serviceId,
                  selectedLabel: _serviceLabel,
                  enabled: !submitting,
                  onChanged: (id) => setState(() {
                    _serviceId = id;
                    _serviceLabel = null;
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
              ],
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Schedule'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 280,
                  child: InkWell(
                    onTap: submitting ? null : _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Appointment date',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(_appointmentDate != null ? dateFormat.format(_appointmentDate!) : '—'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: InkWell(
                    onTap: submitting ? null : _pickStartTime,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start time',
                        suffixIcon: Icon(Icons.access_time_rounded),
                      ),
                      child: Text(_startTime != null ? _formatTime(_startTime!) : '—'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: InkWell(
                    onTap: submitting ? null : _pickEndTime,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End time',
                        suffixIcon: Icon(Icons.access_time_filled_rounded),
                      ),
                      child: Text(_endTime != null ? _formatTime(_endTime!) : '—'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Not set')),
                      DropdownMenuItem(value: 'booked', child: Text('Booked')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      DropdownMenuItem(value: 'no_show', child: Text('No show')),
                    ],
                    onChanged: submitting ? null : (value) => setState(() => _status = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
              enabled: !submitting,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: submitting ? null : _submit,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(submitting ? 'Saving…' : (_isEdit ? 'Update appointment' : 'Create appointment')),
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

String _formatTime(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
