import '../../domain/entities/user.dart';

/// User model
class UserModel extends User {
  /// Constructor
  const UserModel({
    required int id,
    required String name,
    required String email,
    String? role,
    String? photoUrl,
    String? headline,
    required String token,
    String? message,
    Map<String, dynamic>? candidateDetails,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: role,
          photoUrl: photoUrl,
          headline: headline,
          token: token,
          message: message,
          candidateDetails: candidateDetails,
        );

  /// Create a model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      photoUrl: json['profile_photo_url'],
      headline: json['professional_title'] ?? json['headline'],
      token: json['token'] ?? '',
      message: json['message'],
      candidateDetails: json['candidate'] != null ? Map<String, dynamic>.from(json['candidate']) : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_photo_url': photoUrl,
      'headline': headline,
      'token': token,
      'message': message,
      'candidate': candidateDetails,
    };
  }
}
