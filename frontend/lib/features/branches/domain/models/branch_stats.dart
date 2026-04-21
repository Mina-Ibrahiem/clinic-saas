class BranchStats {
  const BranchStats({
    required this.usersCount,
    required this.patientsCount,
    required this.doctorsCount,
    required this.appointmentsCount,
    required this.invoicesCount,
  });

  final int usersCount;
  final int patientsCount;
  final int doctorsCount;
  final int appointmentsCount;
  final int invoicesCount;

  factory BranchStats.fromJson(Map<String, dynamic> json) {
    return BranchStats(
      usersCount: (json['users_count'] as num?)?.toInt() ?? 0,
      patientsCount: (json['patients_count'] as num?)?.toInt() ?? 0,
      doctorsCount: (json['doctors_count'] as num?)?.toInt() ?? 0,
      appointmentsCount: (json['appointments_count'] as num?)?.toInt() ?? 0,
      invoicesCount: (json['invoices_count'] as num?)?.toInt() ?? 0,
    );
  }

  int get totalLinked =>
      usersCount + patientsCount + doctorsCount + appointmentsCount + invoicesCount;
}
