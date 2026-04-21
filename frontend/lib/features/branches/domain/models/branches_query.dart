class BranchesQuery {
  const BranchesQuery({
    this.search,
    this.status,
    this.sort = 'latest',
    this.page = 1,
    this.perPage = 15,
  });

  final String? search;
  final String? status;
  final String sort;
  final int page;
  final int perPage;

  BranchesQuery copyWith({
    Object? search = _sentinel,
    Object? status = _sentinel,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return BranchesQuery(
      search: search == _sentinel ? this.search : search as String?,
      status: status == _sentinel ? this.status : status as String?,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort': sort,
    };
    final s = search?.trim();
    if (s != null && s.isNotEmpty) map['search'] = s;
    final st = status?.trim();
    if (st != null && st.isNotEmpty) map['status'] = st;
    return map;
  }
}

const _sentinel = Object();
