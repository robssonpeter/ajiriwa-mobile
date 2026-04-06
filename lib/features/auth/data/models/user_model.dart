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
    String? token,
    String? message,
    List<Map<String, dynamic>>? candidates,
    int? selectedCandidateId,
    Map<String, dynamic>? candidateDetails,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: role,
          photoUrl: photoUrl,
          headline: headline,
          token: token ?? '',
          message: message,
          candidates: candidates,
          selectedCandidateId: selectedCandidateId,
          candidateDetails: candidateDetails,
        );

  /// Create a model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] != null ? json['user'] as Map<String, dynamic> : json;
    
    return UserModel(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      role: userData['role'],
      photoUrl: userData['profile_photo_url'],
      headline: userData['professional_title'] ?? userData['headline'],
      token: json['token'] ?? '',
      message: json['message'],
      candidates: json['candidateOptions'] != null 
          ? List<Map<String, dynamic>>.from(json['candidateOptions']) 
          : null,
      selectedCandidateId: json['selectedCandidateId'],
      candidateDetails: json['profile'] != null 
          ? Map<String, dynamic>.from(json['profile']) 
          : (userData['candidate'] != null ? Map<String, dynamic>.from(userData['candidate']) : null),
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
      'candidateOptions': candidates,
      'selectedCandidateId': selectedCandidateId,
      'profile': candidateDetails,
    };
  }
}
