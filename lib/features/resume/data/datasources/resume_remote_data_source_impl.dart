import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/models.dart';
import 'resume_remote_data_source.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementation of [ResumeRemoteDataSource]
class ResumeRemoteDataSourceImpl implements ResumeRemoteDataSource {
  /// API client
  final ApiClient apiClient;

  /// Constructor
  const ResumeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ResumeDataModel> getResumeData({int? candidateId}) async {
    try {
      final queryParams = candidateId != null ? {'candidate_id': candidateId} : null;
      final response = await apiClient.get(
        '/my-resume',
        queryParameters: queryParams,
      );
      return ResumeDataModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> getResumeHtml({int? candidateId}) async {
    try {
      final queryParams = candidateId != null ? {'candidate_id': candidateId} : null;
      final response = await apiClient.get(
        '/my-resume/render',
        queryParameters: queryParams,
      );
      // Handle both cases: response is a String directly or a Map with 'html' field
      if (response is String) {
        return response;
      } else if (response is Map && response.containsKey('html')) {
        return response['html'] as String;
      } else {
        throw ServerException('Unexpected response format');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ResumeSectionResponseModel> getResumeSection(String section, {int? candidateId}) async {
    //try {
      final queryParams = candidateId != null ? {'candidate_id': candidateId} : null;
      final response = await apiClient.get(
        '/my-resume/edit/${section == 'personal' ? '' : section}',
        queryParameters: queryParams,
      );
      appLogger.d("you are now on section $section");
      //print(response);
      return ResumeSectionResponseModel.fromJson(response);
    /*} on ServerException {
      rethrow;
    } catch (e) {
      appLogger.d(e.toString());
      appLogger.d(e);
      throw ServerException(e.toString());
    }*/
  }

  @override
  Future<bool> updatePersonal(PersonalModel personal, {int? candidateId}) async {
    try {
      final data = personal.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      data['first_name'] = data['firstName'];
      data['last_name'] = data['lastName'];
      data['dob'] = data['dateOfBirth'];
      data['professional_title'] = data['headline'];
      data['gender'] = data['gender']=="male" ? 1 : 2;

      final response = await apiClient.put(
        '/my-resume/personal',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateCareer(CareerModel career, {int? candidateId}) async {
    try {
      final data = career.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.put(
        '/my-resume/career',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> addExperience(ExperienceModel experience, {int? candidateId}) async {
    try {
      final data = experience.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.post(
        '/experience',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateExperience(ExperienceModel experience, {int? candidateId}) async {
    try {
      final data = experience.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.put(
        '/experience/${experience.id}',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteExperience(int experienceId, {int? candidateId}) async {
    try {
      // Note: candidateId is ignored as delete method doesn't support queryParameters
      final response = await apiClient.delete(
        '/experience/$experienceId',
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> addEducation(EducationModel education, {int? candidateId}) async {
    try {
      final data = education.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.post(
        '/education',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateEducation(EducationModel education, {int? candidateId}) async {
    try {
      final data = education.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.put(
        '/education/${education.id}',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteEducation(int educationId, {int? candidateId}) async {
    try {
      // Note: candidateId is ignored as delete method doesn't support queryParameters
      final response = await apiClient.delete(
        '/education/$educationId',
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> addLanguage(LanguageModel language, {int? candidateId}) async {
    try {
      final data = language.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.post(
        '/languages',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateLanguage(LanguageModel language, {int? candidateId}) async {
    try {
      final data = language.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.put(
        '/languages/${language.id}',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteLanguage(int languageId, {int? candidateId}) async {
    try {
      // Note: candidateId is ignored as delete method doesn't support queryParameters
      final response = await apiClient.delete(
        '/languages/$languageId',
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> addSkill(SkillModel skill, {int? candidateId}) async {
    try {
      final data = skill.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.post(
        '/skills',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateSkill(SkillModel skill, {int? candidateId}) async {
    try {
      final data = skill.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.put(
        '/skills/${skill.id}',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteSkill(int skillId, {int? candidateId}) async {
    try {
      // Note: candidateId is ignored as delete method doesn't support queryParameters
      final response = await apiClient.delete(
        '/skills/$skillId',
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> addAward(AwardModel award, {int? candidateId}) async {
    try {
      final data = award.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.post(
        '/certificates',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateAward(AwardModel award, {int? candidateId}) async {
    try {
      final data = award.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.put(
        '/certificates/${award.id}',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteAward(int awardId, {int? candidateId}) async {
    try {
      // Note: candidateId is ignored as delete method doesn't support queryParameters
      final response = await apiClient.delete(
        '/certificates/$awardId',
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> addReference(ReferenceModel reference, {int? candidateId}) async {
    try {
      final data = reference.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.post(
        '/referees',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateReference(ReferenceModel reference, {int? candidateId}) async {
    try {
      final data = reference.toJson();
      if (candidateId != null) {
        data['candidate_id'] = candidateId;
      }
      final response = await apiClient.put(
        '/referees/${reference.id}',
        data: data,
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteReference(int referenceId, {int? candidateId}) async {
    try {
      // Note: candidateId is ignored as delete method doesn't support queryParameters
      final response = await apiClient.delete(
        '/referees/$referenceId',
      );
      return response['success'] == true;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
