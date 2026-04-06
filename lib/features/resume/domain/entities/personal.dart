import 'package:equatable/equatable.dart';

/// Personal information entity for resume
class Personal extends Equatable {
  /// First name
  final String firstName;

  /// Last name
  final String lastName;

  /// Email
  final String email;

  /// Phone
  final String? phone;

  /// Address
  final String? address;

  /// City
  final String? city;

  /// Country
  final String? country;

  /// Postal code
  final String? postalCode;

  /// Gender
  final String? gender;

  /// Date of birth
  final String? dateOfBirth;

  /// Headline/title
  final String? headline;

  /// Summary
  final String? summary;

  /// Photo URL
  final String? photoUrl;

  /// Constructor
  const Personal({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.gender,
    this.dateOfBirth,
    this.headline,
    this.summary,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phone,
        address,
        city,
        country,
        postalCode,
        gender,
        dateOfBirth,
        headline,
        summary,
        photoUrl,
      ];
}