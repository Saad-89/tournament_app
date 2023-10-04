import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_app/screens/addNewTeam.dart';
import 'package:user_app/screens/editTeam.dart';
import 'package:user_app/screens/teamJoinRequest.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  bool _isLoading = false;
  bool _userHasTeam = false;
  final String? userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _initializeUserTeamStatus();
  }

  Future<void> _initializeUserTeamStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check the subcollection 'teams' inside the user's document in the 'teams' collection
      QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(userId)
          .collection('teams')
          .get();

      setState(() {
        // If there are any documents inside this subcollection, then the user has a team
        _userHasTeam = teamSnapshot.docs.isNotEmpty;
      });
    } catch (error) {
      print('Error fetching team data: $error');
      setState(() {
        _userHasTeam = false; // default to false in case of error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                ),
              )
            : _userHasTeam
                ? MyTeam()
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 245,
                                    padding: EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Color(0xff6555FE),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                  // SizedBox(height: 20),
                                ],
                              ),
                              // Positioned(
                              //   bottom: 0,
                              //   left: 20,
                              //   right: 20,
                              //   child: Container(
                              //     padding: EdgeInsets.symmetric(horizontal: 10),
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.circular(10),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.2),
                              //           spreadRadius: 2,
                              //           blurRadius: 5,
                              //           offset: Offset(0, 3),
                              //         ),
                              //       ],
                              //     ),
                              //     child: TextField(
                              //       onChanged: (value) {
                              //         setState(() {
                              //           searchQuery = value.trim();
                              //         });
                              //         print(
                              //             "Search query updated: $searchQuery");
                              //       },
                              //       decoration: InputDecoration(
                              //         hintText: "Search",
                              //         border: InputBorder.none,
                              //         icon: Icon(Icons.search),
                              //       ),
                              //     ),
                              //   ),
                              // ),
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

                                  final allTeams = snapshot.data!;
                                  final teams = allTeams.where((doc) {
                                    if (searchQuery == null ||
                                        searchQuery!.isEmpty) {
                                      return true;
                                    } else {
                                      final teamData =
                                          doc.data() as Map<String, dynamic>;
                                      final teamName =
                                          teamData['teamName'].toLowerCase();
                                      print('Filtering: $teamName');
                                      return teamName
                                          .contains(searchQuery!.toLowerCase());
                                    }
                                  }).toList();

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: teams.length,
                                    itemBuilder: (context, teamIndex) {
                                      final teamData = teams[teamIndex].data()
                                          as Map<String, dynamic>;
                                      final teamLogo = teamData['logo'];
                                      final teamId = teamData['captainId'];

                                      return Card(
                                        color: Colors.deepPurpleAccent,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Color(0xffFEAF3E),
                                            backgroundImage:
                                                NetworkImage('$teamLogo'),
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
                                            width: 80,
                                            height: 30,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
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
                                                      color: Colors.black,
                                                      fontSize: 10)),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )

                              // StreamBuilder<List<QueryDocumentSnapshot>>(
                              //   stream: fetchAllTeams(),
                              //   builder: (context, snapshot) {
                              //     if (!snapshot.hasData) {
                              //       return Center(
                              //         child: CircularProgressIndicator(
                              //           color: Colors.deepPurpleAccent,
                              //         ),
                              //       );
                              //     }

                              //     final teams = snapshot.data!;

                              //     return ListView.builder(
                              //       shrinkWrap: true,
                              //       physics: NeverScrollableScrollPhysics(),
                              //       itemCount: teams.length,
                              //       itemBuilder: (context, teamIndex) {
                              //         final teamData = teams[teamIndex].data()
                              //             as Map<String, dynamic>;
                              //         final teamLogo = teamData['logo'];
                              //         final teamId = teamData['captainId'];

                              //         return Card(
                              //           color: Colors.deepPurpleAccent,
                              //           elevation: 2,
                              //           shape: RoundedRectangleBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(10)),
                              //           child: ListTile(
                              //             leading: CircleAvatar(
                              //               backgroundColor: Color(0xffFEAF3E),
                              //               backgroundImage:
                              //                   NetworkImage('$teamLogo'),
                              //             ),
                              //             title: Text(
                              //               teamData['teamName'],
                              //               style: TextStyle(
                              //                   fontFamily: 'karla',
                              //                   fontSize: 18,
                              //                   color: Colors.white,
                              //                   fontWeight: FontWeight.bold),
                              //             ),
                              //             subtitle: Text(teamData['tagline'],
                              //                 style: TextStyle(
                              //                     color: Colors.white,
                              //                     fontFamily: 'karla',
                              //                     fontSize: 16)),
                              //             trailing: Container(
                              //               width: 80,
                              //               height: 30,
                              //               child: ElevatedButton(
                              //                 style: ButtonStyle(
                              //                     backgroundColor:
                              //                         MaterialStatePropertyAll(
                              //                             Color(0xffFEAF3E))),
                              //                 onPressed: () {
                              //                   sendJoinRequestToTeam(
                              //                     context,
                              //                     teamId,
                              //                     userId!,
                              //                   );
                              //                 },
                              //                 child: Text('Join Team',
                              //                     style: TextStyle(
                              //                         color: Colors.black,
                              //                         fontSize: 10)),
                              //               ),
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //     );
                              //   },
                              // ),
                              ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: 300,
                              height: 50,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.deepPurpleAccent)),
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddNewTeam()));
                                },
                                child: Text('Add New Team'),
                              ),
                            ),
                          ),
                          // ...
                        ],
                      ),
                    ),
                  ),
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

// Scaffold(
//   body: SingleChildScrollView(
//     child: Column(
//       children: [
//       Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: 245,
//                 padding: EdgeInsets.only(bottom: 20),
//                 decoration: BoxDecoration(
//                   color: Color(0xff6555FE),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(15),
//                     bottomRight: Radius.circular(15),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Teams",
//                             style: TextStyle(
//                                 fontSize: 25,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 fontFamily: 'karla'),
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             "Hi Are You Looking For A Team?",
//                             style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.white,
//                                 fontFamily: 'karla'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//           Positioned(
//             bottom: 0,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: "Search",
//                   border: InputBorder.none,
//                   icon: Icon(Icons.search),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: StreamBuilder<List<QueryDocumentSnapshot>>(
//           stream: fetchAllTeams(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.deepPurpleAccent,
//                 ),
//               );
//             }

//             final teams = snapshot.data!;

//             return ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: teams.length,
//               itemBuilder: (context, teamIndex) {
//                 final teamData =
//                     teams[teamIndex].data() as Map<String, dynamic>;
//                 final teamLogo = teamData['logo'];
//                 final teamId = teamData['captainId'];

//                 return Card(
//                   color: Colors.deepPurpleAccent,
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Color(0xffFEAF3E),
//                       backgroundImage: NetworkImage('$teamLogo'),
//                     ),
//                     title: Text(
//                       teamData['teamName'],
//                       style: TextStyle(
//                           fontFamily: 'karla',
//                           fontSize: 18,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(teamData['tagline'],
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontFamily: 'karla',
//                             fontSize: 16)),
//                     trailing: Container(
//                       width: 80,
//                       height: 30,
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                             backgroundColor: MaterialStatePropertyAll(
//                                 Color(0xffFEAF3E))),
//                         onPressed: () {
//                           sendJoinRequestToTeam(
//                             context,
//                             teamId,
//                             userId!,
//                           );
//                         },
//                         child: Text('Join Team',
//                             style: TextStyle(
//                                 color: Colors.black, fontSize: 10)),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//       SizedBox(
//         height: 20,
//       ),
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           width: 300,
//           height: 50,
//           child: ElevatedButton(
//             style: ButtonStyle(
//                 shape: MaterialStatePropertyAll(RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10))),
//                 backgroundColor:
//                     MaterialStatePropertyAll(Colors.deepPurpleAccent)),
//             onPressed: () async {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => AddNewTeam()));
//             },
//             child: Text('Add New Team'),
//           ),
//         ),
//       )
//     ],
//     ),
//   ),
// );

// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
User? user = FirebaseAuth.instance.currentUser;
String userUuid = auth.currentUser!.uid;
String? _selectedTeamId;

class MyTeam extends StatefulWidget {
  MyTeam({Key? key});

  @override
  _MyTeamState createState() => _MyTeamState();
}

class _MyTeamState extends State<MyTeam> {
  final _formKey = GlobalKey<FormState>();
  final _memberNameController = TextEditingController();
  final _jerseyNumberController = TextEditingController();
  final _specificationController = TextEditingController();

  // String? _selectedImage;
  String? _profileImageUrl;
  bool? _isLoading;
  bool? _isImagePicked;

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

  void _deleteTeam(String teamId) {
    // Delete team from Firestore
    FirebaseFirestore.instance
        .collection('teams')
        .doc(user!.uid)
        .collection('teams')
        .doc(teamId)
        .delete()
        .then((value) {
      print('Team deleted successfully');
    }).catchError((error) {
      // Handle any error that occurred during deletion
      print('Error deleting team: $error');
    });
  }

  // pick image for adding team memebers

  Future<void> uploadProfileImage() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);

        setState(() {
          _isLoading = true;
        });

        // Upload the selected image to Firebase Storage
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('playerProfileImages/$fileName');
        firebase_storage.UploadTask uploadTask = ref.putFile(file);
        firebase_storage.TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() => null);
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        print(imageUrl);

        setState(() {
          _profileImageUrl = imageUrl;
          _isLoading = false;
          _isImagePicked =
              true; // Add this line to set the flag when image is picked
        });
      }
    } catch (error) {
      print('Error uploading profile image: $error');
    }
  }

  void _addTeamMember(String teamId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        print('_profileImageUrl: $_profileImageUrl');
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: uploadProfileImage,
                  child: _profileImageUrl != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(_profileImageUrl!),
                        )
                      : Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: Color(0xff6858FE),
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                                child: Text('Pick Image',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                ),
                TextFormField(
                  controller: _memberNameController,
                  decoration: InputDecoration(labelText: 'Member Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a member name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _jerseyNumberController,
                  decoration: InputDecoration(labelText: 'Jersey Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a jersey number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _specificationController,
                  decoration: InputDecoration(labelText: 'Specification'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.deepPurpleAccent)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveTeamMember(teamId);
                      _clearMemberForm();
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveTeamMember(String teamId) {
    String memberName = _memberNameController.text;
    int jerseyNumber = int.parse(_jerseyNumberController.text);
    String specification = _specificationController.text;

    // Save team member details to Firestore
    FirebaseFirestore.instance
        .collection('teams')
        .doc(user!.uid)
        .collection('teams')
        .doc(teamId)
        .collection('teamMembers')
        .add({
      'playerImageUrl': _profileImageUrl,
      'memberName': memberName,
      'jerseyNumber': jerseyNumber,
      'specification': specification,
    }).then((value) {
      // Team member saved successfully
      _clearMemberForm();
    }).catchError((error) {
      // Handle any error that occurred during saving
      print('Error saving team member: $error');
    });
  }

  // void _editTeamMember(String teamId, String memberId, String memberName,
  //     int jerseyNumber, String specification, String memberProfile) {
  //   _memberNameController.text = memberName;
  //   _jerseyNumberController.text = jerseyNumber.toString();
  //   _specificationController.text = specification;
  //   String profileImage = _profileImageUrl ?? memberProfile;

  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(16.0),
  //         child: Form(
  //           key: _formKey,
  //           child: Column(
  //             children: [
  //               GestureDetector(
  //                   onTap: uploadProfileImage,
  //                   child: _profileImageUrl != null
  //                       ? CircleAvatar(
  //                           radius: 25,
  //                           backgroundImage: NetworkImage(_profileImageUrl!),
  //                         )
  //                       : CircleAvatar(
  //                           radius: 25,
  //                           backgroundImage: NetworkImage(profileImage),
  //                         )),
  //               TextFormField(
  //                 controller: _memberNameController,
  //                 decoration: InputDecoration(labelText: 'Member Name'),
  //                 validator: (value) {
  //                   if (value!.isEmpty) {
  //                     return 'Please enter a member name';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               TextFormField(
  //                 controller: _jerseyNumberController,
  //                 decoration: InputDecoration(labelText: 'Jersey Number'),
  //                 keyboardType: TextInputType.number,
  //                 validator: (value) {
  //                   if (value!.isEmpty) {
  //                     return 'Please enter a jersey number';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               TextFormField(
  //                 controller: _specificationController,
  //                 decoration: InputDecoration(labelText: 'Specification'),
  //               ),
  //               ElevatedButton(
  //                 style: ButtonStyle(
  //                     backgroundColor:
  //                         MaterialStatePropertyAll(Colors.deepPurpleAccent)),
  //                 onPressed: () {
  //                   if (_formKey.currentState!.validate()) {
  //                     _updateTeamMember(teamId, memberId, profileImage);
  //                     Navigator.pop(context);
  //                   }
  //                 },
  //                 child: Text('Update'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _editTeamMember(String teamId, String memberId, String memberName,
      int jerseyNumber, String specification, String memberProfile) {
    _memberNameController.text = memberName;
    _jerseyNumberController.text = jerseyNumber.toString();
    _specificationController.text = specification;
    String profileImage = _profileImageUrl ?? memberProfile;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await uploadProfileImage();

                    // After uploading the profile image, call setState
                    setState(() {
                      profileImage = _profileImageUrl!;
                    });
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                ),
                // GestureDetector(
                //   onTap: uploadProfileImage,
                //   child: CircleAvatar(
                //     radius: 25,
                //     backgroundImage: NetworkImage(profileImage),
                //   ),
                // ),
                TextFormField(
                  controller: _memberNameController,
                  decoration: InputDecoration(labelText: 'Member Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a member name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _jerseyNumberController,
                  decoration: InputDecoration(labelText: 'Jersey Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a jersey number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _specificationController,
                  decoration: InputDecoration(labelText: 'Specification'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.deepPurpleAccent)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateTeamMember(teamId, memberId, profileImage);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateTeamMember(String teamId, String memberId, String profileImage) {
    String memberName = _memberNameController.text;
    int jerseyNumber = int.parse(_jerseyNumberController.text);
    String specification = _specificationController.text;

    // Update team member details in Firestore
    FirebaseFirestore.instance
        .collection('teams')
        .doc(user!.uid)
        .collection('teams')
        .doc(teamId)
        .collection('teamMembers')
        .doc(memberId)
        .update({
      'playerImageUrl': profileImage,
      'memberName': memberName,
      'jerseyNumber': jerseyNumber,
      'specification': specification,
    }).then((value) {
      // Team member updated successfully
      _clearMemberForm();
    }).catchError((error) {
      // Handle any error that occurred during updating
      print('Error updating team member: $error');
    });
  }

  void _deleteTeamMember(String teamId, String memberId) {
    // Delete team member from Firestore
    FirebaseFirestore.instance
        .collection('teams')
        .doc(user!.uid)
        .collection('teams')
        .doc(teamId)
        .collection('teamMembers')
        .doc(memberId)
        .delete()
        .then((value) {
      print('Team member deleted successfully');
    }).catchError((error) {
      // Handle any error that occurred during deletion
      print('Error deleting team member: $error');
    });
  }

  void _clearForm() {
    // _teamNameController.clear();
    // _clubNameController.clear();
    _selectedTeamId = null;
  }

  void _clearMemberForm() {
    _memberNameController.clear();
    _jerseyNumberController.clear();
    _specificationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    print('userUuid: ${user!.uid}');
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .doc(user!.uid)
          .collection('teams')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.amber[300],
          ));
        }

        if (snapshot.data!.docs.isEmpty) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 245,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  width: 80,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Color(0xffFEAF3E))),
                                    onPressed: () {
                                      sendJoinRequestToTeam(
                                        context,
                                        teamId,
                                        user!.uid,
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.deepPurpleAccent)),
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNewTeam()));
                        },
                        child: Text('Add New Team'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // ...
                ],
              ),
            ),
          );
        }

        List<Widget> teamWidgets =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          String teamId = document.id;
          Map<String, dynamic> teamData =
              document.data() as Map<String, dynamic>;
          String teamName = teamData['teamName'];
          String tagline = teamData['tagline'];
          String logo = teamData['logo'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image(image: AssetImage('assets/images/signupTopImage.png')),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('My Team',
                      style: TextStyle(
                          fontFamily: 'karla',
                          fontSize: 26,
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Check if the image URL exists before trying to use it.

                        // Image.network(data['profileImageUrl']),
                        CircleAvatar(
                          backgroundImage: NetworkImage(logo),
                          radius: 60,
                        ),
                        SizedBox(width: 20),
                        // Check if the name exists before trying to use it.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teamName,
                              style: TextStyle(
                                  fontFamily: 'karla',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              tagline,
                              style: TextStyle(
                                  fontFamily: 'karla',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        )
                      ],
                    ),
                    //  adding more fields here to display other data
                    SizedBox(
                      height: 30,
                    ),

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
                                              BorderRadius.circular(10))),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.deepPurpleAccent)),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => EditTeam(
                                              TeamData: teamData,
                                            ))));
                              },
                              child: Text(
                                'Edit Team',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'karla',
                                    fontWeight: FontWeight.w700),
                              ),
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
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.green[400])),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            JoinRequestsScreen(
                                              teamId: teamId,
                                            ))));
                              },
                              child: Text(
                                'View Requests',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'karla',
                                    fontWeight: FontWeight.w700),
                              ),
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
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.amber[300])),
                              onPressed: () async {
                                if (teamId != null) {
                                  _addTeamMember(teamId);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Please select a team first.'),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Add Team Member',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontFamily: 'karla',
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 10, right: 10),
              //   child: ElevatedButton(
              //       style: ButtonStyle(
              //           backgroundColor:
              //               MaterialStatePropertyAll(Colors.deepPurpleAccent)),
              //       onPressed: () {
              //         if (teamId != null) {
              //           _addTeamMember(teamId);
              //         } else {
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             SnackBar(
              //               content: Text('Please select a team first.'),
              //             ),
              //           );
              //         }
              //       },
              //       child: Text(
              //         'add members',
              //         style: TextStyle(fontFamily: 'karla'),
              //       )),
              // ),
              // Card(
              //   elevation: 4,
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10)),
              //   color: Colors.amber[300],
              //   child: Padding(
              //     padding: const EdgeInsets.all(7.0),
              //     child: ListTile(
              //       leading: Container(
              //         width: 70,
              //         height: 70,
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(15),
              //             image: DecorationImage(image: NetworkImage(logo))),
              //         // child: Image.network(tournamentLogo),
              //       ),
              //       title: Text(
              //         '$teamName',
              //         style: TextStyle(
              //             fontFamily: 'karla',
              //             fontSize: 20,
              //             fontWeight: FontWeight.bold),
              //       ),
              //       trailing: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           IconButton(
              //             color: Colors.deepPurpleAccent,
              //             onPressed: () {
              //               // _editTeam(teamId, teamName, clubName);
              //             },
              //             icon: Icon(Icons.edit),
              //           ),
              //           IconButton(
              //             color: Colors.deepPurpleAccent,
              //             onPressed: () {
              //               _deleteTeam(teamId);
              //             },
              //             icon: Icon(Icons.delete),
              //           ),
              //         ],
              //       ),
              //       onTap: () {
              //         _addTeamMember(teamId);
              //       },
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 12,
              ),
              // Center(
              //   child: Text('Team Members',
              //       style: TextStyle(
              //         fontFamily: 'karla',
              //         fontWeight: FontWeight.bold,
              //       )),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _buildTeamMemberList(teamId),
              ),
            ],
          );
        }).toList();

        return ListView(
          children: teamWidgets,
        );
      },
    );
  }

  Widget _buildTeamMemberList(String teamId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .doc(user!.uid)
          .collection('teams')
          .doc(teamId)
          .collection('teamMembers')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.amber[300],
            ),
          );
        }

        List<Widget> teamMemberWidgets =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          String memberId = document.id;
          Map<String, dynamic> teamMemberData =
              document.data() as Map<String, dynamic>;
          String memberName = teamMemberData['memberName'];
          String memberProfile = teamMemberData['playerImageUrl'];

          int jerseyNumber = teamMemberData['jerseyNumber'];
          String specification = teamMemberData['specification'];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff493ADF),
                    Color(0xffFEAF3E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: memberProfile == null
                        ? AssetImage('assets/images/player.png')
                            as ImageProvider
                        : NetworkImage(memberProfile),
                  ),
                  title: Text(
                    '$memberName',
                    style: TextStyle(
                        fontFamily: 'karla',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jersey Number: $jerseyNumber',
                        style: TextStyle(
                            fontFamily: 'karla',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Position: $specification',
                        style: TextStyle(
                            fontFamily: 'karla',
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    // color: Colors.amber[300],
                    color: Colors.green[400],
                    onPressed: () {
                      _editTeamMember(teamId, memberId, memberName,
                          jerseyNumber, specification, memberProfile);
                    },
                    icon: Icon(
                      Icons.edit,
                      // weight: 15,
                      // size: 30,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList();

        return Column(
          children: teamMemberWidgets,
        );
      },
    );
  }
}
