import 'package:shared_preferences/shared_preferences.dart';

class UserCreatedDefibrillatorRepository {
  static const String _storageKey = 'user_created_aed_ids';

  Future<void> add(int defibrillatorId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_storageKey) ?? [];
    if (!ids.contains(defibrillatorId.toString())) {
      ids.add(defibrillatorId.toString());
      await prefs.setStringList(_storageKey, ids);
    }
  }

  Future<bool> contains(int defibrillatorId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_storageKey) ?? [];
    return ids.contains(defibrillatorId.toString());
  }

  Future<void> remove(int defibrillatorId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_storageKey) ?? [];
    ids.remove(defibrillatorId.toString());
    await prefs.setStringList(_storageKey, ids);
  }
}