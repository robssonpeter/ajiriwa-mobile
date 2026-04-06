import '../../domain/entities/skill.dart';

/// Skill model for resume
class SkillModel extends Skill {
  /// Constructor
  const SkillModel({
    int? id,
    required String name,
    int? levelId,
    String? level,
    int? rating,
    String? ratingLabel,
  }) : super(
          id: id,
          name: name,
          levelId: levelId,
          level: level,
          rating: rating,
          ratingLabel: ratingLabel,
        );

  /// Create a model from JSON
  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      levelId: json['levelId'] as int?,
      level: json['level'] as String?,
      rating: json['rating'] as int?,
      ratingLabel: json['rating_label'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating ?? 1, // Default to 1 if rating is null to meet backend requirements
    };
  }
}
