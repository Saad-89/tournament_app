import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditTeam extends StatefulWidget {
  final Map<String, dynamic> TeamData;
  const EditTeam({super.key, required this.TeamData});

  @override
  State<EditTeam> createState() => _EditTeamState();
}

class _EditTeamState extends State<EditTeam> {
  late TextEditingController teamNameController;
  // late TextEditingController captainNameController;
  late TextEditingController PhoneNumberController;
  late TextEditingController emailController;
  late TextEditingController tagLineController;
  // late TextEditingController clubNameController;

  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    teamNameController =
        TextEditingController(text: widget.TeamData['teamName'] ?? '');
    // captainNameController = TextEditingController();
    PhoneNumberController =
        TextEditingController(text: widget.TeamData['phoneNumber'] ?? '');
    emailController =
        TextEditingController(text: widget.TeamData['email'] ?? '');
    tagLineController =
        TextEditingController(text: widget.TeamData['tagline'] ?? '');
    // clubNameController = TextEditingController();
    _profileImageUrl = widget.TeamData['logo'];
  }

  @override
  void dispose() {
    teamNameController.dispose();
    // captainNameController.dispose();
    PhoneNumberController.dispose();
    emailController.dispose();
    tagLineController.dispose();
    // clubNameController.dispose();
    super.dispose();
  }

  String? _selectedImage;
  String? _profileImageUrl;
  bool? _isLoading;
  bool? _isImagePicked;

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
            .child('profileImages/$fileName');
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

  void createTeam() {
    final teamName = teamNameController.text.trim();
    final phoneNumber = PhoneNumberController.text.trim();
    // final captainName = captainNameController.text.trim();
    final email = emailController.text.trim();
    final tagLine = tagLineController.text.trim();
    // final clubName = clubNameController.text.trim();

    List<String> emptyFields = [];
    if (teamName.isEmpty) emptyFields.add('Team Name');
    if (phoneNumber.isEmpty) emptyFields.add('Phone Number');
    // if (captainName.isEmpty) emptyFields.add('Captain Name');
    if (email.isEmpty) emptyFields.add('Email');
    if (tagLine.isEmpty) emptyFields.add('Tagline');
    // if (clubName.isEmpty) emptyFields.add('Club Name');
    if (_profileImageUrl == null) emptyFields.add('Image');

    if (emptyFields.isNotEmpty) {
      String errorMessage;
      if (emptyFields.length > 3) {
        errorMessage = 'Please fill in all fields';
      } else if (emptyFields.length == 1) {
        errorMessage = 'Please select the ${emptyFields[0]} field';
      } else {
        errorMessage =
            'Please fill in or select the following fields:\n${emptyFields.join(', ')}';
      }
      _showSnackBar(errorMessage, Colors.red);
      return;
    }

    final teamData = {
      'createdBy': 'user',
      'teamName': teamName,
      'captainId': userId,
      // 'captainname': captainName,
      'phoneNumber': phoneNumber,
      'email': email,
      'tagline': tagLine,
      // 'clubName': clubName,
      'logo': _profileImageUrl,
    };

    FirebaseFirestore.instance
        .collection('teams')
        .doc(userId)
        .collection('teams')
        .doc(userId)
        .update(teamData)
        .then((value) {
      print('Team updated successfully.');
      _showSnackBar('Team updated successfully', Colors.green);
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to update team: $error');
      _showSnackBar('Failed to updated team', Colors.red);
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image(image: AssetImage('assets/images/signinTopImage.png')),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Edit Team',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: uploadProfileImage,
                            child: _profileImageUrl != null
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.transparent,
                                    child: ClipOval(
                                      child: Image.network(
                                        _profileImageUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )

                                // CircleAvatar(
                                //     radius: 50,
                                //     backgroundImage: NetworkImage(
                                //       _profileImageUrl!,
                                //     ),
                                //   )
                                : Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Color(0xff6858FE),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                          child: Text('Pick Image',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: TextField(
                    //         controller: clubNameController,
                    //         decoration: InputDecoration(
                    //           filled: true,
                    //           hintText: 'Club Name',
                    //           fillColor: Color(0xffEEEEEE),
                    //           border: OutlineInputBorder(),
                    //           enabledBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //               width: 0.5,
                    //               color: Color(0xffEEEEEE),
                    //             ),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //               color: Color(0xffEEEEEE),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: teamNameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Team Name',
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: TextField(
                    //         controller: captainNameController,
                    //         decoration: InputDecoration(
                    //           filled: true,
                    //           hintText: 'Captain Name',
                    //           fillColor: Color(0xffEEEEEE),
                    //           border: OutlineInputBorder(),
                    //           enabledBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //               width: 0.5,
                    //               color: Color(0xffEEEEEE),
                    //             ),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //               color: Color(0xffEEEEEE),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: PhoneNumberController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Phone Number',
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Email',
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagLineController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Tagline',
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffEEEEEE),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 150,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Color(0xff6858FE))),
                      onPressed: () {
                        createTeam();
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(fontFamily: 'karla', fontSize: 18),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 20,
                  // ),
                  // Container(
                  //   width: 150,
                  //   child: ElevatedButton(
                  //     style: ButtonStyle(
                  //         backgroundColor:
                  //             MaterialStatePropertyAll(Color(0xffEEEEEE))),
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: Text(
                  //       'Cancel',
                  //       style: TextStyle(
                  //           fontSize: 18,
                  //           color: Colors.black,
                  //           fontFamily: 'karla'),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
