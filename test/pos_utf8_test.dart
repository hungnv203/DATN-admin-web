import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('POS source contains valid Vietnamese without mojibake markers', () {
    final source = File(
      'lib/presentation/screens/pos_simulator_screen.dart',
    ).readAsStringSync();

    for (final marker in const ['Ã', 'Ä', 'Â', 'á»', 'áº', 'â€¦', '\uFFFD']) {
      expect(source, isNot(contains(marker)), reason: 'Found $marker');
    }
    expect(source, contains('Xác nhận và giữ ghế'));
    expect(source, contains('Tiếp tục tạo đơn chờ thanh toán'));
    expect(source, contains('Xác nhận đã nhận tiền mặt'));
    expect(source, contains('Hủy và trả ghế'));
    expect(source, isNot(contains('holdCreateAndConfirmCash')));
    expect(source, contains('confirmPendingCashPayment'));
    expect(source, contains('cancelCurrentFlow'));
  });
}
