import '../../../../core/network/api_client.dart';
import '../models/cv_optimization_model.dart';
import '../models/subscription_plan_model.dart';
import 'cv_optimization_data_source.dart';

class CvOptimizationDataSourceImpl implements CvOptimizationDataSource {
  final ApiClient apiClient;

  CvOptimizationDataSourceImpl({required this.apiClient});

  @override
  Future<List<CvOptimizationModel>> getOptimizations() async {
    final response = await apiClient.get('/cv-optimizations');
    final data = response['data'] as List<dynamic>? ?? response as List<dynamic>? ?? [];
    return data.map((e) => CvOptimizationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CvOptimizationModel>> getOptimizationsForJob(int jobId) async {
    final response = await apiClient.get('/jobs/$jobId/cv-optimizations');
    final data = response['data'] as List<dynamic>? ?? response as List<dynamic>? ?? [];
    return data.map((e) => CvOptimizationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CvOptimizationModel> getOptimization(int id) async {
    final response = await apiClient.get('/cv-optimizations/$id');
    final data = response['data'] ?? response;
    return CvOptimizationModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CvOptimizationModel> createOptimization({
    required int jobId,
    required int candidateId,
    String? refinementInstruction,
  }) async {
    final body = <String, dynamic>{
      'job_id': jobId,
      'candidate_id': candidateId,
    };
    if (refinementInstruction != null && refinementInstruction.isNotEmpty) {
      body['refinement_instruction'] = refinementInstruction;
    }
    final response = await apiClient.post('/cv-optimizations', data: body);
    final data = response['data'] ?? response['optimization'] ?? response;
    return CvOptimizationModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CvOptimizationModel> generatePdf(int id) async {
    final response = await apiClient.post('/cv-optimizations/$id/generate-pdf');
    final data = response['data'] ?? response['optimization'] ?? response;
    return CvOptimizationModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<String> getPdfStatus(int id) async {
    final response = await apiClient.get('/cv-optimizations/$id/pdf-status');
    return response['status'] as String? ?? 'pending';
  }

  @override
  Future<void> deleteOptimization(int id) async {
    await apiClient.delete('/cv-optimizations/$id');
  }

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    final response = await apiClient.get('/subscription/plans');
    final data = response as List<dynamic>? ?? response['data'] as List<dynamic>? ?? [];
    return data.map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required int planId,
    required String fromUrl,
  }) async {
    final response = await apiClient.post('/subscription/initiate', data: {
      'plan_id': planId,
      'from_url': fromUrl,
    });
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String trackingId) async {
    final response = await apiClient.get('/payment/status', queryParameters: {
      'tracking_id': trackingId,
    });
    return response as Map<String, dynamic>;
  }
}
