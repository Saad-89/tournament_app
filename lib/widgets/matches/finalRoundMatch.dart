import 'package:firebase_auth/firebase_auth.dart';

import '../../firbaseAuth/firebaseAuthService.dart';
import 'Package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinalRoundMatch extends StatefulWidget {
  final String tournamentId;
  final String currentUserId;

  FinalRoundMatch({required this.tournamentId, required this.currentUserId});

  @override
  _FinalRoundMatchState createState() => _FinalRoundMatchState();
}

class _FinalRoundMatchState extends State<FinalRoundMatch> {
  Map<String, bool> scoresAddedStatus = {};
  Map<String, dynamic> matchScores = {};

  @override
  void initState() {
    super.initState();
    // Check if scores have been added and update the 'scoresAdded' flag
    checkScoresForAllMatches();
  }

  Future<void> checkScoresForAllMatches() async {
    final matches = await FirebaseFirestore.instance
        .collection('matchSchedule')
        .doc(widget.tournamentId)
        .collection('finalRoundMatch')
        .where('team1Id', isEqualTo: widget.currentUserId)
        .get();

    matches.docs.forEach((matchDoc) async {
      final matchId = matchDoc.id;
      final scoresCollectionRef = FirebaseFirestore.instance
          .collection('matchSchedule')
          .doc(widget.tournamentId)
          .collection('finalRoundMatch')
          .doc(matchId)
          .collection('scores');

      final currentUserScoreDoc =
          await scoresCollectionRef.doc(widget.currentUserId).get();

      setState(() {
        scoresAddedStatus[matchId] = currentUserScoreDoc.exists;
      });
    });

    // Also check for 'team2Id'
    final matchesForTeam2 = await FirebaseFirestore.instance
        .collection('matchSchedule')
        .doc(widget.tournamentId)
        .collection('finalRoundMatch')
        .where('team2Id', isEqualTo: widget.currentUserId)
        .get();

    matchesForTeam2.docs.forEach((matchDoc) async {
      final matchId = matchDoc.id;
      final scoresCollectionRef = FirebaseFirestore.instance
          .collection('matchSchedule')
          .doc(widget.tournamentId)
          .collection('finalRoundMatch')
          .doc(matchId)
          .collection('scores');

      final currentUserScoreDoc =
          await scoresCollectionRef.doc(widget.currentUserId).get();

      setState(() {
        scoresAddedStatus[matchId] = currentUserScoreDoc.exists;
      });
    });
  }

  Widget buildStars(int count) {
    return Row(
      children: List.generate(
        count,
        (index) => Icon(Icons.star, color: Colors.yellow),
      ),
    );
  }

  FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.tournamentId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final tournamentData =
                snapshot.data!.data() as Map<String, dynamic>;

            final tournamentName = tournamentData['name'];
            final tournamentLogo = tournamentData['tournamentLogo'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // second stream builder
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('matchSchedule')
                      .doc(widget.tournamentId)
                      .collection('finalRoundMatch')
                      .orderBy('matchNumber', descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      final matches = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: matches.length,
                        itemBuilder: (BuildContext context, int index) {
                          final matchData =
                              matches[index].data() as Map<String, dynamic>;
                          final matchId = matches[index].id;
                          final team1Id = matchData['team1Id'];
                          final team2Id = matchData['team2Id'];
                          final stage = matchData['stage'];

                          final team2Review = matchData['team2Review'];
                          final team1Review = matchData['team1Review'];

                          if (team1Id == widget.currentUserId ||
                              team2Id == widget.currentUserId) {
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('matchSchedule')
                                  .doc(widget.tournamentId)
                                  .collection('finalRoundMatch')
                                  .doc(matchId)
                                  .collection('scores')
                                  .doc(team1Id)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot>
                                      team1Snapshot) {
                                return StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('matchSchedule')
                                      .doc(widget.tournamentId)
                                      .collection('finalRoundMatch')
                                      .doc(matchId)
                                      .collection('scores')
                                      .doc(team2Id)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          team2Snapshot) {
                                    int? team1Score;
                                    int? team2Score;

                                    if (team1Snapshot.hasData &&
                                        team2Snapshot.hasData) {
                                      final scoreData1 = team1Snapshot.data!
                                          .data() as Map<String, dynamic>?;
                                      final scoreData2 = team2Snapshot.data!
                                          .data() as Map<String, dynamic>?;

                                      if (scoreData1 != null &&
                                          scoreData2 != null &&
                                          scoreData1['team1Score'] ==
                                              scoreData2['team1Score'] &&
                                          scoreData1['team2Score'] ==
                                              scoreData2['team2Score']) {
                                        team1Score = scoreData1['team1Score'];
                                        team2Score = scoreData1['team2Score'];
                                      }
                                    }

                                    if (team1Score != null &&
                                        team2Score != null) {
                                      String? winnerId;
                                      String? loserId;

                                      // Determine the winner based on scores
                                      if (team1Score > team2Score) {
                                        winnerId = team1Id;
                                        loserId = team2Id;
                                      } else if (team1Score < team2Score) {
                                        winnerId = team2Id;
                                        loserId = team1Id;
                                      } // If scores are equal, it's a draw, so no winner or loser is set.

                                      // Update the match document with the winner's and loser's IDs
                                      if (winnerId != null && loserId != null) {
                                        // Update the winner and loser in the match document
                                        FirebaseFirestore.instance
                                            .collection('matchSchedule')
                                            .doc(widget.tournamentId)
                                            .collection('finalRoundMatch')
                                            .doc(matchId)
                                            .update({
                                          'winner': winnerId,
                                          'loser': loserId
                                        });

                                        // Add the winner's ID to the nextRound's winner subcollection
                                        FirebaseFirestore.instance
                                            .collection('matchSchedule')
                                            .doc(widget.tournamentId)
                                            .collection('finalResult')
                                            .doc('winner')
                                            .collection('teams')
                                            .doc(winnerId)
                                            .set({'teamId': winnerId});

                                        // Add the loser's ID to the nextRound's loser subcollection
                                        FirebaseFirestore.instance
                                            .collection('matchSchedule')
                                            .doc(widget.tournamentId)
                                            .collection('finalResult')
                                            .doc('loser')
                                            .collection('teams')
                                            .doc(loserId)
                                            .set({'teamId': loserId});
                                      }
                                    }

                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(stage,
                                                      style: TextStyle(
                                                          fontFamily: 'karla',
                                                          color: Colors.white)),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        tournamentLogo,
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    tournamentName,
                                                    style: TextStyle(
                                                      fontFamily: 'karla',
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  buildStars(team1Review ?? 0),
                                                  buildStars(team2Review ?? 0),
                                                ],
                                              ),
                                              // ... rest of your UI ...
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: FutureBuilder<
                                                        QuerySnapshot>(
                                                      future: FirebaseFirestore
                                                          .instance
                                                          .collection('teams')
                                                          .doc(team1Id)
                                                          .collection('teams')
                                                          .get(),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Text(
                                                              'Loading...');
                                                        }

                                                        if (snapshot.hasData &&
                                                            snapshot.data!.docs
                                                                .isNotEmpty) {
                                                          final teamData =
                                                              snapshot.data!.docs
                                                                      .first
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>;
                                                          final teamName =
                                                              teamData[
                                                                  'teamName'];
                                                          final logo =
                                                              teamData['logo'];

                                                          return Container(
                                                            width: 100,
                                                            height: 55,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Color(
                                                                  0xff4598FF),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            logo),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Expanded(
                                                                    child: Text(
                                                                      teamName,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            'karla',
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                              'Team 1: -');
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
                                                      color: Colors
                                                          .deepPurpleAccent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: FutureBuilder<
                                                        QuerySnapshot>(
                                                      future: FirebaseFirestore
                                                          .instance
                                                          .collection('teams')
                                                          .doc(team2Id)
                                                          .collection('teams')
                                                          .get(),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Text(
                                                              'Loading...');
                                                        }

                                                        if (snapshot.hasData &&
                                                            snapshot.data!.docs
                                                                .isNotEmpty) {
                                                          final teamData =
                                                              snapshot.data!.docs
                                                                      .first
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>;
                                                          final teamName =
                                                              teamData[
                                                                  'teamName'];
                                                          final logo =
                                                              teamData['logo'];

                                                          return Container(
                                                            width: 100,
                                                            height: 55,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Color(
                                                                  0xff16C495),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            logo),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Expanded(
                                                                    child: Text(
                                                                      teamName,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            'karla',
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                              'Team 2: -');
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),

                                              if (team1Score != null &&
                                                  team2Score != null)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '$team1Score - $team2Score',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: buildScoreButton(
                                                      team1Id,
                                                      team2Id,
                                                      matchId,
                                                      scoresAddedStatus[
                                                              matchId] ??
                                                          false,
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
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber[300],
                      ),
                    );
                  },
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Colors.amber[300],
            ),
          );
        },
      ),
    );
  }

  final String? userId = FirebaseAuth.instance.currentUser!.uid;
  Future<bool> checkScoresAdded(
      String team1Id, String team2Id, String matchId) async {
    try {
      // Replace this logic with your actual Firestore query to check if scores are added.
      final scoreData = await FirebaseFirestore.instance
          .collection('matchSchedule')
          .doc(widget
              .tournamentId) // Assuming you have 'widget.tournamentId' available.
          .collection('finalRoundMatch')
          .doc(matchId) // Assuming you have 'matchId' available.
          .collection('scores')
          .doc(userId)
          .get();

      // Check if the document exists (scores are added).
      return scoreData.exists;
    } catch (e) {
      // Handle any errors that may occur during the Firestore query.
      print('Error checking scores: $e');
      return false; // Return false in case of an error.
    }
  }

  Widget buildScoreButton(
      String team1Id, String team2Id, String matchId, bool scoresAdded) {
    return FutureBuilder<bool>(
      future: checkScoresAdded(team1Id, team2Id,
          matchId), // Replace with your own logic to check scores added
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.deepPurpleAccent,
          ));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == true) {
          return ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all(Colors.deepPurpleAccent),
            ),
            onPressed: () {
              final team1NameFuture = FirebaseFirestore.instance
                  .collection('teams')
                  .doc(team1Id)
                  .collection('teams')
                  .get();
              final team2NameFuture = FirebaseFirestore.instance
                  .collection('teams')
                  .doc(team2Id)
                  .collection('teams')
                  .get();

              Future.wait([team1NameFuture, team2NameFuture]).then((responses) {
                final team1Name = responses[0].docs.isNotEmpty
                    ? responses[0].docs.first['teamName']
                    : '-';
                final team2Name = responses[1].docs.isNotEmpty
                    ? responses[1].docs.first['teamName']
                    : '-';
                final team1logo = responses[0].docs.isNotEmpty
                    ? responses[0].docs.first['logo']
                    : '-';
                final team2logo = responses[1].docs.isNotEmpty
                    ? responses[1].docs.first['logo']
                    : '-';
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: EnterReviewForSecondMatch(
                        tournamentId: widget.tournamentId,
                        matchId: matchId,
                        currentUserId: widget.currentUserId,
                        team1Id: team1Id,
                        team2Id: team2Id,
                        team1Name: team1Name,
                        team2Name: team2Name,
                        team1logo: team1logo,
                        team2logo: team2logo,
                      ),
                    );
                  },
                );
              });
            },
            child: Text(
              'Add Review',
              style: TextStyle(fontFamily: 'karla', fontSize: 18),
            ),
          );
        } else {
          return ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all(Colors.deepPurpleAccent),
            ),
            onPressed: () {
              final team1NameFuture = FirebaseFirestore.instance
                  .collection('teams')
                  .doc(team1Id)
                  .collection('teams')
                  .get();
              final team2NameFuture = FirebaseFirestore.instance
                  .collection('teams')
                  .doc(team2Id)
                  .collection('teams')
                  .get();

              Future.wait([team1NameFuture, team2NameFuture]).then((responses) {
                final team1Name = responses[0].docs.isNotEmpty
                    ? responses[0].docs.first['teamName']
                    : '-';
                final team2Name = responses[1].docs.isNotEmpty
                    ? responses[1].docs.first['teamName']
                    : '-';
                final team1logo = responses[0].docs.isNotEmpty
                    ? responses[0].docs.first['logo']
                    : '-';
                final team2logo = responses[1].docs.isNotEmpty
                    ? responses[1].docs.first['logo']
                    : '-';
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: EnterScoreForSecondMatch(
                        tournamentId: widget.tournamentId,
                        matchId: matchId,
                        currentUserId: widget.currentUserId,
                        team1Id: team1Id,
                        team2Id: team2Id,
                        team1Name: team1Name,
                        team2Name: team2Name,
                        team1logo: team1logo,
                        team2logo: team2logo,
                      ),
                    );
                  },
                );
              });
            },
            child: Text(
              'Add Scores',
              style: TextStyle(fontFamily: 'karla', fontSize: 18),
            ),
          );
        }
      },
    );
  }
}

// score entering pop up...
class EnterScoreForSecondMatch extends StatefulWidget {
  final String tournamentId;
  final String matchId;
  final String currentUserId;
  final String team1Id;
  final String team2Id;
  final String team1Name;
  final String team2Name;
  final String team1logo;
  final String team2logo;
  final Function(int, int)?
      onScoresEntered; // Callback function to pass scores back

  EnterScoreForSecondMatch(
      {required this.tournamentId,
      required this.matchId,
      required this.currentUserId,
      required this.team1Id,
      required this.team2Id,
      required this.team1Name,
      required this.team2Name,
      required this.team1logo,
      required this.team2logo,
      this.onScoresEntered}); // Pass the callback function

  @override
  _EnterScoreForSecondMatchState createState() =>
      _EnterScoreForSecondMatchState();
}

class _EnterScoreForSecondMatchState extends State<EnterScoreForSecondMatch> {
  final TextEditingController team1ScoreController = TextEditingController();
  final TextEditingController team2ScoreController = TextEditingController();

  void _saveScore() {
    final int team1Score = int.tryParse(team1ScoreController.text) ?? 0;
    final int team2Score = int.tryParse(team2ScoreController.text) ?? 0;

    print('Team 1 Score: $team1Score');
    print('Team 2 Score: $team2Score');

    // Store the scores in Firestore under the specific match document
    final DocumentReference matchDocRef = FirebaseFirestore.instance
        .collection('matchSchedule')
        .doc(widget.tournamentId)
        .collection('finalRoundMatch')
        .doc(widget.matchId);

    // Create a subcollection called "scores" and store the scores within it
    final CollectionReference scoresCollectionRef =
        matchDocRef.collection('scores');

    // Store the scores in the "scores" subcollection
    scoresCollectionRef.doc(widget.currentUserId).set({
      'team1Score': team1Score,
      'team2Score': team2Score,
    });

    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Scores',
              style: TextStyle(
                fontFamily: 'karla',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('${widget.team1logo}'),
                    ),
                  ],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: team1ScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${widget.team1Name} Score',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('${widget.team2logo}'),
                    ),
                  ],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: team2ScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${widget.team2Name} Score',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.deepPurpleAccent),
              ),
              onPressed: _saveScore,
              child: Text(
                'Submit',
                style: TextStyle(fontFamily: 'karla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnterReviewForSecondMatch extends StatefulWidget {
  final String tournamentId;
  final String matchId;
  final String currentUserId;
  final String team1Id;
  final String team2Id;
  final String team1Name;
  final String team2Name;
  final String team1logo;
  final String team2logo;
  final Function(int, int)? onScoresEntered;

  EnterReviewForSecondMatch({
    required this.tournamentId,
    required this.matchId,
    required this.currentUserId,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    required this.team1logo,
    required this.team2logo,
    this.onScoresEntered,
  });

  @override
  _EnterReviewForSecondMatchState createState() =>
      _EnterReviewForSecondMatchState();
}

class _EnterReviewForSecondMatchState extends State<EnterReviewForSecondMatch> {
  final TextEditingController team1ScoreController = TextEditingController();
  final TextEditingController team2ScoreController = TextEditingController();
  int thumbsUpCount = 0;

  void _saveReview() async {
    // Store the review in Firestore
    final DocumentReference matchDocRef = FirebaseFirestore.instance
        .collection('matchSchedule')
        .doc(widget.tournamentId)
        .collection('finalRoundMatch')
        .doc(widget.matchId);

    if (widget.currentUserId == widget.team1Id) {
      matchDocRef.update({
        'team2Review': thumbsUpCount,
      });
    } else if (widget.currentUserId == widget.team2Id) {
      matchDocRef.update({
        'team1Review': thumbsUpCount,
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter Review'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(widget.team2logo),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      thumbsUpCount = index + 1;
                    });
                  },
                  child: Icon(
                    Icons.thumb_up,
                    color:
                        index < thumbsUpCount ? Color(0xffFEAF3E) : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.deepPurpleAccent),
              ),
              onPressed: _saveReview,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
