import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_app/screens/addNewTeam.dart';

class joinTeams extends StatefulWidget {
  const joinTeams({Key? key});

  @override
  State<joinTeams> createState() => _joinTeamsState();
}

class _joinTeamsState extends State<joinTeams> {
  bool _isLoading = false;
  bool _userHasTeam = false;
  final String? userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    checkUserTeamStatus();
  }

  Future<void> checkUserTeamStatus() async {
    final teamsQuery =
        await FirebaseFirestore.instance.collection('captains').get();

    for (final teamDoc in teamsQuery.docs) {
      final teamId = teamDoc.id;
      print(teamId);
      final subcollectionQuery = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection(
              'teams') // Replace 'subcollection_name' with the actual name of the subcollection
          .where('captainId', isEqualTo: userId)
          .get();

      if (subcollectionQuery.docs.isNotEmpty) {
        setState(() {
          _userHasTeam = true;
        });
        return;
      }
    }

    setState(() {
      _userHasTeam = false;
    });
  }

  // Future<void> checkUserTeamStatus() async {
  //   final captainsQuery =
  //       await FirebaseFirestore.instance.collection('captains').get();

  //   for (final captainDoc in captainsQuery.docs) {
  //     final captainId = captainDoc.id;
  //     final teamQuery = await FirebaseFirestore.instance
  //         .collection('teams')
  //         .doc(captainId)
  //         .collection('teams')
  //         .where('captainId', isEqualTo: userId)
  //         .get();

  //     if (teamQuery.docs.isNotEmpty) {
  //       setState(() {
  //         _userHasTeam = true;
  //       });
  //       return;
  //     }
  //   }

  //   setState(() {
  //     _userHasTeam = false;
  //   });
  // }

  Future<void> sendJoinRequestToTeam(
    BuildContext context,
    String teamId,
    String userId,
  ) async {
    final requestQuery = await FirebaseFirestore.instance
        .collection('teamJoinRequests')
        .where('teamId', isEqualTo: teamId)
        .where('userId', isEqualTo: userId)
        .get();

    if (requestQuery.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already sent a request to this team'),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final requestRef =
        FirebaseFirestore.instance.collection('teamJoinRequests').doc();

    await requestRef.set({
      'teamId': teamId,
      'userId': userId,
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join request sent successfully to the team'),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 220,
                    padding: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Color(0xff6555FE),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Teams",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'karla'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Hi Are You Looking For A Team?",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'karla'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: fetchAllTeams(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                    ),
                  );
                }

                final teams = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: teams.length,
                  itemBuilder: (context, teamIndex) {
                    final teamData =
                        teams[teamIndex].data() as Map<String, dynamic>;
                    final teamLogo = teamData['logo'];
                    final teamId = teamData['captainId'];

                    return Card(
                      color: Colors.deepPurpleAccent,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xffFEAF3E),
                          backgroundImage: NetworkImage('$teamLogo'),
                        ),
                        title: Text(
                          teamData['teamName'],
                          style: TextStyle(
                              fontFamily: 'karla',
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(teamData['tagline'],
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'karla',
                                fontSize: 16)),
                        trailing: Container(
                          width: 100,
                          height: 30,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color(0xffFEAF3E))),
                            onPressed: () {
                              sendJoinRequestToTeam(
                                context,
                                teamId,
                                userId!,
                              );
                            },
                            child: Text('Join Team',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 10)),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Visibility(
          //   visible: !_userHasTeam,
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 20),
          //     child: Container(
          //       width: 300,
          //       height: 50,
          //       child: ElevatedButton(
          //         style: ButtonStyle(
          //             shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(10))),
          //             backgroundColor:
          //                 MaterialStatePropertyAll(Colors.deepPurpleAccent)),
          //         onPressed: () async {
          //           Navigator.push(context,
          //               MaterialPageRoute(builder: (context) => AddNewTeam()));
          //         },
          //         child: Text('Add New Team'),
          //       ),
          //     ),
          //   ),
          // )
        ]),
      ),
    );
  }

  Stream<List<QueryDocumentSnapshot>> fetchAllTeams() {
    return FirebaseFirestore.instance
        .collection('captains')
        .snapshots()
        .switchMap((captainSnapshot) {
      List<Stream<List<QueryDocumentSnapshot>>> streams = [];

      for (var doc in captainSnapshot.docs) {
        var stream = FirebaseFirestore.instance
            .collection('teams')
            .doc(doc.id)
            .collection('teams')
            .snapshots()
            .map((snapshot) => snapshot.docs);

        streams.add(stream);
      }

      return Rx.combineLatestList(streams).map((listOfLists) {
        return listOfLists.expand((list) => list).toList();
      });
    });
  }
}
