import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/auth/auth_bloc.dart';
import '../viewmodels/auth/auth_event.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_event.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildFeatureCard(
                  icon: Icons.qr_code_scanner,
                  iconColor: const Color(0xFF00897B),
                  bgColor: const Color(0xFFE0F2F1),
                  title: "Scan QR",
                  subtitle:
                      "Scan QR code secara real-time langsung dari kamera",
                ),
                _buildFeatureCard(
                  icon: Icons.link,
                  iconColor: const Color(0xFF7E57C2),
                  bgColor: const Color(0xFFEDE7F6),
                  title: "Link Shortener",
                  subtitle:
                      "Persingkat URL panjang menjadi tautan yang mudah dibagikan",
                ),
                _buildFeatureCard(
                  icon: Icons.grid_view_rounded,
                  iconColor: const Color(0xFF2196F3),
                  bgColor: const Color(0xFFE3F2FD),
                  title: "QR Generator",
                  subtitle:
                      "Buat QR code dari teks atau tautan apapun dengan mudah",
                ),
                _buildFeatureCard(
                  icon: Icons.cloud_outlined,
                  iconColor: const Color(0xFFFBC02D),
                  bgColor: const Color(0xFFFFF9C4),
                  title: "Cloud History",
                  subtitle:
                      "Simpan semua aktivitas di cloud, akses dari mana saja",
                ),
                const SizedBox(height: 40),
                _buildButton(
                  text: "Masuk ke Akun",
                  color: const Color(0xFF004D40),
                  textColor: Colors.white,
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 12),
                _buildButton(
                  text: "Daftar Akun Baru",
                  color: const Color(0xFFCCFFFD),
                  textColor: const Color(0xFF004D40),
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
                TextButton(
                  onPressed: () {
                    // Trigger Guest Mode in BLoC
                    context.read<HistoryBloc>().add(ClearGuestHistory());
                    context.read<AuthBloc>().add(GuestLoginRequested());
                    
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                      arguments: {'isGuest': true, 'userEmail': 'Guest'},
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[600]),
                      children: const [
                        TextSpan(text: "Lanjut sebagai "),
                        TextSpan(
                          text: "Tamu",
                          style: TextStyle(
                            color: Color(0xFF00796B),
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00695C),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.qr_code_2, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: "Selamat datang di "),
              TextSpan(
                text: "Lync",
                style: TextStyle(color: Color(0xFF00695C)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Solusi lengkap untuk scan, persingkat, dan buat QR code",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
