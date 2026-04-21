import 'doctor.dart';
import 'doctor_pagination.dart';

class DoctorsPage {
  const DoctorsPage({
    required this.items,
    required this.pagination,
  });

  final List<Doctor> items;
  final DoctorPagination pagination;

  factory DoctorsPage.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final pageRaw = json['pagination'];

    return DoctorsPage(
      items: itemsRaw is List
          ? itemsRaw.whereType<Map<String, dynamic>>().map(Doctor.fromJson).toList(growable: false)
          : const <Doctor>[],
      pagination: pageRaw is Map<String, dynamic>
          ? DoctorPagination.fromJson(pageRaw)
          : const DoctorPagination(
              currentPage: 1,
              perPage: 15,
              total: 0,
              lastPage: 1,
            ),
    );
  }
}
