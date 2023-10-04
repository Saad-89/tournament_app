import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:user_app/screens/onBoarding/joinOrCreateTeam.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _skillController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _jerseyNoController;

  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _skillController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _jerseyNoController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _skillController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _jerseyNoController.dispose();
    super.dispose();
  }

  String? _selectedImage;
  String? _profileImageUrl;
  bool? _isLoading;
  bool? _isImagePicked;
  DateTime _selectedDate = DateTime.now();

  Future<void> _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        _dateOfBirthController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

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

  void createPlayerProfile() {
    final name = _nameController.text.trim();
    final skill = _skillController.text.trim();
    final dob = _dateOfBirthController.text.trim();
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    final jerseyNumber = _jerseyNoController.text.trim();

    List<String> emptyFields = [];
    if (name.isEmpty) emptyFields.add('Name');
    if (skill.isEmpty) emptyFields.add('Role');
    if (dob.isEmpty) emptyFields.add('DOB');
    if (height.isEmpty) emptyFields.add('Height');
    if (weight.isEmpty) emptyFields.add('Weight');
    if (jerseyNumber.isEmpty) emptyFields.add('Jersey Number');
    if (_profileImageUrl == null) emptyFields.add('Profile Image');

    if (emptyFields.isNotEmpty) {
      String errorMessage;
      if (emptyFields.length > 3) {
        errorMessage = 'Please fill in all fields';
      } else if (emptyFields.length == 1) {
        errorMessage = 'Please complete the ${emptyFields[0]} field';
      } else {
        errorMessage =
            'Please fill in or complete the following fields:\n${emptyFields.join(', ')}';
      }
      _showSnackBar(errorMessage, Colors.red);
      return;
    }

    // if (!_imageSelected) {
    //   _showSnackBar('Please select an image for the team', Colors.red);
    //   return;
    // }

    final playerData = {
      'name': name,
      'userId': userId,
      'dob': dob,
      'role': skill,
      'height': height,
      'weight': weight,
      'jerseyNo': jerseyNumber,
      'profileImageUrl': _profileImageUrl,
    };

    FirebaseFirestore.instance
        .collection('playerProfile')
        .doc(userId)
        .set(playerData)
        .then((value) {
      print('Profile created successfully.');
      _showSnackBar('Profile created successfully', Colors.green);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => JoinORcreateTeam()));
    }).catchError((error) {
      print('Failed to create profile: $error');
      _showSnackBar('Failed to create profile', Colors.red);
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
                  Text('Create Profile',
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
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                // CircleAvatar(
                                //     radius: 40,
                                //     backgroundImage:
                                //         NetworkImage(_profileImageUrl!),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Name',
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
                          child: GestureDetector(
                            onTap: () {
                              _showDatePicker(context);
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _dateOfBirthController,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: 'Date Of Birth',
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
                            controller: _heightController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Height',
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
                            controller: _weightController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Weight',
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
                            controller: _skillController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Role',
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
                            controller: _jerseyNoController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Jersey Numer',
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
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              backgroundColor:
                                  MaterialStatePropertyAll(Color(0xff6858FE))),
                          onPressed: () {
                            createPlayerProfile();
                          },
                          child: Text(
                            'Create',
                            style: TextStyle(fontFamily: 'karla', fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
