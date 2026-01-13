import 'package:firebase_auth/firebase_auth.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock implementation of AuthRepository for testing/development
/// Uses hardcoded OTP "123456" for verification
class MockAuthRepository implements AuthRepository {
  static const String _kLoggedInKey = 'is_logged_in';
  static const String _kMockUserId = 'mock_user_123';
  
  bool _isLoggedIn = false;

  @override
  Future<void> requestOtp(
    String phoneNumber, {
    required OtpSentCallback onCodeSent,
    required OtpErrorCallback onError,
    OtpAutoVerifiedCallback? onAutoVerified,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    print("MockAuth: OTP requested for $phoneNumber");
    
    // Always succeed and provide a mock verification ID
    onCodeSent('mock_verification_id');
  }

  @override
  Future<bool> verifyOtp(String verificationId, String otp) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    if (otp == '123456') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kLoggedInKey, true);
      _isLoggedIn = true;
      return true;
    }
    return false;
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_kLoggedInKey) ?? false;
    return _isLoggedIn;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedInKey);
    _isLoggedIn = false;
  }

  @override
  String? get currentUserId => _isLoggedIn ? _kMockUserId : null;

  @override
  Stream<User?> get authStateChanges {
    // Return empty stream for mock - real state is managed via prefs
    return const Stream.empty();
  }
}
