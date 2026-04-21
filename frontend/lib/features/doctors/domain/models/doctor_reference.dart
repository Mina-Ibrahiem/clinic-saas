class DoctorReference {
  const DoctorReference({
    required this.id,
    required this.label,
    this.code,
    this.extra,
  });

  final int id;
  final String label;
  final String? code;
  final String? extra;

  factory DoctorReference.fromUserJson(Map<String, dynamic> json) {
    return DoctorReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['full_name'] as String?) ?? '',
      code: (json['email'] as String?),
      extra: (json['phone'] as String?),
    );
  }

  factory DoctorReference.fromBranchJson(Map<String, dynamic> json) {
    return DoctorReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['code'] as String?),
      extra: null,
    );
  }

  factory DoctorReference.fromTenantJson(Map<String, dynamic> json) {
    return DoctorReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['slug'] as String?),
      extra: (json['uuid'] as String?),
    );
  }
}
