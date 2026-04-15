import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'auth_data_source.dart';

/// Implementation of the AuthDataSource interface
class AuthDataSourceImpl implements AuthDataSource {
  /// API client
  final ApiClient apiClient;

  /// User data key for secure storage
  static const String userDataKey = 'user_data';

  /// Constructor
  AuthDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        headers: {
          'Accept': 'application/json',
        },
      );

      // Extract user data from response
      final userData = response['user'] as Map<String, dynamic>;

      // Create a new map with all the necessary data
      final userMap = {
        ...userData,
        'token': response['token'],
        'message': response['message'],
      };

      // Create user model from the combined data
      final user = UserModel.fromJson(userMap);

      // Save token for future requests
      await apiClient.saveToken(response['token']);

      // Save user data for offline access
      await apiClient.secureStorage.write(
        key: userDataKey,
        value: json.encode(userMap),
      );

      return user;
    } catch (e) {
      if (e is AuthException || e is ServerException) {
        throw e;
      } else {
        throw ServerException('Login failed');
      }
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
        headers: {
          'Accept': 'application/json',
        },
      );

      // Extract user data from response
      final userData = response['user'] as Map<String, dynamic>;

      // Create a new map with all the necessary data
      final userMap = {
        ...userData,
        'token': response['token'],
        'message': response['message'],
      };

      // Create user model from the combined data
      final user = UserModel.fromJson(userMap);

      // Save token for future requests
      await apiClient.saveToken(response['token']);

      // Save user data for offline access
      await apiClient.secureStorage.write(
        key: userDataKey,
        value: json.encode(userMap),
      );

      return user;
    } catch (e) {
      if (e is AuthException || e is ServerException) {
        throw e;
      } else {
        throw ServerException('Registration failed');
      }
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      // TODO: Implement Google login
      throw UnimplementedError('Google login not implemented');
    } catch (e) {
      throw AuthException('Google login failed');
    }
  }

  @override
  Future<UserModel> loginWithApple() async {
    try {
      // TODO: Implement Apple login
      throw UnimplementedError('Apple login not implemented');
    } catch (e) {
      throw AuthException('Apple login failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');
      await apiClient.deleteToken();

      // Delete stored user data
      await apiClient.secureStorage.delete(key: userDataKey);
    } catch (e) {
      throw ServerException('Logout failed');
    }
  }

  @override
  Future<UserModel?> checkAuth() async {
    try {
      final token = await apiClient.getToken();
      if (token == null) {
        return null;
      }

      // Check for stored candidate ID
      final storedCandidateIdStr = await apiClient.secureStorage.read(key: ApiClient.candidateIdKey);
      final int? storedCandidateId = storedCandidateIdStr != null ? int.tryParse(storedCandidateIdStr) : null;

      try {
        // Try to get current user from server
        return await getCurrentUser(candidateId: storedCandidateId);
      } catch (e) {
        // If server request fails, try to get user from local storage
        final userDataString = await apiClient.secureStorage.read(key: userDataKey);
        if (userDataString != null) {
          try {
            final userMap = json.decode(userDataString) as Map<String, dynamic>;
            return UserModel.fromJson(userMap);
          } catch (e) {
            // If parsing fails, return null
            return null;
          }
        }
        return null;
      }
    } catch (e) {
      // Try to get user from local storage as a fallback
      try {
        final userDataString = await apiClient.secureStorage.read(key: userDataKey);
        if (userDataString != null) {
          final userMap = json.decode(userDataString) as Map<String, dynamic>;
          return UserModel.fromJson(userMap);
        }
      } catch (_) {
        // Ignore errors when reading from storage
      }
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUser({int? candidateId}) async {
    try {
      final path = candidateId != null ? '/profile?candidate_id=$candidateId' : '/profile';
      final response = await apiClient.get(path);
      
      // Save user data for offline access
      await apiClient.secureStorage.write(
        key: userDataKey,
        value: json.encode(response),
      );
      
      if (candidateId != null) {
        await apiClient.secureStorage.write(
          key: ApiClient.candidateIdKey,
          value: candidateId.toString(),
        );
      }

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> switchProfile(int candidateId) async {
    try {
      final user = await getCurrentUser(candidateId: candidateId);
      if (user == null) {
        throw ServerException('Failed to switch profile');
      }
      return user;
    } catch (e) {
      if (e is ServerException) throw e;
      throw ServerException('An error occurred while switching profile');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await apiClient.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
        headers: {
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Password reset request failed');
      }
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.put(
        '/profile/password',
        data: {
          'current_password': oldPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
    } catch (e) {
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Password change failed');
      }
    }
  }
}
