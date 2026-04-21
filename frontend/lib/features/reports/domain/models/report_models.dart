class ReportPagination {
  const ReportPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.from,
    this.to,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int? from;
  final int? to;

  factory ReportPagination.fromJson(Map<String, dynamic> json) {
    return ReportPagination(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      from: (json['from'] as num?)?.toInt(),
      to: (json['to'] as num?)?.toInt(),
    );
  }
}

class ReportReference {
  const ReportReference({
    required this.id,
    required this.label,
    this.code,
    this.extra,
  });

  final int id;
  final String label;
  final String? code;
  final String? extra;
}

class RevenueReportItem {
  const RevenueReportItem({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    this.issuedAt,
    this.dueAt,
    this.patient,
    this.branch,
  });

  final int id;
  final String invoiceNumber;
  final String status;
  final double total;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? issuedAt;
  final DateTime? dueAt;
  final ReportReference? patient;
  final ReportReference? branch;

  factory RevenueReportItem.fromJson(Map<String, dynamic> json) {
    final patientRaw = json['patient'];
    final branchRaw = json['branch'];
    return RevenueReportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      invoiceNumber: (json['invoice_number'] as String?) ?? '',
      status: (json['status'] as String?) ?? '-',
      issuedAt: DateTime.tryParse(json['issued_at']?.toString() ?? ''),
      dueAt: DateTime.tryParse(json['due_at']?.toString() ?? ''),
      total: _toDouble(json['total']),
      paidAmount: _toDouble(json['paid_amount']),
      remainingAmount: _toDouble(json['remaining_amount']),
      patient: patientRaw is Map<String, dynamic>
          ? ReportReference(
              id: (patientRaw['id'] as num?)?.toInt() ?? 0,
              label: (patientRaw['full_name'] as String?) ?? '',
              code: patientRaw['patient_code'] as String?,
            )
          : null,
      branch: branchRaw is Map<String, dynamic>
          ? ReportReference(
              id: (branchRaw['id'] as num?)?.toInt() ?? 0,
              label: (branchRaw['name'] as String?) ?? '',
              code: branchRaw['code'] as String?,
            )
          : null,
    );
  }
}

class PaymentsReportItem {
  const PaymentsReportItem({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    this.paymentDate,
    this.referenceNumber,
    this.invoice,
    this.patient,
    this.branch,
  });

  final int id;
  final double amount;
  final String paymentMethod;
  final DateTime? paymentDate;
  final String? referenceNumber;
  final ReportReference? invoice;
  final ReportReference? patient;
  final ReportReference? branch;

  factory PaymentsReportItem.fromJson(Map<String, dynamic> json) {
    final invoiceRaw = json['invoice'];
    final patientRaw = json['patient'];
    final branchRaw = json['branch'];
    return PaymentsReportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: _toDouble(json['amount']),
      paymentMethod: (json['payment_method'] as String?) ?? '',
      paymentDate: DateTime.tryParse(json['payment_date']?.toString() ?? ''),
      referenceNumber: json['reference_number'] as String?,
      invoice: invoiceRaw is Map<String, dynamic>
          ? ReportReference(
              id: (invoiceRaw['id'] as num?)?.toInt() ?? 0,
              label: (invoiceRaw['invoice_number'] as String?) ?? '',
              code: invoiceRaw['status'] as String?,
              extra: invoiceRaw['total']?.toString(),
            )
          : null,
      patient: patientRaw is Map<String, dynamic>
          ? ReportReference(
              id: (patientRaw['id'] as num?)?.toInt() ?? 0,
              label: (patientRaw['full_name'] as String?) ?? '',
              code: patientRaw['patient_code'] as String?,
            )
          : null,
      branch: branchRaw is Map<String, dynamic>
          ? ReportReference(
              id: (branchRaw['id'] as num?)?.toInt() ?? 0,
              label: (branchRaw['name'] as String?) ?? '',
              code: branchRaw['code'] as String?,
            )
          : null,
    );
  }
}

class AppointmentsReportItem {
  const AppointmentsReportItem({
    required this.id,
    required this.status,
    this.appointmentDate,
    this.startTime,
    this.endTime,
    this.patient,
    this.doctor,
    this.service,
    this.branch,
  });

  final int id;
  final String status;
  final DateTime? appointmentDate;
  final String? startTime;
  final String? endTime;
  final ReportReference? patient;
  final ReportReference? doctor;
  final ReportReference? service;
  final ReportReference? branch;

  factory AppointmentsReportItem.fromJson(Map<String, dynamic> json) {
    ReportReference? mapRef(Map<String, dynamic>? raw, String labelField, {String? codeField}) {
      if (raw == null) return null;
      return ReportReference(
        id: (raw['id'] as num?)?.toInt() ?? 0,
        label: (raw[labelField] as String?) ?? '',
        code: codeField != null ? raw[codeField] as String? : null,
      );
    }

    return AppointmentsReportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? '',
      appointmentDate: DateTime.tryParse(json['appointment_date']?.toString() ?? ''),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      patient: mapRef((json['patient'] as Map<String, dynamic>?), 'full_name', codeField: 'patient_code'),
      doctor: mapRef((json['doctor'] as Map<String, dynamic>?), 'full_name', codeField: 'doctor_code'),
      service: mapRef((json['service'] as Map<String, dynamic>?), 'name', codeField: 'code'),
      branch: mapRef((json['branch'] as Map<String, dynamic>?), 'name', codeField: 'code'),
    );
  }
}

class PatientsReportItem {
  const PatientsReportItem({
    required this.id,
    required this.fullName,
    required this.status,
    this.patientCode,
    this.gender,
    this.phone,
    this.createdAt,
    this.branch,
  });

  final int id;
  final String fullName;
  final String status;
  final String? patientCode;
  final String? gender;
  final String? phone;
  final DateTime? createdAt;
  final ReportReference? branch;

  factory PatientsReportItem.fromJson(Map<String, dynamic> json) {
    final branchRaw = json['branch'];
    return PatientsReportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: (json['full_name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      patientCode: json['patient_code'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      branch: branchRaw is Map<String, dynamic>
          ? ReportReference(
              id: (branchRaw['id'] as num?)?.toInt() ?? 0,
              label: (branchRaw['name'] as String?) ?? '',
              code: branchRaw['code'] as String?,
            )
          : null,
    );
  }
}

class DoctorsReportItem {
  const DoctorsReportItem({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.status,
    required this.appointmentsCount,
    required this.revenueContribution,
    this.doctorCode,
    this.branch,
  });

  final int id;
  final String fullName;
  final String specialization;
  final String status;
  final int appointmentsCount;
  final double revenueContribution;
  final String? doctorCode;
  final ReportReference? branch;

  factory DoctorsReportItem.fromJson(Map<String, dynamic> json) {
    final branchRaw = json['branch'];
    return DoctorsReportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: (json['full_name'] as String?) ?? '',
      specialization: (json['specialization'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      appointmentsCount: (json['appointments_count'] as num?)?.toInt() ?? 0,
      revenueContribution: _toDouble(json['revenue_contribution']),
      doctorCode: json['doctor_code'] as String?,
      branch: branchRaw is Map<String, dynamic>
          ? ReportReference(
              id: (branchRaw['id'] as num?)?.toInt() ?? 0,
              label: (branchRaw['name'] as String?) ?? '',
              code: branchRaw['code'] as String?,
            )
          : null,
    );
  }
}

class ServicesReportItem {
  const ServicesReportItem({
    required this.id,
    required this.name,
    required this.status,
    required this.appointmentsCount,
    required this.revenue,
    this.code,
    this.branch,
  });

  final int id;
  final String name;
  final String status;
  final int appointmentsCount;
  final double revenue;
  final String? code;
  final ReportReference? branch;

  factory ServicesReportItem.fromJson(Map<String, dynamic> json) {
    final branchRaw = json['branch'];
    return ServicesReportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      appointmentsCount: (json['appointments_count'] as num?)?.toInt() ?? 0,
      revenue: _toDouble(json['revenue']),
      code: json['code'] as String?,
      branch: branchRaw is Map<String, dynamic>
          ? ReportReference(
              id: (branchRaw['id'] as num?)?.toInt() ?? 0,
              label: (branchRaw['name'] as String?) ?? '',
              code: branchRaw['code'] as String?,
            )
          : null,
    );
  }
}

class RevenueReportResponse {
  const RevenueReportResponse({
    required this.summary,
    required this.items,
    required this.pagination,
  });

  final Map<String, dynamic> summary;
  final List<RevenueReportItem> items;
  final ReportPagination pagination;

  factory RevenueReportResponse.fromJson(Map<String, dynamic> json) {
    return RevenueReportResponse(
      summary: (json['summary'] as Map<String, dynamic>?) ?? const {},
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RevenueReportItem.fromJson)
          .toList(growable: false),
      pagination: ReportPagination.fromJson((json['pagination'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}

class PaymentsReportResponse {
  const PaymentsReportResponse({
    required this.summary,
    required this.items,
    required this.pagination,
  });

  final Map<String, dynamic> summary;
  final List<PaymentsReportItem> items;
  final ReportPagination pagination;

  factory PaymentsReportResponse.fromJson(Map<String, dynamic> json) {
    return PaymentsReportResponse(
      summary: (json['summary'] as Map<String, dynamic>?) ?? const {},
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PaymentsReportItem.fromJson)
          .toList(growable: false),
      pagination: ReportPagination.fromJson((json['pagination'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}

class AppointmentsReportResponse {
  const AppointmentsReportResponse({
    required this.summary,
    required this.items,
    required this.pagination,
  });

  final Map<String, dynamic> summary;
  final List<AppointmentsReportItem> items;
  final ReportPagination pagination;

  factory AppointmentsReportResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentsReportResponse(
      summary: (json['summary'] as Map<String, dynamic>?) ?? const {},
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AppointmentsReportItem.fromJson)
          .toList(growable: false),
      pagination: ReportPagination.fromJson((json['pagination'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}

class PatientsReportResponse {
  const PatientsReportResponse({
    required this.summary,
    required this.items,
    required this.pagination,
  });

  final Map<String, dynamic> summary;
  final List<PatientsReportItem> items;
  final ReportPagination pagination;

  factory PatientsReportResponse.fromJson(Map<String, dynamic> json) {
    return PatientsReportResponse(
      summary: (json['summary'] as Map<String, dynamic>?) ?? const {},
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PatientsReportItem.fromJson)
          .toList(growable: false),
      pagination: ReportPagination.fromJson((json['pagination'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}

class DoctorsReportResponse {
  const DoctorsReportResponse({
    required this.summary,
    required this.items,
    required this.pagination,
  });

  final Map<String, dynamic> summary;
  final List<DoctorsReportItem> items;
  final ReportPagination pagination;

  factory DoctorsReportResponse.fromJson(Map<String, dynamic> json) {
    return DoctorsReportResponse(
      summary: (json['summary'] as Map<String, dynamic>?) ?? const {},
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DoctorsReportItem.fromJson)
          .toList(growable: false),
      pagination: ReportPagination.fromJson((json['pagination'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}

class ServicesReportResponse {
  const ServicesReportResponse({
    required this.summary,
    required this.items,
    required this.pagination,
  });

  final Map<String, dynamic> summary;
  final List<ServicesReportItem> items;
  final ReportPagination pagination;

  factory ServicesReportResponse.fromJson(Map<String, dynamic> json) {
    return ServicesReportResponse(
      summary: (json['summary'] as Map<String, dynamic>?) ?? const {},
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ServicesReportItem.fromJson)
          .toList(growable: false),
      pagination: ReportPagination.fromJson((json['pagination'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}

double _toDouble(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0;
}
