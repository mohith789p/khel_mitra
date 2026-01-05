abstract class AuthRepository {
  Future<void> requestOtp(String phoneNumber);
  Future<bool> verifyOtp(String phoneNumber, String otp);
  Future<bool> isLoggedIn();
  Future<void> logout();
}
