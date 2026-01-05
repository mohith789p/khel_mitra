import 'package:khel_mitra/features/auth/domain/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements AuthRepository {
  static const String _kLoggedInKey = 'is_logged_in';

  @override
  Future<void> requestOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    // In a real app, this would trigger Firebase Auth
    print("MockAuth: OTP requested for $phoneNumber");
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    if (otp == '123456') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kLoggedInKey, true);
      return true;
    }
    return false;
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedInKey) ?? false;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedInKey);
  }
}
