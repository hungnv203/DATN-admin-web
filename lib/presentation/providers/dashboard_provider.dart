import 'package:flutter/material.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/statistic_repository_impl.dart';

class DashboardProvider extends ChangeNotifier {
  final StatisticRepositoryImpl repository;

  DashboardSummary? _summaryData;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedDays = 30;
  DateTime? _lastUpdated;

  DashboardProvider(this.repository);

  DashboardSummary? get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedDays => _selectedDays;
  DateTime? get lastUpdated => _lastUpdated;

  Future<void> loadDashboard(int days, {bool isSilent = false}) async {
    _selectedDays = days;
    if (!isSilent || _summaryData == null) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final data = await repository.getDashboardSummary(days);
      _summaryData = data;
      _lastUpdated = DateTime.now();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (_summaryData == null) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      notifyListeners();
    }
  }
}
