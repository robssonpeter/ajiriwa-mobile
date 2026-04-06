import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/resume_repository.dart';

part 'resume_event.dart';
part 'resume_state.dart';

/// Resume bloc - manages state for resume editing
class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  /// Repository for resume operations
  final ResumeRepository repository;

  /// Constructor
  ResumeBloc({required this.repository}) : super(ResumeInitial()) {
    on<GetResumeSection>(_onGetResumeSection);
    on<UpdatePersonal>(_onUpdatePersonal);
    on<UpdateCareer>(_onUpdateCareer);

    // Experience events
    on<AddExperience>(_onAddExperience);
    on<UpdateExperience>(_onUpdateExperience);
    on<DeleteExperience>(_onDeleteExperience);

    // Education events
    on<AddEducation>(_onAddEducation);
    on<UpdateEducation>(_onUpdateEducation);
    on<DeleteEducation>(_onDeleteEducation);

    // Language events
    on<AddLanguage>(_onAddLanguage);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<DeleteLanguage>(_onDeleteLanguage);

    // Skill events
    on<AddSkill>(_onAddSkill);
    on<UpdateSkill>(_onUpdateSkill);
    on<DeleteSkill>(_onDeleteSkill);

    // Award events
    on<AddAward>(_onAddAward);
    on<UpdateAward>(_onUpdateAward);
    on<DeleteAward>(_onDeleteAward);

    // Reference events
    on<AddReference>(_onAddReference);
    on<UpdateReference>(_onUpdateReference);
    on<DeleteReference>(_onDeleteReference);

    // Resume data events
    on<GetResumeData>(_onGetResumeData);
    on<GetResumeHtml>(_onGetResumeHtml);
  }

  /// Handle GetResumeSection event
  Future<void> _onGetResumeSection(GetResumeSection event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.getResumeSection(event.section, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (response) => emit(ResumeSectionLoaded(response: response)),
    );
  }

  /// Handle UpdatePersonal event
  Future<void> _onUpdatePersonal(UpdatePersonal event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updatePersonal(event.personal, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const PersonalUpdated()),
    );
  }

  /// Handle UpdateCareer event
  Future<void> _onUpdateCareer(UpdateCareer event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updateCareer(event.career, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const CareerUpdated()),
    );
  }

  // Experience event handlers
  /// Handle AddExperience event
  Future<void> _onAddExperience(AddExperience event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.addExperience(event.experience, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const ExperienceAdded()),
    );
  }

  /// Handle UpdateExperience event
  Future<void> _onUpdateExperience(UpdateExperience event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updateExperience(event.experience, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const ExperienceUpdated()),
    );
  }

  /// Handle DeleteExperience event
  Future<void> _onDeleteExperience(DeleteExperience event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.deleteExperience(event.experienceId, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const ExperienceDeleted()),
    );
  }

  // Education event handlers
  /// Handle AddEducation event
  Future<void> _onAddEducation(AddEducation event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.addEducation(event.education, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const EducationAdded()),
    );
  }

  /// Handle UpdateEducation event
  Future<void> _onUpdateEducation(UpdateEducation event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updateEducation(event.education, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const EducationUpdated()),
    );
  }

  /// Handle DeleteEducation event
  Future<void> _onDeleteEducation(DeleteEducation event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.deleteEducation(event.educationId, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const EducationDeleted()),
    );
  }

  // Language event handlers
  /// Handle AddLanguage event
  Future<void> _onAddLanguage(AddLanguage event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.addLanguage(event.language, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const LanguageAdded()),
    );
  }

  /// Handle UpdateLanguage event
  Future<void> _onUpdateLanguage(UpdateLanguage event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updateLanguage(event.language, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const LanguageUpdated()),
    );
  }

  /// Handle DeleteLanguage event
  Future<void> _onDeleteLanguage(DeleteLanguage event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.deleteLanguage(event.languageId, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const LanguageDeleted()),
    );
  }

  // Skill event handlers
  /// Handle AddSkill event
  Future<void> _onAddSkill(AddSkill event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.addSkill(event.skill, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const SkillAdded()),
    );
  }

  /// Handle UpdateSkill event
  Future<void> _onUpdateSkill(UpdateSkill event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updateSkill(event.skill, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const SkillUpdated()),
    );
  }

  /// Handle DeleteSkill event
  Future<void> _onDeleteSkill(DeleteSkill event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.deleteSkill(event.skillId, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const SkillDeleted()),
    );
  }

  // Award event handlers
  /// Handle AddAward event
  Future<void> _onAddAward(AddAward event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.addAward(event.award, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const AwardAdded()),
    );
  }

  /// Handle UpdateAward event
  Future<void> _onUpdateAward(UpdateAward event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updateAward(event.award, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const AwardUpdated()),
    );
  }

  /// Handle DeleteAward event
  Future<void> _onDeleteAward(DeleteAward event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.deleteAward(event.awardId, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const AwardDeleted()),
    );
  }

  // Reference event handlers
  /// Handle AddReference event
  Future<void> _onAddReference(AddReference event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.addReference(event.reference, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const ReferenceAdded()),
    );
  }

  /// Handle UpdateReference event
  Future<void> _onUpdateReference(UpdateReference event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.updateReference(event.reference, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const ReferenceUpdated()),
    );
  }

  /// Handle DeleteReference event
  Future<void> _onDeleteReference(DeleteReference event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.deleteReference(event.referenceId, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (_) => emit(const ReferenceDeleted()),
    );
  }

  /// Handle GetResumeData event
  Future<void> _onGetResumeData(GetResumeData event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.getResumeData(candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (resumeData) => emit(ResumeDataLoaded(resumeData: resumeData)),
    );
  }

  /// Handle GetResumeHtml event
  Future<void> _onGetResumeHtml(GetResumeHtml event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    final result = await repository.getResumeHtml(candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ResumeError(message: failure.message)),
      (html) => emit(ResumeHtmlLoaded(html: html)),
    );
  }
}
