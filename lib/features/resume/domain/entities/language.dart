import 'package:equatable/equatable.dart';

/// Language entity for resume
class Language extends Equatable {
  /// Language ID
  final int? id;

  /// Language name
  final String name;

  /// Listening proficiency (1-5)
  final int? listening;

  /// Speaking proficiency (1-5)
  final int? speaking;

  /// Reading proficiency (1-5)
  final int? reading;

  /// Writing proficiency (1-5)
  final int? writing;

  /// Overall rating (1-5)
  final int? rating;

  /// Rating label (e.g., "Native / Bilingual")
  final String? ratingLabel;

  /// Level ID
  final int? levelId;

  /// Level name
  final String? level;

  /// Constructor
  const Language({
    this.id,
    required this.name,
    this.listening,
    this.speaking,
    this.reading,
    this.writing,
    this.rating,
    this.ratingLabel,
    this.levelId,
    this.level,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        listening,
        speaking,
        reading,
        writing,
        rating,
        ratingLabel,
        levelId,
        level,
      ];
}
