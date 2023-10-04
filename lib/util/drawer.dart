import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firbaseAuth/firebaseAuthService.dart';
import '../main.dart';
import '../screens/authScreens/signIn.dart';
import '../screens/findTournaments.dart';
import '../screens/profile.dart';
import '../screens/teams.dart';
import '../screens/tournaments.dart';
import '../screens/matches.dart';

import 'userSession.dart';

class MyDrawer extends StatelessWidget {
  FirebaseService firebaseService = FirebaseService();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'karla',
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'P R O F I L E',
              style:
                  TextStyle(fontFamily: 'karla', fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => ProfileScreen())));
            },
          ),
          ListTile(
            title: Text(
              'T E A M',
              style:
                  TextStyle(fontFamily: 'karla', fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: ((context) => MyTeam())));
            },
          ),
          ListTile(
            title: Text(
              'T O U R N A M E N T S',
              style:
                  TextStyle(fontFamily: 'karla', fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => TournamentScreen())));
            },
          ),
          ListTile(
            title: Text(
              'M A T C H E S',
              style:
                  TextStyle(fontFamily: 'karla', fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => MatchesScreen())));
            },
          ),
          ListTile(
            title: Text(
              'F I N D   T O U R N A M E N T S',
              style:
                  TextStyle(fontFamily: 'karla', fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => TournamentsAroundYou())));
            },
          ),
          Divider(), // Add a divider between options and logout button
          ListTile(
            title: Text(
              'L O G O U T',
              style: TextStyle(fontFamily: 'karla'),
            ),
            onTap: () async {
              // Check if the user session exists before signing out
              // bool hasSession = await SessionManager.hasUserSession(user!.uid);

              // Clear the user session if it exists
              // if (hasSession) {
              //   print(
              //       'User ID before clearing session: ${await SessionManager.getUserSession(user!.uid)}');
              //   await SessionManager.clearUserSession(user!.uid);
              //   print(
              //       'User ID after clearing session: ${await SessionManager.getUserSession(user!.uid)}');

              //   // Clear the cache data
              //   await SessionManager.clearCacheData();
              // }
              var sharedPref = await SharedPreferences.getInstance();
              sharedPref.setBool(MyAppState.KEYLOGIN, false);

              // Then sign out the user using Firebase Authentication
              await firebaseService.signOut();

              // Navigate to the SignInScreen if user session exists or is cleared
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignInScreen()));
            },
          ),
        ],
      ),
    );
  }
}
