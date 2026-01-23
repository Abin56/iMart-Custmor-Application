import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/cart_repository.dart';
import '../../infrastructure/data_sources/remote/cart_api.dart';
import '../../infrastructure/repositories/cart_repository_impl.dart';

part 'cart_repository_provider.g.dart';

@riverpod
CartRepository cartRepository(Ref ref) {
  final api = ref.watch(cartApiProvider);
  return CartRepositoryImpl(api);
}
