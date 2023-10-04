import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff493ADF),
        centerTitle: true,
        title: Text(
          'Results',
          style: TextStyle(fontFamily: 'karla'),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tournaments available.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((tournamentDoc) {
              String tournamentName = tournamentDoc['name'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentResultsScreen(
                        tournamentName: tournamentName,
                        tournamentId: tournamentDoc.id,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff493ADF),
                          Color(0xffFEAF3E),
                        ],
                        begin: Alignment.center,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 15),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: Image.network(
                              tournamentDoc['tournamentLogo'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          tournamentName,
                          style: TextStyle(
                            fontFamily: 'karla',
                            fontSize: 19,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TournamentResultsScreen extends StatelessWidget {
  final String tournamentName;
  final String tournamentId;

  TournamentResultsScreen({
    required this.tournamentName,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff493ADF),
        centerTitle: true,
        title: Text(
          '$tournamentName Results',
          style: TextStyle(
            fontFamily: 'karla',
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('matchSchedule')
            .doc(tournamentId)
            .collection('matches')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Color(0xff493ADF),
            ));
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final matches = snapshot.data?.docs;

          if (matches == null || matches.isEmpty) {
            return Center(
                child: Text('No matches available for this tournament.'));
          }

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final matchData = matches[index].data() as Map<String, dynamic>;
              final matchId = matches[index].id;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffFEAF3E), Color(0xff493ADF)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: buildTeamInfo(matchData['team1Id'])),
                          Text(
                            'VS',
                            style: TextStyle(
                              fontFamily: 'karla',
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(child: buildTeamInfo(matchData['team2Id'])),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Text(
                      //   'Match ID: $matchId',
                      //   style: TextStyle(color: Colors.white),
                      // ),
                      // Text(
                      //   'Referee: ${matchData['referee']}',
                      //   style: TextStyle(color: Colors.white),
                      // ),
                      // SizedBox(height: 10),
                      buildScores(tournamentId, matchId, matchData['team1Id'],
                          matchData['team2Id']),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildTeamInfo(String teamId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('teams')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xffFEAF3E),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final teamData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final teamName = teamData['teamName'];
          final logo = teamData['logo'];

          return Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(logo),
              ),
              SizedBox(height: 5),
              Text(
                teamName.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'karla',
                ),
              ),
            ],
          );
        } else {
          return Text('Team Info: -');
        }
      },
    );
  }

  Widget buildScores(
    String docId,
    String matchId,
    String team1Id,
    String team2Id,
  ) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('matchSchedule')
          .doc(docId)
          .collection('matches')
          .doc(matchId)
          .collection('scores')
          .doc(team1Id)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xffFEAF3E),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final scoresData = snapshot.data?.data() as Map<String, dynamic>?;

        if (scoresData == null) {
          return Center(
            child: Text(
              'Pending',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final team1Score = scoresData['team1Score'] as int? ?? 0;
        final team2Score = scoresData['team2Score'] as int? ?? 0;

        return Center(
          child: Text(
            '$team1Score - $team2Score',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'karla',
                fontSize: 18,
                fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }

  // Widget buildScores(String tournamentId, String matchId) {
  //   return StreamBuilder<DocumentSnapshot>(
  //     stream: FirebaseFirestore.instance
  //         .collection('matchSchedule')
  //         .doc(tournamentId)
  //         .collection('matches')
  //         .doc(matchId)
  //         .collection('scores')
  //         .doc('scores')
  //         .snapshots(),
  //     builder:
  //         (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(
  //           child: CircularProgressIndicator(
  //             color: Color(0xffFEAF3E),
  //           ),
  //         );
  //       }

  //       if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       }

  //       if (!snapshot.hasData || snapshot.data?.data() == null) {
  //         return Center(
  //           child: Text(
  //             'Scores: -',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         );
  //       }

  //       final scoresData = snapshot.data!.data() as Map<String, dynamic>;

  //       final team1Score = scoresData['team1Score'] as int? ?? 0;
  //       final team2Score = scoresData['team2Score'] as int? ?? 0;

  //       return Center(
  //         child: Text(
  //           'Scores: $team1Score - $team2Score',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       );
  //     },
  //   );
  // }
}
