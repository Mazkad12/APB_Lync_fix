import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/history_service.dart';


class ShortenScreen extends StatefulWidget {
  final bool isGuest;
  final String userEmail;

  const ShortenScreen({
    super.key,
    required this.isGuest,
    required this.userEmail,
  });

  @override
  State<ShortenScreen> createState() => _ShortenScreenState();
}

class _ShortenScreenState extends State<ShortenScreen> {
  final _urlController = TextEditingController();
  static const Color primaryTosca = Color(0xFF006D66);

  // Variable Logika Manual
  bool _isUrlValid = false;
  bool _showResult = false;
  String currentShortUrl = "";
  String originalUrlInput = "";

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan input untuk ganti warna tombol secara manual
    _urlController.addListener(() {
      setState(() {
        _isUrlValid = _urlController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // Fungsi generate short link random
  String _generateRandomCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
  }

  // Fungsi saat tombol diklik
  void _handleShortenAction() {
    setState(() {
      originalUrlInput = _urlController.text;
      currentShortUrl = "https://ly.nc/${_generateRandomCode()}";
      _showResult = true;

      // Tambahkan ke riwayat global (HistoryService)
      HistoryService.instance.addHistoryItem(
        type: 'PENDEK',
        title: originalUrlInput, // Gunakan url asli sebagai judul untuk dropdown
        originalUrl: originalUrlInput,
        shortUrl: currentShortUrl,
      );

      _urlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // AREA HEADER + CARD MELAYANG
                  SizedBox(
                    height: _showResult ? 550 : 360,
                    child: Stack(
                      children: [
                        // 1. Header Hijau Tosca
                        Container(
                          width: double.infinity,
                          height: 240,
                          color: primaryTosca,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 60,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "LYNC",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Link Shortener",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Ubah URL panjang menjadi tautan pendek instan",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Input Card Melayang (Berubah jadi Hasil jika diklik)
                        Positioned(
                          top: 160,
                          left: 24,
                          right: 24,
                          child: _showResult
                              ? _buildResultCard()
                              : _buildInputCard(),
                        ),
                      ],
                    ),
                  ),

                  // 3. Riwayat Terakhir (Hanya muncul jika sudah ada hasil)
                  if (_showResult) _buildHistorySection(),

                  const SizedBox(height: 10),

                  // 4. Banner Mode Tamu
                  if (widget.isGuest)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFE082).withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Mode Tamu",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF855D00),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Riwayat tidak tersimpan permanen. Login untuk menyimpan semua tautan ke cloud.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF855D00),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAMPILAN KARTU INPUT (SS1)
  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MASUKKAN URL",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.link, color: Colors.grey, size: 20),
              hintText: "https://contoh.url/yang-sangat-panjan",
              hintStyle: TextStyle(color: Colors.grey[350], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: primaryTosca, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isUrlValid ? _handleShortenAction : null,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                "Persingkat Sekarang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                // WARNA MANUAL DISINI
                backgroundColor: _isUrlValid
                    ? primaryTosca
                    : const Color(0xFFF3F4F6),
                foregroundColor: _isUrlValid ? Colors.white : Colors.grey[500],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: const Color(0xFFF3F4F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAMPILAN KARTU HASIL (SS2)
  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: Color(0xFF00C48C), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Tautan Berhasil Dipersingkat!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "URL ASLI",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            originalUrlInput,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FDFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0F2F1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "URL PENDEK",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryTosca,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentShortUrl,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primaryTosca,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.copy, size: 16, color: primaryTosca),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.open_in_new, size: 16, color: primaryTosca),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "KLIK",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "0",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "DIBUAT",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Baru saja",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code, size: 16),
                  label: const Text("Buat QR", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showResult = false),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text("Persingkat Lagi", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: primaryTosca,
                    backgroundColor: const Color(0xFFCCFBF1), // Lebih cerah seperti desain
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET RIWAYAT
  Widget _buildHistorySection() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: HistoryService.instance.historyList,
      builder: (context, history, child) {
        if (history.isEmpty) {
          return const SizedBox.shrink(); // Jangan tampilkan jika riwayat kosong
        }

        // Ambil 3 riwayat terbaru untuk ditampilkan di ShortenScreen
        final recentHistory = history.take(3).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Riwayat Terakhir",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        "Lihat Semua",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryTosca,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: primaryTosca),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recentHistory.map((item) {
                // Tentukan warna icon berdasarkan tipe
                Color iconBgColor;
                Color iconColor;
                IconData iconData;

                if (item['type'] == 'SCAN') {
                  iconBgColor = const Color(0xFFE0FDF4);
                  iconColor = const Color(0xFF00C48C);
                  iconData = Icons.qr_code_scanner;
                } else if (item['type'] == 'PENDEK') {
                  iconBgColor = const Color(0xFFF3E8FF);
                  iconColor = const Color(0xFFA855F7);
                  iconData = Icons.link;
                } else {
                  iconBgColor = const Color(0xFFE0F2FE);
                  iconColor = const Color(0xFF3B82F6);
                  iconData = Icons.qr_code_2;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(iconData, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item['shortUrl'] ?? item['originalUrl'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.copy, size: 18, color: Colors.grey),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
