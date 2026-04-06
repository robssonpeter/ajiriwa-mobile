import '../models/models.dart';

/// Remote data source for resume operations
abstract class ResumeRemoteDataSource {
  /// Get resume section data
  /// 
  /// [section] is the section name (personal, career, experience, education, language, skills, awards, reference)
  /// [candidateId] is optional and used for multi-CV support
  Future<ResumeSectionResponseModel> getResumeSection(String section, {int? candidateId});

  /// Get complete resume data
  /// 
  /// [candidateId] is optional and used for multi-CV support
  Future<ResumeDataModel> getResumeData({int? candidateId});

  /// Get rendered resume HTML
  /// 
  /// [candidateId] is optional and used for multi-CV support
  Future<String> getResumeHtml({int? candidateId});

  /// Update personal information
  Future<bool> updatePersonal(PersonalModel personal, {int? candidateId});

  /// Update career information
  Future<bool> updateCareer(CareerModel career, {int? candidateId});

  /// Add work experience
  Future<bool> addExperience(ExperienceModel experience, {int? candidateId});

  /// Update work experience
  Future<bool> updateExperience(ExperienceModel experience, {int? candidateId});

  /// Delete work experience
  Future<bool> deleteExperience(int experienceId, {int? candidateId});

  /// Add education
  Future<bool> addEducation(EducationModel education, {int? candidateId});

  /// Update education
  Future<bool> updateEducation(EducationModel education, {int? candidateId});

  /// Delete education
  Future<bool> deleteEducation(int educationId, {int? candidateId});

  /// Add language
  Future<bool> addLanguage(LanguageModel language, {int? candidateId});

  /// Update language
  Future<bool> updateLanguage(LanguageModel language, {int? candidateId});

  /// Delete language
  Future<bool> deleteLanguage(int languageId, {int? candidateId});

  /// Add skill
  Future<bool> addSkill(SkillModel skill, {int? candidateId});

  /// Update skill
  Future<bool> updateSkill(SkillModel skill, {int? candidateId});

  /// Delete skill
  Future<bool> deleteSkill(int skillId, {int? candidateId});

  /// Add award/certificate
  Future<bool> addAward(AwardModel award, {int? candidateId});

  /// Update award/certificate
  Future<bool> updateAward(AwardModel award, {int? candidateId});

  /// Delete award/certificate
  Future<bool> deleteAward(int awardId, {int? candidateId});

  /// Add reference
  Future<bool> addReference(ReferenceModel reference, {int? candidateId});

  /// Update reference
  Future<bool> updateReference(ReferenceModel reference, {int? candidateId});

  /// Delete reference
  Future<bool> deleteReference(int referenceId, {int? candidateId});
}
