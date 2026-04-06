import '../../domain/entities/reference.dart';

/// Reference model for resume
class ReferenceModel extends Reference {
  /// Constructor
  const ReferenceModel({
    int? id,
    required String name,
    required String position,
    required String company,
    String? email,
    String? phone,
    String? relationship,
  }) : super(
          id: id,
          name: name,
          position: position,
          company: company,
          email: email,
          phone: phone,
          relationship: relationship,
        );

  /// Create a model from JSON
  factory ReferenceModel.fromJson(Map<String, dynamic> json) {
    return ReferenceModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      position: json['position'] as String,
      company: json['company'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      relationship: json['relationship'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'company': company,
      'email': email,
      'phone': phone,
      'relationship': relationship,
    };
  }
}