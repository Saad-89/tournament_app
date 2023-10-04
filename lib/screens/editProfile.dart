// // import 'package:flutter/material.dart';
// // import 'package:user_app/screens/authScreens/signIn.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import '../../firbaseAuth/firebaseAuthService.dart';

// // class EditProfile extends StatefulWidget {
// //   const EditProfile({Key? key}) : super(key: key);

// //   @override
// //   _EditProfileState createState() => _EditProfileState();
// // }

// // class _EditProfileState extends State<EditProfile> {
// //   final _formKey = GlobalKey<FormState>();
// //   bool _isLoading = false;
// //   bool _passwordVisible = false;
// //   bool _isChecked = false;
// //   String? name;
// //   String? telePhone;
// //   String? email;
// //   String? password;
// //   FirebaseService firebaseService = FirebaseService();

// //   @override
// //   Widget build(BuildContext context) {
// //     return SafeArea(
// //       child: Scaffold(
// //         body: SingleChildScrollView(
// //           physics: BouncingScrollPhysics(),
// //           child: Column(
// //             children: [
// //               Column(
// //                 mainAxisAlignment: MainAxisAlignment
// //                     .start, // Aligns children to the start of the column
// //                 crossAxisAlignment: CrossAxisAlignment
// //                     .stretch, // Stretches children horizontally
// //                 children: [
// //                   Image.asset(
// //                     'assets/images/signupTopImage.png',
// //                     width: MediaQuery.of(context).size.width,

// //                     fit: BoxFit
// //                         .cover, // Fill the width, may crop some parts if the aspect ratio doesn't match
// //                   ),
// //                 ],
// //               ),
// //               // SizedBox(
// //               //   height: 10,
// //               // ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.start,
// //                 children: [
// //                   IconButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                       },
// //                       icon: Icon(Icons.arrow_back)),
// //                 ],
// //               ),
// //               Container(
// //                 width: 500,
// //                 padding: const EdgeInsets.symmetric(horizontal: 20),
// //                 child: Form(
// //                   key: _formKey,
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       const Text(
// //                         'Edit Profile',
// //                         style: TextStyle(
// //                           fontSize: 30,
// //                           color: Colors.black,
// //                           fontFamily: 'karla',
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       const SizedBox(height: 5),
// //                       TextFormField(
// //                         onChanged: (value) {
// //                           name = value;
// //                         },
// //                         validator: (value) {
// //                           if (value == null || value.isEmpty) {
// //                             return 'Please enter your name';
// //                           }
// //                           return null;
// //                         },
// //                         decoration: InputDecoration(
// //                           hintText: 'Username',
// //                           prefixIcon: Icon(
// //                             Icons.person,
// //                             color: Color.fromARGB(255, 166, 167, 172),
// //                           ),
// //                           filled: true,
// //                           fillColor: Color(0xffD9D9D9),
// //                           border: OutlineInputBorder(),
// //                           enabledBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                             borderSide: BorderSide(
// //                               width: 0.5,
// //                               color: Color(0xffD9D9D9),
// //                             ),
// //                           ),
// //                           focusedBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                             borderSide: BorderSide(
// //                               color: Color(0xffD9D9D9),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 15),
// //                       TextFormField(
// //                         onChanged: (value) {
// //                           telePhone = value;
// //                         },
// //                         validator: (value) {
// //                           if (value == null || value.isEmpty) {
// //                             return 'Please enter your phone Number';
// //                           }
// //                           return null;
// //                         },
// //                         decoration: InputDecoration(
// //                           hintText: 'Phonenumber',
// //                           prefixIcon: Icon(
// //                             Icons.phone,
// //                             color: Color.fromARGB(255, 166, 167, 172),
// //                           ),
// //                           filled: true,
// //                           fillColor: Color(0xffD9D9D9),
// //                           border: OutlineInputBorder(),
// //                           enabledBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                             borderSide: BorderSide(
// //                               width: 0.5,
// //                               color: Color(0xffD9D9D9),
// //                             ),
// //                           ),
// //                           focusedBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                             borderSide: BorderSide(
// //                               color: Color(0xffD9D9D9),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 15),
// //                       TextFormField(
// //                         onChanged: (value) {
// //                           email = value;
// //                         },
// //                         validator: (value) {
// //                           if (value == null || value.isEmpty) {
// //                             return 'Please enter your email';
// //                           }
// //                           return null;
// //                         },
// //                         decoration: InputDecoration(
// //                           hintText: 'Email',
// //                           prefixIcon: Icon(
// //                             Icons.email,
// //                             color: Color.fromARGB(255, 166, 167, 172),
// //                           ),
// //                           filled: true,
// //                           fillColor: Color(0xffD9D9D9),
// //                           border: OutlineInputBorder(),
// //                           enabledBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                             borderSide: BorderSide(
// //                               width: 0.5,
// //                               color: Color(0xffD9D9D9),
// //                             ),
// //                           ),
// //                           focusedBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                             borderSide: BorderSide(
// //                               color: Color(0xffD9D9D9),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 15),
// //                       TextFormField(
// //                         onChanged: (value) {
// //                           password = value;
// //                         },
// //                         obscureText: !_passwordVisible,
// //                         validator: (value) {
// //                           if (value == null || value.isEmpty) {
// //                             return 'Please enter your password';
// //                           }
// //                           return null;
// //                         },
// // decoration: InputDecoration(
// //   hintText: 'Password',
// //   prefixIcon: Icon(
// //     Icons.lock,
// //     color: Color.fromARGB(255, 166, 167, 172),
// //   ),
// //   filled: true,
// //   fillColor: Color(0xffD9D9D9),
// //   border: OutlineInputBorder(),
// //   enabledBorder: OutlineInputBorder(
// //     borderRadius: BorderRadius.circular(10),
// //     borderSide: BorderSide(
// //       width: 0.5,
// //       color: Color(0xffD9D9D9),
// //     ),
// //   ),
// //   focusedBorder: OutlineInputBorder(
// //     borderRadius: BorderRadius.circular(10),
// //     borderSide: BorderSide(
// //       color: Color(0xffD9D9D9),
// //     ),
// //   ),
// //                           suffixIcon: Theme(
// //                             data: Theme.of(context).copyWith(
// //                               hoverColor: Colors
// //                                   .transparent, // Adjust the hover effect color
// //                             ),
// //                             child: IconButton(
// //                               onPressed: () {
// //                                 setState(() {
// //                                   _passwordVisible = !_passwordVisible;
// //                                 });
// //                               },
// //                               icon: Icon(
// //                                 _passwordVisible
// //                                     ? Icons.visibility
// //                                     : Icons.visibility_off,
// //                                 color: Color.fromARGB(255, 166, 167, 172),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       Row(
// //                         children: [
// //                           Checkbox(
// //                             checkColor: Colors.white,
// //                             activeColor: Color(0xffFEAF3E),
// //                             shape: ContinuousRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(10)),
// //                             value: _isChecked,
// //                             onChanged: (bool? value) {
// //                               setState(() {
// //                                 _isChecked = value!;
// //                               });
// //                             },
// //                           ),
// //                           Text(
// //                             "I agree to the ",
// //                             style: TextStyle(fontFamily: 'karla', fontSize: 14),
// //                           ),
// //                           Text(
// //                             'Terms & Conditions',
// //                             style: TextStyle(
// //                                 color: Color(0xffFEAF3E),
// //                                 fontFamily: 'karla',
// //                                 fontSize: 14),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 30),
// //                       Container(
// //                         height: 50,
// //                         width: 340,
// //                         decoration: BoxDecoration(
// //                           color: Color(0xff6555FE),
// //                           borderRadius: BorderRadius.circular(15),
// //                         ),
// //                         child: ElevatedButton(
// //                           style: ButtonStyle(
// //                             backgroundColor: MaterialStateProperty.all(
// //                               Color(0xff6555FE),
// //                             ),
// //                             shape: MaterialStateProperty.all(
// //                               // Applying shape to ElevatedButton
// //                               RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(
// //                                     15), // Matching border radius
// //                               ),
// //                             ),
// //                           ),
// //                           onPressed: () async {
// //                             if (_formKey.currentState!.validate()) {
// //                               // Form is valid, handle sign up logic here

// //                               setState(() {
// //                                 _isLoading = true;
// //                               });

// //                               print(name);

// //                               try {
// //                                 String userId = await firebaseService
// //                                     .signUpWithEmailAndPassword(
// //                                         email!, password!);

// //                                 if (userId.isNotEmpty) {
// //                                   print(
// //                                       'User signed up successfully. User ID: $userId');
// //                                   await firebaseService.storeUserInfo(
// //                                       userId, name!, email!, telePhone!);
// //                                   Navigator.pushReplacement(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               SignInScreen()));

// //                                   // setState(() {
// //                                   //   _isLoading = false;
// //                                   // });
// //                                 } else {
// //                                   print('Failed to sign up the user.');
// //                                 }
// //                               } catch (e) {
// //                                 print('An error occurred during sign up: $e');
// //                                 // Handle the error here, e.g., show an error dialog
// //                               } finally {
// //                                 const snackBar = SnackBar(
// //                                   content: Text(
// //                                       'The email address is already exist!'),
// //                                 );
// //                                 ScaffoldMessenger.of(context)
// //                                     .showSnackBar(snackBar);
// //                                 setState(() {
// //                                   _isLoading = false;
// //                                 });
// //                               }
// //                             }
// //                           },
// //                           child: _isLoading
// //                               ? Center(
// //                                   child: CircularProgressIndicator(
// //                                     valueColor: AlwaysStoppedAnimation<Color>(
// //                                         Colors.white),
// //                                   ),
// //                                 )
// //                               : Text(
// //                                   'Submit',
// //                                   style: TextStyle(
// //                                       fontWeight: FontWeight.w600,
// //                                       fontFamily: 'karla',
// //                                       fontSize: 16),
// //                                 ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 10),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(
// //                 height: 50,
// //               ),
// //               Stack(
// //                 children: [
// //                   Image.asset(
// //                     'assets/images/groupImg.png',
// //                     width: MediaQuery.of(context).size.width,
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EditProfile extends StatefulWidget {
//   const EditProfile({Key? key}) : super(key: key);

//   @override
//   _EditProfileState createState() => _EditProfileState();
// }

// class _EditProfileState extends State<EditProfile> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _passwordVisible = false;
//   bool _isChecked = false;
//   String? name;
//   String? telePhone;
//   String? email;
//   String? password;

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUserData();
//   }

//   _loadCurrentUserData() async {
//     final currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       final DocumentSnapshot userData =
//           await _firestore.collection('users').doc(currentUser.uid).get();
//       Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
//       setState(() {
//         name = data['name'];
//         telePhone = data['telePhone'];
//         email = data['email'];
//       });
//     }
//   }

//   Future<void> _updateUserData() async {
//     final currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       await _firestore.collection('playerProfile').doc(currentUser.uid).update({
//         'name': name,
//         'telePhone': telePhone,
//         'email': email,
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Column(
//             children: [
//               Image.asset('assets/images/signupTopImage.png',
//                   width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   IconButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       icon: Icon(Icons.arrow_back))
//                 ],
//               ),
//               Container(
//                 width: 500,
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text('Edit Profile',
//                           style: TextStyle(
//                               fontSize: 30,
//                               color: Colors.black,
//                               fontFamily: 'karla',
//                               fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         initialValue: name,
//                         onChanged: (value) {
//                           name = value;
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your name';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'username',
//                           prefixIcon: Icon(
//                             Icons.lock,
//                             color: Color.fromARGB(255, 166, 167, 172),
//                           ),
//                           filled: true,
//                           fillColor: Color(0xffD9D9D9),
//                           border: OutlineInputBorder(),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               width: 0.5,
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       TextFormField(
//                         initialValue: telePhone,
//                         onChanged: (value) {
//                           telePhone = value;
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your phone Number';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'phone number',
//                           prefixIcon: Icon(
//                             Icons.lock,
//                             color: Color.fromARGB(255, 166, 167, 172),
//                           ),
//                           filled: true,
//                           fillColor: Color(0xffD9D9D9),
//                           border: OutlineInputBorder(),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               width: 0.5,
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       TextFormField(
//                         initialValue: email,
//                         onChanged: (value) {
//                           email = value;
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'eamil',
//                           prefixIcon: Icon(
//                             Icons.lock,
//                             color: Color.fromARGB(255, 166, 167, 172),
//                           ),
//                           filled: true,
//                           fillColor: Color(0xffD9D9D9),
//                           border: OutlineInputBorder(),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               width: 0.5,
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       TextFormField(
//                         onChanged: (value) {
//                           password = value;
//                         },
//                         obscureText: !_passwordVisible,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Password',
//                           filled: true,
//                           fillColor: Color(0xffD9D9D9),
//                           border: OutlineInputBorder(),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               width: 0.5,
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: Color(0xffD9D9D9),
//                             ),
//                           ),
//                           prefixIcon: Icon(
//                             Icons.lock,
//                             color: Color.fromARGB(255, 166, 167, 172),
//                           ),
//                           suffixIcon: IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 _passwordVisible = !_passwordVisible;
//                               });
//                             },
//                             icon: Icon(
//                                 _passwordVisible
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 color: Color.fromARGB(255, 166, 167, 172)),
//                           ),
//                         ),
//                       ),
//                       // Row(
//                       //   children: [
//                       //     Checkbox(
//                       //       checkColor: Colors.white,
//                       //       activeColor: Color(0xffFEAF3E),
//                       //       shape: ContinuousRectangleBorder(
//                       //           borderRadius: BorderRadius.circular(10)),
//                       //       value: _isChecked,
//                       //       onChanged: (bool? value) {
//                       //         setState(() {
//                       //           _isChecked = value!;
//                       //         });
//                       //       },
//                       //     ),
//                       //     Text("I agree to the ",
//                       //         style:
//                       //             TextStyle(fontFamily: 'karla', fontSize: 14)),
//                       //     Text('Terms & Conditions',
//                       //         style: TextStyle(
//                       //             color: Color(0xffFEAF3E),
//                       //             fontFamily: 'karla',
//                       //             fontSize: 14)),
//                       //   ],
//                       // ),
//                       const SizedBox(height: 50),
//                       Container(
//                         height: 50,
//                         width: 340,
//                         decoration: BoxDecoration(
//                           color: Color(0xff6555FE),
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: ElevatedButton(
//                           style: ButtonStyle(
//                               shape: MaterialStatePropertyAll(
//                                   RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(15))),
//                               backgroundColor:
//                                   MaterialStatePropertyAll(Color(0xff6555FE))),
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               setState(() {
//                                 _isLoading = true;
//                               });
//                               try {
//                                 await _updateUserData();
//                                 Navigator.pop(context);
//                               } catch (e) {
//                                 print(e);
//                               } finally {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                         content: Text(
//                                             'Profile updated successfully!')));
//                                 setState(() {
//                                   _isLoading = false;
//                                 });
//                               }
//                             }
//                           },
//                           child: _isLoading
//                               ? CircularProgressIndicator(
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white))
//                               : Text(
//                                   'Submit',
//                                   style: TextStyle(fontSize: 18),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 70,
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Column(
//                   children: [
//                     Image.asset(
//                       'assets/images/groupImg.png',
//                       width: MediaQuery.of(context).size.width,
//                       fit: BoxFit.cover,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:user_app/screens/onBoarding/joinOrCreateTeam.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userProfileData;
  const EditProfile({super.key, required this.userProfileData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
    _nameController =
        TextEditingController(text: widget.userProfileData['name'] ?? '');
    _dateOfBirthController =
        TextEditingController(text: widget.userProfileData['dob'] ?? '');
    _skillController =
        TextEditingController(text: widget.userProfileData['role'] ?? '');
    _heightController =
        TextEditingController(text: widget.userProfileData['height'] ?? '');
    _weightController =
        TextEditingController(text: widget.userProfileData['weight'] ?? '');
    _jerseyNoController =
        TextEditingController(text: widget.userProfileData['jerseyNo'] ?? '');
    _profileImageUrl = widget.userProfileData['profileImageUrl'];
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

  // void createPlayerProfile() {
  //   final name = _nameController.text.trim();
  //   final skill = _skillController.text.trim();
  //   final dob = _dateOfBirthController.text.trim();
  //   final height = _heightController.text.trim();
  //   final weight = _weightController.text.trim();
  //   final jerseyNumber = _jerseyNoController.text.trim();

  //   List<String> emptyFields = [];
  //   if (name.isEmpty) emptyFields.add('Name');
  //   if (skill.isEmpty) emptyFields.add('Role');
  //   if (dob.isEmpty) emptyFields.add('DOB');
  //   if (height.isEmpty) emptyFields.add('Height');
  //   if (weight.isEmpty) emptyFields.add('Weight');
  //   if (jerseyNumber.isEmpty) emptyFields.add('Jersey Number');
  //   if (_profileImageUrl == null) emptyFields.add('Profile Image');

  //   if (emptyFields.isNotEmpty) {
  //     String errorMessage;
  //     if (emptyFields.length > 3) {
  //       errorMessage = 'Please fill in all fields';
  //     } else if (emptyFields.length == 1) {
  //       errorMessage = 'Please complete the ${emptyFields[0]} field';
  //     } else {
  //       errorMessage =
  //           'Please fill in or complete the following fields:\n${emptyFields.join(', ')}';
  //     }
  //     _showSnackBar(errorMessage, Colors.red);
  //     return;
  //   }

  //   // if (!_imageSelected) {
  //   //   _showSnackBar('Please select an image for the team', Colors.red);
  //   //   return;
  //   // }

  //   final playerData = {
  //     'name': name,
  //     'userId': userId,
  //     'dob': dob,
  //     'role': skill,
  //     'height': height,
  //     'weight': weight,
  //     'jerseyNo': jerseyNumber,
  //     'profileImageUrl': _profileImageUrl,
  //   };

  //   FirebaseFirestore.instance
  //       .collection('playerProfile')
  //       .doc(userId)
  //       .set(playerData)
  //       .then((value) {
  //     print('Profile created successfully.');
  //     _showSnackBar('Profile created successfully', Colors.green);
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => JoinORcreateTeam()));
  //   }).catchError((error) {
  //     print('Failed to create profile: $error');
  //     _showSnackBar('Failed to create profile', Colors.red);
  //   });
  // }

  void createPlayerProfile() {
    final name = _nameController.text.trim();
    final skill = _skillController.text.trim();
    final dob = _dateOfBirthController.text.trim();
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    final jerseyNumber = _jerseyNoController.text.trim();

    // Check for empty fields and handle them

    final playerData = {
      'name': name,
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
        .update(playerData) // Use update instead of set to update existing data
        .then((value) {
      print('Profile updated successfully.');
      _showSnackBar('Profile updated successfully', Colors.green);
      // Handle navigation or other actions after updating profile
    }).catchError((error) {
      print('Failed to update profile: $error');
      _showSnackBar('Failed to update profile', Colors.red);
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
                  Text('Edit Profile',
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
                            'Update',
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
