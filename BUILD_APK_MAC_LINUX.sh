#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
echo "=================================================="
echo "RapiKas Money Tracker - Build APK macOS/Linux"
echo "=================================================="
if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] Flutter belum terinstall atau belum masuk PATH."
  echo "Install Flutter dan Android Studio dulu."
  echo "Panduan: https://docs.flutter.dev/get-started/install"
  exit 1
fi

echo "[1/5] Cek Flutter..."
flutter --version

echo "[2/5] Cek environment Android..."
flutter doctor

if [ ! -d "android/app" ]; then
  echo "[3/5] Membuat struktur Android project..."
  flutter create . --platforms=android --org com.rezarajasa --project-name rapikas_money_tracker
else
  echo "[3/5] Struktur Android sudah ada, lanjut..."
fi

echo "[4/5] Mengambil dependency..."
flutter pub get

echo "[5/5] Build APK release..."
flutter build apk --release

echo "=================================================="
echo "SELESAI. APK ada di:"
echo "build/app/outputs/flutter-apk/app-release.apk"
echo "=================================================="
