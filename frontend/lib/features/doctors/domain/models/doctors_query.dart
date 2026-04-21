class DoctorsQuery {
  const DoctorsQuery({
    this.search = '',
    this.status,
    this.branchId,
    this.specialization,
    this.sort = 'latest',
    this.page = 1,
    this.perPage = 12,
  });

  final String search;
  final String? status;
  final int? branchId;
  final String? specialization;
  final String sort;
  final int page;
  final int perPage;

  DoctorsQuery copyWith({
    String? search,
    Object? status = _sentinel,
    Object? branchId = _sentinel,
    Object? specialization = _sentinel,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return DoctorsQuery(
      search: search ?? this.search,
      status: status == _sentinel ? this.status : status as String?,
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      specialization: specialization == _sentinel ? this.specialization : specialization as String?,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'search': search.isEmpty ? null : search,
      'status': status,
      'branch_id': branchId,
      'specialization': specialization?.trim().isEmpty == true ? null : specialization?.trim(),
      'sort': sort,
      'page': page,
      'per_page': perPage,
    }..removeWhere((key, value) => value == null);
  }
}

const _sentinel = Object();
