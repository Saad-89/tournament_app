import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ResultsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Color(0xffFEAF3E),
          ));
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No data available.');
        }

        // Get all the document IDs from the snapshot
        List<String> documentIds =
            snapshot.data!.docs.map((doc) => doc.id).toList();

        // Randomly select one document ID
        String randomDocId = documentIds[Random().nextInt(documentIds.length)];

        return Results(docId: randomDocId);
      },
    );
  }
}

class Results extends StatelessWidget {
  final String docId;

  Results({required this.docId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('matchSchedule')
          .doc(docId)
          .collection('matches')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Color(0xffFEAF3E),
          ));
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final matches = snapshot.data?.docs;

        if (matches == null || matches.isEmpty) {
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
              child: Center(
                child: Text(
                  'No results',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }

        matches.shuffle();

        List<Widget> matchWidgets = [];
        int numberOfMatchesToDisplay = min(2, matches.length);
        for (int i = 0; i < numberOfMatchesToDisplay; i++) {
          final matchData = matches[i].data() as Map<String, dynamic>;
          final matchId = matches[i].id;
          final referee = matchData['referee'];
          final team1Id = matchData['team1Id'];
          final team2Id = matchData['team2Id'];

          Widget matchCard = Card(
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
                      Expanded(child: buildTeamInfo(team1Id)),
                      Text(
                        'VS',
                        style: TextStyle(
                          fontFamily: 'karla',
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: buildTeamInfo(team2Id)),
                    ],
                  ),
                  SizedBox(height: 10),
                  buildScores(team1Id, team2Id, docId, matchId),
                ],
              ),
            ),
          );

          matchWidgets.add(matchCard);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...matchWidgets,
          ],
        );
      },
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
      String team1Id, String team2Id, String docId, String matchId) {
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
}
