import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/screens/authScreens/signIn.dart';
import 'package:user_app/util/bottomNavigational.dart';
import 'screens/gettingStarted.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAppState(),
    );
  }
}

class MyAppState extends StatefulWidget {
  static const String KEYLOGIN = 'Login';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppState> {
  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(MyAppState.KEYLOGIN);

    if (isLoggedIn != null) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationalBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GettingStartedScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GettingStartedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
