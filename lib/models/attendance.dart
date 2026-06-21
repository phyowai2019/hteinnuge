class AttendanceEntry {
  final String studentId, name, grade, gender;
  String status; // တက် | ခွင့် | ပျက် | မမှတ်ရသေး
  String note;

  AttendanceEntry({required this.studentId, required this.name,
    required this.grade, required this.gender,
    this.status = 'မမှတ်ရသေး', this.note = ''});

  factory AttendanceEntry.fromJson(Map<String, dynamic> j) => AttendanceEntry(
    studentId: j['studentId'] ?? '',
    name: j['name'] ?? '',
    grade: j['grade'] ?? '',
    gender: j['gender'] ?? '',
    status: j['status'] ?? 'မမှတ်ရသေး',
    note: j['note'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'studentId': studentId, 'name': name, 'grade': grade,
    'gender': gender, 'status': status, 'note': note,
  };

  bool get isPresent => status == 'တက်';
  bool get isLeave => status == 'ခွင့်';
  bool get isAbsent => status == 'ပျက်';
}
