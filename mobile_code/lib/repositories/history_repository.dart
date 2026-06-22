import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history_model.dart';
import 'package:uuid/uuid.dart';

class HistoryRepository {
  final FirebaseFirestore? _injectedFirestore;
  final _uuid = const Uuid();

  // Reactive Local Storage
  static final List<HistoryModel> _demoHistory = [];
  static final StreamController<List<HistoryModel>> _historyController = StreamController<List<HistoryModel>>.broadcast();

  HistoryRepository({FirebaseFirestore? firestore})
      : _injectedFirestore = firestore {
    _historyController.add(List.unmodifiable(_demoHistory));
  }

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  void _notifyListeners() {
    _historyController.add(List.unmodifiable(_demoHistory));
  }

  void clearGuestHistory() {
    _demoHistory.clear();
    _notifyListeners();
  }

  Future<void> addHistory(HistoryModel history, {bool isGuest = false}) async {
    _demoHistory.insert(0, history);
    _notifyListeners();

    if (isGuest || history.userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(history.userId)
          .collection('history')
          .doc(history.id)
          .set(history.toMap());
    } catch (e) {
      print("Firestore Error: $e");
    }
  }

  Stream<List<HistoryModel>> getHistories(String? userId, {bool isGuest = false}) {
    _notifyListeners();
    if (isGuest || userId == null) return _historyController.stream;

    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            final firestoreData = snapshot.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList();
            
            // Sinkronisasi list cache lokal agar sinkron dengan Firestore
            _demoHistory.clear();
            _demoHistory.addAll(firestoreData);
            
            return firestoreData;
          }).handleError((e) => _demoHistory);
    } catch (e) {
      return _historyController.stream;
    }
  }

  Future<void> deleteHistory(String id, String? userId, {bool isGuest = false}) async {
    _demoHistory.removeWhere((item) => item.id == id);
    _notifyListeners();
    if (isGuest || userId == null) return;
    try {
      await _firestore.collection('users').doc(userId).collection('history').doc(id).delete();
    } catch (e) {}
  }

  Future<void> updateHistoryTitle(String id, String? userId, String newTitle, {bool isGuest = false}) async {
    final index = _demoHistory.indexWhere((item) => item.id == id);
    if(index != -1){
      final item = _demoHistory[index];
      _demoHistory[index] = HistoryModel(
        id: item.id, userId: item.userId, originalUrl: item.originalUrl,
        shortUrl: item.shortUrl, type: item.type, title: newTitle, timestamp: item.timestamp
      );
      _notifyListeners();
    }
    if(isGuest || userId == null) return;
    try {
      await _firestore.collection('users').doc(userId).collection('history').doc(id).update({'title': newTitle});
    } catch(e) {}
  }

  Future<void> migrateHistory(String oldEmail, String newEmail) async {
    try {
      final oldRef = _firestore.collection('users').doc(oldEmail).collection('history');
      final newRef = _firestore.collection('users').doc(newEmail).collection('history');
      
      final snapshot = await oldRef.get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['userId'] = newEmail;
        await newRef.doc(doc.id).set(data);
        await doc.reference.delete();
      }
    } catch (e) {
      print("Migration Error: $e");
      rethrow;
    }
  }

  String generateId() => _uuid.v4();
}
