// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _loading = false;
  String? _error;

  UserModel? get user => _api.currentUser;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => user != null;

  Future<bool> login(String username, String password) async {
    _loading = true; _error = null; notifyListeners();
    final result = await _api.login(username, password);
    _loading = false;
    if (result['ok'] == true) {
      notifyListeners();
      return true;
    }
    _error = result['error'] ?? 'Login failed';
    notifyListeners();
    return false;
  }

  void logout() {
    _api.logout();
    notifyListeners();
  }
}

