import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String id;
  final String? userId; // Null if guest
  final String originalUrl;
  final String? shortUrl;
  final String type; // 'SCAN', 'PENDEK', 'QR'
  final String title;
  final DateTime timestamp;

  HistoryModel({
    required this.id,
    this.userId,
    required this.originalUrl,
    this.shortUrl,
    required this.type,
    required this.title,
    required this.timestamp,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      id: id,
      userId: map['userId'],
      originalUrl: map['originalUrl'] ?? '',
      shortUrl: map['shortUrl'],
      type: map['type'] ?? 'SCAN',
      title: map['title'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] is Timestamp ? (map['timestamp'] as Timestamp).toDate() : DateTime.parse(map['timestamp'].toString()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'originalUrl': originalUrl,
      'shortUrl': shortUrl,
      'type': type,
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
