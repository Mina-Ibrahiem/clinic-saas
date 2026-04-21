import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reports_repository.dart';
import '../../domain/models/report_models.dart';
import '../../domain/models/report_query.dart';

final revenueReportQueryProvider = StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());
final paymentsReportQueryProvider = StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());
final appointmentsReportQueryProvider = StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());
final patientsReportQueryProvider = StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());
final doctorsReportQueryProvider = StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());
final servicesReportQueryProvider = StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());

final revenueReportProvider = FutureProvider.autoDispose<RevenueReportResponse>((ref) async {
  final query = ref.watch(revenueReportQueryProvider);
  return ref.read(reportsRepositoryProvider).fetchRevenue(query);
});

final paymentsReportProvider = FutureProvider.autoDispose<PaymentsReportResponse>((ref) async {
  final query = ref.watch(paymentsReportQueryProvider);
  return ref.read(reportsRepositoryProvider).fetchPayments(query);
});

final appointmentsReportProvider = FutureProvider.autoDispose<AppointmentsReportResponse>((ref) async {
  final query = ref.watch(appointmentsReportQueryProvider);
  return ref.read(reportsRepositoryProvider).fetchAppointments(query);
});

final patientsReportProvider = FutureProvider.autoDispose<PatientsReportResponse>((ref) async {
  final query = ref.watch(patientsReportQueryProvider);
  return ref.read(reportsRepositoryProvider).fetchPatients(query);
});

final doctorsReportProvider = FutureProvider.autoDispose<DoctorsReportResponse>((ref) async {
  final query = ref.watch(doctorsReportQueryProvider);
  return ref.read(reportsRepositoryProvider).fetchDoctors(query);
});

final servicesReportProvider = FutureProvider.autoDispose<ServicesReportResponse>((ref) async {
  final query = ref.watch(servicesReportQueryProvider);
  return ref.read(reportsRepositoryProvider).fetchServices(query);
});
