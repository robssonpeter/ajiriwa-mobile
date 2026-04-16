import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/job_apply_context_model.dart';
import '../models/job_apply_request_model.dart';
import '../models/job_apply_response_model.dart';
import '../models/job_details_model.dart';
import '../models/job_eligibility_model.dart';
import '../models/job_screening_model.dart';
import '../models/jobs_response_model.dart';
import '../models/pre_apply_analysis_model.dart';
import 'job_data_source.dart';

/// Implementation of the JobDataSource interface
class JobDataSourceImpl implements JobDataSource {
  /// API client
  final ApiClient apiClient;

  /// Constructor
  JobDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<JobDetailsModel> getJobDetails(String slug) async {
    try {
      final response = await apiClient.get('/job/$slug');

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobDetailsModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Job Details Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load job details');
      }
    }
  }

  @override
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
  }) async {
    try {
      // Build query parameters
      final queryParameters = <String, dynamic>{};

      // Add search query (API accepts either 'query' or 'search')
      if (query != null && query.isNotEmpty) {
        queryParameters['query'] = query;
      }

      // Add other filters if provided
      if (location != null && location.isNotEmpty) {
        queryParameters['location'] = location;
      }

      if (jobType != null && jobType.isNotEmpty) {
        queryParameters['job_type'] = jobType;
      }

      if (category != null) {
        queryParameters['category'] = category;
      }

      if (industry != null) {
        queryParameters['industry'] = industry;
      }

      if (minSalary != null) {
        queryParameters['min_salary'] = minSalary;
      }

      if (maxSalary != null) {
        queryParameters['max_salary'] = maxSalary;
      }

      // Add pagination parameters
      if (page != null) {
        queryParameters['page'] = page;
      }

      if (perPage != null) {
        queryParameters['per_page'] = perPage;
      }

      final response = await apiClient.get('/jobs', queryParameters: queryParameters);

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobsResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Jobs Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load jobs. Original error: ${e.runtimeType}');
      }
    }
  }

  @override
  Future<JobEligibilityModel> checkJobEligibility(int jobId, {int? candidateId}) async {
    try {
      // Validate job ID
      if (jobId <= 0) {
        throw ServerException('Invalid job ID: $jobId');
      }


      // Build query parameters if candidateId is provided
      final queryParameters = <String, dynamic>{};
      if (candidateId != null) {
        queryParameters['candidate_id'] = candidateId;
      }

      final response = await apiClient.get(
        '/jobs/$jobId/apply/eligibility', 
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null
      );

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobEligibilityModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Job Eligibility Data Source Error', error: e, stackTrace: stackTrace);

      // Try to get more information about the error
      if (e is ServerException) {
          throw e;
      } else {
          throw ServerException('Failed to check job eligibility: ${e.toString()}');
      }
    }
  }

  @override
  Future<JobScreeningModel> getJobScreening(int jobId) async {
    try {
      final response = await apiClient.get('/jobs/$jobId/screening');

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobScreeningModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Job Screening Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load job screening questions');
      }
    }
  }

  @override
  Future<JobApplyResponseModel> applyForJob(int jobId, JobApplyRequestModel request, {int? candidateId}) async {
    try {
      // Add candidateId to the request data if provided
      final requestData = request.toJson();
      if (candidateId != null) {
        requestData['candidate_id'] = candidateId;
      }

      final response = await apiClient.post('/jobs/$jobId/apply', data: requestData);

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobApplyResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Job Apply Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to apply for job');
      }
    }
  }

  @override
  Future<JobApplyIntentResponseModel> recordApplyIntent(int jobId, JobApplyIntentRequestModel request, {int? candidateId}) async {
    try {
      // Add candidateId to the request data if provided
      final requestData = request.toJson();
      if (candidateId != null) {
        requestData['candidate_id'] = candidateId;
      }

      final response = await apiClient.post('/jobs/$jobId/apply/intent', data: requestData);

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobApplyIntentResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Job Apply Intent Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to record apply intent');
      }
    }
  }

  @override
  Future<void> markExternalApplicationAsApplied(int applicationId) async {
    try {
      await apiClient.post('/applications/$applicationId/mark-applied');
    } catch (e, stackTrace) {
      appLogger.e('Mark External Application Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to mark external application as applied');
      }
    }
  }

  @override
  Future<void> recordExternalClick(int jobId, {int? candidateId}) async {
    try {
      // Add candidateId to the request data if provided
      final data = candidateId != null ? {'candidate_id': candidateId} : null;

      await apiClient.post('/jobs/$jobId/apply/external-click', data: data);
    } catch (e, stackTrace) {
      appLogger.e('Record External Click Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to record external click');
      }
    }
  }

  @override
  Future<JobApplyContextModel> getApplyContextBySlug(String slug, {int? candidateId}) async {
    try {

      // Build query parameters if candidateId is provided
      final queryParameters = <String, dynamic>{};
      if (candidateId != null) {
        queryParameters['candidate_id'] = candidateId;
      }

      final response = await apiClient.get(
        '/job/$slug/apply',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null
      );

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobApplyContextModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Job Apply Context Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load job apply context');
      }
    }
  }

  @override
  Future<List<JobDetailsModel>> getSavedJobs() async {
    try {
      final response = await apiClient.get('/jobs/saved');

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      // The response is an array of job objects
      final List<dynamic> jobsJson = response as List<dynamic>;

      // Convert each job object to a JobDetailsModel
      return jobsJson.map((job) => JobDetailsModel.fromJson(job as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      appLogger.e('Saved Jobs Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load saved jobs: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> saveJob(int jobId) async {
    try {
      await apiClient.post('/jobs/$jobId/save');
    } catch (e, stackTrace) {
      appLogger.e('Save Job Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to save job: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> unsaveJob(int jobId) async {
    try {
      await apiClient.delete('/jobs/$jobId/save');
    } catch (e, stackTrace) {
      appLogger.e('Unsave Job Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to unsave job: ${e.toString()}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getCandidates() async {
    try {
      final response = await apiClient.get('/api/v1/candidates');

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      appLogger.e('Get Candidates Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to get candidates: ${e.toString()}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> createCandidate(String professionalTitle) async {
    try {
      final response = await apiClient.post('/api/v1/candidates', data: {
        'professional_title': professionalTitle,
      });

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      appLogger.e('Create Candidate Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to create candidate: ${e.toString()}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> generateCoverLetter({
    required int jobId,
    String? startingPoint,
    String? refineInstructions,
    int? candidateId,
  }) async {
    try {
      final response = await apiClient.post('/cover-letter/generate', data: {
        'job_id': jobId,
        if (startingPoint != null) 'starting_point': startingPoint,
        if (refineInstructions != null) 'refine_instructions': refineInstructions,
        if (candidateId != null) 'candidate_id': candidateId,
      });

      if (response == null) {
        throw ServerException('Failed to generate cover letter');
      }

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      appLogger.e('Generate Cover Letter Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to generate cover letter: ${e.toString()}');
      }
    }
  }

  @override
  Future<PreApplyAnalysisModel> analyzeApplication({
    required String jobSlug,
    String? coverLetter,
    Map<String, dynamic>? screeningResponses,
    int? cvOptimizationId,
  }) async {
    try {
      final response = await apiClient.post('/pre-apply-analysis', data: {
        'job_slug': jobSlug,
        if (coverLetter != null) 'cover_letter': coverLetter,
        if (screeningResponses != null) 'screening_responses': screeningResponses,
        if (cvOptimizationId != null) 'cv_optimization_id': cvOptimizationId,
      });
      if (response == null) throw ServerException('Empty response from analysis');
      return PreApplyAnalysisModel.fromJson(response as Map<String, dynamic>);
    } catch (e, st) {
      appLogger.e('Pre-Apply Analysis Error', error: e, stackTrace: st);
      if (e is ServerException) rethrow;
      throw ServerException('Analysis failed: ${e.runtimeType}');
    }
  }

  @override
  Future<PreApplyAnalysisModel?> getAnalysis(String jobSlug) async {
    try {
      final response = await apiClient.get('/pre-apply-analysis', queryParameters: {
        'job_slug': jobSlug,
      });
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      if (data.isEmpty) return null;
      return PreApplyAnalysisModel.fromJson({'analysis': data});
    } catch (e, st) {
      appLogger.e('Get Analysis Error', error: e, stackTrace: st);
      return null;
    }
  }
}
