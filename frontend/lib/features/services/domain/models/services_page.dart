import 'service.dart';
import 'service_pagination.dart';

class ServicesPage {
  const ServicesPage({
    required this.items,
    required this.pagination,
  });

  final List<Service> items;
  final ServicePagination pagination;

  factory ServicesPage.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final pageRaw = json['pagination'];

    return ServicesPage(
      items: itemsRaw is List
          ? itemsRaw.whereType<Map<String, dynamic>>().map(Service.fromJson).toList(growable: false)
          : const <Service>[],
      pagination: pageRaw is Map<String, dynamic>
          ? ServicePagination.fromJson(pageRaw)
          : const ServicePagination(
              currentPage: 1,
              perPage: 15,
              total: 0,
              lastPage: 1,
            ),
    );
  }
}
