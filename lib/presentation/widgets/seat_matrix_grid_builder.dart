import 'package:flutter/material.dart';

class SeatMatrixGridBuilder extends StatefulWidget {
  final int rows;
  final int columns;
  final Map<String, String> initialSeatMap;
  final Function(Map<String, String> seatMap) onChanged;

  const SeatMatrixGridBuilder({
    super.key,
    required this.rows,
    required this.columns,
    required this.initialSeatMap,
    required this.onChanged,
  });

  @override
  State<SeatMatrixGridBuilder> createState() => _SeatMatrixGridBuilderState();
}

class _SeatMatrixGridBuilderState extends State<SeatMatrixGridBuilder> {
  late Map<String, String> _seatMap;

  @override
  void initState() {
    super.initState();
    _initSeatMap();
  }

  @override
  void didUpdateWidget(covariant SeatMatrixGridBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows || oldWidget.columns != widget.columns) {
      _initSeatMap();
    }
  }

  void _initSeatMap() {
    _seatMap = Map<String, String>.from(widget.initialSeatMap);
    
    // Ensure all grid cells are initialized
    for (int r = 0; r < widget.rows; r++) {
      final rowLabel = String.fromCharCode(65 + r); // A, B, C, D...
      for (int c = 1; c <= widget.columns; c++) {
        final key = '$rowLabel-$c';
        _seatMap.putIfAbsent(key, () => 'Standard');
      }
    }
    widget.onChanged(_seatMap);
  }

  void _toggleSeatType(String key) {
    setState(() {
      final currentType = _seatMap[key];
      String nextType;
      if (currentType == 'Standard') {
        nextType = 'VIP';
      } else if (currentType == 'VIP') {
        nextType = 'Couple';
      } else if (currentType == 'Couple') {
        nextType = 'Empty';
      } else {
        nextType = 'Standard';
      }
      _seatMap[key] = nextType;
    });
    widget.onChanged(_seatMap);
  }

  Color _getSeatColor(String type) {
    switch (type) {
      case 'Standard':
        return Colors.blueGrey.shade700;
      case 'VIP':
        return const Color(0xFFD4AF37); // Gold
      case 'Couple':
        return const Color(0xFFEC407A); // Pink
      case 'Empty':
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend indicator
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(Colors.blueGrey.shade700, 'Ghế thường'),
            _buildLegendItem(const Color(0xFFD4AF37), 'Ghế VIP'),
            _buildLegendItem(const Color(0xFFEC407A), 'Ghế Đôi (Couple)'),
            _buildLegendItem(Colors.white.withOpacity(0.1), 'Ghế Trống (Không có ghế)', borderOnly: true),
          ],
        ),
        const SizedBox(height: 24),
        
        // Grid Builder scroll container
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF16171E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // Screen Indicator
                  Container(
                    width: widget.columns * 60.0 + 40,
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF66FCF1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: const Border(
                        top: BorderSide(color: Color(0xFF66FCF1), width: 2),
                      ),
                    ),
                    child: const Text(
                      'MÀN HÌNH CHIẾU PHIM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF66FCF1),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  
                  // Seats rows
                  for (int r = 0; r < widget.rows; r++) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Row letter indicator on the left
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            String.fromCharCode(65 + r),
                            style: const TextStyle(
                              color: Color(0xFF66FCF1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Seat numbers in the row
                        for (int c = 1; c <= widget.columns; c++) ...[
                          (() {
                            final rowLabel = String.fromCharCode(65 + r);
                            final key = '$rowLabel-$c';
                            final type = _seatMap[key] ?? 'Standard';
                            final color = _getSeatColor(type);
                            
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () => _toggleSeatType(key),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: type == 'Empty' 
                                        ? Colors.white.withOpacity(0.15) 
                                        : Colors.white.withOpacity(0.2),
                                      style: type == 'Empty' ? BorderStyle.solid : BorderStyle.none,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    type == 'Empty' ? '' : '$c',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }()),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                  ]
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool borderOnly = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: borderOnly ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(4),
            border: borderOnly ? Border.all(color: color) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 13),
        ),
      ],
    );
  }
}
