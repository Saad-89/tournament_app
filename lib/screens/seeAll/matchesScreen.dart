import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff493ADF),
        centerTitle: true,
        title: Text(
          'Tournaments',
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
              String tournamentId = tournamentDoc.id;
              String tournamentName = tournamentDoc['name'];
              final tournamentLogo = tournamentDoc['tournamentLogo'];

              return Container(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MatchesScreen(tournamentId, tournamentName),
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
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Color(0xffFEAF3E),
                                  ),
                                ),
                                // Image.network(tournamentLogo)
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.network(
                                      tournamentLogo,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Tap to see matches in ',
                                  style: TextStyle(
                                      fontFamily: 'karla',
                                      color: Colors.white)),
                              Text('$tournamentName',
                                  style: TextStyle(
                                      fontFamily: 'karla',
                                      fontSize: 19,
                                      color: Colors.amber[300])),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              // ListTile(
              //   title: Text(tournamentName),
              //   onTap: () {
              //     // Navigate to the MatchesScreen for the selected tournament
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) =>
              //             MatchesScreen(tournamentId, tournamentName),
              //       ),
              //     );
              //   },
              // );
            }).toList(),
          );
        },
      ),
    );
  }
}

class MatchesScreen extends StatelessWidget {
  final String tournamentId;
  final String tournamentName;

  MatchesScreen(this.tournamentId, this.tournamentName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff493ADF),
        centerTitle: true,
        title: Text(
          tournamentName,
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
              final matchNumber = matchData['matchNumber'];
              final referee = matchData['referee'];

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
                      // SizedBox(height: 10),
                      // Text(
                      //   'Match Number: $matchNumber',
                      //   style: TextStyle(color: Colors.white),
                      // ),
                      // Text(
                      //   'Referee: $referee',
                      //   style: TextStyle(color: Colors.white),
                      // ),
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
