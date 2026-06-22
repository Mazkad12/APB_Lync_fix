import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/auth/auth_bloc.dart';
import '../viewmodels/auth/auth_event.dart';
import '../viewmodels/auth/auth_state.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_state.dart';

class ProfileScreen extends StatefulWidget {
  final bool isGuest;
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.isGuest,
    required this.userEmail,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryTosca = Color(0xFF006D66);
  static const Color bgColor = Color(0xFFF8FAFB);

  late String _currentName;
  late String _currentEmail;
  String? _pendingEmailInput;

  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _currentEmail = widget.isGuest ? "Belum login" : (user?.email ?? widget.userEmail);
    _currentName = widget.isGuest
        ? "Tamu"
        : (user?.displayName ?? widget.userEmail.split('@').first);
    if (_currentName.isNotEmpty && !widget.isGuest) {
      _currentName = _currentName[0].toUpperCase() + _currentName.substring(1);
    }
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !widget.isGuest) {
      try {
        await user.reload();
        if (mounted) {
          context.read<AuthBloc>().add(AppStarted());
        }
      } catch (e) {
        print("Profile reload failed: $e");
      }
    }
  }

  void _showEditProfileDialog() {
    if (widget.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login untuk mengedit profil.")),
      );
      return;
    }

    final nameController = TextEditingController(text: _currentName);
    final emailController = TextEditingController(text: _currentEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                final newEmail = emailController.text.trim();
                if (newName.isEmpty || newEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Username dan Email tidak boleh kosong"), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                setState(() {
                  _pendingEmailInput = newEmail;
                });

                context.read<AuthBloc>().add(
                  UpdateProfileRequested(email: newEmail, displayName: newName)
                );
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTosca,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String initial = _currentName.isNotEmpty ? _currentName[0].toUpperCase() : "?";

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final isEmailPending = _pendingEmailInput != null && _pendingEmailInput != state.user.email;
          setState(() {
            _currentEmail = state.user.email ?? widget.userEmail;
            _currentName = state.user.displayName ?? (state.user.email?.split('@').first ?? 'User');
            if (_currentName.isNotEmpty) {
              _currentName = _currentName[0].toUpperCase() + _currentName.substring(1);
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEmailPending
                  ? "Link verifikasi dikirim ke $_pendingEmailInput. Silakan verifikasi email baru Anda."
                  : "Profil berhasil diperbarui"),
              backgroundColor: const Color(0xFF00C48C),
            ),
          );
          _pendingEmailInput = null;
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Stack(
          children: [
            Scaffold(
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
                      _buildProfileCard(initial, _currentName, _currentEmail),
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
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryTosca),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard(String initial, String name, String email) {
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 10),
                                SizedBox(width: 2),
                                Text(
                                  "PREMIUM",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1F2937),
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
              onPressed: _showEditProfileDialog,
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

        if (!widget.isGuest && state is HistoryLoaded) {
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

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: primaryTosca),
              SizedBox(width: 8),
              Text(
                "Notifikasi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            _notificationsEnabled
                ? "Notifikasi saat ini AKTIF. Apakah Anda ingin menonaktifkan notifikasi?"
                : "Notifikasi saat ini NONAKTIF. Apakah Anda ingin mengaktifkan notifikasi untuk menerima info terbaru?",
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _notificationsEnabled = !_notificationsEnabled;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _notificationsEnabled
                          ? "Notifikasi berhasil diaktifkan"
                          : "Notifikasi berhasil dinonaktifkan",
                    ),
                    backgroundColor: _notificationsEnabled
                        ? const Color(0xFF00C48C)
                        : Colors.grey[700],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTosca,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _notificationsEnabled ? "Nonaktifkan" : "Aktifkan",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSecuritySettings() {
    if (widget.isGuest) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Akses Terbatas", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Silakan login terlebih dahulu untuk mengakses menu Keamanan & Privasi."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: primaryTosca)),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Keamanan & Privasi",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kelola kata sandi, verifikasi, dan privasi akun Anda.",
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                      child: const Icon(Icons.key, color: Color(0xFF4B5563), size: 20),
                    ),
                    title: const Text("Ubah Kata Sandi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text("Kirim email reset kata sandi", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: _currentEmail);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Link reset kata sandi telah dikirim ke $_currentEmail"),
                              backgroundColor: const Color(0xFF00C48C),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal mengirim email reset: ${e.toString()}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                      child: const Icon(Icons.security, color: Color(0xFF0284C7), size: 20),
                    ),
                    title: const Text("Autentikasi Dua Faktor (2FA)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      _twoFactorEnabled ? "2FA Aktif (Simulasi)" : "Amankan akun Anda dengan 2FA",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: _twoFactorEnabled,
                      activeColor: primaryTosca,
                      onChanged: (val) {
                        setModalState(() {
                          _twoFactorEnabled = val;
                        });
                        setState(() {
                          _twoFactorEnabled = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _twoFactorEnabled
                                  ? "Simulasi: Autentikasi dua faktor diaktifkan"
                                  : "Simulasi: Autentikasi dua faktor dinonaktifkan",
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_forever, color: Color(0xFFEF4444), size: 20),
                    ),
                    title: const Text("Hapus Akun", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text("Hapus akun Anda secara permanen", style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteAccountConfirmation();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text("Hapus Akun?", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Tindakan ini tidak dapat dibatalkan. Semua data riwayat tautan dan QR code Anda akan dihapus secara permanen dari server.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.delete();
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Akun berhasil dihapus"),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                    context.read<AuthBloc>().add(LogoutRequested());
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${e.toString().contains('requires-recent-login') ? 'Hapus akun membutuhkan login ulang demi keamanan.' : e.toString()}"),
                        backgroundColor: Colors.red,
                        action: e.toString().contains('requires-recent-login')
                            ? SnackBarAction(
                                label: 'LOGOUT',
                                textColor: Colors.white,
                                onPressed: () {
                                  context.read<AuthBloc>().add(LogoutRequested());
                                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                },
                              )
                            : null,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Hapus Permanen", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showPremiumOffer() {
    if (_isPremium) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.stars, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text("Lync Premium Aktif", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Selamat! Anda sudah menikmati semua fitur premium tanpa batas."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup", style: TextStyle(color: primaryTosca)),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Color(0xFFD97706), size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Upgrade ke Lync Premium",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Buka semua fitur tanpa batas untuk produktivitas maksimal Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              _buildPremiumFeature(Icons.block, "Bebas Iklan", "Fokus penuh tanpa gangguan iklan yang mengganggu."),
              const SizedBox(height: 12),
              _buildPremiumFeature(Icons.link, "Kustom Alias", "Buat link pendek kustom (contoh: lync.id/bisnismu)."),
              const SizedBox(height: 12),
              _buildPremiumFeature(Icons.qr_code_2, "QR Code Kustom Tanpa Batas", "Desain QR Code sesuka Anda tanpa batasan kuota."),
              const SizedBox(height: 12),
              _buildPremiumFeature(Icons.bar_chart, "Statistik Tingkat Lanjut", "Lacak lokasi, referer, dan perangkat pengunjung."),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFEF3C7), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PROMO TAHUNAN", style: TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        SizedBox(height: 4),
                        Text("Rp 149.000 / tahun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
                      ],
                    ),
                    Chip(
                      label: const Text("Hemat 35%", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: const Color(0xFFD97706),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _executeUpgradeFlow();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Berlangganan Sekarang",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumFeature(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFD97706), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }

  void _executeUpgradeFlow() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // Close loading
          setState(() {
            _isPremium = true;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Icon(Icons.check_circle, color: Color(0xFF00C48C), size: 60),
                  const SizedBox(height: 16),
                  const Text("Upgrade Sukses!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text(
                    "Terima kasih! Anda sekarang adalah anggota Lync Premium.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTosca,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Mulai Gunakan", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD97706))),
                SizedBox(height: 20),
                Text("Memproses pembayaran aman...", style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Bagikan Aplikasi Lync",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                  child: const Icon(Icons.copy, color: Color(0xFF4B5563), size: 20),
                ),
                title: const Text("Salin Tautan Unduhan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("lync.app/download", style: TextStyle(fontSize: 12)),
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: "https://lync.app/download"));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tautan unduhan berhasil disalin ke papan klip!"),
                      backgroundColor: Color(0xFF00C48C),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF059669), size: 20),
                ),
                title: const Text("Bagikan via WhatsApp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onTap: () async {
                  Navigator.pop(context);
                  final text = Uri.encodeComponent(
                      "Yuk, gunakan Lync! Aplikasi keren untuk memendekkan link, membuat QR Code kustom, dan melacak analitik pemindaian. Unduh gratis di: https://lync.app/download");
                  final url = Uri.parse("https://wa.me/?text=$text");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tidak dapat membuka WhatsApp")),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                  child: const Icon(Icons.mail_outline, color: Color(0xFF0284C7), size: 20),
                ),
                title: const Text("Kirim via Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onTap: () async {
                  Navigator.pop(context);
                  final subject = Uri.encodeComponent("Rekomendasi Aplikasi Lync");
                  final body = Uri.encodeComponent(
                      "Halo!\n\nSaya ingin merekomendasikan aplikasi Lync untuk memendekkan URL dan membuat QR code kustom.\n\nUnduh di sini: https://lync.app/download");
                  final url = Uri.parse("mailto:?subject=$subject&body=$body");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tidak dapat membuka aplikasi Email")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFAQ() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Bantuan & FAQ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildFAQTile("Apa itu Lync?",
                            "Lync adalah platform all-in-one untuk memendekkan link panjang, membuat kode QR kustom, serta melacak analitik kunjungan secara real-time."),
                        const Divider(),
                        _buildFAQTile("Apakah layanan Lync gratis?",
                            "Ya, semua fitur dasar (memendekkan link standar dan menghasilkan QR code standar) gratis digunakan selamanya. Anda bisa mengupgrade ke Premium jika membutuhkan kustomisasi domain, alias kustom, QR kustom tanpa batas, dan analitik lengkap."),
                        const Divider(),
                        _buildFAQTile("Bagaimana cara membuat QR code kustom?",
                            "Masuk ke tab 'Generator' di menu bawah, masukkan tautan Anda, lalu Anda bisa memilih desain, warna, dan menyematkan logo. Terakhir, klik simpan ke galeri."),
                        const Divider(),
                        _buildFAQTile("Apakah link pendek Lync akan kedaluwarsa?",
                            "Tidak. Semua link pendek yang dibuat oleh akun terdaftar bersifat permanen dan aktif selamanya, kecuali jika Anda menghapusnya secara manual di tab Riwayat."),
                        const Divider(),
                        _buildFAQTile("Mengapa data saya di sinkronisasi ke cloud?",
                            "Lync menggunakan Google Firestore untuk mencadangkan riwayat link dan QR code Anda. Dengan begitu, data Anda aman dan dapat diakses dari perangkat mana pun setelah Anda login."),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
        ),
        iconColor: primaryTosca,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: primaryTosca,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryTosca.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.link, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Lync",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF1F2937)),
                ),
                const Text(
                  "Versi 2.4.1",
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Lync mempermudah manajemen tautan Anda. Pendekkan URL panjang, buat QR Code kustom yang dinamis, serta dapatkan analisis klik yang mendalam untuk bisnis Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey[200]),
                const SizedBox(height: 12),
                const Text(
                  "Dibuat oleh Tim APB Lync",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1F2937)),
                ),
                Text(
                  "© 2026 Lync Inc. Hak Cipta Dilindungi.",
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTosca,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            subtitle: _notificationsEnabled ? "Aktif" : "Nonaktif",
            showBorder: true,
            onTap: _showNotificationDialog,
          ),
          _buildListTile(
            icon: Icons.shield_outlined,
            iconBgColor: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            title: "Keamanan & Privasi",
            subtitle: widget.isGuest
                ? "Login untuk mengatur"
                : (_twoFactorEnabled ? "2FA Aktif, sandi, data" : "2FA Nonaktif, sandi, data"),
            showBorder: true,
            onTap: _showSecuritySettings,
          ),
          _buildListTile(
            icon: _isPremium ? Icons.stars : Icons.star_border,
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: "Upgrade ke Premium",
            subtitle: _isPremium ? "Premium Aktif" : "Fitur tanpa batas",
            showBorder: false,
            onTap: _showPremiumOffer,
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
            onTap: _showShareOptions,
          ),
          _buildListTile(
            icon: Icons.help_outline,
            iconBgColor: const Color(0xFFCCFBF1),
            iconColor: const Color(0xFF0D9488),
            title: "Bantuan & FAQ",
            showBorder: true,
            onTap: _showFAQ,
          ),
          _buildListTile(
            icon: Icons.info_outline,
            iconBgColor: const Color(0xFFF3F4F6),
            iconColor: const Color(0xFF4B5563),
            title: "Tentang Lync",
            subtitle: "Versi 2.4.1",
            showBorder: false,
            onTap: _showAboutDialog,
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
    required VoidCallback onTap,
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
        onTap: onTap,
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
        icon: Icon(widget.isGuest ? Icons.login : Icons.logout, size: 20),
        label: Text(
          widget.isGuest ? "Login Sekarang" : "Keluar dari Akun",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isGuest ? primaryTosca : const Color(0xFFFEE2E2),
          foregroundColor: widget.isGuest ? Colors.white : const Color(0xFFEF4444),
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
