import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

abstract class StatisticRemoteDataSource {
  Future<DashboardSummary> getDashboardSummary(int days);
}

class StatisticRemoteDataSourceImpl implements StatisticRemoteDataSource {
  final DioClient client;

  StatisticRemoteDataSourceImpl(this.client);

  @override
  Future<DashboardSummary> getDashboardSummary(int days) async {
    final response = await client.get(
      '${ApiConstants.adminDashboard}?days=$days',
    );
    return DashboardSummary.fromJson(response.data);
  }
}
