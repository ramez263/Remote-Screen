#!/usr/bin/env bash
set -e
if [ ! -f "android/gradlew" ]; then
  flutter create --platforms=android --org com.hamotunnel --project-name hamo_tunnel_plus .
fi
flutter pub get
flutter build apk --release
echo "APK ready at: build/app/outputs/flutter-apk/app-release.apk"
