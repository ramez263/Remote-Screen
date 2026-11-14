@echo off
echo ==========================================
echo  Hamo Tunnel Plus - Flutter APK Builder
echo ==========================================
if not exist "android\gradlew.bat" (
  echo Initializing Android Gradle wrapper without overwriting lib or Manifest...
  flutter create --platforms=android --org com.hamotunnel --project-name hamo_tunnel_plus .
)
echo Running flutter pub get...
call flutter pub get
if %errorlevel% neq 0 exit /b %errorlevel%
echo Building Release APK...
call flutter build apk --release
if %errorlevel% neq 0 exit /b %errorlevel%
echo.
echo Done! APK is at: build\app\outputs\flutter-apk\app-release.apk
pause
