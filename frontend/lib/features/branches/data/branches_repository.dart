import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/branch.dart';
import '../domain/models/branch_pagination.dart';
import '../domain/models/branch_upsert_payload.dart';
import '../domain/models/branches_page.dart';
import '../domain/models/branches_query.dart';

final branchesRepositoryProvider = Provider<BranchesRepository>((ref) {
  return BranchesRepository(ref.read(apiClientProvider));
});

class BranchesRepository {
  BranchesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<BranchesPage> list(BranchesQuery query) async {
    final response = await _apiClient.get<BranchesPage>(
      '/branches',
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid branches list response.');
        }
        return BranchesPage.fromJson(rawData);
      },
    );

    return response.data ??
        const BranchesPage(
          items: [],
          pagination: BranchPagination(
            currentPage: 1,
            perPage: 15,
            total: 0,
            lastPage: 1,
          ),
        );
  }

  Future<Branch> getById(int id) async {
    final response = await _apiClient.get<Branch>(
      '/branches/$id',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid branch details response.');
        }
        return Branch.fromJson(rawData);
      },
    );

    final branch = response.data;
    if (branch == null) {
      throw ApiException(message: 'Branch details are empty.');
    }
    return branch;
  }

  Future<Branch> create(BranchUpsertPayload payload) async {
    final response = await _apiClient.post<Branch>(
      '/branches',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid create branch response.');
        }
        return Branch.fromJson(rawData);
      },
    );

    final branch = response.data;
    if (branch == null) {
      throw ApiException(message: 'Created branch payload is empty.');
    }
    return branch;
  }

  Future<Branch> update({
    required int id,
    required BranchUpsertPayload payload,
  }) async {
    final response = await _apiClient.put<Branch>(
      '/branches/$id',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid update branch response.');
        }
        return Branch.fromJson(rawData);
      },
    );

    final branch = response.data;
    if (branch == null) {
      throw ApiException(message: 'Updated branch payload is empty.');
    }
    return branch;
  }

  Future<void> delete(int id) async {
    await _apiClient.delete<Object?>(
      '/branches/$id',
      mapper: (_) => null,
    );
  }
}
