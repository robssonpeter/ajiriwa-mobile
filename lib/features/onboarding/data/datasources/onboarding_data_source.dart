import 'dart:io';

abstract class OnboardingDataSource {
  Future<Map<String, dynamic>> uploadCv(File file, int candidateId);
  Future<Map<String, dynamic>> parseCv({
    required String fileUrl,
    required int candidateId,
    int? mediaId,
  });
}
