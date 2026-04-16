import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import 'onboarding_data_source.dart';

class OnboardingDataSourceImpl implements OnboardingDataSource {
  final ApiClient apiClient;

  OnboardingDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> uploadCv(File file, int candidateId) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      'candidate_id': candidateId,
    });

    final response = await apiClient.post(
      '/onboarding/upload',
      data: formData,
    );
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<Map<String, dynamic>> parseCv({
    required String fileUrl,
    required int candidateId,
    int? mediaId,
  }) async {
    final body = <String, dynamic>{
      'file_url': fileUrl,
      'candidate_id': candidateId,
      if (mediaId != null) 'media_id': mediaId,
    };

    final response = await apiClient.post('/onboarding/parse', data: body);
    return Map<String, dynamic>.from(response);
  }
}
