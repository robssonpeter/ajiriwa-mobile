import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository repository;

  OnboardingBloc({required this.repository}) : super(OnboardingInitial()) {
    on<UploadCvEvent>(_onUploadCv);
    on<ParseCvEvent>(_onParseCv);
    on<ResetOnboardingEvent>((_, emit) => emit(OnboardingInitial()));
  }

  Future<void> _onUploadCv(UploadCvEvent event, Emitter<OnboardingState> emit) async {
    emit(CvUploading());
    final result = await repository.uploadCv(event.file, event.candidateId);
    result.fold(
      (failure) => emit(OnboardingError(failure.toString())),
      (data) => emit(CvUploaded(
        fileUrl: data['file_url'] as String,
        candidateId: data['candidate_id'] as int,
        mediaId: data['media_id'] as int?,
      )),
    );
  }

  Future<void> _onParseCv(ParseCvEvent event, Emitter<OnboardingState> emit) async {
    emit(CvParsing(
      fileUrl: event.fileUrl,
      candidateId: event.candidateId,
      mediaId: event.mediaId,
    ));
    final result = await repository.parseCv(
      fileUrl: event.fileUrl,
      candidateId: event.candidateId,
      mediaId: event.mediaId,
    );
    result.fold(
      (failure) => emit(OnboardingError(failure.toString())),
      (completion) => emit(CvParsed(profileCompletion: completion)),
    );
  }
}
