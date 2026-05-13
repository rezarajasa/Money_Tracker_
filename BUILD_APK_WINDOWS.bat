@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo ==================================================
echo RapiKas Money Tracker - Build APK Windows
echo ==================================================
echo.
where flutter >nul 2>nul
if %errorlevel% neq 0 (
  echo [ERROR] Flutter belum terinstall atau belum masuk PATH.
  echo Install Flutter dan Android Studio dulu, lalu buka ulang Command Prompt.
  echo Panduan: https://docs.flutter.dev/get-started/install/windows/mobile
  pause
  exit /b 1
)

echo [1/5] Cek Flutter...
flutter --version

echo.
echo [2/5] Cek environment Android...
flutter doctor

echo.
if not exist android\app (
  echo [3/5] Membuat struktur Android project...
  flutter create . --platforms=android --org com.rezarajasa --project-name rapikas_money_tracker
) else (
  echo [3/5] Struktur Android sudah ada, lanjut...
)

echo.
echo [4/5] Mengambil dependency...
flutter pub get

echo.
echo [5/5] Build APK release...
flutter build apk --release

echo.
echo ==================================================
echo SELESAI.
echo APK ada di:
echo build\app\outputs\flutter-apk\app-release.apk
echo ==================================================
pause
