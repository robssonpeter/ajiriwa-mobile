import '../models/cv_optimization_model.dart';
import '../models/subscription_plan_model.dart';

abstract class CvOptimizationDataSource {
  Future<List<CvOptimizationModel>> getOptimizations();
  Future<List<CvOptimizationModel>> getOptimizationsForJob(int jobId);
  Future<CvOptimizationModel> getOptimization(int id);
  Future<CvOptimizationModel> createOptimization({
    required int jobId,
    required int candidateId,
    String? refinementInstruction,
  });
  Future<CvOptimizationModel> generatePdf(int id);
  Future<String> getPdfStatus(int id);
  Future<void> deleteOptimization(int id);
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans();
  Future<Map<String, dynamic>> initiatePayment({
    required int planId,
    required String fromUrl,
  });
  Future<Map<String, dynamic>> checkPaymentStatus(String trackingId);
}
