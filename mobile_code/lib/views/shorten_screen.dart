import 'dart:math';
import 'package:flutter/material.dart';

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

  // List Riwayat (Frontend Simulation)
  List<Map<String, String>> historyList = [];

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

      // Tambahkan ke riwayat
      historyList.insert(0, {
        'short': currentShortUrl,
        'original': originalUrlInput,
      });

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
      bottomNavigationBar: _buildBottomNav(),
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
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                "Tautan Berhasil!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryTosca,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FDFB),
              borderRadius: BorderRadius.circular(12),
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
                Text(
                  currentShortUrl,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryTosca,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showResult = false),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Baru"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryTosca,
                    side: const BorderSide(color: primaryTosca),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text("Salin"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTosca,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Riwayat Terakhir",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...historyList
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: primaryTosca),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['short']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['original']!,
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
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.qr_code_scanner_rounded, "Scan", false),
          _navItem(Icons.link_rounded, "Shorten", true),
          Transform.translate(
            offset: const Offset(0, -15),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primaryTosca,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryTosca.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          _navItem(Icons.history_rounded, "History", false),
          _navItem(Icons.person_outline_rounded, "Profile", false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primaryTosca : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? primaryTosca : Colors.grey[400],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: primaryTosca,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
