import 'appointment.dart';
import 'appointment_pagination.dart';

class AppointmentsPage {
  const AppointmentsPage({
    required this.items,
    required this.pagination,
  });

  final List<Appointment> items;
  final AppointmentPagination pagination;

  factory AppointmentsPage.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final pageRaw = json['pagination'];

    return AppointmentsPage(
      items: itemsRaw is List
          ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map(Appointment.fromJson)
              .toList(growable: false)
          : const <Appointment>[],
      pagination: pageRaw is Map<String, dynamic>
          ? AppointmentPagination.fromJson(pageRaw)
          : const AppointmentPagination(
              currentPage: 1,
              perPage: 15,
              total: 0,
              lastPage: 1,
            ),
    );
  }
}
