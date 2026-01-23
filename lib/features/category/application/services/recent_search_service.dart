import 'package:hive_ce/hive.dart';

/// Service for managing recent search queries using Hive
class RecentSearchService {
  RecentSearchService(this._box);

  final Box _box;
  static const String _key = 'recent_searches';
  static const int _maxSearches = 10;

  /// Get list of recent searches
  List<String> getRecentSearches() {
    final searches = _box.get(_key, defaultValue: <String>[]) as List;
    return searches.cast<String>();
  }

  /// Add a new search query to recent searches
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final searches = getRecentSearches()
      ..remove(query) // Remove if already exists (to move it to top)
      ..insert(0, query); // Add to beginning

    // Limit to max searches
    if (searches.length > _maxSearches) {
      searches.removeRange(_maxSearches, searches.length);
    }

    await _box.put(_key, searches);
  }

  /// Remove a specific search query
  Future<void> removeSearch(String query) async {
    await _box.put(_key, getRecentSearches()..remove(query));
  }

  /// Clear all recent searches
  Future<void> clearAll() async {
    await _box.delete(_key);
  }

  /// Check if a search query exists in recent searches
  bool contains(String query) {
    return getRecentSearches().contains(query);
  }
}
