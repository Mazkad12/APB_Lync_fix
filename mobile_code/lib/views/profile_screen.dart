import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/auth/auth_bloc.dart';
import '../viewmodels/auth/auth_event.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_state.dart';

class ProfileScreen extends StatelessWidget {
  final bool isGuest;
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.isGuest,
    required this.userEmail,
  });

  static const Color primaryTosca = Color(0xFF006D66);
  static const Color bgColor = Color(0xFFF8FAFB);

  @override
  Widget build(BuildContext context) {
    String displayName = isGuest ? "Tamu" : (userEmail.split('@').first);
    if (displayName.isNotEmpty) {
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }
    String displayEmail = isGuest ? "Belum login" : userEmail;
    String joinedDate = isGuest ? "-" : "Bergabung sejak Januari 2024";
    String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.only(bottom: 24, top: 8),
                child: Text(
                  "Profil",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),

              // Kartu Profil Utama
              _buildProfileCard(initial, displayName, displayEmail, joinedDate),
              const SizedBox(height: 20),

              // Baris Statistik
              _buildStatsRow(),
              const SizedBox(height: 20),

              // Cloud Sync Card
              _buildCloudSyncCard(),
              const SizedBox(height: 24),

              // Pengaturan Section
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  "PENGATURAN",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildSettingsMenu(),
              const SizedBox(height: 24),

              // Lainnya Section
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  "LAINNYA",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildOthersMenu(),
              const SizedBox(height: 32),

              // Tombol Keluar
              _buildLogoutButton(context),
              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  "Lync v2.4.1 · Made with ♥",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String initial, String name, String email, String joined) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primaryTosca,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C48C),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      joined,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Edit Profil Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: Colors.grey[800],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Edit Profil",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        int shortenCount = 0;
        int scanCount = 0;
        int qrCount = 0;

        if (state is HistoryLoaded) {
            shortenCount = state.history.where((i) => i.type == 'PENDEK').length;
            scanCount = state.history.where((i) => i.type == 'SCAN').length;
            qrCount = state.history.where((i) => i.type == 'QR').length;
        }

        return Row(
          children: [
            _buildStatCard("Scan", scanCount.toString(), const Color(0xFFCCFBF1), const Color(0xFF006D66), Icons.qr_code_scanner),
            const SizedBox(width: 12),
            _buildStatCard("Dipendekkan", shortenCount.toString(), const Color(0xFFF3E8FF), const Color(0xFFA855F7), Icons.link),
            const SizedBox(width: 12),
            _buildStatCard("QR Dibuat", qrCount.toString(), const Color(0xFFE0F2FE), const Color(0xFF3B82F6), Icons.qr_code_2),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String count, Color bgColor, Color fgColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: fgColor, size: 20),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudSyncCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFCCFBF1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_outlined, color: primaryTosca, size: 20),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: primaryTosca,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cloud Sinkronisasi Aktif",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 2),
                Text(
                  "Data disimpan otomatis ke Firestore",
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C48C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                "LIVE",
                style: TextStyle(
                  color: Color(0xFF00C48C),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.notifications_none,
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: "Notifikasi",
            subtitle: "Aktif",
            showBorder: true,
          ),
          _buildListTile(
            icon: Icons.shield_outlined,
            iconBgColor: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            title: "Keamanan & Privasi",
            subtitle: "2FA, sandi, data",
            showBorder: true,
          ),
          _buildListTile(
            icon: Icons.star_border,
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: "Upgrade ke Premium",
            subtitle: "Fitur tanpa batas",
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOthersMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.share_outlined,
            iconBgColor: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
            title: "Bagikan Aplikasi",
            showBorder: true,
          ),
          _buildListTile(
            icon: Icons.help_outline,
            iconBgColor: const Color(0xFFCCFBF1),
            iconColor: const Color(0xFF0D9488),
            title: "Bantuan & FAQ",
            showBorder: true,
          ),
          _buildListTile(
            icon: Icons.info_outline,
            iconBgColor: const Color(0xFFF3F4F6),
            iconColor: const Color(0xFF4B5563),
            title: "Tentang Lync",
            subtitle: "Versi 2.4.1",
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool showBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: () {},
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Logika logout
          context.read<AuthBloc>().add(LogoutRequested());
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          isGuest ? "Login Sekarang" : "Keluar dari Akun",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE2E2), // Merah muda
          foregroundColor: const Color(0xFFEF4444), // Merah
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
