# Hamo Tunnel Plus — Build-Ready Flutter Project

## طريقة التشغيل وبناء APK على جهازك (جاهز بالمكتبات والإعدادات)

### على Windows:
1. فك ضغط الملف `hamo_tunnel_plus_flutter.zip`.
2. اضغط مرتين على ملف **`build_apk.bat`** (أو افتح Terminal داخل المجلد وشغّل الأوامر أدناه).

### أو عبر Terminal (Windows / macOS / Linux):
```bash
flutter pub get
flutter build apk --release
```
*(في حال عدم وجود `gradlew` على جهازك، شغّل `flutter create --platforms=android .` أولاً ولن يقوم بتعديل ملفات `lib/` أو `pubspec.yaml` أو `AndroidManifest.xml` الموجودة).*

سيظهر ملف الـ APK الجاهز للتثبيت في المسار:
`build/app/outputs/flutter-apk/app-release.apk`

## المميزات والمكتبات المضمنة:
- **`openvpn_flutter`**: تشغيل بروتوكول OpenVPN الكامل (UDP / TCP / SSL).
- **`file_picker` + `receive_sharing_intent`**: فتح ملفات `.ovpn` من الهاتف أو استلامها مباشرة من تطبيق **Telegram**.
- **`shared_preferences`**: حفظ سيرفرات الـ VPS وملفات الكونفج محلياً.
- **`fl_chart`**: الرسم البياني المباشر لسرعة التنزيل والرفع.
