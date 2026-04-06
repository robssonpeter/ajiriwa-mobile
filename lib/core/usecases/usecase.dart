import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Abstract class for use cases
abstract class UseCase<Type, Params> {
  /// Call method
  Future<Either<Failure, Type>> call(Params params);
}

/// No parameters class for use cases that don't require parameters
class NoParams {}