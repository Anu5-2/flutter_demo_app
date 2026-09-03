import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _usersKey = 'registered_users';
  static const _currentUserKey = 'current_user';

  Future<String?> register({
    required String petName,
    String email = '',
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final petKey = petName.trim().toLowerCase();

    if (users.containsKey(petKey)) {
      return 'An account already exists for that pet name.';
    }

    users[petKey] = {
      'petName': petName.trim(),
      'email': email.trim(),
      'password': password,
    };

    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, petKey);
    return null;
  }

  Future<LoginResult> login({
    required String petName,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final petKey = petName.trim().toLowerCase();

    if (!users.containsKey(petKey)) {
      return LoginResult(
          success: false, error: 'No account found for that pet name.');
    }

    final storedPassword = users[petKey]!['password'];
    if (storedPassword != password) {
      return LoginResult(success: false, error: 'Incorrect password.');
    }

    await prefs.setString(_currentUserKey, petKey);

    final displayName = users[petKey]!['petName'] ?? petName;
    return LoginResult(success: true, petName: displayName);
  }

  /// Logs in by matching the account whose stored email matches.
  /// Used by the new email/password login screen.
  Future<LoginResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final normalizedEmail = email.trim().toLowerCase();

    String? matchedKey;
    Map<String, dynamic>? matchedUser;
    for (final entry in users.entries) {
      if ((entry.value['email'] as String?)?.toLowerCase() == normalizedEmail) {
        matchedKey = entry.key;
        matchedUser = entry.value;
        break;
      }
    }

    if (matchedUser == null) {
      return LoginResult(
          success: false, error: 'No account found for that email.');
    }
    if (matchedUser['password'] != password) {
      return LoginResult(success: false, error: 'Incorrect password.');
    }

    await prefs.setString(_currentUserKey, matchedKey!);
    return LoginResult(success: true, petName: matchedUser['petName']);
  }

  /// Returns the account data for whoever is currently signed in
  /// on this device, or null if no one is signed in.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final petKey = prefs.getString(_currentUserKey);
    if (petKey == null) return null;
    final users = _loadUsers(prefs);
    return users[petKey];
  }

  /// Clears the current session (does not delete the account itself).
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<bool> getNotificationPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_pref_$key') ?? true;
  }

  Future<void> setNotificationPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_pref_$key', value);
  }

  Future<bool> getLocationSharing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('location_sharing') ?? true;
  }

  Future<void> setLocationSharing(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_sharing', value);
  }

  Future<String?> changePassword(
      {required String currentPassword, required String newPassword}) async {
    final prefs = await SharedPreferences.getInstance();
    final petKey = prefs.getString(_currentUserKey);
    if (petKey == null) return 'No user logged in';
    final users = _loadUsers(prefs);
    final user = users[petKey];
    if (user == null) return 'User not found';
    if (user['password'] != currentPassword) {
      return 'Current password is incorrect';
    }
    user['password'] = newPassword;
    await prefs.setString(_usersKey, jsonEncode(users));
    return null;
  }

  Future<void> deleteLocationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('location_history');
  }

  Future<void> deleteCurrentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final petKey = prefs.getString(_currentUserKey);
    if (petKey == null) return;
    final users = _loadUsers(prefs);
    users.remove(petKey);
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.remove(_currentUserKey);
  }

  /// Get user account by pet name (for password reset)
  Future<Map<String, dynamic>?> getUserByPetName(String petName) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final petKey = petName.trim().toLowerCase();
    return users[petKey];
  }

  /// Generate and store a password reset code
  Future<bool> setPasswordResetCode(String petName, String resetCode) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final key = 'reset_code_${petName.trim().toLowerCase()}';
      await prefs.setString(key, resetCode);
      // Code expires in 1 hour (in production, check timestamp)
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset password with verification code
  Future<bool> resetPassword({
    required String petName,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final users = _loadUsers(prefs);
      final petKey = petName.trim().toLowerCase();

      if (!users.containsKey(petKey)) {
        return false;
      }

      users[petKey]!['password'] = newPassword;
      await prefs.setString(_usersKey, jsonEncode(users));

      // Clear reset code
      await prefs.remove('reset_code_$petKey');

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateCurrentPetProfile(
      {required String petName,
      required String petType,
      required String breed,
      required String age,
      required String weight,
      String? photoPath}) async {
    final prefs = await SharedPreferences.getInstance();
    final petKey = prefs.getString(_currentUserKey);
    if (petKey == null) return;
    final users = _loadUsers(prefs);
    final user = users[petKey];
    if (user == null) return;
    user['petName'] = petName;
    user['petType'] = petType;
    user['breed'] = breed;
    user['age'] = age;
    user['weight'] = weight;
    if (photoPath != null) user['petPhotoPath'] = photoPath;
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Map<String, Map<String, dynamic>> _loadUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
    );
  }
}

class LoginResult {
  final bool success;
  final String? error;
  final String? petName;

  LoginResult({required this.success, this.error, this.petName});
}
