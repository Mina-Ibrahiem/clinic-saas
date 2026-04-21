class ServiceUpsertPayload {
  const ServiceUpsertPayload({
    required this.name,
    required this.price,
    this.code,
    this.description,
    this.durationMinutes,
    this.status,
    this.branchId,
  });

  final String name;
  final double price;
  final String? code;
  final String? description;
  final int? durationMinutes;
  final String? status;
  final int? branchId;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'code': code?.trim().isEmpty == true ? null : code?.trim(),
      'description': description?.trim().isEmpty == true ? null : description?.trim(),
      'price': price,
      'duration_minutes': durationMinutes,
      'status': status?.trim().isEmpty == true ? null : status?.trim(),
      'branch_id': branchId,
    }..removeWhere((key, value) => value == null);
  }
}
