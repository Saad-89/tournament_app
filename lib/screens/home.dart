import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/screens/gettingStarted.dart';
import 'package:user_app/screens/newsList.dart';
import 'package:user_app/screens/seeAll/matchesScreen.dart';
import 'package:user_app/screens/seeAll/news.dart';
import '../firbaseAuth/firebaseAuthService.dart';
import '../main.dart';
import '../util/notificationService.dart/notificationService.dart';
import '../util/test.dart';
import '../widgets/home/results.dart';
import 'authScreens/signIn.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';
import 'notificationScreen.dart';
import 'seeAll/resultsScreen.dart';
import 'seeAll/teamScreen.dart';
import 'seeAll/tournamentScreen.dart';

class UserProfile {
  final String name;
  final String profileImageUrl;

  UserProfile({required this.name, required this.profileImageUrl});
}

class TeamInfo {
  final String teamName;
  final String logoUrl;

  TeamInfo(this.teamName, this.logoUrl);
}

final FirebaseAuth auth = FirebaseAuth.instance;
String currentUserId = auth.currentUser!.uid;

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseService firebaseService = FirebaseService();

  Future<void> _refresh() async {
    setState(() {});
  }

  Future<List<String>> fetchRandomTeams(int limit) async {
    final captainsSnapshot =
        await FirebaseFirestore.instance.collection('captains').get();

    final List<String> teamIds = [];

    for (var doc in captainsSnapshot.docs) {
      final teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(doc.id)
          .collection('teams')
          .get();

      for (var teamDoc in teamSnapshot.docs) {
        teamIds.add(teamDoc.id);
      }
    }

    // Shuffle the teamIds list randomly
    teamIds.shuffle(Random());

    // Limit the list to the first four elements (four random teams)
    return teamIds.take(limit).toList();
  }

  Future<List<String>> fetchRandomTournaments(int limit) async {
    final eventsSnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    final List<String> tournamentIds = [];

    for (var doc in eventsSnapshot.docs) {
      tournamentIds.add(doc.id);
    }

    // Shuffle the tournamentIds list randomly
    tournamentIds.shuffle(Random());

    // Limit the list to the first 'limit' elements (random tournaments)
    return tournamentIds.take(limit).toList();
  }

  // get random matches
  Future<List<QueryDocumentSnapshot>> fetchRandomMatches() async {
    try {
      // Step 1: Fetch all tournamentIds from 'events' collection
      final eventTournaments =
          await FirebaseFirestore.instance.collection('events').get();
      if (eventTournaments.docs.isEmpty) {
        throw Exception('No events found');
      }

      final List<String> tournamentIds =
          eventTournaments.docs.map((doc) => doc.id).toList();

      print('All Tournament IDs from events: $tournamentIds');

      // Step 2: Check which tournamentIds are present in 'matchSchedule' collection
      List<String> availableTournamentIds = [];
      for (String tournamentId in tournamentIds) {
        final doc = await FirebaseFirestore.instance
            .collection('matchSchedule')
            .doc(tournamentId)
            .get();
        if (!doc.exists) {
          availableTournamentIds.add(tournamentId);
        }
      }

      print(
          'Tournament IDs available in matchSchedule: $availableTournamentIds');

      if (availableTournamentIds.isEmpty) {
        throw Exception('No available matches found for the event tournaments');
      }

      // Step 3: Randomly select a tournamentId and fetch its matches
      final randomTournamentId = availableTournamentIds[
          Random().nextInt(availableTournamentIds.length)];
      final allMatches = await FirebaseFirestore.instance
          .collection('matchSchedule')
          .doc(randomTournamentId)
          .collection('matches')
          .get();

      if (allMatches.docs.isEmpty) {
        throw Exception('No matches found for the selected tournament');
      }

      print(
          'Randomly selected Tournament ID: $randomTournamentId'); // Print the selected tournament ID

      // Step 4: Randomly select two matches
      allMatches.docs.shuffle();
      final selectedMatches =
          allMatches.docs.sublist(0, min(2, allMatches.docs.length));

      print('Randomly selected Match IDs:');
      for (final match in selectedMatches) {
        print('Match ID: ${match.id}'); // Print the selected match IDs
      }

      return selectedMatches;
    } catch (e) {
      print('Error while fetching matches: $e');
      throw e;
    }
  }

// ..................
  Future<void> printMatchScheduleDocIds() async {
    try {
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection('events').get();
      List<String> docIds = query.docs.map((doc) => doc.id).toList();
      print("Document IDs from matchSchedule: $docIds");
    } catch (e) {
      print("Error fetching from matchSchedule: $e");
    }
  }

  //....................

  Future<List<String>> fetchDocumentIds() async {
    List<String> documentIds = [];

    try {
      // Access the "matchSchedule" collection
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('matchSchedule').get();

      // Iterate through the documents and add document IDs to the list
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String docId = doc.id;
        documentIds.add(docId);
        print('Fetched Document ID: $docId');
      }
    } catch (e) {
      print('Error fetching document IDs: $e');
    }

    return documentIds;
  }

  // .........
  Future<void> fetchAndCreateList() async {
    // Step 1: Fetch document IDs from the first collection
    List<String> documentIds = await fetchDocumentIdsFromCollection('events');

    // Step 2: Check if the document IDs are present in the second collection
    List<String> matchingIds =
        await checkDocumentIdsInCollection(documentIds, 'matchSchedule');

    // Step 3: Create a list with matching document IDs
    print('Matching Document IDs: $matchingIds');
  }

  Future<List<String>> fetchDocumentIdsFromCollection(
      String collectionName) async {
    List<String> documentIds = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        documentIds.add(doc.id);
      }
    } catch (e) {
      print('Error fetching document IDs: $e');
    }

    return documentIds;
  }

  Future<List<String>> checkDocumentIdsInCollection(
      List<String> documentIds, String collectionName) async {
    List<String> matchingIds = [];

    try {
      for (String docId in documentIds) {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(docId)
            .get();
        if (docSnapshot.exists) {
          matchingIds.add(docId);
        }
      }
    } catch (e) {
      print('Error checking document IDs: $e');
    }

    return matchingIds;
  }

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.black,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('playerProfile')
                .doc(currentUserId) // Replace with the actual user UID
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                ));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error fetching user profile data'));
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('User profile data not found'));
              }

              final userProfileData =
                  snapshot.data!.data() as Map<String, dynamic>;
              // ignore: unnecessary_null_comparison
              if (userProfileData == null) {
                return Center(child: Text('User profile data is empty'));
              }

              final userProfile = UserProfile(
                name: userProfileData['name'] as String,
                profileImageUrl: userProfileData['profileImageUrl'] as String,
              );

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 230,
                          padding: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Color(0xff6555FE),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 40,
                                        bottom: 16),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          userProfile.profileImageUrl),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: IconButton(
                                      onPressed: () async {
                                        // String deviceId =
                                        //     await notificationServices
                                        //         .getDeviceToken();
                                        // print('this is device id: $deviceId');

                                        // await printMatchScheduleDocIds();
                                        // fetchAndCreateList();
                                        // var sharedPref = await SharedPreferences
                                        //     .getInstance();
                                        // sharedPref.setBool(
                                        //     MyAppState.KEYLOGIN, false);
                                        // await firebaseService.signOut();
                                        // Navigator.pushReplacement(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             GettingStartedScreen()));
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NotificationScreen()));
                                      },
                                      icon: Icon(
                                        Icons.notifications_outlined,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hi, ${userProfile.name}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'karla'),
                                    ),
                                    Text(
                                      "Welcome to Tournament App",
                                      style: TextStyle(
                                          fontSize: 16,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          // ... Displaying all teams, tournaments, etc.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Teams",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'karla'),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    seeAllTeamScreen()));
                                      },
                                      child: Text(
                                        "See All",
                                        style: TextStyle(
                                            fontFamily: 'karla',
                                            color: Color(0xffFEAF3E)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FutureBuilder<List<String>>(
                                        // Provide the list of team document IDs here
                                        future: fetchRandomTeams(4),
                                        builder: (context, teamIdsSnapshot) {
                                          if (teamIdsSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: Colors.deepPurpleAccent,
                                            ));
                                          }

                                          if (teamIdsSnapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error fetching team IDs'));
                                          }

                                          final teamIds =
                                              teamIdsSnapshot.data ?? [];

                                          return Row(
                                            children: teamIds.map((teamId) {
                                              return StreamBuilder<
                                                  QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('teams')
                                                    .doc(teamId)
                                                    .collection('teams')
                                                    .snapshots(),
                                                builder: (context,
                                                    teamDataSnapshot) {
                                                  if (teamDataSnapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      color: Colors
                                                          .deepPurpleAccent,
                                                    ));
                                                  }

                                                  if (teamDataSnapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error fetching team data');
                                                  }

                                                  final teamDataDocs =
                                                      teamDataSnapshot
                                                          .data!.docs;

                                                  return Row(
                                                    children: teamDataDocs
                                                        .map((teamDataDoc) {
                                                      final teamData =
                                                          teamDataDoc.data()
                                                              as Map<String,
                                                                  dynamic>;
                                                      final teamName =
                                                          teamData['teamName']
                                                                  as String? ??
                                                              'No Team Name';
                                                      final teamLogoUrl =
                                                          teamData['logo']
                                                                  as String? ??
                                                              'default_logo_url';

                                                      return Card(
                                                        shadowColor:
                                                            Colors.black,
                                                        elevation: 3,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        child: Center(
                                                          child: Container(
                                                            width: 80,
                                                            height: 105,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 8),
                                                            child: Column(
                                                              children: [
                                                                CircleAvatar(
                                                                  radius: 30,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                          teamLogoUrl),
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  teamName,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'karla',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          // matches widget
                          // Column(
                          //   children: [
                          //     SizedBox(
                          //       child: MatchesWidget(),
                          //     ),
                          //   ],
                          // ),

                          // tournaments ....
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Tournaments",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'karla',
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SeeAllTournamentScreen()));
                                      },
                                      child: Text(
                                        "See All",
                                        style: TextStyle(
                                          fontFamily: 'karla',
                                          color: Color(0xffFEAF3E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FutureBuilder<List<String>>(
                                        // Provide the list of tournament document IDs here
                                        future: fetchRandomTournaments(2),
                                        builder:
                                            (context, tournamentIdsSnapshot) {
                                          if (tournamentIdsSnapshot
                                                  .connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: Colors.deepPurpleAccent,
                                            ));
                                          }

                                          if (tournamentIdsSnapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error fetching tournament IDs'));
                                          }

                                          final tournamentIds =
                                              tournamentIdsSnapshot.data ?? [];

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: tournamentIds
                                                .map((tournamentId) {
                                              return StreamBuilder<
                                                  DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('events')
                                                    .doc(tournamentId)
                                                    .snapshots(),
                                                builder: (context,
                                                    tournamentSnapshot) {
                                                  if (tournamentSnapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      color: Colors
                                                          .deepPurpleAccent,
                                                    ));
                                                  }

                                                  if (tournamentSnapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error fetching tournament data');
                                                  }

                                                  final tournamentData =
                                                      tournamentSnapshot.data!
                                                              .data()
                                                          as Map<String,
                                                              dynamic>;
                                                  final tournamentName =
                                                      tournamentData['name']
                                                              as String? ??
                                                          'No Tournament Name';
                                                  final tournamentLogoUrl =
                                                      tournamentData[
                                                                  'tournamentLogo']
                                                              as String? ??
                                                          'assets/images/player.png';
                                                  final tournamentDate =
                                                      tournamentData['date']
                                                              as String? ??
                                                          'No Date';
                                                  print(
                                                      'tournamentLogoUrl: $tournamentLogoUrl');

                                                  return Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    elevation: 3,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xffFEAF3E),
                                                            Color(0xff493ADF),
                                                          ],
                                                          begin: Alignment
                                                              .topRight,
                                                          end: Alignment
                                                              .bottomLeft,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      width: 165,
                                                      height: 170,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 16),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 30,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    tournamentLogoUrl),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            tournamentName,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'karla',
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text(
                                                            tournamentDate,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'karla',
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          // display matches...
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Matches",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'karla',
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TournamentsScreen()));
                                      },
                                      child: Text(
                                        "See All",
                                        style: TextStyle(
                                          fontFamily: 'karla',
                                          color: Color(0xffFEAF3E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: StreamBuilder<QuerySnapshot>(
                                //         stream: FirebaseFirestore.instance
                                //             .collection('matchSchedule')
                                //             .doc(
                                //                 '122f894f-934d-48da-a42c-c274dfe52675')
                                //             .collection('matches')
                                //             .orderBy('matchNumber',
                                //                 descending: false)
                                //             .snapshots(),
                                //         builder: (BuildContext context,
                                //             AsyncSnapshot<QuerySnapshot>
                                //                 snapshot) {
                                //           if (snapshot.hasData) {
                                //             final matches = snapshot.data!.docs;
                                //             return ListView.builder(
                                //               physics:
                                //                   NeverScrollableScrollPhysics(),
                                //               shrinkWrap: true,
                                //               itemCount: 2,
                                //               // matches.length,
                                //               itemBuilder:
                                //                   (BuildContext context,
                                //                       int index) {
                                //                 final matchData =
                                //                     matches[index].data()
                                //                         as Map<String, dynamic>;

                                //                 if (matchData != null) {
                                //                   final matchNumber =
                                //                       matchData['matchNumber'];
                                //                   final team1Id =
                                //                       matchData['team1Id'];
                                //                   final team2Id =
                                //                       matchData['team2Id'];
                                //                   final matchTime =
                                //                       matchData['matchTime'];
                                //                   final ground =
                                //                       matchData['ground'];

                                //                   return Card(
                                //                     shape:
                                //                         RoundedRectangleBorder(
                                //                       borderRadius:
                                //                           BorderRadius.circular(
                                //                               30),
                                //                     ),
                                //                     elevation: 3,
                                //                     child: Container(
                                //                       padding:
                                //                           EdgeInsets.symmetric(
                                //                               vertical: 12),
                                //                       decoration: BoxDecoration(
                                //                         gradient:
                                //                             LinearGradient(
                                //                           colors: [
                                //                             Color(0xffFEAF3E),
                                //                             Color(0xff493ADF),
                                //                           ],
                                //                           begin: Alignment
                                //                               .topRight,
                                //                           end: Alignment
                                //                               .bottomLeft,
                                //                         ),
                                //                         borderRadius:
                                //                             BorderRadius
                                //                                 .circular(30),
                                //                       ),
                                //                       child: Column(
                                //                         children: [
                                //                           // Team Logos and Names
                                //                           Row(
                                //                             mainAxisAlignment:
                                //                                 MainAxisAlignment
                                //                                     .center,
                                //                             children: [
                                //                               Expanded(
                                //                                 child: FutureBuilder<
                                //                                     QuerySnapshot>(
                                //                                   future: FirebaseFirestore
                                //                                       .instance
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .doc(
                                //                                           team1Id)
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .get(),
                                //                                   builder: (BuildContext
                                //                                           context,
                                //                                       AsyncSnapshot<
                                //                                               QuerySnapshot>
                                //                                           snapshot) {
                                //                                     if (snapshot
                                //                                             .connectionState ==
                                //                                         ConnectionState
                                //                                             .waiting) {
                                //                                       return Center(
                                //                                           child:
                                //                                               CircularProgressIndicator(
                                //                                         color: Color(
                                //                                             0xffFEAF3E),
                                //                                       ));
                                //                                     }

                                //                                     if (snapshot
                                //                                             .hasData &&
                                //                                         snapshot
                                //                                             .data!
                                //                                             .docs
                                //                                             .isNotEmpty) {
                                //                                       final teamData = snapshot
                                //                                           .data!
                                //                                           .docs
                                //                                           .first
                                //                                           .data() as Map<String, dynamic>;
                                //                                       final teamName =
                                //                                           teamData[
                                //                                               'teamName'];
                                //                                       final logo =
                                //                                           teamData[
                                //                                               'logo'];

                                //                                       return Column(
                                //                                         children: [
                                //                                           CircleAvatar(
                                //                                             radius:
                                //                                                 25,
                                //                                             backgroundImage:
                                //                                                 NetworkImage(logo),
                                //                                           ),
                                //                                           SizedBox(
                                //                                               height: 5),
                                //                                           Text(
                                //                                             teamName.toUpperCase(),
                                //                                             style: TextStyle(
                                //                                                 color: Colors.white,
                                //                                                 fontSize: 16,
                                //                                                 fontFamily: 'karla'),
                                //                                           ),
                                //                                         ],
                                //                                       );
                                //                                     } else {
                                //                                       return Text(
                                //                                           'Team 1: -');
                                //                                     }
                                //                                   },
                                //                                 ),
                                //                               ),
                                //                               Text(
                                //                                 'VS',
                                //                                 style:
                                //                                     TextStyle(
                                //                                   fontFamily:
                                //                                       'karla',
                                //                                   fontSize: 22,
                                //                                   color: Colors
                                //                                       .white,
                                //                                   fontWeight:
                                //                                       FontWeight
                                //                                           .bold,
                                //                                 ),
                                //                               ),
                                //                               Expanded(
                                //                                 child: FutureBuilder<
                                //                                     QuerySnapshot>(
                                //                                   future: FirebaseFirestore
                                //                                       .instance
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .doc(
                                //                                           team2Id)
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .get(),
                                //                                   builder: (BuildContext
                                //                                           context,
                                //                                       AsyncSnapshot<
                                //                                               QuerySnapshot>
                                //                                           snapshot) {
                                //                                     if (snapshot
                                //                                             .connectionState ==
                                //                                         ConnectionState
                                //                                             .waiting) {
                                //                                       return Center(
                                //                                           child:
                                //                                               CircularProgressIndicator(
                                //                                         color: Colors
                                //                                             .deepPurpleAccent,
                                //                                       ));
                                //                                     }

                                //                                     if (snapshot
                                //                                             .hasData &&
                                //                                         snapshot
                                //                                             .data!
                                //                                             .docs
                                //                                             .isNotEmpty) {
                                //                                       final teamData = snapshot
                                //                                           .data!
                                //                                           .docs
                                //                                           .first
                                //                                           .data() as Map<String, dynamic>;
                                //                                       final teamName =
                                //                                           teamData[
                                //                                               'teamName'];
                                //                                       final logo =
                                //                                           teamData[
                                //                                               'logo'];

                                //                                       return Column(
                                //                                         children: [
                                //                                           CircleAvatar(
                                //                                             radius:
                                //                                                 25,
                                //                                             backgroundImage:
                                //                                                 NetworkImage(logo),
                                //                                           ),
                                //                                           SizedBox(
                                //                                               height: 5),
                                //                                           Text(
                                //                                             teamName.toUpperCase(),
                                //                                             style: TextStyle(
                                //                                                 color: Colors.white,
                                //                                                 fontSize: 16,
                                //                                                 fontFamily: 'karla'),
                                //                                           ),
                                //                                         ],
                                //                                       );
                                //                                     } else {
                                //                                       return Text(
                                //                                           'Team 2: -');
                                //                                     }
                                //                                   },
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                   );
                                //                 } else {
                                //                   return SizedBox();
                                //                 }
                                //               },
                                //             );
                                //           }
                                // return Center(
                                //   child: CircularProgressIndicator(
                                //     color: Colors.amber[300],
                                //   ),
                                // );
                                //         },
                                //       ),
                                //     ),
                                //   ],
                                // )
                                Column(
                                  children: [
                                    SizedBox(
                                      child: MatchesWidget(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          // displaying teams scores...
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Results",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'karla',
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ResultsScreen()));
                                      },
                                      child: Text(
                                        "See All",
                                        style: TextStyle(
                                          fontFamily: 'karla',
                                          color: Color(0xffFEAF3E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Column(
                                  children: [
                                    SizedBox(child: ResultsWidget()),
                                  ],
                                ),
                                // SizedBox(height: 10),
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: StreamBuilder<QuerySnapshot>(
                                //         stream: FirebaseFirestore.instance
                                //             .collection('matchSchedule')
                                //             .doc(
                                //                 '122f894f-934d-48da-a42c-c274dfe52675')
                                //             .collection('matches')
                                //             // .orderBy('matchNumber', descending: false)
                                //             .snapshots(),
                                //         builder: (BuildContext context,
                                //             AsyncSnapshot<QuerySnapshot>
                                //                 snapshot) {
                                //           if (snapshot.hasData) {
                                //             final matches = snapshot.data!.docs;
                                //             return ListView.builder(
                                //               physics:
                                //                   NeverScrollableScrollPhysics(),
                                //               shrinkWrap: true,
                                //               itemCount: 2,
                                //               // matches.length,
                                //               itemBuilder:
                                //                   (BuildContext context,
                                //                       int index) {
                                //                 final matchData =
                                //                     matches[index].data()
                                //                         as Map<String, dynamic>;

                                //                 if (matchData != null) {
                                //                   final matchNumber =
                                //                       matchData['matchNumber'];
                                //                   final team1Id =
                                //                       matchData['team1Id'];
                                //                   final team2Id =
                                //                       matchData['team2Id'];
                                //                   final matchTime =
                                //                       matchData['matchTime'];
                                //                   final ground =
                                //                       matchData['ground'];

                                //                   return Card(
                                //                     shape:
                                //                         RoundedRectangleBorder(
                                //                       borderRadius:
                                //                           BorderRadius.circular(
                                //                               30),
                                //                     ),
                                //                     elevation: 3,
                                //                     child: Container(
                                //                       padding:
                                //                           EdgeInsets.symmetric(
                                //                               vertical: 12),
                                //                       decoration: BoxDecoration(
                                //                         gradient:
                                //                             LinearGradient(
                                //                           colors: [
                                //                             Color(0xff493ADF),
                                //                             Color(0xffFEAF3E),
                                //                           ],
                                //                           begin: Alignment
                                //                               .topRight,
                                //                           end: Alignment
                                //                               .bottomLeft,
                                //                         ),
                                //                         borderRadius:
                                //                             BorderRadius
                                //                                 .circular(30),
                                //                       ),
                                //                       child: Column(
                                //                         children: [
                                //                           // Team Logos and Names
                                //                           Row(
                                //                             mainAxisAlignment:
                                //                                 MainAxisAlignment
                                //                                     .center,
                                //                             children: [
                                //                               Expanded(
                                //                                 child: FutureBuilder<
                                //                                     QuerySnapshot>(
                                //                                   future: FirebaseFirestore
                                //                                       .instance
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .doc(
                                //                                           team1Id)
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .get(),
                                //                                   builder: (BuildContext
                                //                                           context,
                                //                                       AsyncSnapshot<
                                //                                               QuerySnapshot>
                                //                                           snapshot) {
                                //                                     if (snapshot
                                //                                             .connectionState ==
                                //                                         ConnectionState
                                //                                             .waiting) {
                                //                                       return Center(
                                //                                           child:
                                //                                               CircularProgressIndicator(
                                //                                         color: Colors
                                //                                             .deepPurpleAccent,
                                //                                       ));
                                //                                     }

                                //                                     if (snapshot
                                //                                             .hasData &&
                                //                                         snapshot
                                //                                             .data!
                                //                                             .docs
                                //                                             .isNotEmpty) {
                                //                                       final teamData = snapshot
                                //                                           .data!
                                //                                           .docs
                                //                                           .first
                                //                                           .data() as Map<String, dynamic>;
                                //                                       final teamName =
                                //                                           teamData[
                                //                                               'teamName'];
                                //                                       final team1score =
                                //                                           teamData['team1Score'] ??
                                //                                               'pending';
                                //                                       final logo =
                                //                                           teamData[
                                //                                               'logo'];

                                //                                       return Row(
                                //                                         mainAxisAlignment:
                                //                                             MainAxisAlignment.end,
                                //                                         children: [
                                //                                           CircleAvatar(
                                //                                             radius:
                                //                                                 25,
                                //                                             backgroundImage:
                                //                                                 NetworkImage(logo),
                                //                                           ),
                                //                                           SizedBox(
                                //                                               width: 10),
                                //                                           Text(
                                //                                             team1score.toUpperCase(),
                                //                                             style: TextStyle(
                                //                                                 color: Colors.white,
                                //                                                 fontSize: 18,
                                //                                                 fontWeight: FontWeight.bold,
                                //                                                 fontFamily: 'karla'),
                                //                                           ),
                                //                                         ],
                                //                                       );
                                //                                     } else {
                                //                                       return Text(
                                //                                           'Team 1: -');
                                //                                     }
                                //                                   },
                                //                                 ),
                                //                               ),
                                //                               Text(
                                //                                 ' : ',
                                //                                 style:
                                //                                     TextStyle(
                                //                                   fontFamily:
                                //                                       'karla',
                                //                                   fontSize: 18,
                                //                                   color: Colors
                                //                                       .white,
                                //                                   fontWeight:
                                //                                       FontWeight
                                //                                           .bold,
                                //                                 ),
                                //                               ),
                                //                               Expanded(
                                //                                 child: FutureBuilder<
                                //                                     QuerySnapshot>(
                                //                                   future: FirebaseFirestore
                                //                                       .instance
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .doc(
                                //                                           team2Id)
                                //                                       .collection(
                                //                                           'teams')
                                //                                       .get(),
                                //                                   builder: (BuildContext
                                //                                           context,
                                //                                       AsyncSnapshot<
                                //                                               QuerySnapshot>
                                //                                           snapshot) {
                                //                                     if (snapshot
                                //                                             .connectionState ==
                                //                                         ConnectionState
                                //                                             .waiting) {
                                //                                       return Center(
                                //                                           child:
                                //                                               CircularProgressIndicator(
                                //                                         color: Color(
                                //                                             0xffFEAF3E),
                                //                                       ));
                                //                                     }

                                //                                     if (snapshot
                                //                                             .hasData &&
                                //                                         snapshot
                                //                                             .data!
                                //                                             .docs
                                //                                             .isNotEmpty) {
                                //                                       final teamData = snapshot
                                //                                           .data!
                                //                                           .docs
                                //                                           .first
                                //                                           .data() as Map<String, dynamic>;
                                //                                       final teamName =
                                //                                           teamData[
                                //                                               'teamName'];
                                //                                       final team2score =
                                //                                           teamData['team2Score'] ??
                                //                                               'pending';

                                //                                       final logo =
                                //                                           teamData[
                                //                                               'logo'];

                                //                                       return Row(
                                //                                         mainAxisAlignment:
                                //                                             MainAxisAlignment.start,
                                //                                         children: [
                                //                                           Text(
                                //                                             team2score.toUpperCase(),
                                //                                             style: TextStyle(
                                //                                                 color: Colors.white,
                                //                                                 fontSize: 18,
                                //                                                 fontWeight: FontWeight.bold,
                                //                                                 fontFamily: 'karla'),
                                //                                           ),
                                //                                           SizedBox(
                                //                                               width: 10),
                                //                                           CircleAvatar(
                                //                                             radius:
                                //                                                 25,
                                //                                             backgroundImage:
                                //                                                 NetworkImage(logo),
                                //                                           ),
                                //                                         ],
                                //                                       );
                                //                                     } else {
                                //                                       return Text(
                                //                                           'Team 2: -');
                                //                                     }
                                //                                   },
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                   );
                                //                 } else {
                                //                   return SizedBox();
                                //                 }
                                //               },
                                //             );
                                //           }
                                //           return Center(
                                //             child: CircularProgressIndicator(
                                //               color: Colors.amber[300],
                                //             ),
                                //           );
                                //         },
                                //       ),
                                //     ),
                                //   ],
                                // )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          // displaying latest news......
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Latest News",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'karla',
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewsListSeeAll()));
                                      },
                                      child: Text(
                                        "See All",
                                        style: TextStyle(
                                          fontFamily: 'karla',
                                          color: Color(0xffFEAF3E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                NewsList(),
                                // ListView.builder(
                                //   shrinkWrap: true,
                                //   itemCount: 2, // Replace with your news data
                                //   itemBuilder: (BuildContext context, int index) {
                                //     final newsItem = [
                                //       index
                                //     ]; // Replace with your news data model

                                //     return Card(
                                //       color: Color(0xffFEAF3E),
                                //       shape: RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(10)),
                                //       child: Padding(
                                //         padding: const EdgeInsets.symmetric(
                                //             vertical: 8.0),
                                //         child: Padding(
                                //           padding: const EdgeInsets.symmetric(
                                //               horizontal: 5),
                                //           child: Row(
                                //             crossAxisAlignment:
                                //                 CrossAxisAlignment.start,
                                //             children: [
                                //               // Profile Image
                                //               CircleAvatar(
                                //                 radius: 30,
                                //                 backgroundImage: AssetImage(
                                //                     'assets/images/news.png'),
                                //               ),
                                //               SizedBox(width: 10),
                                //               // News Text
                                //               Expanded(
                                //                 child: Text(
                                //                   'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus lacinia odio vitae vestibulum.',
                                //                   style: TextStyle(
                                //                       fontFamily: 'karla',
                                //                       fontSize: 16),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //     );
                                //   },
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Future<void> fetchAndPrintTeamData(String topLevelCollectionName) async {
//   print('Fetching team data...');
//   try {
//     CollectionReference topLevelCollection =
//         FirebaseFirestore.instance.collection(topLevelCollectionName);
//     QuerySnapshot topLevelSnapshot = await topLevelCollection.get();
//     print('Number of top-level docs: ${topLevelSnapshot.docs.length}');

//     for (var topLevelDoc in topLevelSnapshot.docs) {
//       CollectionReference subCollection =
//           topLevelDoc.reference.collection('teams');
//       QuerySnapshot subCollectionSnapshot = await subCollection.get();
//       print(
//           'Number of sub-collection docs: ${subCollectionSnapshot.docs.length}');

//       for (var subDoc in subCollectionSnapshot.docs) {
//         String teamName = subDoc['teamName'];
//         String logoUrl = subDoc['logo'];

//         print(
//             'Top-Level Doc ID: ${topLevelDoc.id}, Team Name: $teamName, Logo URL: $logoUrl');
//       }
//     }
//   } catch (error) {
//     print('Error fetching team data: $error');
//   }
// }

// Future<void> printAllTeamNames() async {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   CollectionReference topLevelTeams = firestore.collection('teams');

//   try {
//     print("Fetching top-level documents...");
//     QuerySnapshot topLevelSnapshot = await topLevelTeams.get();
//     print("Fetched top-level documents successfully!");

//     // Print the number of top-level documents.
//     print(
//         "Total number of top-level documents: ${topLevelSnapshot.docs.length}");

//     for (QueryDocumentSnapshot topLevelDoc in topLevelSnapshot.docs) {
//       print("Top-level Document ID: ${topLevelDoc.id}");

//       try {
//         QuerySnapshot subTeamsSnapshot =
//             await topLevelTeams.doc(topLevelDoc.id).collection('teams').get();

//         for (QueryDocumentSnapshot subTeamDoc in subTeamsSnapshot.docs) {
//           // Extract and print teamName.
//           String? teamName = (subTeamDoc.data()
//               as Map<String, dynamic>)['teamName'] as String?;
//           if (teamName != null) {
//             print("Team Name: $teamName");
//           } else {
//             print(
//                 "Team Name not found or is null for sub-document ID: ${subTeamDoc.id}");
//           }
//         }
//       } catch (subError) {
//         print(
//             "Error fetching subcollection for top-level document ID: ${topLevelDoc.id}. Error: $subError");
//       }
//     }
//   } catch (topError) {
//     print("Error fetching top-level documents. Error: $topError");
//   }
// }
