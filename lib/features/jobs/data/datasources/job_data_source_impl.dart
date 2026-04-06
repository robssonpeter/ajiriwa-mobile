import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/job_apply_context_model.dart';
import '../models/job_apply_request_model.dart';
import '../models/job_apply_response_model.dart';
import '../models/job_details_model.dart';
import '../models/job_eligibility_model.dart';
import '../models/job_screening_model.dart';
import '../models/jobs_response_model.dart';
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
      print('Job Details Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Jobs Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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

      print('Checking job eligibility for job ID: $jobId, candidateId: $candidateId');

      // Build query parameters if candidateId is provided
      final queryParameters = <String, dynamic>{};
      if (candidateId != null) {
        queryParameters['candidate_id'] = candidateId;
      }

      final response = await apiClient.get(
        '/jobs/$jobId/apply/eligibility', 
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null
      );
      print('Job eligibility response: $response');

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return JobEligibilityModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Job Eligibility Data Source Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('Stack Trace: $stackTrace');

      // Try to get more information about the error
      if (e is ServerException) {
        print('Server Exception Message: ${e.message}');
        throw e;
      } else {
        print('Unknown Error: $e');
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
      print('Job Screening Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Job Apply Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Job Apply Intent Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Mark External Application Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Record External Click Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print("fetching application information using $slug, candidateId: $candidateId");

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
      print('Job Apply Context Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Saved Jobs Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Saving job with ID: $jobId');
      await apiClient.post('/jobs/$jobId/save');
    } catch (e, stackTrace) {
      print('Save Job Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Unsaving job with ID: $jobId');
      await apiClient.delete('/jobs/$jobId/save');
    } catch (e, stackTrace) {
      print('Unsave Job Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Getting candidates list');
      final response = await apiClient.get('/api/v1/candidates');

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      print('Get Candidates Data Source Error: $e');
      print('Stack Trace: $stackTrace');
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
      print('Creating new candidate with professional title: $professionalTitle');
      final response = await apiClient.post('/api/v1/candidates', data: {
        'professional_title': professionalTitle,
      });

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      print('Create Candidate Data Source Error: $e');
      print('Stack Trace: $stackTrace');
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to create candidate: ${e.toString()}');
      }
    }
  }
}
