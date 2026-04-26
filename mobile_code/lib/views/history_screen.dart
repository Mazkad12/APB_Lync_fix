import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color primaryTosca = Color(0xFF006D66);
  String activeFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: HistoryService.instance.historyList,
          builder: (context, history, child) {
            int scanCount = history.where((i) => i['type'] == 'SCAN').length;
            int pendekCount = history.where((i) => i['type'] == 'PENDEK').length;

            List<Map<String, dynamic>> filteredHistory = history;
            if (activeFilter.startsWith('Scan')) {
              filteredHistory = history.where((i) => i['type'] == 'SCAN').toList();
            } else if (activeFilter.startsWith('Dipendekkan')) {
              filteredHistory = history.where((i) => i['type'] == 'PENDEK').toList();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Riwayat",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.history, size: 14, color: primaryTosca),
                            const SizedBox(width: 4),
                            Text("${history.length} item", style: const TextStyle(color: primaryTosca, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', Icons.access_time_filled, activeFilter == 'Semua'),
                      const SizedBox(width: 12),
                      _buildFilterChip('Scan ($scanCount)', Icons.qr_code_scanner, activeFilter.startsWith('Scan')),
                      const SizedBox(width: 12),
                      _buildFilterChip('Dipendekkan ($pendekCount)', Icons.link, activeFilter.startsWith('Dipendekkan')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: filteredHistory.isEmpty
                      ? const Center(child: Text("Belum ada riwayat", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) => HistoryCardItem(data: filteredHistory[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryTosca : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isActive ? [BoxShadow(color: primaryTosca.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[500]),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class HistoryCardItem extends StatefulWidget {
  final Map<String, dynamic> data;
  const HistoryCardItem({Key? key, required this.data}) : super(key: key);

  @override
  State<HistoryCardItem> createState() => _HistoryCardItemState();
}

class _HistoryCardItemState extends State<HistoryCardItem> {
  bool _isExpanded = false;

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
            decoration: BoxDecoration(color: color.withOpacity(0.95), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
              ],
            ),
          ),
        ),
      ),
    );
    overlayState?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 32),
              ),
              const SizedBox(height: 20),
              const Text("Hapus Riwayat?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const SizedBox(height: 12),
              Text("Item ini akan dihapus secara permanen dari cloud storage kamu.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFFF3F4F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("Batal", style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HistoryService.instance.deleteHistoryItem(id);
                        Navigator.pop(context);
                        _showTopSnackBar(context, "Item dihapus dari riwayat", Icons.info_outline, const Color(0xFF006D66).withOpacity(0.8));
                      },
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      label: const Text("Hapus"),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditLabelModal(BuildContext context, String currentTitle, String originalUrl) {
    final TextEditingController _titleController = TextEditingController(text: currentTitle);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Edit Label", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.grey, size: 20)),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.edit, color: Color(0xFF006D66), size: 20),
                suffixIcon: GestureDetector(onTap: () => _titleController.clear(), child: const Icon(Icons.close, color: Colors.grey, size: 18)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF006D66), width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF006D66), width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Konten:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(originalUrl, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6), foregroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.data['id'] != null) {
                        HistoryService.instance.updateHistoryTitle(widget.data['id'], _titleController.text);
                        _showTopSnackBar(context, "Label berhasil disimpan!", Icons.check_circle_outline, const Color(0xFF00C48C));
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006D66), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.data['type'] ?? 'SCAN';
    Color iconBgColor = type == 'SCAN' ? const Color(0xFFE0FDF4) : (type == 'PENDEK' ? const Color(0xFFF3E8FF) : const Color(0xFFE0F2FE));
    Color iconColor = type == 'SCAN' ? const Color(0xFF00C48C) : (type == 'PENDEK' ? const Color(0xFFA855F7) : const Color(0xFF3B82F6));
    IconData iconData = type == 'SCAN' ? Icons.qr_code_scanner : (type == 'PENDEK' ? Icons.link : Icons.qr_code_2);
    String badgeText = type;

    String title = widget.data['title'] ?? '';
    String originalUrl = widget.data['originalUrl'] ?? widget.data['url'] ?? '';
    String shortUrl = widget.data['shortUrl'] ?? '';
    String time = widget.data['time'] ?? 'Baru saja';
    bool hasCustomLabel = title != originalUrl;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: _isExpanded ? Border.all(color: const Color(0xFFE0F2F1), width: 1.5) : null, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)), child: Icon(iconData, color: iconColor, size: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasCustomLabel) ...[
                        Row(children: [Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), _buildBadge(iconBgColor, iconData, iconColor, badgeText)]),
                        const SizedBox(height: 4),
                        Text(originalUrl, style: TextStyle(fontSize: 13, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ] else ...[
                        Align(alignment: Alignment.centerLeft, child: _buildBadge(iconBgColor, iconData, iconColor, badgeText)),
                        const SizedBox(height: 4),
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1F2937)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 4),
                      Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(_isExpanded ? Icons.expand_more : Icons.chevron_right, color: Colors.grey[300]),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade100, thickness: 1),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("URL ASLI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        GestureDetector(onTap: () { Clipboard.setData(ClipboardData(text: originalUrl)); _showTopSnackBar(context, "URL asli disalin!", Icons.check_circle_outline, const Color(0xFF00C48C)); }, child: const Icon(Icons.copy, size: 14, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(originalUrl, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4), maxLines: 4, overflow: TextOverflow.ellipsis),
                    if (shortUrl.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("URL PENDEK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          GestureDetector(onTap: () { Clipboard.setData(ClipboardData(text: shortUrl)); _showTopSnackBar(context, "URL pendek disalin!", Icons.check_circle_outline, const Color(0xFF00C48C)); }, child: const Icon(Icons.copy, size: 14, color: Color(0xFF006D66))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(shortUrl, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006D66))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildButton(label: "Label", icon: Icons.edit, onPressed: () => _showEditLabelModal(context, title, originalUrl)),
                  const SizedBox(width: 8),
                  _buildButton(label: "Salin", icon: Icons.copy, isPrimary: true, onPressed: () { Clipboard.setData(ClipboardData(text: shortUrl.isNotEmpty ? shortUrl : originalUrl)); _showTopSnackBar(context, "URL ${shortUrl.isNotEmpty ? 'pendek' : 'asli'} disalin!", Icons.check_circle_outline, const Color(0xFF00C48C)); }),
                  const SizedBox(width: 8),
                  _buildDeleteButton(onPressed: () { if (widget.data['id'] != null) _showDeleteConfirmation(context, widget.data['id']); }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Color bgColor, IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 10, color: color), const SizedBox(width: 4), Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color))]),
    );
  }

  Widget _buildButton({required String label, required IconData icon, required VoidCallback onPressed, bool isPrimary = false}) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(foregroundColor: isPrimary ? const Color(0xFF006D66) : Colors.grey[800], backgroundColor: isPrimary ? const Color(0xFFCCFBF1) : const Color(0xFFF3F4F6), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildDeleteButton({required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(foregroundColor: Colors.red[700], backgroundColor: const Color(0xFFFEE2E2), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Icon(Icons.delete_outline, size: 20),
    );
  }
}
