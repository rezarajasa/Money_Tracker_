# Opsi Provider Kurs

## 1. Frankfurter
Cocok untuk MVP karena public API, open-source, dan tidak butuh API key. Dapat digunakan untuk latest rate dan historical rate. Cocok untuk aplikasi money tracker pribadi.

## 2. ExchangeRate-API
Cocok jika ingin coverage mata uang lebih luas dan opsi free/pro. Ada open access endpoint tanpa API key, tetapi untuk production lebih stabil memakai API key/pro plan.

## 3. Provider bank / money changer lokal
Cocok jika aplikasi ingin menampilkan kurs beli/jual yang dekat dengan kebutuhan Indonesia, seperti kurs bank atau money changer. Biasanya perlu izin/API khusus atau scraping yang harus dipastikan legal.

## Rekomendasi
Untuk tahap awal gunakan Frankfurter atau ExchangeRate-API. Setelah aplikasi stabil, tambahkan mode manual agar admin bisa memasukkan kurs beli/jual sendiri.
