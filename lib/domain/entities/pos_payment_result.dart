import 'booking.dart';

class PosPaymentResult {
  final bool success;
  final bool isReplay;
  final String paymentState;
  final String errorCode;
  final Booking? booking;

  const PosPaymentResult({
    required this.success,
    required this.isReplay,
    required this.paymentState,
    required this.errorCode,
    this.booking,
  });
}
