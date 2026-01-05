import 'package:khel_mitra/features/profile/domain/profile_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class MockProfileRepository implements ProfileRepository {
  static const String _kProfileCompleteKey = 'is_profile_complete';
  static const String _kNameKey = 'profile_name';
  static const String _kDobKey = 'profile_dob';
  static const String _kGenderKey = 'profile_gender';
  static const String _kHeightKey = 'profile_height';

  @override
  Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kProfileCompleteKey) ?? false;
  }

  @override
  Future<void> saveProfile({required String name, required DateTime dob, required String gender, required double heightCm}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNameKey, name);
    await prefs.setString(_kDobKey, dob.toIso8601String());
    await prefs.setString(_kGenderKey, gender);
    await prefs.setDouble(_kHeightKey, heightCm);
    await prefs.setBool(_kProfileCompleteKey, true);
  }

  @override
  Future<double?> getDiskSpaceFreeMb() async {
    try {
      // Use path_provider to get app directory and check free space
      final directory = await getApplicationDocumentsDirectory();
      final stat = await FileStat.stat(directory.path);
      // Note: FileStat doesn't give free space. We'll mock this for now.
      // On real implementation, use a platform channel or native code.
      // For MVP, return a safe value (assume enough space).
      return 2048.0; // Mock: 2GB free
    } catch (e) {
      print("DiskSpace Error: $e");
      return 2048.0; // Fail open for mock
    }
  }

  @override
  Future<double?> getHeightCm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_kHeightKey);
  }
}
