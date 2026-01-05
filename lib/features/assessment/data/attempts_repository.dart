import 'dart:convert';
import 'package:khel_mitra/features/assessment/models/attempt_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttemptsRepository {
  static const String _kAttemptsKey = 'attempts_list';

  Future<List<AttemptModel>> getAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kAttemptsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => AttemptModel.fromJson(j)).toList();
  }

  Future<void> saveAttempt(AttemptModel attempt) async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = await getAttempts();
    attempts.add(attempt);

    final jsonList = attempts.map((a) => a.toJson()).toList();
    await prefs.setString(_kAttemptsKey, json.encode(jsonList));
  }

  Future<void> clearAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAttemptsKey);
  }
}
