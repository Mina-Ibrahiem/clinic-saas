class AppointmentUpsertPayload {
  const AppointmentUpsertPayload({
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.serviceId,
    this.status,
    this.branchId,
    this.notes,
  });

  final int patientId;
  final int doctorId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final int? serviceId;
  final String? status;
  final int? branchId;
  final String? notes;

  Map<String, dynamic> toJson() {
    String formatDate(DateTime value) => value.toIso8601String().split('T').first;

    String trimOrEmpty(String value) => value.trim();

    return {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'service_id': serviceId,
      'appointment_date': formatDate(appointmentDate),
      'start_time': trimOrEmpty(startTime),
      'end_time': trimOrEmpty(endTime),
      'status': status?.trim().isEmpty == true ? null : status,
      'branch_id': branchId,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
    }..removeWhere((key, value) => value == null);
  }
}
