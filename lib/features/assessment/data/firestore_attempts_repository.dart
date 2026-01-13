import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khel_mitra/features/assessment/domain/attempts_repository.dart';
import 'package:khel_mitra/features/assessment/models/attempt_model.dart';

/// Firestore implementation of AttemptsRepository
/// Stores attempts in users/{uid}/attempts collection
class FirestoreAttemptsRepository implements AttemptsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the attempts collection reference for current user
  CollectionReference<Map<String, dynamic>> get _attemptsCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('attempts');
  }

  @override
  Future<List<AttemptModel>> getAttempts() async {
    try {
      final snapshot = await _attemptsCollection
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AttemptModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('FirestoreAttempts: Error getting attempts: $e');
      return [];
    }
  }

  @override
  Future<void> saveAttempt(AttemptModel attempt) async {
    try {
      await _attemptsCollection.doc(attempt.id).set(attempt.toJson());
    } catch (e) {
      print('FirestoreAttempts: Error saving attempt: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAttempts() async {
    try {
      final snapshot = await _attemptsCollection.get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('FirestoreAttempts: Error clearing attempts: $e');
      rethrow;
    }
  }

  @override
  Stream<List<AttemptModel>> watchAttempts() {
    return _attemptsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return AttemptModel.fromJson(data);
          }).toList();
        });
  }
}
