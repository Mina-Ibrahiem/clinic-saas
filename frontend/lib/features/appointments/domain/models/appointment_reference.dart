class AppointmentReference {
  const AppointmentReference({
    required this.id,
    required this.label,
    this.code,
    this.extra,
  });

  final int id;
  final String label;
  final String? code;
  final String? extra;

  factory AppointmentReference.fromPatientJson(Map<String, dynamic> json) {
    return AppointmentReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['full_name'] as String?) ?? '',
      code: (json['patient_code'] as String?),
      extra: (json['phone'] as String?),
    );
  }

  factory AppointmentReference.fromDoctorJson(Map<String, dynamic> json) {
    return AppointmentReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['full_name'] as String?) ?? '',
      code: (json['doctor_code'] as String?),
      extra: (json['specialization'] as String?),
    );
  }

  factory AppointmentReference.fromServiceJson(Map<String, dynamic> json) {
    return AppointmentReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['code'] as String?),
      extra: null,
    );
  }

  factory AppointmentReference.fromBranchJson(Map<String, dynamic> json) {
    return AppointmentReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['code'] as String?),
      extra: null,
    );
  }
}
