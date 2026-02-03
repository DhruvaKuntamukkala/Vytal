  import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';

  // Save email and password locally
  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  // Retrieve saved email and password
  static Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final password = prefs.getString(_passwordKey);
    return {'email': email, 'password': password};
  }

  // Clear saved credentials (e.g., on logout)
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }

  // Check if user is already logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_emailKey) && prefs.containsKey(_passwordKey);
  }
}
