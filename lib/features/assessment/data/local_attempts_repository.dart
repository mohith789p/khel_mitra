import 'dart:convert';
import 'package:khel_mitra/features/assessment/domain/attempts_repository.dart';
import 'package:khel_mitra/features/assessment/models/attempt_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local implementation of AttemptsRepository using SharedPreferences
class LocalAttemptsRepository implements AttemptsRepository {
  static const String _kAttemptsKey = 'attempts_list';

  @override
  Future<List<AttemptModel>> getAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kAttemptsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => AttemptModel.fromJson(j)).toList();
  }

  @override
  Future<void> saveAttempt(AttemptModel attempt) async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = await getAttempts();
    attempts.add(attempt);

    final jsonList = attempts.map((a) => a.toJson()).toList();
    await prefs.setString(_kAttemptsKey, json.encode(jsonList));
  }

  @override
  Future<void> clearAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAttemptsKey);
  }

  @override
  Stream<List<AttemptModel>> watchAttempts() async* {
    // Local storage doesn't support real-time updates
    // Just yield current attempts once
    yield await getAttempts();
  }
}
