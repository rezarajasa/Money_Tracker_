# RapiKas - Panduan Login Supabase Auth

Versi ini sudah ditambahkan fitur login asli dengan Supabase Auth:

- Login email + password
- Daftar akun email + password
- Lupa password / reset password
- Login Google OAuth
- Session tetap tersimpan setelah aplikasi ditutup
- Mode demo tetap tersedia jika Supabase belum dikonfigurasi

## 1. Aktifkan Auth Email di Supabase

1. Buka Supabase Dashboard.
2. Pilih project RapiKas.
3. Buka **Authentication > Providers**.
4. Pastikan **Email** aktif.
5. Atur apakah email confirmation ingin aktif atau tidak.

Jika email confirmation aktif, user harus membuka link verifikasi dari email sebelum bisa login normal.

## 2. Isi konfigurasi Supabase di Flutter

Buka file:

```text
lib/config/app_config.dart
```

Ubah bagian berikut:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

Menjadi data project Supabase Anda:

```dart
static const String supabaseUrl = 'https://xxxxxxxxxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOi...';
```

Ambil dari:

```text
Supabase Dashboard > Project Settings > API
```

Gunakan **anon/public key** saja. Jangan masukkan `service_role key` ke aplikasi Android.

## 3. Redirect URL untuk Google Login dan Reset Password

Di file Flutter sudah disiapkan:

```dart
static const String authRedirectUrl = 'io.supabase.rapikas://login-callback/';
```

Tambahkan URL ini ke Supabase:

```text
Authentication > URL Configuration > Redirect URLs
```

Tambahkan:

```text
io.supabase.rapikas://login-callback/
```

## 4. Tambahkan deep link ke AndroidManifest

Setelah menjalankan:

```bash
flutter create . --platforms=android --org com.rezarajasa --project-name rapikas_money_tracker
```

buka file:

```text
android/app/src/main/AndroidManifest.xml
```

Di dalam `<activity ...>` untuk `MainActivity`, tambahkan intent-filter ini:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.rapikas" android:host="login-callback" />
</intent-filter>
```

Contoh posisi sederhananya:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">

    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>

    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="io.supabase.rapikas" android:host="login-callback" />
    </intent-filter>
</activity>
```

## 5. Mengaktifkan Google Login di Supabase

1. Buka Google Cloud Console.
2. Buat OAuth Client ID tipe **Web application**.
3. Ambil **Client ID** dan **Client Secret**.
4. Buka Supabase Dashboard.
5. Masuk ke **Authentication > Providers > Google**.
6. Enable Google provider.
7. Masukkan Client ID dan Client Secret.
8. Tambahkan callback URL Supabase ke Google Authorized redirect URIs.

Callback URL Supabase biasanya tersedia di halaman Google Provider Supabase, formatnya seperti:

```text
https://PROJECT_ID.supabase.co/auth/v1/callback
```

## 6. Jalankan aplikasi

```bash
flutter pub get
flutter run
```

Build APK:

```bash
flutter build apk --release
```

## 7. Catatan testing

- Jika Supabase belum diisi, aplikasi akan menampilkan info bahwa Supabase belum dikonfigurasi.
- Tombol **Coba mode demo tanpa Supabase** tetap bisa dipakai untuk melihat UI aplikasi.
- Login Google membutuhkan konfigurasi provider dan deep link Android.
- Login email/password bisa langsung dipakai setelah Email provider aktif dan database schema sudah dijalankan.
