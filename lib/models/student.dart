class StudentModel {
  final String id, name, grade, gender;
  final String? dob, father, mother, phone, address;
  final double? attendancePct;

  StudentModel({required this.id, required this.name, required this.grade,
    required this.gender, this.dob, this.father, this.mother,
    this.phone, this.address, this.attendancePct});

  factory StudentModel.fromJson(Map<String, dynamic> j) => StudentModel(
    id: j['ID'] ?? j['id'] ?? '',
    name: j['Name'] ?? j['name'] ?? '',
    grade: j['Grade'] ?? j['grade'] ?? '',
    gender: j['Gender'] ?? j['gender'] ?? '',
    dob: j['DOB'] ?? j['dob'],
    father: j['Father'] ?? j['father'],
    mother: j['Mother'] ?? j['mother'],
    phone: j['Phone'] ?? j['phone'],
    address: j['Address'] ?? j['address'],
    attendancePct: (j['AttendancePct'] ?? j['attendancePct'])?.toDouble(),
  );

  int get age {
    if (dob == null) return 0;
    try {
      final parts = dob!.split('-');
      if (parts.length < 3) return 0;
      final born = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now = DateTime.now();
      int age = now.year - born.year;
      if (now.month < born.month || (now.month == born.month && now.day < born.day)) age--;
      return age;
    } catch(_) { return 0; }
  }
}

// lib/models/attendance.dart