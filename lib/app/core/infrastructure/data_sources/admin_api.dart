import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/api_client.dart';
import '../../network/endpoints.dart';

/// Data source for admin-related API calls
class AdminApi {
  AdminApi(this._apiClient);

  final ApiClient _apiClient;

  /// Fetch admin phone number from backend
  /// Returns the phone number string or null if not available
  Future<String?> getAdminPhone() async {
    try {
      print('🔵 [AdminAPI] Fetching admin phone from: ${ApiEndpoints.adminPhone}');
      final response = await _apiClient.get(ApiEndpoints.adminPhone);

      print('🔵 [AdminAPI] Response status: ${response.statusCode}');
      print('🔵 [AdminAPI] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Handle paginated response: {"count": 1, "results": [{"phone_number": "+919876543211"}]}
        if (data.containsKey('results') && data['results'] is List) {
          final results = data['results'] as List<dynamic>;
          if (results.isNotEmpty) {
            final firstResult = results[0] as Map<String, dynamic>;
            final phoneNumber = firstResult['phone_number'] as String?;
            print('🟢 [AdminAPI] Admin phone number: $phoneNumber');
            return phoneNumber;
          }
        }

        // Fallback: Check if direct phone field exists
        if (data.containsKey('phone')) {
          return data['phone'] as String?;
        }
      }

      print('🟡 [AdminAPI] No phone number found in response');
      return null;
    } on DioException catch (e) {
      print('🔴 [AdminAPI] DioException: ${e.message}');
      // Return null on error - will use fallback number
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Error fetching admin phone: ${e.message}');
    } catch (e) {
      print('🔴 [AdminAPI] Error: $e');
      rethrow;
    }
  }
}

/// Provider for AdminApi
final adminApiProvider = Provider<AdminApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminApi(apiClient);
});
