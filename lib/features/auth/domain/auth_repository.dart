import 'package:firebase_auth/firebase_auth.dart';

/// Callback type definitions for OTP flow
typedef OtpSentCallback = void Function(String verificationId);
typedef OtpErrorCallback = void Function(String error);
typedef OtpAutoVerifiedCallback = void Function();

/// Abstract repository interface for authentication
abstract class AuthRepository {
  /// Request OTP to be sent to the given phone number
  /// [phoneNumber] should include country code (e.g., +919876543210)
  Future<void> requestOtp(
    String phoneNumber, {
    required OtpSentCallback onCodeSent,
    required OtpErrorCallback onError,
    OtpAutoVerifiedCallback? onAutoVerified,
  });

  /// Verify the OTP entered by user
  /// Returns true if verification successful
  Future<bool> verifyOtp(String verificationId, String otp);

  /// Check if user is currently logged in
  Future<bool> isLoggedIn();

  /// Log out the current user
  Future<void> logout();

  /// Get current user's UID (null if not logged in)
  String? get currentUserId;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;
}
