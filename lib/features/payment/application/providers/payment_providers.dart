import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/core/providers/network_providers.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../infrastructure/repositories/payment_repository_impl.dart';

part 'payment_providers.g.dart';

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRepositoryImpl(dio);
}
