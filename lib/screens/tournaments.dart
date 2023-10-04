// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// import 'tournamentViewDetails.dart';

// class TournamentScreen extends StatelessWidget {
//   // Get current user ID
//   final String? userId = FirebaseAuth.instance.currentUser!.uid;

//   Future<void> sendJoinRequest(
//     BuildContext context,
//     String tournamentId,
//     String userId,
//     String teamId,
//   ) async {
//     // Check if the current user has created a team
//     final teamQuery = await FirebaseFirestore.instance
//         .collection('teams')
//         .doc(userId)
//         .collection('teams')
//         .where('captainId', isEqualTo: userId)
//         .get();

//     if (teamQuery.docs.isEmpty) {
//       // If no team is found, display a Snackbar to create a team first
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please create a team first'),
//           backgroundColor: Colors.red,
//           shape:
//               BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     // A team created by the current user exists, send the join request
//     final requestRef = FirebaseFirestore.instance
//         .collection('requestToJoin')
//         .doc('$tournamentId-$userId');

//     await requestRef.set({
//       'tournamentId': tournamentId,
//       'userId': userId,
//       'teamId': teamId,
//       'status': 'pending', // Initial status of the request
//       'createdBy': 'user'
//     });

//     // Show a Snackbar message when the join request is sent successfully
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Join request sent successfully'),
//         backgroundColor: Colors.green,
//         shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             height: 120,
//             width: MediaQuery.of(context).size.width,
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.deepPurpleAccent,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(10),
//                 bottomRight: Radius.circular(10),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 textAlign: TextAlign.center,
//                 'Tournaments',
//                 style: TextStyle(
//                   fontFamily: 'karla',
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance.collection('events').snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: Colors.amber[300],
//                     ),
//                   );
//                 }

//                 if (snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No tournaments available'));
//                 }

//                 return ListView.builder(
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final document = snapshot.data!.docs[index];
//                     final tournamentData =
//                         document.data() as Map<String, dynamic>;
//                     final String tournamentId = document.id;

//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           gradient: LinearGradient(
//                             colors: [
//                               Color(0xffFEAF3E),
//                               Color(0xff493ADF),
//                             ],
//                             begin: Alignment.center,
//                             end: Alignment.topCenter,
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Column(
//                             children: [
//                               CircleAvatar(
//                                 backgroundImage: NetworkImage(
//                                     tournamentData['tournamentLogo']),
//                               ),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                 tournamentData['name'],
//                                 style: TextStyle(
//                                     fontFamily: 'karla',
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white),
//                               ),
//                               SizedBox(height: 8),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Container(
//                                     height: 40,
//                                     width: 80,
//                                     decoration: BoxDecoration(
//                                         color: Colors.deepPurpleAccent,
//                                         borderRadius: BorderRadius.circular(5)),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: Row(
//                                         children: [
//                                           Icon(
//                                             Icons.timer,
//                                             color: Color(0xffFEB651),
//                                           ),
//                                           SizedBox(width: 5),
//                                           Text(
//                                             tournamentData['time'],
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           ), // Placeholder
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 40,
//                                     width: 120,
//                                     decoration: BoxDecoration(
//                                         color: Colors.deepPurpleAccent,
//                                         borderRadius: BorderRadius.circular(5)),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(5.0),
//                                       child: Row(
//                                         children: [
//                                           Icon(
//                                             Icons.calendar_today,
//                                             color: Color(0xffFEB651),
//                                           ),
//                                           SizedBox(width: 5),
//                                           Text(
//                                             tournamentData['date'],
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 8),
// Row(
//   children: [
//     Expanded(
//       child: Container(
//         height: 50,
//         child: ElevatedButton(
//           style: ButtonStyle(
//               shape: MaterialStatePropertyAll(
//                   RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(
//                               20))),
//               backgroundColor:
//                   MaterialStatePropertyAll(
//                       Colors.deepPurpleAccent)),
//           onPressed: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         TournamentDetailScreen(
//                           tournamentId:
//                               tournamentId,
//                         )));
//           },
//           child: Text('View Details',
//               style: TextStyle(
//                   fontFamily: 'karla',
//                   fontSize: 18)),
//         ),
//       ),
//     ),
//   ],
// ),
//                               SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Container(
//                                       height: 50,
//                                       child: ElevatedButton(
// style: ButtonStyle(
//     shape: MaterialStatePropertyAll(
//         RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(
//                     20))),
//     backgroundColor:
//         MaterialStatePropertyAll(
//             Colors.green)),
//                                         onPressed: () {
//                                           sendJoinRequest(
//                                             context,
//                                             tournamentId,
//                                             userId!,
//                                             userId!,
//                                           );
//                                         },
//                                         child: Text('Join Request',
//                                             style: TextStyle(
//                                                 fontFamily: 'karla',
//                                                 fontSize: 18)),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 8),
//                             ],
//                           ),
//                         ),
//                       ),
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'tournamentViewDetails.dart';

class TournamentScreen extends StatefulWidget {
  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final String? userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> sendJoinRequest(
    BuildContext context,
    String tournamentId,
    String userId,
    String teamId,
  ) async {
    final teamQuery = await FirebaseFirestore.instance
        .collection('teams')
        .doc(userId)
        .collection('teams')
        .where('captainId', isEqualTo: userId)
        .get();

    if (teamQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please create a team first'),
          backgroundColor: Colors.red,
          shape:
              BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final requestRef = FirebaseFirestore.instance
        .collection('requestToJoin')
        .doc('$tournamentId-$userId');

    await requestRef.set({
      'tournamentId': tournamentId,
      'userId': userId,
      'teamId': teamId,
      'status': 'pending',
      'createdBy': 'user'
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join request sent successfully'),
        backgroundColor: Colors.green,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Stream<String> getRequestStatusStream(String tournamentId) {
    final requestRef = FirebaseFirestore.instance
        .collection('requestToJoin')
        .doc('$tournamentId-$userId')
        .snapshots();

    return requestRef.map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        return status;
      } else {
        return 'not_requested';
      }
    }).handleError((error) {
      print('Error retrieving request status: $error');
      return 'error';
    });
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.black,
        child: Column(
          children: [
            Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  'Tournaments',
                  style: TextStyle(
                    fontFamily: 'karla',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('events').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber[300],
                      ),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tournaments available'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final document = snapshot.data!.docs[index];
                      final tournamentData =
                          document.data() as Map<String, dynamic>;
                      final String tournamentId = document.id;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffFEAF3E),
                                Color(0xff493ADF),
                              ],
                              begin: Alignment.center,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.network(
                                      tournamentData['tournamentLogo'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  tournamentData['name'],
                                  style: TextStyle(
                                      fontFamily: 'karla',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurpleAccent,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.timer,
                                              color: Color(0xffFEB651),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              tournamentData['time'] ?? '7 PM',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 120,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurpleAccent,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: Color(0xffFEB651),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              tournamentData['date'],
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              shape: MaterialStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20))),
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.deepPurpleAccent)),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TournamentDetailScreen(
                                                          tournamentId:
                                                              tournamentId,
                                                        )));
                                          },
                                          child: Text('View Details',
                                              style: TextStyle(
                                                  fontFamily: 'karla',
                                                  fontSize: 18)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        child: StreamBuilder<String>(
                                          stream: getRequestStatusStream(
                                              tournamentId),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return ElevatedButton(
                                                style: ButtonStyle(
                                                    shape: MaterialStatePropertyAll(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20))),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.green)),
                                                onPressed: () {},
                                                child: Text(
                                                  'Error',
                                                  style: TextStyle(
                                                    fontFamily: 'karla',
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              );
                                            }

                                            final requestStatus =
                                                snapshot.data ??
                                                    'not_requested';

                                            if (requestStatus == 'pending') {
                                              return ElevatedButton(
                                                style: ButtonStyle(
                                                    shape: MaterialStatePropertyAll(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20))),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.green)),
                                                onPressed: () {},
                                                child: Text(
                                                  'Pending',
                                                  style: TextStyle(
                                                    fontFamily: 'karla',
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              );
                                            } else if (requestStatus ==
                                                'approved') {
                                              return SizedBox(); // Hide the button if approved
                                            } else {
                                              return ElevatedButton(
                                                style: ButtonStyle(
                                                    shape: MaterialStatePropertyAll(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20))),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.green)),
                                                onPressed: () {
                                                  sendJoinRequest(
                                                    context,
                                                    tournamentId,
                                                    userId!,
                                                    userId!,
                                                  );
                                                },
                                                child: Text(
                                                  'Join Request',
                                                  style: TextStyle(
                                                    fontFamily: 'karla',
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
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
