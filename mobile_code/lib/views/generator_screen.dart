import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/history/history_bloc.dart';
import '../viewmodels/history/history_event.dart';
import '../models/history_model.dart';
import 'package:uuid/uuid.dart';

class GeneratorScreen extends StatefulWidget {
  final bool isGuest;
  final String? userEmail;

  const GeneratorScreen({super.key, required this.isGuest, this.userEmail});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _globalKey = GlobalKey();
  static const Color primaryTosca = Color(0xFF006D66);
  String qrData = "";

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

      final directory = (await getApplicationDocumentsDirectory()).path;
      File imgFile = File('$directory/lync_qr_${DateTime.now().millisecondsSinceEpoch}.png');
      await imgFile.writeAsBytes(pngBytes);

      final success = await GallerySaver.saveImage(imgFile.path, albumName: 'Lync');
      
      if(success != null && success) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR Code disimpan ke Galeri!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
            );
         }
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
                   ],
                 )
               )
            ]
          ],
        ),
      ),
    );
  }
}
