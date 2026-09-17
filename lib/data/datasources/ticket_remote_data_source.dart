import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/ticket_detail_model.dart';

abstract class TicketRemoteDataSource {
  Future<List<TicketDetailModel>> getTickets();
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final DioClient client;

  TicketRemoteDataSourceImpl(this.client);

  @override
  Future<List<TicketDetailModel>> getTickets() async {
    final response = await client.get(ApiConstants.tickets);
    final List<dynamic> data = response.data;
    return data.map((json) => TicketDetailModel.fromJson(json)).toList();
  }
}
