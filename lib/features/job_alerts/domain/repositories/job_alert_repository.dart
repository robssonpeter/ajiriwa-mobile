import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/job_alert.dart';

abstract class JobAlertRepository {
  Future<Either<Failure, List<JobAlert>>> getAlerts();

  Future<Either<Failure, JobAlert>> createAlert({
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote,
  });

  Future<Either<Failure, JobAlert>> updateAlert({
    required int id,
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote,
    bool isActive,
  });

  Future<Either<Failure, void>> deleteAlert(int id);
}
