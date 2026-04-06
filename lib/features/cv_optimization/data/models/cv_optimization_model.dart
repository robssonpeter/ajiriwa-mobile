import '../../domain/entities/cv_optimization.dart';

class CvOptimizationModel extends CvOptimization {
  const CvOptimizationModel({
    required super.id,
    required super.jobId,
    required super.candidateId,
    required super.status,
    required super.version,
    super.jobTitle,
    super.companyName,
    super.content,
    super.pdfUrl,
    super.pdfStatus,
    super.refinementInstruction,
    required super.createdAt,
  });

  factory CvOptimizationModel.fromJson(Map<String, dynamic> json) {
    return CvOptimizationModel(
      id: json['id'] as int,
      jobId: json['job_id'] as int,
      candidateId: json['candidate_id'] as int,
      status: json['status'] as String? ?? 'pending',
      version: json['version'] as int? ?? 1,
      jobTitle: json['job']?['title'] as String?,
      companyName: json['job']?['company']?['name'] as String?,
      content: json['content'] as Map<String, dynamic>?,
      pdfUrl: json['pdf_url'] as String?,
      pdfStatus: json['pdf_status'] as String?,
      refinementInstruction: json['refinement_instruction'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'job_id': jobId,
        'candidate_id': candidateId,
        'status': status,
        'version': version,
        'pdf_url': pdfUrl,
        'pdf_status': pdfStatus,
        'refinement_instruction': refinementInstruction,
        'created_at': createdAt.toIso8601String(),
      };
}
