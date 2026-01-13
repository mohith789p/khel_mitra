import 'package:khel_mitra/features/assessment/models/attempt_model.dart';

/// Abstract interface for attempts repository
abstract class AttemptsRepository {
  Future<List<AttemptModel>> getAttempts();
  Future<void> saveAttempt(AttemptModel attempt);
  Future<void> clearAttempts();
  Stream<List<AttemptModel>> watchAttempts();
}
