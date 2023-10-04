import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// class SessionManager {
//   // Method to save the user session with a unique user key
//   static Future<bool> saveUserSession(String userId) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.setString(_getUserKey(userId), userId);
//   }

//   // Method to get the user session with a unique user key
//   static Future<String?> getUserSession(String userId) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_getUserKey(userId));
//   }

//   // Method to check if a user session exists with a unique user key
//   static Future<bool> hasUserSession(String userId) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.containsKey(_getUserKey(userId));
//   }

//   // Method to clear the user session with a unique user key
//   static Future<bool> clearUserSession(String userId) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.remove(_getUserKey(userId));
//   }

//   // Helper method to create a unique user key
//   static String _getUserKey(String userId) {
//     return 'user_key_$userId';
//   }

//   // Method to clear the cache data
//   static Future<void> clearCacheData() async {
//     // Clear the cached files managed by flutter_cache_manager
//     await DefaultCacheManager().emptyCache();

//     // Optionally, you can also clear any other cached data here if needed
//     // For example, if you have custom caching mechanisms.

//     print('Cache data cleared.');
//   }
// }


// class UserSession {
//   static const String userSessionKey = "user_session";

//   static Future<void> storeUserSession(String userId) async {
//     String user = FirebaseAuth.instance.currentUser!.uid;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(user, userId);
//   }

//   static Future<String?> getUserSession() async {
//     String user = FirebaseAuth.instance.currentUser!.uid;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(user);
//   }

//   static Future<void> clearUserSession() async {
//     String user = FirebaseAuth.instance.currentUser!.uid;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(user);
//     print('successfully clear user session');
//   }
// }
