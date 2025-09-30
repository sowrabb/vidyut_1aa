import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper so admin stores can talk to a persistence layer
/// without depending on `SharedPreferences` directly.
class AdminPersistence {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool?> getBool(String key) async =>
      (await _ensurePrefs()).getBool(key);
  Future<int?> getInt(String key) async => (await _ensurePrefs()).getInt(key);
  Future<double?> getDouble(String key) async =>
      (await _ensurePrefs()).getDouble(key);
  Future<String?> getString(String key) async =>
      (await _ensurePrefs()).getString(key);
  Future<List<String>?> getStringList(String key) async =>
      (await _ensurePrefs()).getStringList(key);

  Future<void> setBool(String key, bool value) async =>
      (await _ensurePrefs()).setBool(key, value);
  Future<void> setInt(String key, int value) async =>
      (await _ensurePrefs()).setInt(key, value);
  Future<void> setDouble(String key, double value) async =>
      (await _ensurePrefs()).setDouble(key, value);
  Future<void> setString(String key, String value) async =>
      (await _ensurePrefs()).setString(key, value);
  Future<void> setStringList(String key, List<String> value) async =>
      (await _ensurePrefs()).setStringList(key, value);

  Future<void> remove(String key) async => (await _ensurePrefs()).remove(key);
}
