import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/exceptions.dart';
import '../utils/app_logger.dart';

/// API client for making HTTP requests
class ApiClient {
  /// Dio instance
  final Dio dio;

  /// Secure storage for storing tokens
  final FlutterSecureStorage secureStorage;

  /// Base URL for the API
  static const String baseUrl = 'https://www.ajiriwa.net/api/v1';

  /// Token key for secure storage
  static const String tokenKey = 'auth_token';

  /// Selected candidate ID key for secure storage
  static const String candidateIdKey = 'selected_candidate_id';

  // Stream that fires when a 401 Unauthorized response is received.
  // AuthBloc subscribes to this to trigger automatic logout.
  static final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();
  static Stream<void> get unauthorizedStream => _unauthorizedController.stream;

  /// Constructor
  ApiClient({
    required this.dio,
    required this.secureStorage,
  }) {
    dio.options.baseUrl = baseUrl;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for authentication and multi-profile support
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = await secureStorage.read(key: tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add selected candidate ID if not already present in query parameters
          if (!options.queryParameters.containsKey('candidate_id')) {
            final candidateId = await secureStorage.read(key: candidateIdKey);
            if (candidateId != null) {
              options.queryParameters['candidate_id'] = candidateId;
            }
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Broadcast unauthorized event so AuthBloc can trigger logout
            _unauthorizedController.add(null);
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Make a GET request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a POST request
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? headers}) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a PUT request
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      appLogger.d('PUT $path', error: data);
      final response = await dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a DELETE request
  Future<dynamic> delete(String path) async {
    try {
      final response = await dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle response
  dynamic _handleResponse(Response? response) {
    if (response == null) return null;

    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
      case 422:
        String errorMessage = response.statusCode == 400 ? 'Bad request' : 'Validation failed';
        if (response.data is Map) {
          if (response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
          if (response.data.containsKey('errors') && response.data['errors'] is Map) {
            final errors = response.data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstField = errors.keys.first;
              final fieldErrors = errors[firstField];
              if (fieldErrors is List && fieldErrors.isNotEmpty) {
                errorMessage = fieldErrors.first.toString();
              }
            }
          }
        }
        throw ServerException(errorMessage);
      case 401:
        throw AuthException('Unauthorized');
      case 403:
        throw AuthException('Forbidden');
      case 404:
        throw ServerException('Not found');
      case 500:
      default:
        throw ServerException('Server error');
    }
  }

  /// Handle error
  Exception _handleError(DioException error) {
    appLogger.e(
      'HTTP ${error.requestOptions.method} ${error.requestOptions.uri}',
      error: error.message,
    );

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection timeout');
    } else if (error.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection');
    } else if (error.response != null) {
      try {
        final result = _handleResponse(error.response!);
        if (result == null) return ServerException('Empty response');
        return ServerException('Server error');
      } catch (e) {
        if (e is ServerException) return e;
        if (e is AuthException) return e;
        return ServerException('Server error: ${e.toString()}');
      }
    } else {
      return ServerException('Unknown error: ${error.message}');
    }
  }

  /// Save token to secure storage
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: tokenKey, value: token);
  }

  /// Get token from secure storage
  Future<String?> getToken() async {
    return await secureStorage.read(key: tokenKey);
  }

  /// Delete token from secure storage
  Future<void> deleteToken() async {
    await secureStorage.delete(key: tokenKey);
  }
}
