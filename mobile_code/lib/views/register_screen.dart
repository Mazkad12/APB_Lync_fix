import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/auth/auth_bloc.dart';
import '../viewmodels/auth/auth_event.dart';
import '../viewmodels/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk menangkap input teks
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Warna sesuai referensi desain Lync
  static const Color primaryTosca = Color(0xFF006D66);
  static const Color textBlack = Color(0xFF111827);

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi'), backgroundColor: Colors.red),
      );
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid'), backgroundColor: Colors.red),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter'), backgroundColor: Colors.red),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi password tidak cocok'), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<AuthBloc>().add(RegisterRequested(email, password, name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(
            context,
            '/main',
            arguments: {'isGuest': false, 'userEmail': state.user.email ?? 'User'},
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        bool _isLoading = state is AuthLoading;
        return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFB,
      ), // Background abu-abu sangat muda
      body: SafeArea(
        child: SingleChildScrollView(
          // --- PADDING HORIZONTAL 30 SESUAI PERMINTAAN ---
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "Buat Akun Baru",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textBlack,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Daftar gratis dan mulai gunakan Lync sekarang",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 35),

              // Form Input
              _buildLabel("NAMA LENGKAP"),
              _buildTextField(
                _nameController,
                "Nama lengkap kamu",
                Icons.person_outline,
              ),

              const SizedBox(height: 20),
              _buildLabel("EMAIL"),
              _buildTextField(
                _emailController,
                "contoh@email.com",
                Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),
              _buildLabel("PASSWORD"),
              _buildTextField(
                _passwordController,
                "Minimal 6 karakter",
                Icons.lock_outline,
                isPassword: true,
                obscure: _obscurePass,
                onToggle: () => setState(() => _obscurePass = !_obscurePass),
              ),

              const SizedBox(height: 20),
              _buildLabel("KONFIRMASI PASSWORD"),
              _buildTextField(
                _confirmController,
                "Ulangi password",
                Icons.lock_outline,
                isPassword: true,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),

              const SizedBox(height: 25),

              // Syarat & Ketentuan
              Center(child: _buildTermsText()),

              const SizedBox(height: 35),

              // Tombol Daftar (FE Only)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTosca,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Buat Akun",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // Footer
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    children: [
                      const TextSpan(text: "Sudah punya akun? "),
                      TextSpan(
                        text: "Masuk",
                        style: const TextStyle(
                          color: primaryTosca,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  // Widget Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textBlack,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // Widget Helper untuk Input Field
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryTosca, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: onToggle,
                )
              : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.5),
        children: const [
          TextSpan(text: "Dengan mendaftar, kamu menyetujui "),
          TextSpan(
            text: "Syarat & Ketentuan",
            style: TextStyle(color: primaryTosca, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " dan "),
          TextSpan(
            text: "Kebijakan Privasi",
            style: TextStyle(color: primaryTosca, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " Lync."),
        ],
      ),
      textAlign: TextAlign
          .center, // <-- Sekarang sudah benar karena menggunakan named argument
    );
  }
}
