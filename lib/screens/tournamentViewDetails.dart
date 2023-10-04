import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TournamentDetailScreen extends StatefulWidget {
  final String tournamentId;
  const TournamentDetailScreen({required this.tournamentId, super.key});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                  SizedBox(
                    height: 10,
                  ),
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
                      'Tournament Details',
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('matchSchedule')
                  .doc(widget.tournamentId)
                  .collection('matches')
                  .orderBy('matchNumber', descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber[300],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      Center(child: Text('No Details')),
                    ],
                  );
                } else {
                  // Retrieve the list of matches
                  final matches = snapshot.data!.docs;

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: matches.length,
                    itemBuilder: (BuildContext context, int index) {
                      final matchData =
                          matches[index].data() as Map<String, dynamic>;

                      // Extract match details
                      final matchId = matches[index].id;
                      final matchNumber = matchData['matchNumber'];
                      final team1Id = matchData['team1Id'];
                      final team2Id = matchData['team2Id'];
                      final matchTime = matchData['matchTime'];
                      final matchdate = matchData['matchDate'];
                      final ground = matchData['ground'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xff493ADF),
                                Color(0xffFEAF3E),
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.center,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Add vertical space between containers
                                SizedBox(height: 10),

                                // teams 1 vs team 2..........
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('teams')
                                            .doc(team1Id)
                                            .collection('teams')
                                            .get(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text('Loading...');
                                          }

                                          if (snapshot.hasData &&
                                              snapshot.data!.docs.isNotEmpty) {
                                            final teamData =
                                                snapshot.data!.docs.first.data()
                                                    as Map<String, dynamic>;
                                            final teamName =
                                                teamData['teamName'];
                                            final logo = teamData['logo'];

                                            return Container(
                                              width: 100,
                                              height: 55,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Color(0xff4598FF),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage:
                                                          NetworkImage(logo),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        teamName,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'karla',
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Text('Team 1: -');
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'VS',
                                      style: TextStyle(
                                        fontFamily: 'karla',
                                        fontSize: 22,
                                        color: Colors.deepPurpleAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('teams')
                                            .doc(team2Id)
                                            .collection('teams')
                                            .get(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text('Loading...');
                                          }

                                          if (snapshot.hasData &&
                                              snapshot.data!.docs.isNotEmpty) {
                                            final teamData =
                                                snapshot.data!.docs.first.data()
                                                    as Map<String, dynamic>;
                                            final teamName =
                                                teamData['teamName'];
                                            final logo = teamData['logo'];

                                            return Container(
                                              width: 100,
                                              height: 55,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Color(0xff16C495),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage:
                                                          NetworkImage(logo),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        teamName,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'karla',
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Text('Team 2: -');
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                // Add vertical space between the last row widget
                                SizedBox(height: 10),

                                // Additional match details
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.place,
                                              color: Colors.deepPurpleAccent,
                                            ),
                                            Text(
                                              '$ground',
                                              style: TextStyle(
                                                fontFamily: 'karla',
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurpleAccent,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      color: Color(0xffFEB651),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      matchTime,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Container(
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurpleAccent,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      color: Color(0xffFEB651),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      matchdate,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class TournamentDetailScreen extends StatefulWidget {
//   final String tournamentId;
//   const TournamentDetailScreen({required this.tournamentId, super.key});

//   @override
//   State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
// }

// class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
//   final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: 140,
//               width: MediaQuery.of(context).size.width,
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.deepPurpleAccent,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(10),
//                   bottomRight: Radius.circular(10),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           icon: Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                           ))
//                     ],
//                   ),
//                   Center(
//                     child: Text(
//                       textAlign: TextAlign.center,
//                       'Tournament Details',
//                       style: TextStyle(
//                         fontFamily: 'karla',
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('matchSchedule')
//                   .doc(widget.tournamentId)
//                   .collection('matches')
//                   .orderBy('matchNumber', descending: false)
//                   .snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasData) {
//                   // Retrieve the list of matches
//                   final matches = snapshot.data!.docs;

//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: matches.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       final matchData =
//                           matches[index].data() as Map<String, dynamic>;

//                       if (matchData != null) {
//                         // Extract match details
//                         final matchId = matches[index].id;
//                         final matchNumber = matchData['matchNumber'];
//                         final team1Id = matchData['team1Id'];
//                         final team2Id = matchData['team2Id'];
//                         final matchTime = matchData['matchTime'];
//                         final matchdate = matchData['matchDate'];
//                         final ground = matchData['ground'];

//                         // Determine if the current user's team is playing the match
//                         // final bool isCurrentUserTeamMatch =
//                         //     team1Id == currentUserId ||
//                         //         team2Id == currentUserId;
//                         // final bool isMatchDisabled = !isCurrentUserTeamMatch;

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 5, horizontal: 8),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Color(0xff493ADF),
//                                   Color(0xffFEAF3E),
//                                 ],
//                                 begin: Alignment.topRight,
//                                 end: Alignment.center,
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 children: [
//                                   // Add vertical space between containers
//                                   SizedBox(height: 10),

//                                   // teams 1 vs team 2..........
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Expanded(
//                                         child: FutureBuilder<QuerySnapshot>(
//                                           future: FirebaseFirestore.instance
//                                               .collection('teams')
//                                               .doc(team1Id)
//                                               .collection('teams')
//                                               .get(),
//                                           builder: (BuildContext context,
//                                               AsyncSnapshot<QuerySnapshot>
//                                                   snapshot) {
//                                             if (snapshot.connectionState ==
//                                                 ConnectionState.waiting) {
//                                               return Text('Loading...');
//                                             }

//                                             if (snapshot.hasData &&
//                                                 snapshot
//                                                     .data!.docs.isNotEmpty) {
//                                               final teamData = snapshot
//                                                       .data!.docs.first
//                                                       .data()
//                                                   as Map<String, dynamic>;
//                                               final teamName =
//                                                   teamData['teamName'];
//                                               final logo = teamData['logo'];

//                                               return Container(
//                                                 width: 100,
//                                                 height: 55,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                   color: Color(0xff4598FF),
//                                                 ),
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(horizontal: 8),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: [
//                                                       CircleAvatar(
//                                                         backgroundColor:
//                                                             Colors.grey,
//                                                         backgroundImage:
//                                                             NetworkImage(logo),
//                                                       ),
//                                                       SizedBox(width: 10),
//                                                       Text(
//                                                         teamName,
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontFamily: 'karla',
//                                                           fontSize: 16,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             } else {
//                                               return Text('Team 1: -');
//                                             }
//                                           },
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Text(
//                                         'VS',
//                                         style: TextStyle(
//                                           fontFamily: 'karla',
//                                           fontSize: 22,
//                                           color: Colors.deepPurpleAccent,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Expanded(
//                                         child: FutureBuilder<QuerySnapshot>(
//                                           future: FirebaseFirestore.instance
//                                               .collection('teams')
//                                               .doc(team2Id)
//                                               .collection('teams')
//                                               .get(),
//                                           builder: (BuildContext context,
//                                               AsyncSnapshot<QuerySnapshot>
//                                                   snapshot) {
//                                             if (snapshot.connectionState ==
//                                                 ConnectionState.waiting) {
//                                               return Text('Loading...');
//                                             }

//                                             if (snapshot.hasData &&
//                                                 snapshot
//                                                     .data!.docs.isNotEmpty) {
//                                               final teamData = snapshot
//                                                       .data!.docs.first
//                                                       .data()
//                                                   as Map<String, dynamic>;
//                                               final teamName =
//                                                   teamData['teamName'];
//                                               final logo = teamData['logo'];

//                                               return Container(
//                                                 width: 100,
//                                                 height: 55,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                   color: Color(0xff16C495),
//                                                 ),
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(horizontal: 8),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: [
//                                                       CircleAvatar(
//                                                         backgroundColor:
//                                                             Colors.grey,
//                                                         backgroundImage:
//                                                             NetworkImage(logo),
//                                                       ),
//                                                       SizedBox(width: 10),
//                                                       Text(
//                                                         teamName,
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontFamily: 'karla',
//                                                           fontSize: 16,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             } else {
//                                               return Text('Team 2: -');
//                                             }
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),

//                                   // Add vertical space between the last row widget
//                                   SizedBox(height: 10),

//                                   // Additional match details
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Column(
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.place,
//                                                 color: Colors.deepPurpleAccent,
//                                               ),
//                                               Text(
//                                                 '$ground',
//                                                 style: TextStyle(
//                                                   fontFamily: 'karla',
//                                                   fontSize: 18,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: 5),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             children: [
//                                               Container(
//                                                 height: 40,
//                                                 width: 120,
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       Colors.deepPurpleAccent,
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                 ),
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(2.0),
//                                                   child: Row(
//                                                     children: [
//                                                       Icon(
//                                                         Icons.timer,
//                                                         color:
//                                                             Color(0xffFEB651),
//                                                       ),
//                                                       SizedBox(width: 5),
//                                                       Text(
//                                                         matchTime,
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 20,
//                                               ),
//                                               Container(
//                                                 height: 40,
//                                                 width: 120,
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       Colors.deepPurpleAccent,
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                 ),
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(5.0),
//                                                   child: Row(
//                                                     children: [
//                                                       Icon(
//                                                         Icons.calendar_today,
//                                                         color:
//                                                             Color(0xffFEB651),
//                                                       ),
//                                                       SizedBox(width: 5),
//                                                       Text(
//                                                         matchdate,
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       )
//                                     ],
//                                   ),
//                                   SizedBox(height: 10),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         return SizedBox();
//                       }
//                     },
//                   );
//                 }
//                 return Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.amber[300],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
