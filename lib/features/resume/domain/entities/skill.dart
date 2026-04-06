import 'package:equatable/equatable.dart';

/// Skill entity for resume
class Skill extends Equatable {
  /// Skill ID
  final int? id;

  /// Skill name
  final String name;

  /// Proficiency level ID
  final int? levelId;

  /// Proficiency level name
  final String? level;

  /// Rating value (1-5)
  final int? rating;

  /// Rating label (e.g., "Beginner", "Expert")
  final String? ratingLabel;

  /// Constructor
  const Skill({
    this.id,
    required this.name,
    this.levelId,
    this.level,
    this.rating,
    this.ratingLabel,
  });

  @override
  List<Object?> get props => [id, name, levelId, level, rating, ratingLabel];
}
