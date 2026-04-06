import '../models/dashboard_model.dart';

/// Data source interface for dashboard data
abstract class DashboardDataSource {
  /// Get dashboard data from the API
  Future<DashboardModel> getDashboard();
}