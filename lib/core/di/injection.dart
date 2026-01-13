import 'package:get_it/get_it.dart';
import 'package:khel_mitra/features/assessment/data/firestore_attempts_repository.dart';
import 'package:khel_mitra/features/assessment/domain/attempts_repository.dart';
import 'package:khel_mitra/features/auth/data/firebase_auth_repository.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';
import 'package:khel_mitra/features/profile/data/firestore_profile_repository.dart';
import 'package:khel_mitra/features/profile/domain/profile_repository.dart';

final getIt = GetIt.instance;

/// Configure dependency injection
/// All repositories use Firestore for cloud sync
void configureDependencies() {
  // Auth Repository - Firebase
  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(),
  );

  // Profile Repository - Firestore
  getIt.registerLazySingleton<ProfileRepository>(
    () => FirestoreProfileRepository(),
  );

  // Attempts Repository - Firestore
  getIt.registerLazySingleton<AttemptsRepository>(
    () => FirestoreAttemptsRepository(),
  );
}
