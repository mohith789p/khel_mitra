import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khel_mitra/features/profile/domain/profile_repository.dart';

/// Firestore implementation of ProfileRepository
/// Stores profile in users/{uid}/profile/data
class FirestoreProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the profile document reference for current user
  DocumentReference<Map<String, dynamic>> get _profileDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('profile').doc('data');
  }

  @override
  Future<bool> isProfileComplete() async {
    try {
      final doc = await _profileDoc.get();
      return doc.exists && doc.data()?['name'] != null;
    } catch (e) {
      print('FirestoreProfile: Error checking profile: $e');
      return false;
    }
  }

  @override
  Future<void> saveProfile({
    required String name,
    required DateTime dob,
    required String gender,
    required double heightCm,
  }) async {
    try {
      await _profileDoc.set({
        'name': name,
        'dob': dob.toIso8601String(),
        'gender': gender,
        'heightCm': heightCm,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('FirestoreProfile: Error saving profile: $e');
      rethrow;
    }
  }

  @override
  Future<double?> getDiskSpaceFreeMb() async {
    // Disk space check doesn't apply to cloud storage
    // Return a high value to indicate "enough space"
    return 10240.0; // 10GB
  }

  @override
  Future<double?> getHeightCm() async {
    try {
      final doc = await _profileDoc.get();
      return doc.data()?['heightCm'] as double?;
    } catch (e) {
      print('FirestoreProfile: Error getting height: $e');
      return null;
    }
  }

  /// Get full profile data
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final doc = await _profileDoc.get();
      return doc.data();
    } catch (e) {
      print('FirestoreProfile: Error getting profile: $e');
      return null;
    }
  }
}
