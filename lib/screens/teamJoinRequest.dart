// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class JoinRequestsScreen extends StatelessWidget {
//   final String teamId;
//   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>();

//   JoinRequestsScreen({required this.teamId});

//   Stream<List<DocumentSnapshot>> fetchJoinRequests() {
//     return FirebaseFirestore.instance
//         .collection('teamJoinRequests')
//         .where('teamId', isEqualTo: teamId)
//         .snapshots()
//         .map((querySnapshot) => querySnapshot.docs);
//   }

//   Stream<DocumentSnapshot> fetchPlayerProfile(String userId) {
//     return FirebaseFirestore.instance
//         .collection('playerProfile')
//         .doc(userId)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldMessenger(
//       key: _scaffoldMessengerKey,
//       child: Scaffold(
//         body: Column(
//           children: [
// Container(
//   height: 140,
//   width: MediaQuery.of(context).size.width,
//   padding: EdgeInsets.all(16),
//   decoration: BoxDecoration(
//     color: Colors.deepPurpleAccent,
//     borderRadius: BorderRadius.only(
//       bottomLeft: Radius.circular(10),
//       bottomRight: Radius.circular(10),
//     ),
//   ),
//   child: Column(
//     children: [
//       SizedBox(height: 10),
//       Row(
//         children: [
//           IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               Icons.arrow_back,
//               color: Colors.white,
//             ),
//           )
//         ],
//       ),
//       Center(
//         child: Text(
//           'Join Requests',
//           style: TextStyle(
//             fontFamily: 'karla',
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
//             Expanded(
//               child: StreamBuilder<List<DocumentSnapshot>>(
//                 stream: fetchJoinRequests(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(
//                         child: CircularProgressIndicator(
//                             color: Colors.deepPurpleAccent));
//                   }
//                   final joinRequests = snapshot.data!;
//                   if (joinRequests.isEmpty) {
//                     return Center(
//                         child: Text('No join requests at the moment.'));
//                   }
//                   return ListView.builder(
//                     itemCount: joinRequests.length,
//                     itemBuilder: (context, index) {
//                       final request =
//                           joinRequests[index].data() as Map<String, dynamic>;
//                       final requestId = joinRequests[index].id;
//                       final userId = request['userId'];
//                       return StreamBuilder<DocumentSnapshot>(
//                         stream: fetchPlayerProfile(userId),
//                         builder: (context, playerSnapshot) {
//                           if (!playerSnapshot.hasData) {
//                             return SizedBox.shrink();
//                           }
//                           final playerData = playerSnapshot.data!.data()
//                               as Map<String, dynamic>;
//                           final playerImageUrl = playerData['profileImageUrl'];
//                           final playerRole = playerData['role'];
//                           final playerName = playerData['name'];
//                           final int playerJerseyNo =
//                               int.parse(playerData['jerseyNo']);
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Color(0xff66bb6a),
//                                     Color(0xffFEAF3E)
//                                   ],
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                 ),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: ListTile(
//                                 leading: CircleAvatar(
//                                   radius: 30,
//                                   backgroundImage: NetworkImage(playerImageUrl),
//                                 ),
//                                 title: Text(playerName,
//                                     style: TextStyle(
//                                         fontFamily: 'karla',
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700)),
//                                 subtitle: Text(playerRole,
//                                     style: TextStyle(
//                                         fontFamily: 'karla',
//                                         fontSize: 16,
//                                         color: Color(0xff493ADF),
//                                         fontWeight: FontWeight.w400)),
//                                 trailing: ElevatedButton(
//                                   style: ButtonStyle(
//                                       backgroundColor:
//                                           MaterialStateProperty.all(
//                                               Color(0xff493ADF))),
//                                   onPressed: () async {
//                                     // Step 1: Update the status in teamJoinRequests
//                                     await FirebaseFirestore.instance
//                                         .collection('teamJoinRequests')
//                                         .doc(requestId)
//                                         .update({'status': 'approved'});

// // Step 2: Save the player to the team
// await FirebaseFirestore.instance
//     .collection('teams')
//     .doc(teamId)
//     .collection('teams')
//     .doc(teamId)
//     .collection('teamMembers')
//     .add({
//   'memberName': playerName,
//   'jerseyNumber': playerJerseyNo.toInt(),
//   'specification': playerRole,
//   'playerId': userId
// });

//                                     // Show success message
//                                     _scaffoldMessengerKey.currentState!
//                                         .showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                             'Player request approved and added to team.'),
//                                         backgroundColor: Colors.green,
//                                       ),
//                                     );
//                                   },
//                                   child: Text(request['status'] == 'approved'
//                                       ? 'Approved'
//                                       : 'Approve'),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRequestsScreen extends StatelessWidget {
  final String teamId;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  JoinRequestsScreen({required this.teamId});

  Stream<List<QueryDocumentSnapshot>> fetchJoinRequests() {
    return FirebaseFirestore.instance
        .collection('teamJoinRequests')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  Stream<DocumentSnapshot> fetchPlayerProfile(String userId) {
    return FirebaseFirestore.instance
        .collection('playerProfile')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Join Requests'),
        // ),
        body: Column(
          children: [
            Container(
              height: 140,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Center(
                    child: Text(
                      'Join Requests',
                      style: TextStyle(
                        fontFamily: 'karla',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: fetchJoinRequests(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent,
                      ),
                    );
                  }
                  final joinRequests = snapshot.data!;
                  if (joinRequests.isEmpty) {
                    return Center(
                      child: Text('No join requests at the moment.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: joinRequests.length,
                    itemBuilder: (context, index) {
                      final request =
                          joinRequests[index].data() as Map<String, dynamic>;
                      final requestId = joinRequests[index].id;
                      final userId = request['userId'];

                      if (request['status'] == 'approved') {
                        return SizedBox.shrink();
                      }

                      return StreamBuilder<DocumentSnapshot>(
                        stream: fetchPlayerProfile(userId),
                        builder: (context, playerSnapshot) {
                          if (!playerSnapshot.hasData) {
                            return SizedBox.shrink();
                          }
                          final playerData = playerSnapshot.data!.data()
                              as Map<String, dynamic>;
                          final playerImageUrl = playerData['profileImageUrl'];
                          final playerRole = playerData['role'];
                          final playerName = playerData['name'];

                          final int playerJerseyNo =
                              int.parse(playerData['jerseyNo']);

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff66bb6a),
                                    Color(0xffFEAF3E)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(playerImageUrl),
                                ),
                                title: Text(playerName),
                                subtitle: Text(playerRole),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('teamJoinRequests')
                                        .doc(requestId)
                                        .update({'status': 'approved'});

                                    // Step 2: Save the player to the team
                                    await FirebaseFirestore.instance
                                        .collection('teams')
                                        .doc(teamId)
                                        .collection('teams')
                                        .doc(teamId)
                                        .collection('teamMembers')
                                        .add({
                                      'playerImageUrl': playerImageUrl,
                                      'memberName': playerName,
                                      'jerseyNumber': playerJerseyNo.toInt(),
                                      'specification': playerRole,
                                      'playerId': userId
                                    });

                                    _scaffoldMessengerKey.currentState!
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Player request approved.',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Text('Approve'),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}










 // void _saveTeamMember(String teamId, String playerName, String playerRole,
  //     int playerJerseyNo, String playerId) {
  //   FirebaseFirestore.instance
  //       .collection('teams')
  //       .doc(teamId)
  //       .collection('teams')
  //       .doc(teamId)
  //       .collection('teamMembers')
  //       .add({
  //     'memberName': playerName,
  //     'jerseyNumber': playerJerseyNo,
  //     'specification': playerRole,
  //     'playerId': playerId
  //   });
  // }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class JoinRequestsScreen extends StatelessWidget {
//   final String teamId;

//   JoinRequestsScreen({required this.teamId});

//   Stream<List<DocumentSnapshot>> fetchJoinRequests() {
//     return FirebaseFirestore.instance
//         .collection('teamJoinRequests')
//         .where('teamId', isEqualTo: teamId)
//         .where('status',
//             isEqualTo: 'pending') // You can change the status as needed
//         .snapshots()
//         .map((querySnapshot) => querySnapshot.docs);
//   }

//   Stream<DocumentSnapshot> fetchPlayerProfile(String userId) {
//     return FirebaseFirestore.instance
//         .collection('playerProfile')
//         .doc(userId)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             height: 140,
//             width: MediaQuery.of(context).size.width,
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.deepPurpleAccent,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(10),
//                 bottomRight: Radius.circular(10),
//               ),
//             ),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         icon: Icon(
//                           Icons.arrow_back,
//                           color: Colors.white,
//                         ))
//                   ],
//                 ),
//                 Center(
//                   child: Text(
//                     textAlign: TextAlign.center,
//                     'Join Requests',
//                     style: TextStyle(
//                       fontFamily: 'karla',
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<List<DocumentSnapshot>>(
//               stream: fetchJoinRequests(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: Colors.deepPurpleAccent,
//                     ),
//                   );
//                 }

//                 final joinRequests = snapshot.data!;

//                 if (joinRequests.isEmpty) {
//                   return Center(
//                     child: Text('No join requests at the moment.'),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: joinRequests.length,
//                   itemBuilder: (context, index) {
//                     final request =
//                         joinRequests[index].data() as Map<String, dynamic>;
//                     final requestId = joinRequests[index].id;
//                     final userId = request['userId'];

//                     return StreamBuilder<DocumentSnapshot>(
//                       stream: fetchPlayerProfile(userId),
//                       builder: (context, playerSnapshot) {
//                         if (!playerSnapshot.hasData) {
//                           return SizedBox
//                               .shrink(); // Return an empty widget while loading player data
//                         }

//                         final playerData =
//                             playerSnapshot.data!.data() as Map<String, dynamic>;
//                         final playerImageUrl = playerData['profileImageUrl'];
//                         final playerName = playerData['name'];
//                         final playerRole = playerData['role'];

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Color(0xff66bb6a),
//                                   // Color(0xff493ADF),
//                                   Color(0xffFEAF3E),
//                                 ],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: ListTile(
//                               leading: CircleAvatar(
//                                 radius: 30,
//                                 backgroundImage: NetworkImage(
//                                   playerImageUrl,
//                                 ),
//                               ),
//                               title: Text(
//                                 playerName,
//                                 style: TextStyle(
//                                     fontFamily: 'karla',
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w700),
//                               ),
//                               subtitle: Text(
//                                 playerRole,
//                                 style: TextStyle(
//                                     fontFamily: 'karla',
//                                     fontSize: 16,
//                                     color: Color(0xff493ADF),
//                                     fontWeight: FontWeight.w400),
//                               ),
//                               // You can display additional player information here
//                               // ...
//                               trailing: ElevatedButton(
//                                 style: ButtonStyle(
//                                     backgroundColor: MaterialStatePropertyAll(
//                                         Color(0xff493ADF))),
//                                 onPressed: () {
//                                   // Handle the request (approve or reject)
//                                   // You can update the request status in Firestore and take appropriate actions.
//                                   // For example:
//                                   FirebaseFirestore.instance
//                                       .collection('teamJoinRequests')
//                                       .doc(requestId)
//                                       .update({'status': 'approved'}).then((_) {
//                                     // Request approved, you can update UI accordingly
//                                     print(
//                                         'Join request approved for User ID: $userId');
//                                   }).catchError((error) {
//                                     // Handle the error
//                                     print(
//                                         'Error approving join request: $error');
//                                   });
//                                 },
//                                 child: Text('Approve'),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
