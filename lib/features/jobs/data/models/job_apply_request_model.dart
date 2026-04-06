import 'package:equatable/equatable.dart';

/// Job apply request model
class JobApplyRequestModel extends Equatable {
  /// Screening answers
  final List<ScreeningAnswerModel> screeningAnswers;

  /// Resume ID
  final int resumeId;

  /// Cover letter
  final String? coverLetter;

  /// Attachments
  final List<AttachmentModel>? attachments;

  /// Constructor
  const JobApplyRequestModel({
    required this.screeningAnswers,
    required this.resumeId,
    this.coverLetter,
    this.attachments,
  });

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    // Format the data according to the backend validation requirements
    return {
      'cover_letter': coverLetter ?? '', // Required field
      'document_ids': attachments?.map((a) => a.fileId).toList() ?? [], // Array of integers
      'screening_responses': screeningAnswers.map((a) => {
        'screening_id': a.questionId,
        'response': a.answerText ?? '',
        'type': a.type ?? '', // Include the type field
      }).toList(),
    };
  }

  @override
  List<Object?> get props => [screeningAnswers, resumeId, coverLetter, attachments];
}

/// Screening answer model
class ScreeningAnswerModel extends Equatable {
  /// Question ID
  final int questionId;

  /// Answer text
  final String? answerText;

  /// Answer choice ID
  final int? answerChoiceId;

  /// Question type
  final String? type;

  /// Constructor
  const ScreeningAnswerModel({
    required this.questionId,
    this.answerText,
    this.answerChoiceId,
    this.type,
  });

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      if (answerText != null && answerText!.isNotEmpty) 'answer_text': answerText,
      if (answerChoiceId != null) 'answer_choice_id': answerChoiceId,
      if (type != null) 'type': type,
    };
  }

  @override
  List<Object?> get props => [questionId, answerText, answerChoiceId, type];
}

/// Attachment model
class AttachmentModel extends Equatable {
  /// File ID
  final int fileId;

  /// Attachment type
  final String type;

  /// Constructor
  const AttachmentModel({
    required this.fileId,
    required this.type,
  });

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [fileId, type];
}

/// Job apply intent request model
class JobApplyIntentRequestModel extends Equatable {
  /// Apply mode
  final String mode;

  /// Notes
  final String? notes;

  /// Constructor
  const JobApplyIntentRequestModel({
    required this.mode,
    this.notes,
  });

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [mode, notes];
}
