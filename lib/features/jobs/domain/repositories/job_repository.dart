import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/job_apply_context.dart';
import '../entities/job_apply_response.dart';
import '../entities/job_details.dart';
import '../entities/job_eligibility.dart';
import '../entities/job_screening.dart';
import '../entities/jobs_response.dart';
import '../entities/pre_apply_analysis.dart';

/// Repository interface for job data
abstract class JobRepository {
  /// Get job details by slug
  Future<Either<Failure, JobDetails>> getJobDetails(String slug);

  /// Get jobs list with optional filters
  Future<Either<Failure, JobsResponse>> getJobs({
    String? query,
    String? location,
    String? jobType,
    int? category,
    int? industry,
    int? minSalary,
    int? maxSalary,
    int? page,
    int? perPage,
  });

  /// Check eligibility to apply for a job
  Future<Either<Failure, JobEligibility>> checkJobEligibility(int jobId, {int? candidateId});

  /// Get screening questions for a job
  Future<Either<Failure, JobScreening>> getJobScreening(int jobId);

  /// Apply for a job
  Future<Either<Failure, JobApplyResponse>> applyForJob({
    required int jobId,
    required List<Map<String, dynamic>> screeningAnswers,
    required int resumeId,
    String? coverLetter,
    List<Map<String, dynamic>>? attachments,
    int? candidateId,
  });

  /// Record apply intent for external URL or instruction-based applications
  Future<Either<Failure, JobApplyIntentResponse>> recordApplyIntent({
    required int jobId,
    required String mode,
    String? notes,
    int? candidateId,
  });

  /// Mark an external application as applied
  Future<Either<Failure, void>> markExternalApplicationAsApplied(int applicationId);

  /// Record external click for a job
  Future<Either<Failure, void>> recordExternalClick(int jobId, {int? candidateId});

  /// Get apply context by slug
  Future<Either<Failure, JobApplyContext>> getApplyContextBySlug(String slug, {int? candidateId});

  /// Get saved jobs
  Future<Either<Failure, List<JobDetails>>> getSavedJobs();

  /// Save a job
  Future<Either<Failure, void>> saveJob(int jobId);

  /// Unsave a job
  Future<Either<Failure, void>> unsaveJob(int jobId);

  /// Get list of candidates (CVs) for the current user
  Future<Either<Failure, Map<String, dynamic>>> getCandidates();

  /// Create a new candidate (CV) for the current user
  Future<Either<Failure, Map<String, dynamic>>> createCandidate(String professionalTitle);

  /// Generate an AI cover letter
  Future<Either<Failure, Map<String, dynamic>>> generateCoverLetter({
    required int jobId,
    String? startingPoint,
    String? refineInstructions,
    int? candidateId,
  });

  /// Run pre-application analysis
  Future<Either<Failure, PreApplyAnalysis>> analyzeApplication({
    required String jobSlug,
    String? coverLetter,
    Map<String, dynamic>? screeningResponses,
    int? cvOptimizationId,
  });

  /// Get existing pre-application analysis for a job
  Future<Either<Failure, PreApplyAnalysis?>> getAnalysis(String jobSlug);
}
