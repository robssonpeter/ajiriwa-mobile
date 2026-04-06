import '../models/job_apply_context_model.dart';
import '../models/job_apply_request_model.dart';
import '../models/job_apply_response_model.dart';
import '../models/job_details_model.dart';
import '../models/job_eligibility_model.dart';
import '../models/job_screening_model.dart';
import '../models/jobs_response_model.dart';

/// Data source interface for job data
abstract class JobDataSource {
  /// Get job details from the API by slug
  Future<JobDetailsModel> getJobDetails(String slug);

  /// Get jobs list from the API with optional filters
  Future<JobsResponseModel> getJobs({
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
  Future<JobEligibilityModel> checkJobEligibility(int jobId, {int? candidateId});

  /// Get screening questions for a job
  Future<JobScreeningModel> getJobScreening(int jobId);

  /// Apply for a job
  Future<JobApplyResponseModel> applyForJob(int jobId, JobApplyRequestModel request, {int? candidateId});

  /// Record apply intent for external URL or instruction-based applications
  Future<JobApplyIntentResponseModel> recordApplyIntent(int jobId, JobApplyIntentRequestModel request, {int? candidateId});

  /// Mark an external application as applied
  Future<void> markExternalApplicationAsApplied(int applicationId);

  /// Record external click for a job
  Future<void> recordExternalClick(int jobId, {int? candidateId});

  /// Get apply context by slug
  Future<JobApplyContextModel> getApplyContextBySlug(String slug, {int? candidateId});

  /// Get saved jobs from the API
  Future<List<JobDetailsModel>> getSavedJobs();

  /// Save a job
  Future<void> saveJob(int jobId);

  /// Unsave a job
  Future<void> unsaveJob(int jobId);

  /// Get list of candidates (CVs) for the current user
  Future<Map<String, dynamic>> getCandidates();

  /// Create a new candidate (CV) for the current user
  Future<Map<String, dynamic>> createCandidate(String professionalTitle);
}
