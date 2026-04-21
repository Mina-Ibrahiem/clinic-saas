import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/service.dart';
import '../domain/models/service_pagination.dart';
import '../domain/models/service_upsert_payload.dart';
import '../domain/models/services_page.dart';
import '../domain/models/services_query.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository(ref.read(apiClientProvider));
});

class ServicesRepository {
  ServicesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ServicesPage> list(ServicesQuery query) async {
    final response = await _apiClient.get<ServicesPage>(
      '/services',
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid services list response.');
        }
        return ServicesPage.fromJson(rawData);
      },
    );

    return response.data ??
        const ServicesPage(
          items: [],
          pagination: ServicePagination(
            currentPage: 1,
            perPage: 15,
            total: 0,
            lastPage: 1,
          ),
        );
  }

  Future<Service> getById(int id) async {
    final response = await _apiClient.get<Service>(
      '/services/$id',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid service details response.');
        }
        return Service.fromJson(rawData);
      },
    );

    final service = response.data;
    if (service == null) {
      throw ApiException(message: 'Service details are empty.');
    }
    return service;
  }

  Future<Service> create(ServiceUpsertPayload payload) async {
    final response = await _apiClient.post<Service>(
      '/services',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid create service response.');
        }
        return Service.fromJson(rawData);
      },
    );

    final service = response.data;
    if (service == null) {
      throw ApiException(message: 'Created service payload is empty.');
    }
    return service;
  }

  Future<Service> update({
    required int id,
    required ServiceUpsertPayload payload,
  }) async {
    final response = await _apiClient.put<Service>(
      '/services/$id',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid update service response.');
        }
        return Service.fromJson(rawData);
      },
    );

    final service = response.data;
    if (service == null) {
      throw ApiException(message: 'Updated service payload is empty.');
    }
    return service;
  }

  Future<void> delete(int id) async {
    await _apiClient.delete<Object?>(
      '/services/$id',
      mapper: (_) => null,
    );
  }
}
