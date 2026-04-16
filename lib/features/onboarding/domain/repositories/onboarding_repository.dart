import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class OnboardingRepository {
  /// Uploads a CV file. Returns a map with file_url, media_id, candidate_id.
  Future<Either<Failure, Map<String, dynamic>>> uploadCv(File file, int candidateId);

  /// Parses the uploaded CV via AI and populates the profile.
  /// Returns profile_completion percentage.
  Future<Either<Failure, int>> parseCv({
    required String fileUrl,
    required int candidateId,
    int? mediaId,
  });
}
