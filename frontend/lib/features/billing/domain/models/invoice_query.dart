class InvoiceQuery {
  const InvoiceQuery({
    this.search = '',
    this.status,
    this.patientId,
    this.appointmentId,
    this.branchId,
    this.dateFrom,
    this.dateTo,
    this.sort = 'latest',
    this.page = 1,
    this.perPage = 12,
  });

  final String search;
  final String? status;
  final int? patientId;
  final int? appointmentId;
  final int? branchId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String sort;
  final int page;
  final int perPage;

  InvoiceQuery copyWith({
    String? search,
    Object? status = _sentinel,
    Object? patientId = _sentinel,
    Object? appointmentId = _sentinel,
    Object? branchId = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return InvoiceQuery(
      search: search ?? this.search,
      status: status == _sentinel ? this.status : status as String?,
      patientId: patientId == _sentinel ? this.patientId : patientId as int?,
      appointmentId: appointmentId == _sentinel ? this.appointmentId : appointmentId as int?,
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    String formatDate(DateTime value) => value.toIso8601String().split('T').first;

    return {
      'search': search.isEmpty ? null : search,
      'status': status,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'branch_id': branchId,
      'date_from': dateFrom != null ? formatDate(dateFrom!) : null,
      'date_to': dateTo != null ? formatDate(dateTo!) : null,
      'sort': sort,
      'page': page,
      'per_page': perPage,
    }..removeWhere((key, value) => value == null);
  }
}

const _sentinel = Object();
