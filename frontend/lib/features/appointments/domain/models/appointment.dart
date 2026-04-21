import 'appointment_reference.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.status,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.tenantId,
    this.branchId,
    this.patientId,
    this.doctorId,
    this.serviceId,
    this.notes,
    this.patient,
    this.doctor,
    this.service,
    this.branch,
  });

  final int id;
  final String status;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final int? tenantId;
  final int? branchId;
  final int? patientId;
  final int? doctorId;
  final int? serviceId;
  final String? notes;
  final AppointmentReference? patient;
  final AppointmentReference? doctor;
  final AppointmentReference? service;
  final AppointmentReference? branch;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(Object? raw) {
      final parsed = DateTime.tryParse(raw?.toString() ?? '');
      return parsed ?? DateTime.now();
    }

    final patientRaw = json['patient'];
    final doctorRaw = json['doctor'];
    final serviceRaw = json['service'];
    final branchRaw = json['branch'];

    return Appointment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'booked',
      appointmentDate: parseDate(json['appointment_date']),
      startTime: (json['start_time'] as String?) ?? '',
      endTime: (json['end_time'] as String?) ?? '',
      tenantId: (json['tenant_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      patientId: (json['patient_id'] as num?)?.toInt(),
      doctorId: (json['doctor_id'] as num?)?.toInt(),
      serviceId: (json['service_id'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      patient: patientRaw is Map<String, dynamic> ? AppointmentReference.fromPatientJson(patientRaw) : null,
      doctor: doctorRaw is Map<String, dynamic> ? AppointmentReference.fromDoctorJson(doctorRaw) : null,
      service: serviceRaw is Map<String, dynamic> ? AppointmentReference.fromServiceJson(serviceRaw) : null,
      branch: branchRaw is Map<String, dynamic> ? AppointmentReference.fromBranchJson(branchRaw) : null,
    );
  }
}
