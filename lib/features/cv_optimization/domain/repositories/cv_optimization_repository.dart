import '../entities/cv_optimization.dart';
import '../entities/subscription_plan.dart';

abstract class CvOptimizationRepository {
  Future<List<CvOptimization>> getOptimizations();
  Future<List<CvOptimization>> getOptimizationsForJob(int jobId);
  Future<CvOptimization> getOptimization(int id);
  Future<CvOptimization> createOptimization({
    required int jobId,
    required int candidateId,
    String? refinementInstruction,
  });
  Future<CvOptimization> generatePdf(int id);
  Future<String> getPdfStatus(int id);
  Future<void> deleteOptimization(int id);

  // Subscription & Payment
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  Future<Map<String, dynamic>> initiatePayment({
    required int planId,
    required String fromUrl,
  });
  Future<Map<String, dynamic>> checkPaymentStatus(String trackingId);
}
