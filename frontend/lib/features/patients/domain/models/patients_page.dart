import 'patient.dart';
import 'patient_pagination.dart';

class PatientsPage {
  const PatientsPage({
    required this.items,
    required this.pagination,
  });

  final List<Patient> items;
  final PatientPagination pagination;

  factory PatientsPage.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final pageRaw = json['pagination'];
    final parsedItems = itemsRaw is List
        ? itemsRaw
            .whereType<Map<String, dynamic>>()
            .map(Patient.fromJson)
            .toList(growable: false)
        : const <Patient>[];

    return PatientsPage(
      items: parsedItems,
      pagination: pageRaw is Map<String, dynamic>
          ? PatientPagination.fromJson(pageRaw)
          : const PatientPagination(
              currentPage: 1,
              perPage: 15,
              total: 0,
              lastPage: 1,
            ),
    );
  }
}
