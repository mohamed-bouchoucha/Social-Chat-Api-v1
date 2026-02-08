import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  static late SharedPreferences _prefs;
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token storage
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // User data
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString('user_data', json.encode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userString = _prefs.getString('user_data');
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  static Future<void> deleteUser() async {
    await _prefs.remove('user_data');
  }

  // Theme
  static Future<void> saveTheme(bool isDark) async {
    await _prefs.setBool('is_dark_theme', isDark);
  }

  static Future<bool> getTheme() async {
    return _prefs.getBool('is_dark_theme') ?? false;
  }

  // Clear all
  static Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}