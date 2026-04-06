import '../../domain/entities/cv_optimization.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/cv_optimization_repository.dart';
import '../datasources/cv_optimization_data_source.dart';

class CvOptimizationRepositoryImpl implements CvOptimizationRepository {
  final CvOptimizationDataSource dataSource;

  CvOptimizationRepositoryImpl({required this.dataSource});

  @override
  Future<List<CvOptimization>> getOptimizations() => dataSource.getOptimizations();

  @override
  Future<List<CvOptimization>> getOptimizationsForJob(int jobId) =>
      dataSource.getOptimizationsForJob(jobId);

  @override
  Future<CvOptimization> getOptimization(int id) => dataSource.getOptimization(id);

  @override
  Future<CvOptimization> createOptimization({
    required int jobId,
    required int candidateId,
    String? refinementInstruction,
  }) =>
      dataSource.createOptimization(
        jobId: jobId,
        candidateId: candidateId,
        refinementInstruction: refinementInstruction,
      );

  @override
  Future<CvOptimization> generatePdf(int id) => dataSource.generatePdf(id);

  @override
  Future<String> getPdfStatus(int id) => dataSource.getPdfStatus(id);

  @override
  Future<void> deleteOptimization(int id) => dataSource.deleteOptimization(id);

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() => dataSource.getSubscriptionPlans();

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required int planId,
    required String fromUrl,
  }) =>
      dataSource.initiatePayment(planId: planId, fromUrl: fromUrl);

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String trackingId) =>
      dataSource.checkPaymentStatus(trackingId);
}
