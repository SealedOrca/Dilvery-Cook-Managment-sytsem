import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String isLoggedInKey = 'isLoggedIn';

  // Check if the user is logged in
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  // Log the user in
  static Future<void> logIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, true);
  }

  // Log the user out
  static Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, false);
  }
}
