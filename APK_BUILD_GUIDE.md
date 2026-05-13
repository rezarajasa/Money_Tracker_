# Panduan Membuat APK RapiKas Money Tracker

Paket ini berisi source code aplikasi **RapiKas Money Tracker** dan script otomatis untuk membuild menjadi file `.apk`.

## Yang perlu diinstall

1. Flutter SDK
2. Android Studio
3. Android SDK / Command-line Tools dari Android Studio
4. Git, jika diminta Flutter

## Cara paling mudah di Windows

1. Extract file ZIP ini.
2. Buka folder hasil extract.
3. Klik dua kali file:

```text
BUILD_APK_WINDOWS.bat
```

4. Tunggu proses selesai.
5. File APK akan muncul di:

```text
build\app\outputs\flutter-apk\app-release.apk
```

## Cara macOS/Linux

Buka Terminal di folder project, lalu jalankan:

```bash
chmod +x BUILD_APK_MAC_LINUX.sh
./BUILD_APK_MAC_LINUX.sh
```

Hasil APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Jika muncul error Android license

Jalankan:

```bash
flutter doctor --android-licenses
```

Tekan `y` sampai selesai.

## Jika ingin test di HP sebelum build

1. Aktifkan Developer Options di HP Android.
2. Aktifkan USB Debugging.
3. Sambungkan HP ke laptop.
4. Jalankan:

```bash
flutter run
```

Atau di Windows klik:

```text
RUN_DEBUG_WINDOWS.bat
```

## Setup Supabase

1. Masuk Supabase Dashboard.
2. Buka SQL Editor.
3. Jalankan file:

```text
supabase/schema.sql
```

4. Ambil `Project URL` dan `anon public key`.
5. Masukkan ke file:

```text
lib/config/app_config.dart
```

Bagian:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

## Catatan penting

Paket ini adalah **source code aplikasi siap-build**. File APK final hanya bisa dibuat di komputer yang sudah memiliki Flutter dan Android SDK, karena proses build Android membutuhkan toolchain tersebut.
