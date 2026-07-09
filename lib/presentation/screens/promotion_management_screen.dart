import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class PromotionManagementScreen extends StatefulWidget {
  const PromotionManagementScreen({super.key});

  @override
  State<PromotionManagementScreen> createState() =>
      _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  final List<_Promotion> _promotions = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPromotions());
  }

  Future<void> _fetchPromotions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = context.read<DioClient>();
      final response = await client.get(ApiConstants.promotions);
      final data = response.data as List<dynamic>;
      setState(() {
        _promotions
          ..clear()
          ..addAll(data.map((item) => _Promotion.fromJson(item)));
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePromotion({_Promotion? promotion}) async {
    final result = await showDialog<_PromotionFormResult>(
      context: context,
      builder: (_) => _PromotionDialog(promotion: promotion),
    );
    if (result == null) return;

    try {
      final client = context.read<DioClient>();
      final payload = result.toJson(id: promotion?.id);
      if (promotion == null) {
        await client.post(ApiConstants.promotions, data: payload);
      } else {
        await client.put('${ApiConstants.promotions}/${promotion.id}',
            data: payload);
      }
      await _fetchPromotions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deletePromotion(_Promotion promotion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete promotion'),
        content: Text('Delete code ${promotion.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final client = context.read<DioClient>();
      await client.delete('${ApiConstants.promotions}/${promotion.id}');
      await _fetchPromotions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      appBar: AppBar(
        title: const Text('Promotion Management'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _fetchPromotions,
            icon: const Icon(Icons.refresh_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _savePromotion(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New code'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoading && _promotions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _promotions.isEmpty
                ? Center(child: Text(_errorMessage!))
                : ListView.separated(
                    itemCount: _promotions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final promotion = _promotions[index];
                      return _PromotionTile(
                        promotion: promotion,
                        onEdit: () => _savePromotion(promotion: promotion),
                        onDelete: () => _deletePromotion(promotion),
                      );
                    },
                  ),
      ),
    );
  }
}

class _PromotionTile extends StatelessWidget {
  const _PromotionTile({
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
  });

  final _Promotion promotion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16171E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${promotion.discountType} ${promotion.discountValue} | Min ${promotion.minOrder} | ${promotion.status}',
                  style: const TextStyle(color: Color(0xFFC5C6C7)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: onDelete,
            color: Colors.redAccent,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _PromotionDialog extends StatefulWidget {
  const _PromotionDialog({this.promotion});

  final _Promotion? promotion;

  @override
  State<_PromotionDialog> createState() => _PromotionDialogState();
}

class _PromotionDialogState extends State<_PromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _valueController;
  late final TextEditingController _minOrderController;
  String _discountType = 'Fixed';
  String _status = 'Active';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    final promotion = widget.promotion;
    _codeController = TextEditingController(text: promotion?.code ?? '');
    _valueController = TextEditingController(
      text: promotion?.discountValue.toStringAsFixed(0) ?? '',
    );
    _minOrderController = TextEditingController(
      text: promotion?.minOrder.toStringAsFixed(0) ?? '0',
    );
    _discountType = promotion?.discountType ?? 'Fixed';
    _status = promotion?.status ?? 'Active';
    _startDate = promotion?.startDate ?? _startDate;
    _endDate = promotion?.endDate ?? _endDate;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.promotion == null ? 'New promotion' : 'Edit promotion'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _discountType,
                decoration: const InputDecoration(labelText: 'Discount type'),
                items: const [
                  DropdownMenuItem(value: 'Fixed', child: Text('Fixed amount')),
                  DropdownMenuItem(value: 'Percent', child: Text('Percent')),
                ],
                onChanged: (value) => setState(() {
                  _discountType = value ?? 'Fixed';
                }),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount value'),
                validator: _positiveNumberValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min order'),
                validator: _nonNegativeNumberValidator,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) => setState(() {
                  _status = value ?? 'Active';
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Start: ${_formatDate(_startDate)}')),
                  TextButton(
                    onPressed: () => _pickDate(isStart: true),
                    child: const Text('Pick'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('End: ${_formatDate(_endDate)}')),
                  TextButton(
                    onPressed: () => _pickDate(isStart: false),
                    child: const Text('Pick'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: current,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _PromotionFormResult(
        code: _codeController.text.trim(),
        discountType: _discountType,
        discountValue: double.parse(_valueController.text.trim()),
        startDate: _startDate,
        endDate: _endDate,
        minOrder: double.parse(_minOrderController.text.trim()),
        status: _status,
      ),
    );
  }

  String? _positiveNumberValidator(String? value) {
    final parsed = double.tryParse(value ?? '');
    return parsed == null || parsed <= 0 ? 'Must be greater than 0' : null;
  }

  String? _nonNegativeNumberValidator(String? value) {
    final parsed = double.tryParse(value ?? '');
    return parsed == null || parsed < 0 ? 'Must be 0 or greater' : null;
  }
}

class _Promotion {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final double minOrder;
  final String status;

  const _Promotion({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.minOrder,
    required this.status,
  });

  factory _Promotion.fromJson(Map<String, dynamic> json) {
    return _Promotion(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      discountType: json['discountType'] ?? '',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.now(),
      minOrder: (json['minOrder'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}

class _PromotionFormResult {
  final String code;
  final String discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final double minOrder;
  final String status;

  const _PromotionFormResult({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.minOrder,
    required this.status,
  });

  Map<String, dynamic> toJson({String? id}) {
    return {
      if (id != null) 'id': id,
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'minOrder': minOrder,
      'status': status,
    };
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
