import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/report_models.dart';
import '../domain/models/report_query.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.read(apiClientProvider));
});

class ReportsRepository {
  ReportsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<RevenueReportResponse> fetchRevenue(ReportQuery query) async {
    return _get('/reports/revenue', query, RevenueReportResponse.fromJson);
  }

  Future<PaymentsReportResponse> fetchPayments(ReportQuery query) async {
    return _get('/reports/payments', query, PaymentsReportResponse.fromJson);
  }

  Future<AppointmentsReportResponse> fetchAppointments(ReportQuery query) async {
    return _get('/reports/appointments', query, AppointmentsReportResponse.fromJson);
  }

  Future<PatientsReportResponse> fetchPatients(ReportQuery query) async {
    return _get('/reports/patients', query, PatientsReportResponse.fromJson);
  }

  Future<DoctorsReportResponse> fetchDoctors(ReportQuery query) async {
    return _get('/reports/doctors', query, DoctorsReportResponse.fromJson);
  }

  Future<ServicesReportResponse> fetchServices(ReportQuery query) async {
    return _get('/reports/services', query, ServicesReportResponse.fromJson);
  }

  Future<T> _get<T>(
    String path,
    ReportQuery query,
    T Function(Map<String, dynamic> json) parser,
  ) async {
    final response = await _apiClient.get<T>(
      path,
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid report response for $path');
        }
        return parser(rawData);
      },
    );

    final data = response.data;
    if (data == null) {
      throw ApiException(message: 'Report data is empty for $path');
    }
    return data;
  }
}
