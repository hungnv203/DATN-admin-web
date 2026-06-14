import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final TextEditingController _qrController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _checkIn() async {
    final qrCode = _qrController.text.trim();
    if (qrCode.isEmpty) {
      setState(() => _message = "Vui lòng nhập mã QR");
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final dio = Dio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.tickets}/checkin',
        data: {'qrCode': qrCode},
      );

      setState(() {
        _message = response.data['message'] ?? 'Check-in thành công';
      });
    } on DioException catch (e) {
      setState(() {
        _message = e.response?.data?['message'] ?? "Lỗi kết nối server";
      });
    } catch (e) {
      setState(() {
        _message = "Đã xảy ra lỗi không xác định";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in Vé (QR)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _qrController,
              decoration: const InputDecoration(
                labelText: 'Mã QR Code',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.qr_code_scanner),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkIn,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Thực hiện Check-in'),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
