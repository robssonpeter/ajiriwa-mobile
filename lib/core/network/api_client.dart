import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/exceptions.dart';

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
            // Handle unauthorized error
            // TODO: Implement token refresh or logout
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Make a GET request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Check if the request should be skipped based on the path
      // This is a simple check; in a real app, you might want to use a more sophisticated approach
      if (path.contains('/apply') && queryParameters != null && queryParameters.containsKey('size')) {
        final size = int.tryParse(queryParameters['size'].toString()) ?? 0;
        if (size > 200000) {
          print('Skipping request to $path because size ($size) exceeds 200000');
          return null; // Skip the request
        }
      }

      final response = await dio.get(
        path,
        queryParameters: queryParameters,
      );

      // Check if the response size exceeds 200000
      final responseSize = _estimateResponseSize(response);
      if (responseSize > 200000) {
        print('Skipping response from $path because size ($responseSize) exceeds 200000');
        return null; // Skip the response
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Estimate the size of a response in bytes
  int _estimateResponseSize(Response response) {
    if (response.data == null) {
      return 0;
    }

    if (response.data is String) {
      return response.data.length;
    }

    if (response.data is Map || response.data is List) {
      final jsonString = json.encode(response.data);
      return jsonString.length;
    }

    return 0;
  }

  /// Make a POST request
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? headers}) async {
    try {
      // Check if the request should be skipped based on the path and data size
      if (path.contains('/apply') && data != null) {
        final dataSize = _estimateDataSize(data);
        if (dataSize > 200000) {
          print('Skipping request to $path because data size ($dataSize) exceeds 200000');
          return null; // Skip the request
        }
      }

      final response = await dio.post(
        path,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      );

      // Check if the response size exceeds 200000
      final responseSize = _estimateResponseSize(response);
      if (responseSize > 200000) {
        print('Skipping response from $path because size ($responseSize) exceeds 200000');
        return null; // Skip the response
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Estimate the size of request data in bytes
  int _estimateDataSize(dynamic data) {
    if (data == null) {
      return 0;
    }

    if (data is String) {
      return data.length;
    }

    if (data is Map || data is List) {
      final jsonString = json.encode(data);
      return jsonString.length;
    }

    return 0;
  }

  /// Make a PUT request
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      print("sending data to url $path");
      print(data);
      final response = await dio.put(
        path,
        data: data,
      );
      print(response);
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
    // If response is null, return null (skipped due to size limit)
    if (response == null) {
      return null;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
      case 422:
        // Extract error message from response body
        String errorMessage = response.statusCode == 400 ? 'Bad request' : 'Validation failed';
        if (response.data is Map) {
          if (response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }

          // Check for detailed validation errors
          if (response.data.containsKey('errors') && response.data['errors'] is Map) {
            final errors = response.data['errors'] as Map;
            if (errors.isNotEmpty) {
              // Get the first error message from the first field
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
    // Print detailed error information for debugging
    print('DioException Type: ${error.type}');
    print('DioException Message: ${error.message}');
    print('DioException Error: ${error.error}');
    print('DioException RequestOptions: ${error.requestOptions.uri}');
    print('DioException RequestOptions Method: ${error.requestOptions.method}');
    print('DioException RequestOptions Headers: ${error.requestOptions.headers}');
    print('DioException Response: ${error.response}');

    // Check if the request should be skipped based on the path
    final path = error.requestOptions.path;
    if (path.contains('/apply')) {
      // Check if the response size exceeds 200000
      if (error.response != null) {
        final responseSize = _estimateResponseSize(error.response!);
        if (responseSize > 200000) {
          print('Skipping error response from $path because size ($responseSize) exceeds 200000');
          return ServerException('Response size exceeds limit');
        }
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection timeout');
    } else if (error.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection');
    } else if (error.response != null) {
      try {
        // Try to handle the response, but catch any exceptions
        final result = _handleResponse(error.response!);
        if (result == null) {
          return ServerException('Response size exceeds limit');
        }
        return ServerException('Server error');
      } catch (e) {
        // If _handleResponse throws an exception, return a ServerException with the error message
        if (e is ServerException) {
          return e;
        } else if (e is AuthException) {
          return e;
        } else {
          return ServerException('Server error: ${e.toString()}');
        }
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
