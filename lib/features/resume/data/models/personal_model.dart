import '../../domain/entities/personal.dart';

/// Personal information model for resume
class PersonalModel extends Personal {
  /// Constructor
  const PersonalModel({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? gender,
    String? dateOfBirth,
    String? headline,
    String? summary,
    String? photoUrl,
  }) : super(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address: address,
          city: city,
          country: country,
          postalCode: postalCode,
          gender: gender,
          dateOfBirth: dateOfBirth,
          headline: headline,
          summary: summary,
          photoUrl: photoUrl,
        );

  /// Create a model from JSON
  factory PersonalModel.fromJson(Map<String, dynamic> json) {
    return PersonalModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      headline: json['headline'] as String?,
      summary: json['summary'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'headline': headline,
      'summary': summary,
      'photoUrl': photoUrl,
    };
  }
}