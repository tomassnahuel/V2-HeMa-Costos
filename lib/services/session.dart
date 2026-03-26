import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<void> saveSession(String email, String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
    await prefs.setString("device_id", deviceId);
    await prefs.setBool("logged", true);
  }

  static Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("logged") ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}