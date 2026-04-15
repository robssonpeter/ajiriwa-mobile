import '../../domain/entities/award.dart';

/// Award/Certificate model for resume
class AwardModel extends Award {
  /// Constructor
  const AwardModel({
    int? id,
    required String name,
    required String issuer,
    required String date,
    String? description,
    int? categoryId,
    String? category,
    String? countryId,
    String? country,
    int? industryId,
    String? industry,
    String? attachment,
    String? filePath,
  }) : super(
          id: id,
          name: name,
          issuer: issuer,
          date: date,
          description: description,
          categoryId: categoryId,
          category: category,
          countryId: countryId,
          country: country,
          industryId: industryId,
          industry: industry,
          attachment: attachment,
          filePath: filePath,
        );

  /// Create a model from JSON
  factory AwardModel.fromJson(Map<String, dynamic> json) {
    return AwardModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      date: json['date'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: json['category_id'] as int?,
      category: json['category'] as String?,
      countryId: json['country_id'] as String?,
      country: json['country'] as String?,
      industryId: json['industry_id'] as int?,
      industry: json['industry'] as String?,
      attachment: json['attachment_url'] as String? ?? json['attachment'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'date': date,
      'description': description,
      'category_id': categoryId,
      'category': category,
      'country_id': countryId,
      'country': country,
      'industry_id': industryId,
      'industry': industry,
      'attachment_url': attachment,
    };
  }
}
