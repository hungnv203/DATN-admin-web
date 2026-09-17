import '../../domain/entities/ticket_detail.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_data_source.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TicketDetail>> getTickets() async =>
      List<TicketDetail>.from(await remoteDataSource.getTickets());
}
