import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

/// File is being uploaded to the server
class CvUploading extends OnboardingState {}

/// File uploaded — we have the URL and are ready to parse
class CvUploaded extends OnboardingState {
  final String fileUrl;
  final int candidateId;
  final int? mediaId;
  const CvUploaded({required this.fileUrl, required this.candidateId, this.mediaId});
  @override
  List<Object?> get props => [fileUrl, candidateId, mediaId];
}

/// AI is parsing the CV content
class CvParsing extends OnboardingState {
  final String fileUrl;
  final int candidateId;
  final int? mediaId;
  const CvParsing({required this.fileUrl, required this.candidateId, this.mediaId});
  @override
  List<Object?> get props => [fileUrl, candidateId, mediaId];
}

/// Parsing complete — profile is populated
class CvParsed extends OnboardingState {
  final int profileCompletion;
  const CvParsed({required this.profileCompletion});
  @override
  List<Object?> get props => [profileCompletion];
}

/// Something went wrong
class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);
  @override
  List<Object?> get props => [message];
}
