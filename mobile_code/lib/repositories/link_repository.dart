import 'package:cloud_firestore/cloud_firestore.dart';

class LinkRepository {
  final FirebaseFirestore? _injectedFirestore;

  LinkRepository({FirebaseFirestore? firestore})
      : _injectedFirestore = firestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  Future<void> addLink(String shortCode, String originalUrl) async {
    try {
      await _firestore.collection('links').doc(shortCode).set({
        'originalUrl': originalUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add link to global collection: ${e.toString()}');
    }
  }
}
