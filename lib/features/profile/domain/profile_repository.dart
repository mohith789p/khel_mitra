abstract class ProfileRepository {
  Future<bool> isProfileComplete();
  Future<void> saveProfile({
    required String name,
    required DateTime dob,
    required String gender,
    required double heightCm,
  });
  Future<double?> getDiskSpaceFreeMb();
}
