import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class HistoryService {
  // Singleton pattern
  HistoryService._privateConstructor();
  static final HistoryService instance = HistoryService._privateConstructor();

  final _uuid = const Uuid();

  // ValueNotifier untuk state management yang reaktif
  final ValueNotifier<List<Map<String, dynamic>>> historyList = ValueNotifier([]);

  void addHistoryItem({
    required String type, // 'SCAN', 'PENDEK', 'QR'
    required String title,
    required String originalUrl,
    required String shortUrl,
  }) {
    final newItem = {
      'id': _uuid.v4(),
      'type': type,
      'title': title,
      'originalUrl': originalUrl,
      'shortUrl': shortUrl,
      'time': 'Baru saja',
      'timestamp': DateTime.now(), // Bisa digunakan untuk sorting/filtering nanti
    };
    
    // Update list: tambahkan di awal
    final currentList = List<Map<String, dynamic>>.from(historyList.value);
    currentList.insert(0, newItem);
    
    // Assign kembali untuk mentrigger ValueListenableBuilder
    historyList.value = currentList;
  }

  void deleteHistoryItem(String id) {
    final currentList = List<Map<String, dynamic>>.from(historyList.value);
    currentList.removeWhere((item) => item['id'] == id);
    historyList.value = currentList;
  }

  void updateHistoryTitle(String id, String newTitle) {
    final currentList = List<Map<String, dynamic>>.from(historyList.value);
    final index = currentList.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      currentList[index] = {
        ...currentList[index],
        'title': newTitle,
      };
      historyList.value = currentList;
    }
  }

  void clearHistory() {
    historyList.value = [];
  }
}
