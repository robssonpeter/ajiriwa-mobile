import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  /// User ID
  final int id;

  /// User name
  final String name;

  /// User email
  final String email;

  /// User role
  final String? role;

  /// User profile photo URL
  final String? photoUrl;

  /// User headline/title
  final String? headline;

  /// User token
  final String token;

  /// User message
  final String? message;

  /// Available candidates for this user (multi-profile)
  final List<Map<String, dynamic>>? candidates;

  /// Currently selected candidate ID
  final int? selectedCandidateId;

  /// User candidate details (deprecated: use candidates and selectedCandidateId instead)
  final Map<String, dynamic>? candidateDetails;

  /// Constructor
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.photoUrl,
    this.headline,
    required this.token,
    this.message,
    this.candidates,
    this.selectedCandidateId,
    this.candidateDetails,
  });

  @override
  List<Object?> get props => [id, name, email, role, photoUrl, headline, token, message, candidates, selectedCandidateId, candidateDetails];
}
