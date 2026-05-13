# Panduan Fitur Kurs / Multi-Currency RapiKas

Fitur ini menambahkan kemampuan aplikasi untuk mencatat transaksi dalam beberapa mata uang, menampilkan daftar kurs, melakukan konversi, dan menghitung total saldo setara IDR.

## Fitur yang sudah ditambahkan

1. Tab baru **Kurs** di bottom navigation.
2. Konverter mata uang.
3. Daftar kurs lengkap: USD, EUR, GBP, JPY, SAR, AED, SGD, MYR, AUD, CAD, CHF, CNY, HKD, KRW, THB, INR, PHP, VND, TRY.
4. Dompet bisa memakai mata uang berbeda, misalnya IDR dan USD.
5. Transaksi bisa dicatat dengan mata uang berbeda.
6. Total saldo dashboard dikonversi ke IDR.
7. Database Supabase untuk:
   - `supported_currencies`
   - `currency_rates`
   - `user_currency_preferences`
8. Supabase Edge Function `update-currency-rates` untuk menarik kurs otomatis dari provider.

## Catatan penting

Rate di UI starter masih memakai **sample rate** supaya aplikasi bisa langsung dibuka tanpa koneksi API. Untuk produksi, gunakan tabel `currency_rates` dari Supabase dan update otomatis lewat Edge Function.

## Cara menjalankan module database kurs

Jika database utama belum pernah dibuat, cukup jalankan:

```sql
supabase/schema.sql
```

Jika database utama sudah pernah dibuat, jalankan khusus:

```sql
supabase/currency_schema.sql
```

## Cara deploy Edge Function kurs

Pastikan Supabase CLI sudah terpasang dan project sudah link.

```bash
supabase functions deploy update-currency-rates
```

Set secret yang diperlukan:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=isi_service_role_key_anda
```

Lalu jalankan function:

```bash
supabase functions invoke update-currency-rates
```

## Provider kurs

Default function menggunakan Frankfurter public API dengan URL:

```text
https://api.frankfurter.dev/v1/latest?base=IDR
```

Jika provider tidak mendukung base IDR di wilayah tertentu, Anda bisa mengganti `CURRENCY_API_URL` atau menggunakan provider lain seperti ExchangeRate-API / layanan bank / API kurs pilihan Anda.

## Saran production

- Simpan kurs harian, jangan hanya kurs real-time, supaya laporan masa lalu tetap akurat.
- Simpan `exchange_rate_to_base` pada transaksi agar histori transaksi tidak berubah ketika kurs hari ini berubah.
- Jangan menaruh `service_role key` di APK. Gunakan hanya di Supabase Edge Function.
- Tambahkan jadwal update kurs harian dengan cron/scheduler, misalnya setiap pagi.

