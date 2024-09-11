import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _userDetailsKey = 'user_details';

  // Save user data to shared preferences
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userDataJson = jsonEncode({'data': userData});
    await prefs.setString(_userDetailsKey, userDataJson);
  }

  // Retrieve user data from shared preferences
  static Future<Map<String, dynamic>?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userDataJson = prefs.getString(_userDetailsKey);

    if (userDataJson != null) {
      final Map<String, dynamic> userData = jsonDecode(userDataJson)['data'];
      return userData;
    }
    return null; // Return null if no user data is saved
  }

  // Clear user data from shared preferences
  static Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDetailsKey);
  }

  // Save the token specifically (optional utility function)
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic>? userData = await getUserData();

    if (userData != null) {
      userData['token'] = token;
      await saveUserData(userData); // Update user data with the new token
    }
  }

  // Retrieve the token from shared preferences (optional utility function)
  static Future<String?> getToken() async {
    final Map<String, dynamic>? userData = await getUserData();
    return userData?['token'];
  }
}
