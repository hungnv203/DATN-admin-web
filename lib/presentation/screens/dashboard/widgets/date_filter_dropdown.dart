import 'package:flutter/material.dart';
import '../../../../core/theme/admin_theme.dart';

class DateFilterDropdown extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onDaysChanged;

  const DateFilterDropdown({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  static const List<Map<String, dynamic>> _options = [
    {'label': 'Hôm nay', 'days': 1},
    {'label': '7 ngày qua', 'days': 7},
    {'label': '30 ngày qua', 'days': 30},
    {'label': '90 ngày qua', 'days': 90},
    {'label': '1 năm qua', 'days': 365},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedDays,
          dropdownColor: AdminColors.surfaceHigh,
          style: const TextStyle(color: AdminColors.text, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AdminColors.muted),
          items: _options.map((option) {
            return DropdownMenuItem<int>(
              value: option['days'] as int,
              child: Text(option['label'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onDaysChanged(value);
          },
        ),
      ),
    );
  }
}
