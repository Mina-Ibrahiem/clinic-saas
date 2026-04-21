import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dashboard_repository.dart';
import '../../domain/models/dashboard_models.dart';

class DashboardFilters {
  const DashboardFilters({
    this.branchId,
    this.dateFrom,
    this.dateTo,
  });

  final int? branchId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  DashboardFilters copyWith({
    Object? branchId = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
  }) {
    return DashboardFilters(
      branchId: branchId == _sentinel ? this.branchId : branchId as int?,
      dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
    );
  }
}

const _sentinel = Object();

final dashboardFiltersProvider = StateProvider.autoDispose<DashboardFilters>((ref) {
  return const DashboardFilters();
});

final dashboardOverviewProvider = FutureProvider.autoDispose<DashboardOverview>((ref) async {
  final filters = ref.watch(dashboardFiltersProvider);
  return ref.read(dashboardRepositoryProvider).fetchOverview(branchId: filters.branchId);
});

final dashboardRevenueSummaryProvider = FutureProvider.autoDispose<DashboardRevenueSummary>((ref) async {
  final filters = ref.watch(dashboardFiltersProvider);
  return ref.read(dashboardRepositoryProvider).fetchRevenueSummary(
        branchId: filters.branchId,
        dateFrom: filters.dateFrom,
        dateTo: filters.dateTo,
      );
});

final dashboardAppointmentsSummaryProvider = FutureProvider.autoDispose<DashboardAppointmentsSummary>((ref) async {
  final filters = ref.watch(dashboardFiltersProvider);
  return ref.read(dashboardRepositoryProvider).fetchAppointmentsSummary(
        branchId: filters.branchId,
        dateFrom: filters.dateFrom,
        dateTo: filters.dateTo,
      );
});
