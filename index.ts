/// Placeholder service untuk offline-first mode.
/// Pada versi produksi, gunakan sqflite untuk menyimpan transaksi lokal,
/// lalu buat sync queue ke Supabase ketika internet tersedia.
class LocalDatabaseService {
  LocalDatabaseService._();

  static Future<void> init() async {
    // TODO: buka database SQLite, buat tabel lokal, migrasi versi database.
  }

  static Future<void> enqueueSync(Map<String, dynamic> payload) async {
    // TODO: simpan perubahan ke sync queue lokal.
  }

  static Future<void> flushSyncQueue() async {
    // TODO: kirim perubahan lokal ke Supabase.
  }
}
