import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history_model.dart';
import 'package:uuid/uuid.dart';

class HistoryRepository {
  final FirebaseFirestore? _injectedFirestore;
  final _uuid = const Uuid();

  // Local volatile list for Guest users
  final List<HistoryModel> _guestHistory = [];

  HistoryRepository({FirebaseFirestore? firestore})
      : _injectedFirestore = firestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  Future<void> addHistory(HistoryModel history, {bool isGuest = false}) async {
    if (isGuest || history.userId == null) {
      _guestHistory.insert(0, history);
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(history.userId)
          .collection('history')
          .doc(history.id)
          .set(history.toMap());
    } catch (e) {
      throw Exception('Failed to add history: ${e.toString()}');
    }
  }

  Stream<List<HistoryModel>> getHistories(String? userId, {bool isGuest = false}) {
    if (isGuest || userId == null) {
      // Simulate a stream for local data
      return Stream.value(_guestHistory);
    }

    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> deleteHistory(String id, String? userId, {bool isGuest = false}) async {
    if (isGuest || userId == null) {
      _guestHistory.removeWhere((item) => item.id == id);
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete history: ${e.toString()}');
    }
  }

  Future<void> updateHistoryTitle(String id, String? userId, String newTitle, {bool isGuest = false}) async {
    if(isGuest || userId == null){
      final index = _guestHistory.indexWhere((item) => item.id == id);
      if(index != -1){
        final item = _guestHistory[index];
        _guestHistory[index] = HistoryModel(
          id: item.id,
          userId: item.userId,
          originalUrl: item.originalUrl,
          shortUrl: item.shortUrl,
          type: item.type,
          title: newTitle,
          timestamp: item.timestamp
        );
      }
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(id)
          .update({'title': newTitle});
    } catch(e) {
      throw Exception('Failed to update label: ${e.toString()}');
    }
  }

  String generateId() => _uuid.v4();
}
