import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_app/screens/authScreens/signIn.dart';
import '../firbaseAuth/firebaseAuthService.dart';
import '../screens/findTournaments.dart';
import '../screens/home.dart';
import '../screens/matches.dart';
import '../screens/profile.dart';
import '../screens/teams.dart';
import '../screens/tournaments.dart';

class BottomNavigationalBar extends StatefulWidget {
  @override
  _BottomNavigationalBarState createState() => _BottomNavigationalBarState();
}

class _BottomNavigationalBarState extends State<BottomNavigationalBar> {
  FirebaseService firebaseService = FirebaseService();
  String? user = FirebaseAuth.instance.currentUser!.uid;
  int _currentIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    HomeScreen(),
    TournamentsAroundYou(),
    ProfileScreen(),
    TournamentScreen(),
    MyTeam(),
    MatchesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports), label: 'Tournaments'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Team'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports), label: 'Matches'),
        ],
      ),
    );
  }
}

















// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:user_app/screens/authScreens/signIn.dart';
// import '../firbaseAuth/firebaseAuthService.dart';
// import '../screens/findTournaments.dart';
// import '../screens/matches.dart';
// import '../screens/profile.dart';
// import '../screens/teams.dart';
// import '../screens/tournaments.dart';

// class BottomNavigationalBar extends StatefulWidget {
//   @override
//   _BottomNavigationalBarState createState() => _BottomNavigationalBarState();
// }

// class _BottomNavigationalBarState extends State<BottomNavigationalBar> {
//   FirebaseService firebaseService = FirebaseService();
//   String? user = FirebaseAuth.instance.currentUser!.uid;
//   int _currentIndex = 0;

//   // List of screens
//   final List<Widget> _screens = [
//     ProfileScreen(), // Center(child: Text('Profile Screen')), // ProfileScreen()
//     TeamScreen(), // Center(child: Text('Team Screen')),
//     TournamentScreen(), // Center(child: Text('Tournament Screen')), //
//     MatchesScreen(),
//     TournamentsAroundYou()
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   centerTitle: true,
//       //   backgroundColor: Colors.deepPurpleAccent,
//       //   title: Text('Home'),
//       // ),
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         iconSize: 30,
//         selectedItemColor: Colors.deepPurpleAccent,
//         unselectedItemColor: Colors.grey[500],
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         onTap: (index) async {
//           if (index == 5) {
//             // Logout option
//             await firebaseService.signOut();
//             Navigator.pushReplacement(context,
//                 MaterialPageRoute(builder: (context) => SignInScreen()));
//           } else {
//             setState(() {
//               _currentIndex = index;
//             });
//           }
//         },
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Team'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today), label: 'Tournaments'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.sports_esports), label: 'Matches'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Map'),
//           BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
//         ],
//       ),
//     );
//   }
// }



