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

  /// User candidate details
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
    this.candidateDetails,
  });

  @override
  List<Object?> get props => [id, name, email, role, photoUrl, headline, token, message, candidateDetails];
}
