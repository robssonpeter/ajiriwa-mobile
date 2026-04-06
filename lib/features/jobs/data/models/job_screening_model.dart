import 'package:equatable/equatable.dart';

import '../../domain/entities/job_screening.dart';

/// Job screening model
class JobScreeningModel extends Equatable {
  /// List of screening questions
  final List<ScreeningQuestionModel> questions;

  /// Constructor
  const JobScreeningModel({
    required this.questions,
  });

  /// Convert model to entity
  JobScreening toEntity() {
    return JobScreening(
      questions: questions.map((q) => q.toEntity()).toList(),
    );
  }

  /// Create model from JSON
  factory JobScreeningModel.fromJson(dynamic json) {
    List<dynamic> questionsJson;

    if (json is List) {
      // If the API returns a list directly
      questionsJson = json;
    } else if (json is Map<String, dynamic>) {
      // If the API returns a map with a 'questions' key
      questionsJson = json['questions'] as List<dynamic>? ?? [];
    } else {
      // Fallback to empty list if json is neither a list nor a map
      questionsJson = [];
    }

    return JobScreeningModel(
      questions: questionsJson
          .map((q) => ScreeningQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [questions];
}

/// Screening question model
class ScreeningQuestionModel extends Equatable {
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
  final List<ScreeningQuestionChoiceModel>? choices;

  /// Constructor
  const ScreeningQuestionModel({
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

  /// Convert model to entity
  ScreeningQuestion toEntity() {
    return ScreeningQuestion(
      id: id,
      question: question,
      answer: answer,
      type: type,
      necessity: necessity,
      jobId: jobId,
      name: name,
      questionType: questionType,
      options: options,
      inputType: inputType,
      createdAt: createdAt,
      updatedAt: updatedAt,
      applicantAnswer: applicantAnswer,
      variableName: variableName,
      filterOperator: filterOperator,
      filterValue: filterValue,
      optionsDecoded: optionsDecoded,
      description: description,
      required: required,
      choices: choices?.map((c) => c.toEntity()).toList(),
    );
  }

  /// Create model from JSON
  factory ScreeningQuestionModel.fromJson(Map<String, dynamic> json) {
    final choicesJson = json['choices'] as List<dynamic>? ?? [];

    // Parse options_decoded if available
    List<String>? optionsDecoded;
    if (json['options_decoded'] != null) {
      optionsDecoded = (json['options_decoded'] as List<dynamic>)
          .map((option) => option.toString())
          .toList();
    }

    return ScreeningQuestionModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer']?.toString(),
      type: json['type'] ?? 'text',
      necessity: json['necessity'] ?? 'required',
      jobId: json['job_id']?.toString(),
      name: json['name'],
      questionType: json['question_type'],
      options: json['options'],
      inputType: json['input_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      applicantAnswer: json['applicant_answer'],
      variableName: json['variable_name'],
      filterOperator: json['filter_operator'],
      filterValue: json['filter_value'],
      optionsDecoded: optionsDecoded,
      description: json['description'],
      required: json['necessity'] == 'required' || json['required'] == true,
      choices: choicesJson.isNotEmpty
          ? choicesJson
              .map((c) => ScreeningQuestionChoiceModel.fromJson(c as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'type': type,
      'necessity': necessity,
      'job_id': jobId,
      'name': name,
      'question_type': questionType,
      'options': options,
      'input_type': inputType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'applicant_answer': applicantAnswer,
      'variable_name': variableName,
      'filter_operator': filterOperator,
      'filter_value': filterValue,
      'description': description,
      'required': required,
      if (choices != null) 'choices': choices!.map((c) => c.toJson()).toList(),
      if (optionsDecoded != null) 'options_decoded': optionsDecoded,
    };
  }

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

/// Screening question choice model
class ScreeningQuestionChoiceModel extends Equatable {
  /// Choice ID
  final int id;

  /// Choice text
  final String text;

  /// Constructor
  const ScreeningQuestionChoiceModel({
    required this.id,
    required this.text,
  });

  /// Convert model to entity
  ScreeningQuestionChoice toEntity() {
    return ScreeningQuestionChoice(
      id: id,
      text: text,
    );
  }

  /// Create model from JSON
  factory ScreeningQuestionChoiceModel.fromJson(Map<String, dynamic> json) {
    return ScreeningQuestionChoiceModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }

  @override
  List<Object?> get props => [id, text];
}
