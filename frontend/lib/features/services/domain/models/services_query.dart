class ServicesQuery {
  const ServicesQuery({
    this.search = '',
    this.status,
    this.branchId,
    this.minPrice,
    this.maxPrice,
    this.sort = 'latest',
    this.page = 1,
    this.perPage = 12,
  });

  final String search;
  final String? status;
  final int? branchId;
  final double? minPrice;
  final double? maxPrice;
  final String sort;
  final int page;
  final int perPage;

  ServicesQuery copyWith({
    String? search,
    Object? status = _sentinel,
    Object? branchId = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return ServicesQuery(
      search: search ?? this.search,
      status: status == _sentinel ? this.status : status as String?,
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      minPrice: minPrice == _sentinel ? this.minPrice : minPrice as double?,
      maxPrice: maxPrice == _sentinel ? this.maxPrice : maxPrice as double?,
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
      'min_price': minPrice,
      'max_price': maxPrice,
      'sort': sort,
      'page': page,
      'per_page': perPage,
    }..removeWhere((key, value) => value == null);
  }
}

const _sentinel = Object();
