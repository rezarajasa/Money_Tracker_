Lanjutkan dan sempurnakan aplikasi Flutter Money Tracker Pro bernama RapiKas.

Project ini sudah memiliki starter code Flutter dan Supabase. Tugas Anda adalah membuat aplikasi Android APK production-ready dengan fitur berikut:

1. Auth Supabase: login email, Google login, reset password.
2. Dashboard total saldo setara IDR.
3. Multi-wallet: cash, bank, e-wallet, tabungan, kartu kredit, investasi, dan dompet valas.
4. Multi-currency: wallet dan transaksi dapat memakai mata uang berbeda.
5. Fitur Kurs & Valas:
   - daftar mata uang populer dan lengkap,
   - kurs beli, kurs jual, kurs tengah,
   - konverter mata uang,
   - riwayat kurs,
   - update kurs otomatis dari Supabase Edge Function,
   - pilihan provider kurs,
   - mode input kurs manual.
6. Transaksi income, expense, dan transfer antar wallet.
7. Kategori dengan icon dan warna.
8. Budget bulanan per kategori.
9. Laporan harian, mingguan, bulanan, tahunan.
10. Export PDF/CSV/Excel.
11. Utang, piutang, tagihan, cicilan, target keuangan.
12. Upload foto struk ke Supabase Storage.
13. AI financial insight untuk ringkasan dan saran penghematan.
14. Offline-first dengan local database dan sync ke Supabase.
15. Keamanan PIN dan biometric.
16. Dark mode, light mode, dan multi-language Indonesia/English/Arabic.

Desain UI:
- Modern, minimalist, Apple-like
- Clean cards, soft shadow, rounded corners
- Bottom navigation: Home, Transaksi, Budget, Laporan, Kurs, Profil
- Warna utama hijau finansial / teal premium
- Mobile-first, smooth, dan mudah dipahami

Gunakan schema Supabase:
- supabase/schema.sql
- supabase/currency_schema.sql

Gunakan Edge Function:
- supabase/functions/update-currency-rates/index.ts

Pastikan service_role key tidak pernah dimasukkan ke aplikasi Android. Gunakan service_role hanya di Edge Function.


Tambahkan/pertahankan fitur autentikasi lengkap: Login email/password, register, lupa password, Google OAuth melalui Supabase Auth, session persistence, deep link callback Android, dan proteksi data berdasarkan user_id dengan RLS.
