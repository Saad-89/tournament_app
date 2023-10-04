import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/screens/authScreens/signIn.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_app/screens/onBoarding/playerProfile.dart';
import '../../firbaseAuth/firebaseAuthService.dart';
import '../../main.dart';
import '../../util/notificationService.dart/notificationService.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _isChecked = false;
  String? name;
  String? telePhone;
  String? email;
  String? password;
  FirebaseService firebaseService = FirebaseService();

  Future<void> addUserToCaptainsCollection(String userId, String name) async {
    try {
      // Reference to the Firestore collection
      final captainsCollection =
          FirebaseFirestore.instance.collection('captains');

      // Create a document in the "captains" collection with the user's ID as the document ID
      await captainsCollection.doc(userId).set({
        'captainId': userId,
        'name': name,
        // Add other fields as needed
      });
    } catch (e) {
      // Handle any errors here
      print('Error adding user to Captains collection: $e');
    }
  }

  NotificationServices notificationServices = NotificationServices();

  void registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (!_isChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red,
            content: Text('Please check the Terms & Conditions.'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      print(name);

      try {
        String userId = await firebaseService.signUpWithEmailAndPassword(
          email!,
          password!,
        );

        if (userId.isNotEmpty) {
          print('User signed up successfully. User ID: $userId');
          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.setBool(MyAppState.KEYLOGIN, true);

          String deviceId = await notificationServices.getDeviceToken();

          // Add user information including "teamNCondition"
          await firebaseService.storeUserInfo(
              userId, name!, email!, telePhone!, _isChecked, deviceId);

          // Add the user to the "Captains" collection
          await addUserToCaptainsCollection(userId, name!);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerProfileScreen(),
            ),
          );
        } else {
          print('Failed to sign up the user.');
        }
      } catch (e) {
        print('An error occurred during sign up: $e');
        // Handle the error here, e.g., show an error dialog
      } finally {
        // const snackBar = SnackBar(
        //   content: Text('The email address is already exist!'),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment
                    .start, // Aligns children to the start of the column
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Stretches children horizontally
                children: [
                  Image.asset(
                    'assets/images/signupTopImage.png',
                    width: MediaQuery.of(context).size.width,

                    fit: BoxFit
                        .cover, // Fill the width, may crop some parts if the aspect ratio doesn't match
                  ),
                ],
              ),
              Container(
                width: 500,
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontFamily: 'karla',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 5),
                      TextFormField(
                        onChanged: (value) {
                          name = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 166, 167, 172),
                          ),
                          filled: true,
                          fillColor: Color(0xffD9D9D9),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 0.5,
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        onChanged: (value) {
                          telePhone = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone Number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Phonenumber',
                          prefixIcon: Icon(
                            Icons.phone,
                            color: Color.fromARGB(255, 166, 167, 172),
                          ),
                          filled: true,
                          fillColor: Color(0xffD9D9D9),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 0.5,
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        onChanged: (value) {
                          email = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color.fromARGB(255, 166, 167, 172),
                          ),
                          filled: true,
                          fillColor: Color(0xffD9D9D9),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 0.5,
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        onChanged: (value) {
                          password = value;
                        },
                        obscureText: !_passwordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color.fromARGB(255, 166, 167, 172),
                          ),
                          filled: true,
                          fillColor: Color(0xffD9D9D9),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 0.5,
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xffD9D9D9),
                            ),
                          ),
                          suffixIcon: Theme(
                            data: Theme.of(context).copyWith(
                              hoverColor: Colors
                                  .transparent, // Adjust the hover effect color
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color.fromARGB(255, 166, 167, 172),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: Color(0xffFEAF3E),
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          Text(
                            "I agree to the ",
                            style: TextStyle(fontFamily: 'karla', fontSize: 14),
                          ),
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                                color: Color(0xffFEAF3E),
                                fontFamily: 'karla',
                                fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        height: 50,
                        width: 340,
                        decoration: BoxDecoration(
                          color: Color(0xff6555FE),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Color(0xff6555FE),
                            ),
                            shape: MaterialStateProperty.all(
                              // Applying shape to ElevatedButton
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Matching border radius
                              ),
                            ),
                          ),
                          onPressed: () async {
                            registerUser();
                          },
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'karla',
                                      fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/groupImg.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    children: [
                      Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account! ',
                            style: TextStyle(fontFamily: 'karla', fontSize: 15),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => SignInScreen())));
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  fontFamily: 'karla',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xffFEAF3E)),
                            ),
                          )
                        ],
                      )),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}







 // if (_formKey.currentState!.validate()) {
                            //   // Form is valid, handle sign up logic here

                            //   setState(() {
                            //     _isLoading = true;
                            //   });

                            //   print(name);

                            //   try {
                            //     String userId = await firebaseService
                            //         .signUpWithEmailAndPassword(
                            //             email!, password!);

                            //     if (userId.isNotEmpty) {
                            //       print(
                            //           'User signed up successfully. User ID: $userId');
                            //       await firebaseService.storeUserInfo(
                            //           userId, name!, email!, telePhone!);
                            //       Navigator.pushReplacement(
                            //           context,
                            //           MaterialPageRoute(
                            //               builder: (context) =>
                            //                   SignInScreen()));

                            //       // setState(() {
                            //       //   _isLoading = false;
                            //       // });
                            //     } else {
                            //       print('Failed to sign up the user.');
                            //     }
                            //   } catch (e) {
                            //     print('An error occurred during sign up: $e');
                            //     // Handle the error here, e.g., show an error dialog
                            //   } finally {
                            //     const snackBar = SnackBar(
                            //       content: Text(
                            //           'The email address is already exist!'),
                            //     );
                            //     ScaffoldMessenger.of(context)
                            //         .showSnackBar(snackBar);
                            //     setState(() {
                            //       _isLoading = false;
                            //     });
                            //   }
                            // }