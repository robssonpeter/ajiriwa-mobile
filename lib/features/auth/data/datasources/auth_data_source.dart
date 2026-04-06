import '../models/user_model.dart';

/// Data source interface for authentication
abstract class AuthDataSource {
  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Login with Google
  Future<UserModel> loginWithGoogle();

  /// Login with Apple
  Future<UserModel> loginWithApple();

  /// Logout the current user
  Future<void> logout();

  /// Check if the user is authenticated
  Future<UserModel?> checkAuth();

  /// Get the current user
  Future<UserModel?> getCurrentUser();

  /// Request password reset for the given email
  Future<void> forgotPassword({
    required String email,
  });
}
