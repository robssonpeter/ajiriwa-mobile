import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class UploadCvEvent extends OnboardingEvent {
  final File file;
  final int candidateId;
  const UploadCvEvent({required this.file, required this.candidateId});
  @override
  List<Object?> get props => [file, candidateId];
}

class ParseCvEvent extends OnboardingEvent {
  final String fileUrl;
  final int candidateId;
  final int? mediaId;
  const ParseCvEvent({required this.fileUrl, required this.candidateId, this.mediaId});
  @override
  List<Object?> get props => [fileUrl, candidateId, mediaId];
}

class ResetOnboardingEvent extends OnboardingEvent {}
