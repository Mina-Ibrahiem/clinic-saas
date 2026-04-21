class DoctorUpsertPayload {
  const DoctorUpsertPayload({
    required this.fullName,
    required this.specialization,
    this.userId,
    this.doctorCode,
    this.licenseNumber,
    this.consultationFee,
    this.bio,
    this.status,
    this.branchId,
  });

  final String fullName;
  final String specialization;
  final int? userId;
  final String? doctorCode;
  final String? licenseNumber;
  final double? consultationFee;
  final String? bio;
  final String? status;
  final int? branchId;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'doctor_code': doctorCode?.trim().isEmpty == true ? null : doctorCode?.trim(),
      'full_name': fullName.trim(),
      'specialization': specialization.trim(),
      'license_number': licenseNumber?.trim().isEmpty == true ? null : licenseNumber?.trim(),
      'consultation_fee': consultationFee,
      'bio': bio?.trim().isEmpty == true ? null : bio?.trim(),
      'status': status?.trim().isEmpty == true ? null : status?.trim(),
      'branch_id': branchId,
    }..removeWhere((key, value) => value == null);
  }
}
