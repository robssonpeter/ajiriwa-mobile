import 'package:equatable/equatable.dart';

/// Award/Certificate entity for resume
class Award extends Equatable {
  /// Award ID
  final int? id;

  /// Award/Certificate name
  final String name;

  /// Issuing organization
  final String issuer;

  /// Date received
  final String date;

  /// Description
  final String? description;

  /// Category ID
  final int? categoryId;

  /// Category name
  final String? category;

  /// Country ID (ISO code)
  final String? countryId;

  /// Country name
  final String? country;

  /// Industry ID
  final int? industryId;

  /// Industry name
  final String? industry;

  /// Attachment URL (from server)
  final String? attachment;

  /// Local file path for upload
  final String? filePath;

  /// Constructor
  const Award({
    this.id,
    required this.name,
    required this.issuer,
    required this.date,
    this.description,
    this.categoryId,
    this.category,
    this.countryId,
    this.country,
    this.industryId,
    this.industry,
    this.attachment,
    this.filePath,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        issuer,
        date,
        description,
        categoryId,
        category,
        countryId,
        country,
        industryId,
        industry,
        attachment,
        filePath,
      ];
}
