import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardOverview> fetchOverview({int? branchId}) async {
    final response = await _apiClient.get<DashboardOverview>(
      '/dashboard/overview',
      queryParameters: {
        'branch_id': branchId,
      }..removeWhere((key, value) => value == null),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid dashboard overview response.');
        }
        return DashboardOverview.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Dashboard overview is empty.');
    }
    return data;
  }

  Future<DashboardRevenueSummary> fetchRevenueSummary({
    int? branchId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _apiClient.get<DashboardRevenueSummary>(
      '/dashboard/revenue-summary',
      queryParameters: {
        'branch_id': branchId,
        'date_from': _formatDate(dateFrom),
        'date_to': _formatDate(dateTo),
      }..removeWhere((key, value) => value == null),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid revenue summary response.');
        }
        return DashboardRevenueSummary.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Revenue summary is empty.');
    }
    return data;
  }

  Future<DashboardAppointmentsSummary> fetchAppointmentsSummary({
    int? branchId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _apiClient.get<DashboardAppointmentsSummary>(
      '/dashboard/appointments-summary',
      queryParameters: {
        'branch_id': branchId,
        'date_from': _formatDate(dateFrom),
        'date_to': _formatDate(dateTo),
      }..removeWhere((key, value) => value == null),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid appointments summary response.');
        }
        return DashboardAppointmentsSummary.fromJson(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Appointments summary is empty.');
    }
    return data;
  }
}

String? _formatDate(DateTime? value) => value?.toIso8601String().split('T').first;
