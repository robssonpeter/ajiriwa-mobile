import '../../domain/entities/language.dart';

/// Language model for resume
class LanguageModel extends Language {
  /// Constructor
  const LanguageModel({
    int? id,
    required String name,
    int? listening,
    int? speaking,
    int? reading,
    int? writing,
    int? rating,
    String? ratingLabel,
    int? levelId,
    String? level,
  }) : super(
          id: id,
          name: name,
          listening: listening,
          speaking: speaking,
          reading: reading,
          writing: writing,
          rating: rating,
          ratingLabel: ratingLabel,
          levelId: levelId,
          level: level,
        );

  /// Create a model from JSON
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      listening: json['listening'] as int?,
      speaking: json['speaking'] as int?,
      reading: json['reading'] as int?,
      writing: json['writing'] as int?,
      rating: json['rating'] as int?,
      ratingLabel: json['rating_label'] as String?,
      levelId: json['level_id'] as int?,
      level: json['level'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'listening': listening,
      'speaking': speaking,
      'reading': reading,
      'writing': writing,
      'rating': rating,
      'level_id': levelId,
      'level': level,
    };
  }
}
