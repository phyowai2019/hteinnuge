# 🏫 မူလတန်းကျောင်း SMS — Flutter App

[![Build](https://github.com/YOUR_USERNAME/sms-myanmar/actions/workflows/build.yml/badge.svg)](https://github.com/YOUR_USERNAME/sms-myanmar/actions)

## Setup

### 1. GAS URL ထည့်ပါ
```dart
// lib/config/api.dart
static const String gasUrl = 'YOUR_GAS_DEPLOYMENT_URL';
```

### 2. Padauk Font
[fonts.google.com/specimen/Padauk](https://fonts.google.com/specimen/Padauk) မှ download → `assets/fonts/` ထဲ ထည့်

### 3. Run
```bash
flutter pub get
flutter run
```

## GitHub Actions — APK ထုတ်နည်း
1. GitHub repo သို့ push
2. Actions → latest run → Artifacts → `sms-myanmar-apk`

## Features
- 🔐 Login (Admin/Teacher/Parent/Student)
- 📊 Dashboard
- 📋 Roll Call
- 👥 Students
- 🗓 Timetable
- 📝 Scores
- 📋 Duties & Committees
- 💰 Finance (ငွေစာရင်းရှင်းတမ်း)
- 🔔 Notifications
- 🔒 Role permissions
