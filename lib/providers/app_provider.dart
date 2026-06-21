// lib/providers/app_provider.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic>? dashStats;
  Map<String, dynamic>? todayAtt;
  Map<String, dynamic>? settings;
  bool loadingDash = false;

  Future<void> loadDashboard() async {
    loadingDash = true; notifyListeners();
    final results = await Future.wait([
      _api.getDashboardStats(),
      _api.getTodayAttendanceSummary(),
      _api.getSettings(),
    ]);
    dashStats = results[0]['ok'] == true ? results[0] : null;
    todayAtt  = results[1]['ok'] == true ? results[1] : null;
    settings  = results[2]['ok'] == true ? results[2]['data'] : null;
    loadingDash = false;
    notifyListeners();
  }
}
