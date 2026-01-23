import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for checkout line cache metadata
/// Stores Last-Modified and ETag headers for HTTP 304 optimization
class CheckoutLineLocalDataSource {
  CheckoutLineLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyLastModified = 'checkout_lines_last_modified';
  static const String _keyETag = 'checkout_lines_etag';

  /// Get cached Last-Modified header
  String? getLastModified() {
    return _prefs.getString(_keyLastModified);
  }

  /// Get cached ETag header
  String? getETag() {
    return _prefs.getString(_keyETag);
  }

  /// Save Last-Modified header
  Future<void> saveLastModified(String value) async {
    await _prefs.setString(_keyLastModified, value);
  }

  /// Save ETag header
  Future<void> saveETag(String value) async {
    await _prefs.setString(_keyETag, value);
  }

  /// Clear cache metadata
  Future<void> clearCacheMetadata() async {
    await _prefs.remove(_keyLastModified);
    await _prefs.remove(_keyETag);
  }
}
