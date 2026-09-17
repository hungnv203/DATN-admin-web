import '../datasources/statistic_remote_data_source.dart';
import '../models/dashboard_model.dart';

abstract class StatisticRepository {
  Future<DashboardSummary> getDashboardSummary(int days);
}

class StatisticRepositoryImpl implements StatisticRepository {
  final StatisticRemoteDataSource remoteDataSource;

  StatisticRepositoryImpl(this.remoteDataSource);

  @override
  Future<DashboardSummary> getDashboardSummary(int days) async {
    return await remoteDataSource.getDashboardSummary(days);
  }
}
