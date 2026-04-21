class Patient {
  const Patient({
    required this.id,
    required this.patientCode,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.status,
    this.tenantId,
    this.branchId,
    this.dateOfBirth,
    this.email,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.bloodGroup,
    this.allergies,
    this.medicalNotes,
    this.branchName,
    this.tenantName,
    this.appointmentsCount,
    this.invoicesCount,
    this.notesCount,
  });

  final int id;
  final String patientCode;
  final String fullName;
  final String phone;
  final String gender;
  final String status;
  final int? tenantId;
  final int? branchId;
  final DateTime? dateOfBirth;
  final String? email;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? bloodGroup;
  final String? allergies;
  final String? medicalNotes;
  final String? branchName;
  final String? tenantName;
  final int? appointmentsCount;
  final int? invoicesCount;
  final int? notesCount;

  factory Patient.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final stats = json['stats'] as Map<String, dynamic>?;
    final branch = json['branch'] as Map<String, dynamic>?;
    final tenant = json['tenant'] as Map<String, dynamic>?;

    return Patient(
      id: (json['id'] as num?)?.toInt() ?? 0,
      patientCode: (json['patient_code'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? 'unknown',
      status: (json['status'] as String?) ?? 'active',
      tenantId: (json['tenant_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      dateOfBirth: parseDate(json['date_of_birth']),
      email: json['email'] as String?,
      address: json['address'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      bloodGroup: json['blood_group'] as String?,
      allergies: json['allergies'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      branchName: branch?['name']?.toString(),
      tenantName: tenant?['name']?.toString(),
      appointmentsCount: (stats?['appointments_count'] as num?)?.toInt(),
      invoicesCount: (stats?['invoices_count'] as num?)?.toInt(),
      notesCount: (stats?['notes_count'] as num?)?.toInt(),
    );
  }
}
