import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/scan/scan_bloc.dart';
import '../viewmodels/scan/scan_event.dart';
import '../viewmodels/scan/scan_state.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_event.dart';
import '../models/history_model.dart';
import 'package:uuid/uuid.dart';

class ScannerScreen extends StatefulWidget {
  final bool isGuest;
  final String? userEmail;

  const ScannerScreen({super.key, required this.isGuest, this.userEmail});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    context.read<ScanBloc>().add(StartScan());
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _showTopSnackBar(BuildContext context, String message, IconData icon, Color color) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlayState?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanBloc, ScanState>(
      listener: (context, state) {
        if (state is ScanSuccess) {
          _showTopSnackBar(context, "QR Code Berhasil Dipindai!", Icons.check_circle, Colors.green);
          
          final newHistory = HistoryModel(
            id: _uuid.v4(),
            userId: widget.isGuest ? null : widget.userEmail, // Should actually map to Firebase UID if available
            originalUrl: state.scannedData,
            type: 'SCAN',
            title: 'Scanned Link',
            timestamp: DateTime.now(),
          );

          context.read<HistoryBloc>().add(AddHistory(newHistory, userId: widget.isGuest ? null : widget.userEmail, isGuest: widget.isGuest));
          
          // Switch tab to shorten or history later using callback or we can navigate
        } else if (state is ScanFailure) {
           _showTopSnackBar(context, state.error, Icons.error, Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String code = barcodes.first.rawValue ?? "Unknown";
                    // Avoid multiple calls in the same scan session
                    if (state is ScanInProgress || state is ScanInitial) {
                      context.read<ScanBloc>().add(ProcessScannedData(code));
                      cameraController.stop(); // Stop camera after successful scan
                    }
                  }
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.flash_on, color: Colors.white),
                              iconSize: 28,
                              onPressed: () => cameraController.toggleTorch(),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.flip_camera_ios),
                              iconSize: 28,
                              onPressed: () => cameraController.switchCamera(),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Scanner Overlay Graphic
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF006D66), width: 4),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          "Arahkan kamera ke QR Code",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const Spacer(),
                      if (state is ScanSuccess)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Hasil Scan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(state.scannedData, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF006D66),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14)
                                  ),
                                  onPressed: () {
                                    context.read<ScanBloc>().add(ResetScan());
                                    cameraController.start();
                                  },
                                  child: const Text("Scan Lagi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
