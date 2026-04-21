import 'doctor_reference.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.status,
    this.tenantId,
    this.branchId,
    this.userId,
    this.doctorCode,
    this.licenseNumber,
    this.consultationFee,
    this.bio,
    this.appointmentsCount,
    this.notesCount,
    this.user,
    this.branch,
    this.tenant,
  });

  final int id;
  final String fullName;
  final String specialization;
  final String status;
  final int? tenantId;
  final int? branchId;
  final int? userId;
  final String? doctorCode;
  final String? licenseNumber;
  final double? consultationFee;
  final String? bio;
  final int? appointmentsCount;
  final int? notesCount;
  final DoctorReference? user;
  final DoctorReference? branch;
  final DoctorReference? tenant;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    final userRaw = json['user'];
    final branchRaw = json['branch'];
    final tenantRaw = json['tenant'];
    final stats = statsRaw is Map<String, dynamic> ? statsRaw : const <String, dynamic>{};

    return Doctor(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tenantId: (json['tenant_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      doctorCode: json['doctor_code'] as String?,
      fullName: (json['full_name'] as String?) ?? '',
      specialization: (json['specialization'] as String?) ?? '',
      licenseNumber: json['license_number'] as String?,
      consultationFee: _toDoubleOrNull(json['consultation_fee']),
      bio: json['bio'] as String?,
      status: (json['status'] as String?) ?? 'active',
      appointmentsCount: (stats['appointments_count'] as num?)?.toInt(),
      notesCount: (stats['notes_count'] as num?)?.toInt(),
      user: userRaw is Map<String, dynamic> ? DoctorReference.fromUserJson(userRaw) : null,
      branch: branchRaw is Map<String, dynamic> ? DoctorReference.fromBranchJson(branchRaw) : null,
      tenant: tenantRaw is Map<String, dynamic> ? DoctorReference.fromTenantJson(tenantRaw) : null,
    );
  }
}

double? _toDoubleOrNull(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString());
}
