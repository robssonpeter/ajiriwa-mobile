import 'package:equatable/equatable.dart';

/// Reference entity for resume
class Reference extends Equatable {
  /// Reference ID
  final int? id;

  /// Reference name
  final String name;

  /// Reference position/title
  final String position;

  /// Reference company/organization
  final String company;

  /// Reference email
  final String? email;

  /// Reference phone
  final String? phone;

  /// Relationship
  final String? relationship;

  /// Constructor
  const Reference({
    this.id,
    required this.name,
    required this.position,
    required this.company,
    this.email,
    this.phone,
    this.relationship,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        position,
        company,
        email,
        phone,
        relationship,
      ];
}