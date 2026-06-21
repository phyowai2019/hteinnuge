# မူလတန်းကျောင်း SMS — Flutter App

## Phase 1 Files (ဤ zip ထဲတွင်)

```
sms_myanmar/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── api.dart
│   │   └── theme.dart
│   ├── models/
│   │   ├── user.dart        (UserModel)
│   │   ├── student.dart     (StudentModel)
│   │   └── attendance.dart  (AttendanceEntry)
│   ├── services/
│   │   └── api_service.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── app_provider.dart
│   └── screens/
│       ├── login/login_screen.dart
│       ├── main/main_shell.dart
│       ├── dashboard/dashboard_screen.dart
│       ├── students/students_screen.dart
│       ├── attendance/rollcall_screen.dart
│       ├── teachers/teachers_screen.dart
│       └── settings/settings_screen.dart
└── assets/
    └── fonts/
        ├── Padauk-Regular.ttf  ← download လုပ်ပါ
        └── Padauk-Bold.ttf
```

## Setup Steps

### 1. code.gs တွင် doPost ထည့်ပါ
`gas_api_addition.gs` ဖိုင်မှ `doPost()` function ကို
လက်ရှိ `code.gs` အဆုံးတွင် paste လုပ်ပြီး New version deploy လုပ်ပါ

### 2. API URL ထည့်ပါ
`lib/config/api.dart` တွင်:
```dart
static const String gasUrl = 'https://script.google.com/macros/s/YOUR_ID/exec';
```

### 3. Padauk Font download လုပ်ပါ
https://fonts.google.com/specimen/Padauk မှ download ပြီး
`assets/fonts/` folder ထဲ ထည့်ပါ

### 4. Build ပြုလုပ်ပါ
```bash
flutter pub get
flutter run                    # debug
flutter build apk --release    # Android APK
flutter build ios --release    # iOS
flutter build web              # Web
```

## Phase 2 (နောက်ထပ်ထည့်မည်)
- Timetable screen
- Scores/grades screen
- Attendance history
- Teacher schedule

## Phase 3 (နောက်ထပ်ထည့်မည်)
- Duties & Committees
- ID Card + QR scanner
- Push notifications
- Offline mode
- Photo upload
