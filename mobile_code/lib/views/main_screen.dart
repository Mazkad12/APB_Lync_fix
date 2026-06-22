import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_event.dart';
import '../viewmodels/auth/auth_bloc.dart';
import '../viewmodels/auth/auth_state.dart';
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
  int _currentIndex = 0; // Default ke tab Shorten
  String? _qrUrl;

  void _onGenerateQR(String url) {
    setState(() {
      _qrUrl = url;
      _currentIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentEmail = (authState is Authenticated) ? (authState.user.email ?? widget.userEmail) : widget.userEmail;

        final pages = [
          ShortenScreen(
            isGuest: widget.isGuest,
            userEmail: currentEmail,
            onViewAll: () => _onTabTapped(3),
            onGenerateQR: _onGenerateQR,
          ),
          _qrUrl != null
              ? GeneratorScreen(
                  key: ValueKey(_qrUrl),
                  isGuest: widget.isGuest,
                  userEmail: currentEmail,
                  initialQrData: _qrUrl,
                  onViewAll: () => _onTabTapped(3),
                )
              : GeneratorScreen(
                  isGuest: widget.isGuest,
                  userEmail: currentEmail,
                  onViewAll: () => _onTabTapped(3),
                ),
          ScannerScreen(isGuest: widget.isGuest, userEmail: currentEmail),
          HistoryScreen(isGuest: widget.isGuest, userEmail: currentEmail),
          ProfileScreen(isGuest: widget.isGuest, userEmail: currentEmail),
        ];

        // Memuat history saat layar utama dipanggil
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<HistoryBloc>().add(LoadHistory(userId: widget.isGuest ? null : currentEmail, isGuest: widget.isGuest));
        });

        return WillPopScope(
          onWillPop: () async {
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
              });
              return false;
            }
            return true;
          },
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        );
      },
    );
  }
}
