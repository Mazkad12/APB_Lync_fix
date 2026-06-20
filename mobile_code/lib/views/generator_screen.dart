import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_event.dart';
import '../models/history_model.dart';
import '../viewmodels/history/history_state.dart';
import 'package:uuid/uuid.dart';

class GeneratorScreen extends StatefulWidget {
  final bool isGuest;
  final String? userEmail;
  final String? initialQrData;
  final VoidCallback? onViewAll;

  const GeneratorScreen({
    super.key,
    required this.isGuest,
    this.userEmail,
    this.initialQrData,
    this.onViewAll,
  });

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _globalKey = GlobalKey();
  static const Color primaryTosca = Color(0xFF006D66);
  String qrData = "";

  @override
  void initState() {
    super.initState();
    if (widget.initialQrData != null && widget.initialQrData!.isNotEmpty) {
      _textController.text = widget.initialQrData!;
      qrData = widget.initialQrData!;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newHistory = HistoryModel(
          id: const Uuid().v4(),
          userId: widget.isGuest ? null : widget.userEmail,
          originalUrl: qrData,
          type: 'QR',
          title: 'Generated QR Code',
          timestamp: DateTime.now(),
        );
        context.read<HistoryBloc>().add(
          AddHistory(newHistory, userId: widget.isGuest ? null : widget.userEmail, isGuest: widget.isGuest),
        );
      });
    }
  }

  void _generateQR() {
    setState(() {
      qrData = _textController.text;
    });
    
    if (qrData.isNotEmpty) {
      final newHistory = HistoryModel(
          id: const Uuid().v4(),
          userId: widget.isGuest ? null : widget.userEmail,
          originalUrl: qrData,
          type: 'QR',
          title: 'Generated QR Code',
          timestamp: DateTime.now(),
      );
      context.read<HistoryBloc>().add(AddHistory(newHistory, userId: widget.isGuest ? null : widget.userEmail, isGuest: widget.isGuest));
    }
  }

  Future<void> _saveQRToGallery() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes, album: 'Lync', name: 'lync_qr_${DateTime.now().millisecondsSinceEpoch}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code disimpan ke Galeri!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan QR: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text("QR Generator", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryTosca,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             Container(
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
                    "TEKS ATAU TAUTAN",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Masukkan teks atau tautan...",
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryTosca, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _generateQR,
                      icon: const Icon(Icons.qr_code),
                      label: const Text("Buat QR Code", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTosca,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ]
              )
            ),
            const SizedBox(height: 32),
            if (qrData.isNotEmpty) ...[
               Container(
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
                   children: [
                     RepaintBoundary(
                        key: _globalKey,
                        child: Container(
                          color: Colors.white, // Ensure white background for saving
                          padding: const EdgeInsets.all(16.0),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200.0,
                            foregroundColor: primaryTosca,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saveQRToGallery,
                          icon: const Icon(Icons.download),
                          label: const Text("Simpan ke Galeri", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCCFBF1),
                            foregroundColor: primaryTosca,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ]
                  )
                )
             ],
             const SizedBox(height: 32),
             _buildHistorySection(),
             const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // WIDGET RIWAYAT
  Widget _buildHistorySection() {
    if (widget.isGuest) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoaded) {
          final qrHistory = state.history.where((i) => i.type == 'QR').toList();
          if (qrHistory.isEmpty) {
            return const SizedBox.shrink(); 
          }

          final recentHistory = qrHistory.take(3).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                    GestureDetector(
                      onTap: widget.onViewAll,
                      child: Row(
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
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...recentHistory.map((item) {
                  Color iconBgColor = const Color(0xFFE0F2FE);
                  Color iconColor = const Color(0xFF3B82F6);
                  IconData iconData = Icons.qr_code_2;

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
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.shortUrl ?? item.originalUrl,
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
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              String copyText = item.shortUrl ?? item.originalUrl;
                              Clipboard.setData(ClipboardData(text: copyText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Tautan disalin!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.copy, size: 18, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
