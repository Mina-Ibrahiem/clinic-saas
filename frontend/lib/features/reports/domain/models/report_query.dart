class ReportQuery {
  const ReportQuery({
    this.page = 1,
    this.perPage = 15,
    this.branchId,
    this.status,
    this.paymentMethod,
    this.invoiceId,
    this.patientId,
    this.doctorId,
    this.serviceId,
    this.dateFrom,
    this.dateTo,
  });

  final int page;
  final int perPage;
  final int? branchId;
  final String? status;
  final String? paymentMethod;
  final int? invoiceId;
  final int? patientId;
  final int? doctorId;
  final int? serviceId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  ReportQuery copyWith({
    int? page,
    int? perPage,
    Object? branchId = _sentinel,
    Object? status = _sentinel,
    Object? paymentMethod = _sentinel,
    Object? invoiceId = _sentinel,
    Object? patientId = _sentinel,
    Object? doctorId = _sentinel,
    Object? serviceId = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
  }) {
    return ReportQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      status: status == _sentinel ? this.status : status as String?,
      paymentMethod: paymentMethod == _sentinel ? this.paymentMethod : paymentMethod as String?,
      invoiceId: invoiceId == _sentinel ? this.invoiceId : invoiceId as int?,
      patientId: patientId == _sentinel ? this.patientId : patientId as int?,
      doctorId: doctorId == _sentinel ? this.doctorId : doctorId as int?,
      serviceId: serviceId == _sentinel ? this.serviceId : serviceId as int?,
      dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    String? formatDate(DateTime? value) => value?.toIso8601String().split('T').first;
    return {
      'page': page,
      'per_page': perPage,
      'branch_id': branchId,
      'status': status,
      'payment_method': paymentMethod,
      'invoice_id': invoiceId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'service_id': serviceId,
      'date_from': formatDate(dateFrom),
      'date_to': formatDate(dateTo),
    }..removeWhere((key, value) => value == null);
  }
}

const _sentinel = Object();
