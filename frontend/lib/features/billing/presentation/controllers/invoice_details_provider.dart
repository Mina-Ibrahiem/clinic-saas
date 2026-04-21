import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/invoices_repository.dart';
import '../../domain/models/invoice.dart';

final invoiceDetailsVersionProvider = StateProvider.autoDispose.family<int, int>((ref, invoiceId) => 0);

final invoiceDetailsProvider = FutureProvider.autoDispose.family<Invoice, int>((ref, invoiceId) async {
  ref.watch(invoiceDetailsVersionProvider(invoiceId));
  return ref.read(invoicesRepositoryProvider).getById(invoiceId);
});
