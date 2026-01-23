import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/hive/boxes.dart';
import '../storage/hive/keys.dart';
import 'endpoints.dart';
import 'network_exceptions.dart';

class ApiClient {
  ApiClient();
  late Dio dio;
  // Use in-memory CookieJar - persistence handled by Hive
  late CookieJar cookieJar;

  // Use centralized configuration
  static String get baseUrl => AppConfig.apiBaseUrl;

  static Duration get _defaultConnectTimeout => AppConfig.connectTimeout;
  static Duration get _defaultReceiveTimeout => AppConfig.receiveTimeout;

  // Guest mode check function - will be set by main.dart
  bool Function()? isGuestMode;

  Future<void> init() async {
    // 1. Create in-memory CookieJar (Hive handles persistence)
    cookieJar = CookieJar();

    // 2. Restore cookies from Hive on startup
    try {
      await _restoreCookiesFromHive();
      final existingCookies = await cookieJar.loadForRequest(
        Uri.parse(AppConfig.apiBaseUrl),
      );

      // ignore: unused_local_variable
      for (final cookie in existingCookies) {}
      // ignore: empty_catches
    } catch (e) {}

    // 2. Create dio with options
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: _defaultConnectTimeout,
        receiveTimeout: _defaultReceiveTimeout,
        sendTimeout: _defaultConnectTimeout,
        contentType: 'application/json',
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    // 3. Cookies
    dio.interceptors.add(CookieManager(cookieJar));

    // Note: Authentication is handled via session cookies (CookieManager above)
    // No additional user context headers needed for authenticated requests

    // 5. Debug logging
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
      );
    }

    // 6. Guest mode & CSRF interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if user is in guest mode
          final isGuest = isGuestMode?.call() ?? false;

          if (isGuest) {
            // For guest mode: Use 'dev: 2' header, skip CSRF
            options.headers['dev'] = '2';
          } else {
            // For authenticated users: Use CSRF token
            final csrf = await _getCsrfToken();
            if (csrf != null) {
              options.headers['X-CSRFToken'] = csrf;
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Helper for CSRF token
  Future<String?> _getCsrfToken() async {
    final cookies = await cookieJar.loadForRequest(
      Uri.parse(dio.options.baseUrl),
    );

    final csrfCookie = cookies.firstWhere(
      (c) => c.name.toLowerCase() == 'csrftoken',
      orElse: () => Cookie('', ''),
    );

    return csrfCookie.value.isEmpty ? null : csrfCookie.value;
  }

  /// Backup cookies to Hive for reliable persistence
  /// This is called after successful login/signup responses
  Future<void> backupCookiesToHive() async {
    try {
      final cookies = await cookieJar.loadForRequest(
        Uri.parse(AppConfig.apiBaseUrl),
      );

      if (cookies.isEmpty) {
        return;
      }

      // Serialize cookies to string format for Hive storage
      final cookieStrings = cookies.map((c) {
        // Store cookie in a format that can be reconstructed
        return '${c.name}=${c.value};domain=${c.domain ?? ''};path=${c.path ?? '/'};expires=${c.expires?.toIso8601String() ?? ''}';
      }).toList();

      await Boxes.cacheBox.put(HiveKeys.sessionCookies, cookieStrings);
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Restore cookies from Hive backup
  Future<void> _restoreCookiesFromHive() async {
    try {
      final cookieStrings = Boxes.cacheBox.get(HiveKeys.sessionCookies);
      if (cookieStrings == null || (cookieStrings as List).isEmpty) {
        return;
      }

      final uri = Uri.parse(AppConfig.apiBaseUrl);
      final cookies = <Cookie>[];

      for (final cookieStr in cookieStrings) {
        try {
          final cookie = _parseCookieString(cookieStr as String);
          if (cookie != null) {
            cookies.add(cookie);
          }
          // ignore: empty_catches
        } catch (e) {}
      }

      if (cookies.isNotEmpty) {
        await cookieJar.saveFromResponse(uri, cookies);
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Parse a cookie string back to Cookie object
  Cookie? _parseCookieString(String cookieStr) {
    try {
      final parts = cookieStr.split(';');
      if (parts.isEmpty) return null;

      // First part is name=value
      final nameValue = parts[0].split('=');
      if (nameValue.length < 2 || nameValue[0].isEmpty) return null;

      final cookie = Cookie(nameValue[0], nameValue.sublist(1).join('='));

      // Parse other attributes
      for (var i = 1; i < parts.length; i++) {
        final attr = parts[i].trim();
        if (attr.startsWith('domain=')) {
          final domain = attr.substring(7);
          if (domain.isNotEmpty) cookie.domain = domain;
        } else if (attr.startsWith('path=')) {
          cookie.path = attr.substring(5);
        } else if (attr.startsWith('expires=')) {
          final expiresStr = attr.substring(8);
          if (expiresStr.isNotEmpty) {
            cookie.expires = DateTime.tryParse(expiresStr);
          }
        }
      }

      return cookie;
    } catch (e) {
      return null;
    }
  }

  /// Clear cookies from both PersistCookieJar and Hive backup
  Future<void> clearAllCookies() async {
    await cookieJar.deleteAll();
    await Boxes.cacheBox.delete(HiveKeys.sessionCookies);
  }

  // GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final mergedHeaders = {
        if (options?.headers != null) ...options!.headers!,
        if (headers != null) ...headers,
      };

      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          headers: mergedHeaders.isEmpty ? null : mergedHeaders,
        ),
      );

      return response;
    } on DioException catch (error) {
      throw NetworkException.fromDio(error);
    }
  }

  // POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final mergedHeaders = {
        if (options?.headers != null) ...options!.headers!,
        if (headers != null) ...headers,
      };

      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          headers: mergedHeaders.isEmpty ? null : mergedHeaders,
        ),
      );

      return response;
    } on DioException catch (error) {
      throw NetworkException.fromDio(error);
    }
  }

  // PATCH
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final mergedHeaders = <String, dynamic>{
        if (options?.headers != null) ...options!.headers!,
        if (headers != null) ...headers,
      };
      final requestHeaders = mergedHeaders.isEmpty ? null : mergedHeaders;

      final response = await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(headers: requestHeaders),
      );
      return response;
    } on DioException catch (error) {
      throw NetworkException.fromDio(error);
    }
  }

  // DELETE
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final mergedHeaders = <String, dynamic>{
        if (options?.headers != null) ...options!.headers!,
        if (headers != null) ...headers,
      };
      final requestHeaders = mergedHeaders.isEmpty ? null : mergedHeaders;

      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(headers: requestHeaders),
      );
      return response;
    } on DioException catch (error) {
      throw NetworkException.fromDio(error);
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient must be overridden in main.dart');
});
