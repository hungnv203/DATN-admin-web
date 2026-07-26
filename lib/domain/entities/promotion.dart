class Promotion {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final double minOrder;
  final String status;

  const Promotion({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.minOrder,
    required this.status,
  });
}
