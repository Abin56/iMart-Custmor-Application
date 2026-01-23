import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/home_repository.dart';
import '../../infrastructure/data_sources/remote/home_api.dart';
import '../../infrastructure/repositories/home_repository_impl.dart';

part 'home_repository_provider.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  final api = ref.watch(homeApiProvider);
  return HomeRepositoryImpl(api);
}
