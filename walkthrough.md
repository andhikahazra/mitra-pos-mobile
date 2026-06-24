# Simulasi Operasional Mitra POS (Super Seeder)

> [!NOTE]
> *Walkthrough* ini mendokumentasikan hasil eksekusi dari **DatabaseSeeder.php** yang baru saja dibangun secara khusus untuk menghasilkan simulasi bisnis pergudangan dan POS (*Point of Sales*) berskala kecil-menengah secara realistis.

## 1. Skala Data yang Dihasilkan
Seeder telah dijalankan dan berhasil menghasilkan ekosistem data yang terpadu:
- **20 Produk Berbeda**: Dikelompokkan ke dalam 5 Kategori (Kardus, Lakban, Alat Packing, Karung Plastik, dan Bubble Wrap).
- **2 Supplier & 2 Pengguna**: Simulasi suplai oleh 2 vendor, dioperasikan oleh akun `Owner` dan `Karyawan`.
- **60+ Barang Masuk (Restock)**: Menciptakan lebih dari 60 *Batch* inventaris dengan kode format riil `BM-BBB-SSS`.
- **212 Transaksi POS Harian**: Dibuat dengan kode format riil `TKMP-BBB-SSS` yang tersebar secara acak di jam kerja (misal: pukul 14:35) selama 60 hari berturut-turut.
- **549 Log Stok**: Rekaman audit *inventory* yang sempurna (keluar/masuk) untuk memastikan laporan arus barang tidak cacat.

## 2. Kepatuhan Terhadap Logika Sistem (*Business Logic*)
Seeder ini tidak mengarang bebas, melainkan patuh 100% pada *Controller* Anda:

> [!IMPORTANT]
> **Custom Batch Allocation**
> Saat pelanggan POS membeli barang di simulasi, seeder tidak menggunakan FIFO. Sistem seeder memprioritaskan pengambilan stok dari **Batch dengan Harga Beli Termurah**, dan jika harganya sama, akan menghabiskan **Batch dengan Sisa QTY Paling Sedikit** (mencegah tumpukan barang nanggung di gudang).

## 3. Efek Variasi terhadap ROP
Untuk memastikan perhitungan **Reorder Point (ROP)** tidak membosankan saat Anda presentasi (semuanya berstatus "Aman"), di hari ke-60 pukul 17:30 sore, seeder mensimulasikan sebuah **Transaksi Borongan Masif** (`TKMP-999-999`).

Perusahaan fiktif memborong *Kardus Polos 20x20x20*, sehingga sisa stoknya menipis menjadi **5 buah**. 
Dampak seketikanya sangat memukau:

```json
{
    "nama": "Kardus Polos 20x20x20",
    "stok": 5,
    "rata_penjualan_harian": 8.37,
    "reorder_point": 129
}
```
Karena stok (5) jatuh jauh di bawah batas ROP (129), produk ini otomatis akan masuk status **"Perlu Pesan / Kritis"** di sistem Anda, sementara kardus dan lakban ukuran lainnya tetap aman di angka stok 100-200 pcs.

---
**Status:** ✅ Siap digunakan untuk demonstrasi ke Dosen / Penguji. Semua tabel terhubung dengan relasi yang kokoh.
