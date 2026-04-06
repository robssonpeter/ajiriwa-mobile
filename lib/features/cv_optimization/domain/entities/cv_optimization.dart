import 'package:equatable/equatable.dart';

class CvOptimization extends Equatable {
  final int id;
  final int jobId;
  final int candidateId;
  final String status; // pending, processing, completed, failed
  final int version;
  final String? jobTitle;
  final String? companyName;
  final Map<String, dynamic>? content;
  final String? pdfUrl;
  final String? pdfStatus;
  final String? refinementInstruction;
  final DateTime createdAt;

  const CvOptimization({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.status,
    required this.version,
    this.jobTitle,
    this.companyName,
    this.content,
    this.pdfUrl,
    this.pdfStatus,
    this.refinementInstruction,
    required this.createdAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isProcessing => status == 'processing' || status == 'pending';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [id, jobId, candidateId, status, version, createdAt];
}
