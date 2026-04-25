import 'package:flutter/material.dart';
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
            
            // Hitung jumlah masing-masing tipe
            int scanCount = history.where((i) => i['type'] == 'SCAN').length;
            int pendekCount = history.where((i) => i['type'] == 'PENDEK').length;
            
            // Terapkan filter
            List<Map<String, dynamic>> filteredHistory = history;
            if (activeFilter.startsWith('Scan')) {
              filteredHistory = history.where((i) => i['type'] == 'SCAN').toList();
            } else if (activeFilter.startsWith('Dipendekkan')) {
              filteredHistory = history.where((i) => i['type'] == 'PENDEK').toList();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Riwayat",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.history, size: 14, color: primaryTosca),
                            const SizedBox(width: 4),
                            Text(
                              "${history.length} item",
                              style: const TextStyle(
                                color: primaryTosca,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Chips
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

                // History List
                Expanded(
                  child: filteredHistory.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada riwayat",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            return HistoryCardItem(data: filteredHistory[index]);
                          },
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
      onTap: () {
        setState(() {
          activeFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryTosca : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryTosca.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
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

  void _showEditLabelModal(BuildContext context, String currentTitle, String originalUrl) {
    final TextEditingController _titleController = TextEditingController(text: currentTitle);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Label",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.edit, color: Color(0xFF006D66), size: 20),
                  suffixIcon: GestureDetector(
                    onTap: () => _titleController.clear(),
                    child: const Icon(Icons.close, color: Colors.grey, size: 18),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF006D66), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF006D66), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Konten:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                originalUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.data['id'] != null) {
                          HistoryService.instance.updateHistoryTitle(widget.data['id'], _titleController.text);
                        }
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D66),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.data['type'] ?? 'SCAN';
    Color iconBgColor;
    Color iconColor;
    IconData iconData;
    String badgeText;

    if (type == 'SCAN') {
      iconBgColor = const Color(0xFFE0FDF4);
      iconColor = const Color(0xFF00C48C);
      iconData = Icons.qr_code_scanner;
      badgeText = 'SCAN';
    } else if (type == 'PENDEK') {
      iconBgColor = const Color(0xFFF3E8FF);
      iconColor = const Color(0xFFA855F7);
      iconData = Icons.link;
      badgeText = 'PENDEK';
    } else {
      iconBgColor = const Color(0xFFE0F2FE);
      iconColor = const Color(0xFF3B82F6);
      iconData = Icons.qr_code_2;
      badgeText = 'QR';
    }

    // Default values if original/short are not set yet
    String title = widget.data['title'] ?? '';
    String originalUrl = widget.data['originalUrl'] ?? widget.data['url'] ?? '';
    String shortUrl = widget.data['shortUrl'] ?? '';
    String time = widget.data['time'] ?? 'Baru saja';

    // Cek apakah judul telah diubah (custom label)
    bool hasCustomLabel = title != originalUrl;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: _isExpanded ? Border.all(color: const Color(0xFFE0F2F1), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Selalu tampil)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasCustomLabel) ...[
                        // Jika ada label custom: Label sejajar dengan badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1F2937),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(iconData, size: 10, color: iconColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    badgeText,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: iconColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Tampilkan URL Asli di bawah label custom
                        Text(
                          originalUrl,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        // Jika tidak ada label: Badge di atas, URL di bawah
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(iconData, size: 10, color: iconColor),
                                const SizedBox(width: 4),
                                Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: iconColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title, // title sama dengan originalUrl di kasus ini
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_more : Icons.chevron_right,
                  color: Colors.grey[300],
                ),
              ],
            ),
            
            // Expanded Section
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade100, thickness: 1),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "URL ASLI",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Icon(Icons.copy, size: 14, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      originalUrl,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (shortUrl.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "URL PENDEK",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Icon(Icons.copy, size: 14, color: Color(0xFF006D66)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shortUrl,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006D66),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditLabelModal(context, title, originalUrl),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Label", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        backgroundColor: const Color(0xFFF3F4F6),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement Copy
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text("Salin", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF006D66),
                        backgroundColor: const Color(0xFFCCFBF1), // Cyan muda
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.data['id'] != null) {
                        HistoryService.instance.deleteHistoryItem(widget.data['id']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      backgroundColor: const Color(0xFFFEE2E2), // Merah muda
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
