// lib/config/api.dart
class ApiConfig {
  // ← GAS Web App URL ထည့်ပါ
  static const String gasUrl =
      'https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec';

  static const Duration timeout = Duration(seconds: 30);
  static const String appName = 'မူလတန်းကျောင်း SMS';
  static const String appVersion = '1.0.0';

  static const List<String> grades = [
    'KG','Grade 1','Grade 2','Grade 3','Grade 4','Grade 5',
    'Grade 6','Grade 7','Grade 8','Grade 9',
  ];

  static const Map<String, String> roleLabels = {
    'admin': 'Admin',
    'teacher': 'ဆရာ/မ',
    'parent': 'မိဘ',
    'student': 'ကျောင်းသား',
  };
}
