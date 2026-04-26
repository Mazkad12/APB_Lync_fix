import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_event.dart';
import '../widgets/custom_bottom_nav.dart';
import 'shorten_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'scanner_screen.dart';
import 'generator_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isGuest;
  final String userEmail;

  const MainScreen({
    super.key,
    required this.isGuest,
    required this.userEmail,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default ke tab Shorten

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ScannerScreen(isGuest: widget.isGuest, userEmail: widget.userEmail),
      ShortenScreen(
        isGuest: widget.isGuest,
        userEmail: widget.userEmail,
        onViewAll: () => _onTabTapped(3),
      ),
      GeneratorScreen(isGuest: widget.isGuest, userEmail: widget.userEmail),
      HistoryScreen(isGuest: widget.isGuest, userEmail: widget.userEmail),
      ProfileScreen(isGuest: widget.isGuest, userEmail: widget.userEmail),
    ];
  }

  void _onTabTapped(int index) {
    if (widget.isGuest && index == 3) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Akses Terbatas"),
            content: const Text("Fitur Riwayat hanya tersedia untuk pengguna terdaftar. Silakan login untuk menyimpan dan melihat riwayat tautan Anda."),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D66),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Login Sekarang", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Memuat history saat layar utama dipanggil
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<HistoryBloc>().add(LoadHistory(userId: widget.isGuest ? null : widget.userEmail, isGuest: widget.isGuest));
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
