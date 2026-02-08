import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:social_chat_app/core/constants/app_constants.dart';

/// Local storage service for persisting data
/// 
/// Uses Flutter Secure Storage for sensitive data (tokens) and
/// SharedPreferences for non-sensitive data (user info, settings).
class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  /// Initialize SharedPreferences - call in main() before runApp
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================================
  // TOKEN STORAGE (Secure)
  // ============================================

  /// Save access token securely
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  /// Get stored access token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  /// Delete access token
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  /// Save refresh token securely
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  /// Delete refresh token
  static Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  /// Check if user is logged in (has valid token)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================
  // USER DATA
  // ============================================

  /// Save user data as JSON
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs?.setString(AppConstants.userKey, json.encode(user));
  }

  /// Get stored user data
  static Future<Map<String, dynamic>?> getUser() async {
    final userString = _prefs?.getString(AppConstants.userKey);
    if (userString != null) {
      return json.decode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Delete stored user data
  static Future<void> deleteUser() async {
    await _prefs?.remove(AppConstants.userKey);
  }

  // ============================================
  // THEME SETTINGS
  // ============================================

  /// Save theme preference (isDark)
  static Future<void> saveTheme(bool isDark) async {
    await _prefs?.setBool(AppConstants.themeKey, isDark);
  }

  /// Get theme preference
  static bool getTheme() {
    return _prefs?.getBool(AppConstants.themeKey) ?? false;
  }

  // ============================================
  // GENERAL SETTINGS
  // ============================================

  /// Save a string value
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get a string value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Save a bool value
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Get a bool value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Save an int value
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// Get an int value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // ============================================
  // CLEANUP
  // ============================================

  /// Clear all stored data (for logout)
  static Future<void> clearAll() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }

  /// Clear only auth data (tokens + user)
  static Future<void> clearAuthData() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUser();
  }
}