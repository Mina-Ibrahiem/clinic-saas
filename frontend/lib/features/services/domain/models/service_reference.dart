class ServiceReference {
  const ServiceReference({
    required this.id,
    required this.label,
    this.code,
    this.extra,
  });

  final int id;
  final String label;
  final String? code;
  final String? extra;

  factory ServiceReference.fromBranchJson(Map<String, dynamic> json) {
    return ServiceReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['code'] as String?),
      extra: null,
    );
  }

  factory ServiceReference.fromTenantJson(Map<String, dynamic> json) {
    return ServiceReference(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['name'] as String?) ?? '',
      code: (json['slug'] as String?),
      extra: (json['uuid'] as String?),
    );
  }
}
