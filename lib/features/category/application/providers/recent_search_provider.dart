import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/core/storage/hive/boxes.dart';
import '../services/recent_search_service.dart';

part 'recent_search_provider.g.dart';

/// Provider for recent search service
@riverpod
RecentSearchService recentSearchService(Ref ref) {
  return RecentSearchService(Boxes.cacheBox);
}

/// Provider for recent searches list
@riverpod
class RecentSearches extends _$RecentSearches {
  @override
  List<String> build() {
    final service = ref.watch(recentSearchServiceProvider);
    return service.getRecentSearches();
  }

  /// Add a new search query
  Future<void> addSearch(String query) async {
    final service = ref.read(recentSearchServiceProvider);
    await service.addSearch(query);
    ref.invalidateSelf();
  }

  /// Remove a specific search query
  Future<void> removeSearch(String query) async {
    final service = ref.read(recentSearchServiceProvider);
    await service.removeSearch(query);
    ref.invalidateSelf();
  }

  /// Clear all recent searches
  Future<void> clearAll() async {
    final service = ref.read(recentSearchServiceProvider);
    await service.clearAll();
    ref.invalidateSelf();
  }
}
