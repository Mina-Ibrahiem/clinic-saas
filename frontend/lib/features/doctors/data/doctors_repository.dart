import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/doctor.dart';
import '../domain/models/doctor_pagination.dart';
import '../domain/models/doctor_upsert_payload.dart';
import '../domain/models/doctors_page.dart';
import '../domain/models/doctors_query.dart';

final doctorsRepositoryProvider = Provider<DoctorsRepository>((ref) {
  return DoctorsRepository(ref.read(apiClientProvider));
});

class DoctorsRepository {
  DoctorsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DoctorsPage> list(DoctorsQuery query) async {
    final response = await _apiClient.get<DoctorsPage>(
      '/doctors',
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid doctors list response.');
        }
        return DoctorsPage.fromJson(rawData);
      },
    );

    return response.data ??
        const DoctorsPage(
          items: [],
          pagination: DoctorPagination(
            currentPage: 1,
            perPage: 15,
            total: 0,
            lastPage: 1,
          ),
        );
  }

  Future<Doctor> getById(int id) async {
    final response = await _apiClient.get<Doctor>(
      '/doctors/$id',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid doctor details response.');
        }
        return Doctor.fromJson(rawData);
      },
    );

    final doctor = response.data;
    if (doctor == null) {
      throw ApiException(message: 'Doctor details are empty.');
    }
    return doctor;
  }

  Future<Doctor> create(DoctorUpsertPayload payload) async {
    final response = await _apiClient.post<Doctor>(
      '/doctors',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid create doctor response.');
        }
        return Doctor.fromJson(rawData);
      },
    );

    final doctor = response.data;
    if (doctor == null) {
      throw ApiException(message: 'Created doctor payload is empty.');
    }
    return doctor;
  }

  Future<Doctor> update({
    required int id,
    required DoctorUpsertPayload payload,
  }) async {
    final response = await _apiClient.put<Doctor>(
      '/doctors/$id',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid update doctor response.');
        }
        return Doctor.fromJson(rawData);
      },
    );

    final doctor = response.data;
    if (doctor == null) {
      throw ApiException(message: 'Updated doctor payload is empty.');
    }
    return doctor;
  }

  Future<void> delete(int id) async {
    await _apiClient.delete<Object?>(
      '/doctors/$id',
      mapper: (_) => null,
    );
  }
}
