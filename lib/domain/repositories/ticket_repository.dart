import '../../domain/entities/ticket_detail.dart';

abstract class TicketRepository {
  Future<List<TicketDetail>> getTickets();
}
