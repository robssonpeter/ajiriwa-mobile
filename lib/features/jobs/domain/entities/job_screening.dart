import 'package:equatable/equatable.dart';

/// Job screening entity
class JobScreening extends Equatable {
  /// List of screening questions
  final List<ScreeningQuestion> questions;

  /// Constructor
  const JobScreening({
    required this.questions,
  });

  @override
  List<Object?> get props => [questions];
}

/// Screening question entity
class ScreeningQuestion extends Equatable {
  /// Question ID
  final int id;

  /// Question text
  final String question;

  /// Question answer (expected answer)
  final String? answer;

  /// Question type (experience, custom, education, location, certification, etc.)
  final String type;

  /// Necessity (required, preferred)
  final String necessity;

  /// Job ID
  final String? jobId;

  /// Name
  final String? name;

  /// Question type (minimum, ideal, custom)
  final String? questionType;

  /// Options JSON string
  final String? options;

  /// Input type (number, text, select, date)
  final String? inputType;

  /// Created at timestamp
  final String? createdAt;

  /// Updated at timestamp
  final String? updatedAt;

  /// Applicant answer
  final String? applicantAnswer;

  /// Variable name
  final String? variableName;

/// Filter operator
  final String? filterOperator;

  /// Filter value
  final String? filterValue;

  /// Options decoded
  final List<String>? optionsDecoded;

  /// Description
  final String? description;

  /// Whether the question is required
  final bool required;

  /// Choices for multiple choice questions
  final List<ScreeningQuestionChoice>? choices;

  /// Constructor
  const ScreeningQuestion({
    required this.id,
    required this.question,
    this.answer,
    required this.type,
    required this.necessity,
    this.jobId,
    this.name,
    this.questionType,
    this.options,
    this.inputType,
    this.createdAt,
    this.updatedAt,
    this.applicantAnswer,
    this.variableName,
    this.filterOperator,
    this.filterValue,
    this.optionsDecoded,
    this.description,
    required this.required,
    this.choices,
  });

  @override
  List<Object?> get props => [
        id,
        question,
        answer,
        type,
        necessity,
        jobId,
        name,
        questionType,
        options,
        inputType,
        createdAt,
        updatedAt,
        applicantAnswer,
        variableName,
        filterOperator,
        filterValue,
        optionsDecoded,
        description,
        required,
        choices,
      ];
}

/// Screening question choice entity
class ScreeningQuestionChoice extends Equatable {
  /// Choice ID
  final int id;

  /// Choice text
  final String text;

  /// Constructor
  const ScreeningQuestionChoice({
    required this.id,
    required this.text,
  });

  @override
  List<Object?> get props => [id, text];
}
