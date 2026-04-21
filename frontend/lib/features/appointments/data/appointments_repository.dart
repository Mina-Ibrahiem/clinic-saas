import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/appointment.dart';
import '../domain/models/appointment_pagination.dart';
import '../domain/models/appointments_page.dart';
import '../domain/models/appointments_query.dart';
import '../domain/models/appointment_upsert_payload.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepository(ref.read(apiClientProvider));
});

class AppointmentsRepository {
  AppointmentsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AppointmentsPage> list(AppointmentsQuery query) async {
    final response = await _apiClient.get<AppointmentsPage>(
      '/appointments',
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid appointments list response.');
        }
        return AppointmentsPage.fromJson(rawData);
      },
    );

    return response.data ??
        const AppointmentsPage(
          items: [],
          pagination: AppointmentPagination(
            currentPage: 1,
            perPage: 15,
            total: 0,
            lastPage: 1,
          ),
        );
  }

  Future<Appointment> getById(int id) async {
    final response = await _apiClient.get<Appointment>(
      '/appointments/$id',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid appointment details response.');
        }
        return Appointment.fromJson(rawData);
      },
    );

    final appointment = response.data;
    if (appointment == null) {
      throw ApiException(message: 'Appointment details are empty.');
    }
    return appointment;
  }

  Future<Appointment> create(AppointmentUpsertPayload payload) async {
    final response = await _apiClient.post<Appointment>(
      '/appointments',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid create appointment response.');
        }
        return Appointment.fromJson(rawData);
      },
    );

    final appointment = response.data;
    if (appointment == null) {
      throw ApiException(message: 'Created appointment payload is empty.');
    }
    return appointment;
  }

  Future<Appointment> update({
    required int id,
    required AppointmentUpsertPayload payload,
  }) async {
    final response = await _apiClient.put<Appointment>(
      '/appointments/$id',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid update appointment response.');
        }
        return Appointment.fromJson(rawData);
      },
    );

    final appointment = response.data;
    if (appointment == null) {
      throw ApiException(message: 'Updated appointment payload is empty.');
    }
    return appointment;
  }

  Future<void> delete(int id) async {
    await _apiClient.delete<Object?>(
      '/appointments/$id',
      mapper: (_) => null,
    );
  }
}
