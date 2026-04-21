import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../domain/models/billing_pagination.dart';
import '../domain/models/invoice.dart';
import '../domain/models/invoice_query.dart';
import '../domain/models/invoice_upsert_payload.dart';
import '../domain/models/invoices_page.dart';

final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) {
  return InvoicesRepository(ref.read(apiClientProvider));
});

class InvoicesRepository {
  InvoicesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<InvoicesPage> list(InvoiceQuery query) async {
    final response = await _apiClient.get<InvoicesPage>(
      '/invoices',
      queryParameters: query.toQueryParameters(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid invoices list response.');
        }
        return InvoicesPage.fromJson(rawData);
      },
    );

    return response.data ??
        const InvoicesPage(
          items: [],
          pagination: BillingPagination(
            currentPage: 1,
            perPage: 15,
            total: 0,
            lastPage: 1,
          ),
        );
  }

  Future<Invoice> getById(int id) async {
    final response = await _apiClient.get<Invoice>(
      '/invoices/$id',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid invoice details response.');
        }
        return Invoice.fromJson(rawData);
      },
    );

    final invoice = response.data;
    if (invoice == null) {
      throw ApiException(message: 'Invoice details are empty.');
    }
    return invoice;
  }

  Future<Invoice> create(InvoiceUpsertPayload payload) async {
    final response = await _apiClient.post<Invoice>(
      '/invoices',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid create invoice response.');
        }
        return Invoice.fromJson(rawData);
      },
    );

    final invoice = response.data;
    if (invoice == null) {
      throw ApiException(message: 'Created invoice payload is empty.');
    }
    return invoice;
  }

  Future<Invoice> update({
    required int id,
    required InvoiceUpsertPayload payload,
  }) async {
    final response = await _apiClient.put<Invoice>(
      '/invoices/$id',
      data: payload.toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid update invoice response.');
        }
        return Invoice.fromJson(rawData);
      },
    );

    final invoice = response.data;
    if (invoice == null) {
      throw ApiException(message: 'Updated invoice payload is empty.');
    }
    return invoice;
  }

  Future<void> delete(int id) async {
    await _apiClient.delete<Object?>(
      '/invoices/$id',
      mapper: (_) => null,
    );
  }
}
