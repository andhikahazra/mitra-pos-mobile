# Rencana Implementasi: Master Database Seeder yang Komprehensif

Anda meminta satu `DatabaseSeeder.php` utama yang menyimulasikan seluruh operasional toko Anda layaknya data riil yang sudah berjalan berbulan-bulan, lengkap dengan riwayat log yang sempurna.

## Analisis Sistem & Kebutuhan (Revisi Berdasarkan *Review*)
Berdasarkan eksplorasi terhadap arsitektur tabel dan *Controller* sistem Anda:
1. **Peran (Roles):** Terdapat peran `owner` dan `karyawan`. Owner bertindak sebagai pengambil keputusan (misal: ROP/Barang Masuk) dan Karyawan memegang POS.
2. **Logika Pengambilan Batch (Custom, BUKAN FIFO):** Sistem tidak mengambil stok lama lebih dulu, melainkan mencari **Harga Modal Termurah** (`harga_beli` ASC), lalu jika sama dicari **Sisa Stok Paling Sedikit** (`qty_sisa` ASC).
3. **Pencatatan Log Stok:** Setiap barang masuk atau terjual **wajib** tercatat di tabel `log_stok` lengkap dengan `barang_masuk_id` atau `transaksi_id`, dan tipe (`masuk`/`keluar`).
4. **Format Waktu Lengkap:** Transaksi akan diberi jam dan menit spesifik (`Y-m-d H:i:00`) agar simulasi terlihat senyata mungkin dalam satu hari jam kerja.
5. **Format Kode Sistem:** 
   - Transaksi: `TKMP-BBB-SSS` (BBB=Batch Harian, SSS=Sequence).
   - Barang Masuk: (Tergantung logika controller, umumnya kita sesuaikan dengan standar seperti `BM-Ymd-XXX`).

## Proposed Changes

### [MODIFY] [DatabaseSeeder.php](file:///d:/mitra_pos_project/mitra_pos_web/database/seeders/DatabaseSeeder.php)
Saya akan membangun "Super Seeder" yang merepresentasikan seluruh ekosistem bisnis Mitra POS:
1. **Wipe Data Bersih:** Semua tabel operasional (`transaksi`, `barang_masuk`, `produk`, dll) di-*truncate* agar tidak bertumpuk. Tabel `settings` tidak disentuh.
2. **Master Data Otentik:** Membuat akun "Owner" dan "Karyawan", Kategori, Supplier, dan 7 Produk (termasuk *stock* dan *non_stock*).
3. **Simulasi Transaksional Riil (60 Hari):**
   - **Barang Masuk (Restock):** Dihasilkan setiap beberapa hari sekali, stok akan dibuatkan `stok_batch` baru dan tercatat di `log_stok` (tipe `masuk`).
   - **Simulasi Penjualan POS:** Transaksi dibuat dengan jam/menit acak di jam kerja.
   - **Penerapan Custom Batch:** Seeder akan melakukan pencarian *batch* saat penjualan persis seperti di `TransactionController`:
     `orderBy('harga_beli', 'asc')->orderBy('qty_sisa', 'asc')`.
   - **Pencatatan Log Stok Keluar:** Tercatat akurat di `log_stok` untuk setiap barang yang laku.
4. **Pembuktian ROP:** Di akhir bulan kedua, saya akan menyedot stok Kardus dan Gunting secara masif agar laporannya bervariasi (Ada yang Kritis, ada yang Aman).
5. **Kalkulasi ROP:** Otomatis memanggil `php artisan rop:calculate` di akhir seeder.

## User Review Required

> [!IMPORTANT]
> Rencana ini telah disesuaikan 100% dengan alur *Controller* Anda: **Role Owner/Karyawan**, **Log Stok**, dan **Custom Batch Termurah & Terdikit**. 

Silakan tinjau dan balas **"Lanjut"** jika Anda setuju untuk mengeksekusi rencana ini menjadi satu file `DatabaseSeeder.php`.
