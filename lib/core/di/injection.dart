import 'package:get_it/get_it.dart';
import 'package:khel_mitra/features/auth/data/firebase_auth_repository.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';
import 'package:khel_mitra/features/profile/data/mock_profile_repository.dart';
import 'package:khel_mitra/features/profile/domain/profile_repository.dart';

final getIt = GetIt.instance;

/// Configure dependency injection
/// Set [useMockAuth] to true for development without Firebase
void configureDependencies({bool useMockAuth = false}) {
  // Auth Repository - Firebase by default
  if (useMockAuth) {
    // Use mock for development/testing
    getIt.registerLazySingleton<AuthRepository>(
      () => throw UnimplementedError('Import MockAuthRepository if using mock'),
    );
  } else {
    getIt.registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(),
    );
  }

  // Profile Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => MockProfileRepository(),
  );
}
