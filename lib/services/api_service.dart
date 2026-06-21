// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/user.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  UserModel? currentUser;

  Future<Map<String, dynamic>> _post(String action, [dynamic params]) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.gasUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action, 'params': params ?? {}}),
      ).timeout(ApiConfig.timeout);
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {'ok': false, 'error': 'HTTP ${res.statusCode}'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Auth
  Future<Map<String, dynamic>> login(String u, String p) async {
    final r = await _post('login', {'username': u, 'password': p});
    if (r['ok'] == true) currentUser = UserModel.fromJson(r['user']);
    return r;
  }
  void logout() => currentUser = null;

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() => _post('getDashboardStats');
  Future<Map<String, dynamic>> getTodayAttendanceSummary() => _post('getTodayAttendanceSummary');

  // Students
  Future<Map<String, dynamic>> getStudents({String? query, String? grade, String? gender}) =>
      _post('searchStudentsAdvanced', {'query': query??'','grade': grade??'ALL','gender': gender??'ALL'});

  // Roll Call
  Future<Map<String, dynamic>> getDailyRoll(String date, String grade, [String tg='']) =>
      _post('getDailyRoll', {'date': date, 'grade': grade, 'teacherGrade': tg});
  Future<Map<String, dynamic>> saveDailyRoll(String date, List entries, [String tg='']) =>
      _post('saveDailyRoll', {'date': date, 'entries': entries, 'teacherGrade': tg});
  Future<Map<String, dynamic>> getTeacherDailyRoll(String date) =>
      _post('getTeacherDailyRoll', {'date': date});
  Future<Map<String, dynamic>> saveTeacherDailyRoll(String date, List entries) =>
      _post('saveTeacherDailyRoll', {'date': date, 'entries': entries});

  // Teachers
  Future<Map<String, dynamic>> getAllTeachers() => _post('getAllTeachers');
  Future<Map<String, dynamic>> getTeacherWorkload() => _post('getTeacherWorkload');

  // Timetable
  Future<Map<String, dynamic>> getTimetable(String grade) =>
      _post('getTimetable', {'grade': grade});

  // Duties & Committees
  Future<Map<String, dynamic>> getDuties([String? tid]) =>
      _post('getDuties', {'teacherId': tid??''});
  Future<Map<String, dynamic>> getCommittees() => _post('getCommittees');

  // Finance
  Future<Map<String, dynamic>> getFinanceGroups() => _post('getFinanceGroups');
  Future<Map<String, dynamic>> getFinanceData(String groupId) =>
      _post('getFinanceData', groupId);
  Future<Map<String, dynamic>> saveFinanceGroup(Map d) => _post('saveFinanceGroup', d);
  Future<Map<String, dynamic>> deleteFinanceGroup(String id) => _post('deleteFinanceGroup', id);
  Future<Map<String, dynamic>> saveFinanceIncome(Map d) => _post('saveFinanceIncome', d);
  Future<Map<String, dynamic>> deleteFinanceIncome(String id) => _post('deleteFinanceIncome', id);
  Future<Map<String, dynamic>> saveFinanceExpense(Map d) => _post('saveFinanceExpense', d);
  Future<Map<String, dynamic>> deleteFinanceExpense(String id) => _post('deleteFinanceExpense', id);

  // Settings / Notifications / Scores
  Future<Map<String, dynamic>> getSettings() => _post('getSettings');
  Future<Map<String, dynamic>> getNotifications() => _post('getNotifs');
  Future<Map<String, dynamic>> getStudentScores(String sid, String grade) =>
      _post('getStudentScores', {'studentId': sid, 'grade': grade});
  Future<Map<String, dynamic>> getRolePerms() => _post('getRolePerms');

  String get today {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }
}
