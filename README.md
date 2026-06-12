# Lync - Aplikasi Pemindai QR & Shortener Link (Kelompok 3)

**Lync** adalah platform produktivitas manajemen kode QR dan tautan berbasis mobile yang mengadopsi sistem penyimpanan data berbasis awan (*cloud storage*) secara penuh. Berbeda dengan aplikasi penyimpanan lokal, Lync memfasilitasi pengguna untuk menyimpan seluruh riwayat pemindaian dan pembuatan tautan secara terpusat di server, sehingga data tetap terjaga dan dapat diakses kembali meski pengguna berganti perangkat.

## 🚀 Fitur Utama
Aplikasi ini menyediakan berbagai fitur utama untuk manajemen interaksi digital:
* **QR to Link Scanner**: Fitur utama untuk memindai kode QR secara real-time menggunakan kamera ponsel dan mengonversinya menjadi tautan digital.
* **Instant Link Shortener**: Layanan penyederhanaan URL panjang menjadi tautan pendek yang dikelola melalui logika Cloud Functions untuk pengalihan otomatis.
* **Link to QR Generator**: Fitur yang memungkinkan pengguna mengubah tautan teks apa pun kembali menjadi gambar kode QR yang dapat diunduh dan dibagikan.
* **Cloud Scan History**: Penyimpanan riwayat aktivitas pemindaian secara persisten di Cloud Firestore, sehingga data tidak membebani memori lokal ponsel.
* **History Management (CRUD)**: Kemampuan bagi pengguna terdaftar untuk membaca (*Read*), memberi label (*Update*), dan menghapus (*Delete*) riwayat scan tertentu secara permanen dari server awan.
* **Secure Authentication**: Sistem pendaftaran dan masuk pengguna menggunakan Firebase Auth untuk melindungi privasi data riwayat pribadi.

## 🏗️ Arsitektur Sistem
Pengembangan Lync menggunakan pola arsitektur **MVVM (Model-View-ViewModel)** yang dikombinasikan dengan **Repository Pattern** untuk menciptakan ekosistem kode yang modular.

### Struktur Teknologi:
* **Frontend**: Dibangun menggunakan **Flutter (Dart)** untuk memberikan performa native yang mulus dan optimal pada integrasi kamera.
* **Backend**: Memanfaatkan layanan **Firebase** sebagai pengganti server tradisional untuk menjalankan logika pemendekan tautan dan generator QR.
* **Database**: Menggunakan **Cloud Firestore** untuk menjamin integritas data riwayat dan kecepatan pencarian secara real-time.

## 🛠️ Functional Requirement (FR)


| Nama Anggota | PIC / Jobdesk |
| :--- | :--- |
| **Gregorius Edgar Dessaratu'** | Flutter UX Interface |
| **Andhika Bima Pramudito** | QR Scanning Engine |
| **Muhammad Azka Darmawan** | Cloud History & CRUD |
| **Muhammad Nabil Alfarizi** | Serverless Redirect |
| **Jundi Haq Darmawan** | Secure Auth & DB |

---
*© 2026 Program Studi Teknologi Informasi - Universitas Telkom*
