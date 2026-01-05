import 'package:get_it/get_it.dart';
import 'package:khel_mitra/features/auth/data/mock_auth_repository.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';
import 'package:khel_mitra/features/profile/data/mock_profile_repository.dart';
import 'package:khel_mitra/features/profile/domain/profile_repository.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
  getIt.registerLazySingleton<ProfileRepository>(() => MockProfileRepository());
}
