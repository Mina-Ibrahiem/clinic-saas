class PaymentQuery {
  const PaymentQuery({
    this.search = '',
    this.paymentMethod,
    this.branchId,
    this.invoiceId,
    this.dateFrom,
    this.dateTo,
    this.sort = 'latest',
    this.page = 1,
    this.perPage = 15,
  });

  final String search;
  final String? paymentMethod;
  final int? branchId;
  final int? invoiceId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String sort;
  final int page;
  final int perPage;

  PaymentQuery copyWith({
    String? search,
    Object? paymentMethod = _sentinel,
    Object? branchId = _sentinel,
    Object? invoiceId = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return PaymentQuery(
      search: search ?? this.search,
      paymentMethod: paymentMethod == _sentinel ? this.paymentMethod : paymentMethod as String?,
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      invoiceId: invoiceId == _sentinel ? this.invoiceId : invoiceId as int?,
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
      'payment_method': paymentMethod,
      'branch_id': branchId,
      'invoice_id': invoiceId,
      'date_from': dateFrom != null ? formatDate(dateFrom!) : null,
      'date_to': dateTo != null ? formatDate(dateTo!) : null,
      'sort': sort,
      'page': page,
      'per_page': perPage,
    }..removeWhere((key, value) => value == null);
  }
}

const _sentinel = Object();
