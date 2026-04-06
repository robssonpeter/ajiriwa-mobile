import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../models/user_model.dart';

/// Implementation of the AuthRepository interface
class AuthRepositoryImpl implements AuthRepository {
  /// Remote data source
  final AuthDataSource remoteDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  /// Constructor
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.login(
          email: email,
          password: password,
        );
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.register(
          name: name,
          email: email,
          password: password,
        );
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.loginWithGoogle();
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithApple() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.loginWithApple();
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.logout();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User?>> checkAuth() async {
    try {
      final user = await remoteDataSource.checkAuth();
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getCurrentUser();
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.forgotPassword(email: email);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
