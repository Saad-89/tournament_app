import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MatchesWidget extends StatelessWidget {
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

        return MatchItem(docId: randomDocId);
      },
    );
  }
}

class MatchItem extends StatelessWidget {
  final String docId;

  MatchItem({required this.docId});

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
                  'No match yet',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }

        // Shuffle the matches to get a random order
        matches.shuffle();

        // Get the first 2 matches (or less if there are fewer than 2 matches)
        List<Widget> matchWidgets = [];
        int numberOfMatchesToDisplay = min(2, matches.length);
        for (int i = 0; i < numberOfMatchesToDisplay; i++) {
          final matchData = matches[i].data() as Map<String, dynamic>;
          final matchNumber = matchData['matchNumber'];
          final referee = matchData['referee'];

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
                ],
              ),
            ),
          );

          matchWidgets.add(matchCard);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Document ID: $docId'),
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
}
