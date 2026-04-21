class AppointmentsQuery {
  const AppointmentsQuery({
    this.search = '',
    this.doctorId,
    this.patientId,
    this.serviceId,
    this.status,
    this.branchId,
    this.appointmentDate,
    this.dateFrom,
    this.dateTo,
    this.sort = 'latest',
    this.page = 1,
    this.perPage = 12,
  });

  final String search;
  final int? doctorId;
  final int? patientId;
  final int? serviceId;
  final String? status;
  final int? branchId;
  final DateTime? appointmentDate;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String sort;
  final int page;
  final int perPage;

  AppointmentsQuery copyWith({
    String? search,
    Object? doctorId = _sentinel,
    Object? patientId = _sentinel,
    Object? serviceId = _sentinel,
    Object? status = _sentinel,
    Object? branchId = _sentinel,
    Object? appointmentDate = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return AppointmentsQuery(
      search: search ?? this.search,
      doctorId: doctorId == _sentinel ? this.doctorId : doctorId as int?,
      patientId: patientId == _sentinel ? this.patientId : patientId as int?,
      serviceId: serviceId == _sentinel ? this.serviceId : serviceId as int?,
      status: status == _sentinel ? this.status : status as String?,
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      appointmentDate: appointmentDate == _sentinel ? this.appointmentDate : appointmentDate as DateTime?,
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
      'doctor_id': doctorId,
      'patient_id': patientId,
      'service_id': serviceId,
      'status': status,
      'branch_id': branchId,
      'appointment_date': appointmentDate != null ? formatDate(appointmentDate!) : null,
      'date_from': dateFrom != null ? formatDate(dateFrom!) : null,
      'date_to': dateTo != null ? formatDate(dateTo!) : null,
      'sort': sort,
      'page': page,
      'per_page': perPage,
    }..removeWhere((key, value) => value == null);
  }
}

const _sentinel = Object();
