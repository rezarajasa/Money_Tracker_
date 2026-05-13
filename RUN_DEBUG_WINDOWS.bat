@echo off
cd /d "%~dp0"
where flutter >nul 2>nul
if %errorlevel% neq 0 (
  echo Flutter belum terinstall atau belum masuk PATH.
  pause
  exit /b 1
)
if not exist android\app (
  flutter create . --platforms=android --org com.rezarajasa --project-name rapikas_money_tracker
)
flutter pub get
flutter run
pause
