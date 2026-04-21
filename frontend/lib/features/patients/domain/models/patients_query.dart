class PatientsQuery {
  const PatientsQuery({
    this.search = '',
    this.gender,
    this.status,
    this.branchId,
    this.sort = 'latest',
    this.page = 1,
    this.perPage = 12,
  });

  final String search;
  final String? gender;
  final String? status;
  final int? branchId;
  final String sort;
  final int page;
  final int perPage;

  PatientsQuery copyWith({
    String? search,
    Object? gender = _sentinel,
    Object? status = _sentinel,
    Object? branchId = _sentinel,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return PatientsQuery(
      search: search ?? this.search,
      gender: gender == _sentinel ? this.gender : gender as String?,
      status: status == _sentinel ? this.status : status as String?,
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'search': search.isEmpty ? null : search,
      'gender': gender,
      'status': status,
      'branch_id': branchId,
      'sort': sort,
      'page': page,
      'per_page': perPage,
    }..removeWhere((key, value) => value == null);
  }
}

const _sentinel = Object();
