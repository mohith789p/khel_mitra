import 'package:firebase_auth/firebase_auth.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';

/// Firebase implementation of AuthRepository using Phone Authentication
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int? _resendToken;

  @override
  Future<void> requestOtp(
    String phoneNumber, {
    required OtpSentCallback onCodeSent,
    required OtpErrorCallback onError,
    OtpAutoVerifiedCallback? onAutoVerified,
  }) async {
    // Ensure phone number has country code
    final formattedPhone = phoneNumber.startsWith('+') 
        ? phoneNumber 
        : '+91$phoneNumber';

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only with auto-retrieval)
        try {
          await _auth.signInWithCredential(credential);
          onAutoVerified?.call();
        } catch (e) {
          onError('Auto-verification failed: ${e.toString()}');
        }
      },
      
      verificationFailed: (FirebaseAuthException e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-phone-number':
            errorMessage = 'Invalid phone number format';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later';
            break;
          case 'quota-exceeded':
            errorMessage = 'SMS quota exceeded. Please try again later';
            break;
          default:
            errorMessage = e.message ?? 'Verification failed';
        }
        onError(errorMessage);
      },
      
      codeSent: (String verificationId, int? resendToken) {
        _resendToken = resendToken;
        onCodeSent(verificationId);
      },
      
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timed out, user must enter OTP manually
        // verificationId is the same as the one passed to codeSent
      },
    );
  }

  @override
  Future<bool> verifyOtp(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return false;
      }
      rethrow;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
