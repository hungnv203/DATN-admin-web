import '../../domain/entities/pos_payment_result.dart';
import 'booking_model.dart';

class PosPaymentResultModel extends PosPaymentResult {
  const PosPaymentResultModel({
    required super.success,
    required super.isReplay,
    required super.paymentState,
    required super.errorCode,
    super.booking,
  });

  factory PosPaymentResultModel.fromJson(Map<String, dynamic> json) {
    final bookingJson = json['booking'];
    return PosPaymentResultModel(
      success: json['success'] == true,
      isReplay: json['isReplay'] == true,
      paymentState: json['paymentState']?.toString() ?? '',
      errorCode: json['errorCode']?.toString() ?? '',
      booking: bookingJson is Map
          ? BookingModel.fromJson(Map<String, dynamic>.from(bookingJson))
          : null,
    );
  }
}
