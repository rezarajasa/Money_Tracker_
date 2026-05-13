# RapiKas Money Tracker Pro

Starter aplikasi **Money Tracker APK** berbasis Flutter + Supabase dengan fitur keuangan lengkap dan tambahan **multi-currency / info kurs**.

## Fitur utama

- Login email/password, daftar akun, lupa password, dan Google login
- Dashboard total saldo
- Pemasukan dan pengeluaran
- Dompet multi-mata uang
- Budget bulanan
- Laporan kategori
- Tab **Kurs & Valas**
- Konverter mata uang
- Daftar kurs lengkap populer
- Database Supabase lengkap
- RLS policy Supabase
- Edge Function untuk update kurs otomatis
- Script build APK Windows dan Mac/Linux

## Struktur penting

```text
lib/main.dart                         UI Flutter utama
lib/utils/money_formatter.dart         Format uang IDR dan valas
supabase/schema.sql                    Schema database lengkap
supabase/currency_schema.sql           Module database kurs jika database sudah ada
supabase/functions/update-currency-rates/index.ts
                                      Edge Function update kurs
docs/CURRENCY_FEATURE_GUIDE.md         Panduan fitur kurs
docs/CURRENCY_PROVIDER_OPTIONS.md      Opsi provider kurs
docs/AUTH_LOGIN_GUIDE.md                Panduan login Supabase Auth
BUILD_APK_WINDOWS.bat                  Script build APK Windows
BUILD_APK_MAC_LINUX.sh                 Script build APK Mac/Linux
```

## Cara build APK

```bash
flutter pub get
flutter build apk --release
```

Hasil APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Cara setup login

1. Buka `lib/config/app_config.dart`.
2. Isi `supabaseUrl` dan `supabaseAnonKey` dari Supabase Project Settings > API.
3. Jalankan schema database di Supabase SQL Editor.
4. Untuk Google login dan reset password, ikuti `docs/AUTH_LOGIN_GUIDE.md`.

## Cara setup database

1. Buka Supabase Dashboard.
2. Masuk ke SQL Editor.
3. Paste isi `supabase/schema.sql`.
4. Klik Run.

Jika database lama sudah ada, jalankan juga:

```text
supabase/currency_schema.sql
```

## Catatan kurs

Rate yang tampil di aplikasi starter adalah sample rate agar aplikasi bisa langsung dites. Untuk produksi, aktifkan Edge Function `update-currency-rates` agar data kurs tersimpan ke Supabase.

