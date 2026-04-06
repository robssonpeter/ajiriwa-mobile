import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Login with Google
  Future<Either<Failure, User>> loginWithGoogle();

  /// Login with Apple
  Future<Either<Failure, User>> loginWithApple();

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Check if the user is authenticated
  Future<Either<Failure, User?>> checkAuth();

  /// Get the current user
  Future<Either<Failure, User?>> getCurrentUser({int? candidateId});

  /// Switch to a different candidate profile
  Future<Either<Failure, User>> switchProfile(int candidateId);

  /// Request password reset for the given email
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });
}
