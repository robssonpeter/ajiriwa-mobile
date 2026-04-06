import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_data_source.dart';
import '../models/dashboard_model.dart';

/// Implementation of the DashboardRepository interface
class DashboardRepositoryImpl implements DashboardRepository {
  /// Remote data source
  final DashboardDataSource remoteDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  /// Constructor
  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Helper method to map recent applications from models to entities
  List<RecentApplication> _mapRecentApplications(List<RecentApplicationModel> applications) {
    return applications.map((app) {
      if (app.job == null) {
        // Handle case where job is null
        return RecentApplication(
          id: app.id,
          status: app.status,
          appliedAt: app.appliedAt,
          job: null,
        );
      } else {
        // Handle case where job is not null
        return RecentApplication(
          id: app.id,
          status: app.status,
          appliedAt: app.appliedAt,
          job: Job(
            id: app.job!.id,
            title: app.job!.title,
            location: app.job!.location,
            deadline: app.job!.deadline,
            company: Company(
              id: app.job!.company.id,
              name: app.job!.company.name,
              logo: app.job!.company.logo,
              logoUrl: app.job!.company.logoUrl,
            ),
          ),
        );
      }
    }).toList();
  }

  @override
  Future<Either<Failure, Dashboard>> getDashboard() async {
    if (await networkInfo.isConnected) {
      try {
        final dashboardModel = await remoteDataSource.getDashboard();
        // Convert DashboardModel to Dashboard entity
        final dashboard = Dashboard(
          profileCompletion: ProfileCompletion(
            percentage: dashboardModel.profileCompletion.percentage,
            missingSections: dashboardModel.profileCompletion.missingSections,
          ),
          recommendedJobs: dashboardModel.recommendedJobs
              .map((job) => RecommendedJob(
                    id: job.id,
                    title: job.title,
                    location: job.location,
                    minSalary: job.minSalary,
                    maxSalary: job.maxSalary,
                    type: job.type,
                    deadline: job.deadline,
                    isApplied: job.isApplied,
                    isSaved: job.isSaved,
                    slug: job.slug,
                    company: Company(
                      id: job.company.id,
                      name: job.company.name,
                      logo: job.company.logo,
                      logoUrl: job.company.logoUrl,
                    ),
                  ))
              .toList(),
          recentApplications: _mapRecentApplications(dashboardModel.recentApplications),
        );
        return Right(dashboard);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
