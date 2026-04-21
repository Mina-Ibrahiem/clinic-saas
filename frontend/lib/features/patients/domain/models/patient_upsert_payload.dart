class PatientUpsertPayload {
  const PatientUpsertPayload({
    required this.fullName,
    required this.phone,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.bloodGroup,
    this.allergies,
    this.medicalNotes,
    this.status,
    this.branchId,
  });

  final String fullName;
  final String phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? email;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? bloodGroup;
  final String? allergies;
  final String? medicalNotes;
  final String? status;
  final int? branchId;

  Map<String, dynamic> toJson() {
    String? trimOrNull(String? value) {
      if (value == null) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return {
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'gender': trimOrNull(gender),
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'email': trimOrNull(email),
      'address': trimOrNull(address),
      'emergency_contact_name': trimOrNull(emergencyContactName),
      'emergency_contact_phone': trimOrNull(emergencyContactPhone),
      'blood_group': trimOrNull(bloodGroup),
      'allergies': trimOrNull(allergies),
      'medical_notes': trimOrNull(medicalNotes),
      'status': trimOrNull(status),
      'branch_id': branchId,
    }..removeWhere((key, value) => value == null);
  }
}
