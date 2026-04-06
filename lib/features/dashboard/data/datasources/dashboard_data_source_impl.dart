import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';
import 'dashboard_data_source.dart';

/// Implementation of the DashboardDataSource interface
class DashboardDataSourceImpl implements DashboardDataSource {
  /// API client
  final ApiClient apiClient;

  /// Constructor
  DashboardDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<DashboardModel> getDashboard() async {
    try {
      final response = await apiClient.get('/dashboard');
      return DashboardModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load dashboard data');
      }
    }
  }
}