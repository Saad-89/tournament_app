import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/main.dart';
import 'package:user_app/screens/authScreens/signUp.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../firbaseAuth/firebaseAuthService.dart';
import '../../util/bottomNavigational.dart';
import '../home.dart';
import 'forgetPasswordPage.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _passwordVisible = false;

  String? email;
  String? password;
  FirebaseService firebaseService = FirebaseService();
  // SessionManager usersession = SessionManager();

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String userId =
          await firebaseService.signInWithEmailAndPassword(email!, password!);
      if (userId.isNotEmpty) {
        // Check if the user is an user

        bool isUser = await firebaseService.checkUserRole(userId);
        if (isUser) {
          print('user signed in successfully. User ID: $userId');
          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.setBool(MyAppState.KEYLOGIN, true);
          // await UserSession.storeUserSession(userId);
          // await SessionManager.saveUserSession(userId);
          // Proceed with user-specific actions'Navigator
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BottomNavigationalBar()));
          // Navigator.push(
          //     context, MaterialPageRoute(builder: ((context) => HomeScreen())));
        } else {
          print('User is not a user.');
          // Display appropriate message or take necessary actions for non-user users
        }
      } else {
        print('Failed to sign in the user.');
        const snackBar = SnackBar(
          content: Text('Please enter correct email or password!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/images/signinTopImage.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Image.asset(
                        'assets/images/startedScreenPic.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontFamily: 'karla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            hintText: 'Username',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 166, 167, 172),
                            ),
                            prefixIconColor: Color(0xffFEAF3E),
                            filled: true,
                            fillColor: Color(0xffD9D9D9),
                            counterStyle: TextStyle(),
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
                            hintText: 'password',
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
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            ForgetPaswordScreen())));
                              },
                              child: Text(
                                'Forget Password?',
                                style: TextStyle(
                                    fontFamily: 'karla',
                                    fontSize: 16,
                                    color: Color(0xffFEAF3E)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          height: 50,
                          width: 350,
                          decoration: BoxDecoration(
                            color: Color(0xff6555FE),
                            borderRadius: BorderRadius.circular(
                                15), // Increased border radius
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xff6555FE)),
                              shape: MaterialStateProperty.all(
                                // Applying shape to ElevatedButton
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15), // Matching border radius
                                ),
                              ),
                            ),
                            onPressed: () async {
                              await _handleSignIn();
                            },
                            child: _isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Log In',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'karla',
                                        fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22.058),
                      ],
                    ),
                  ),
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
                                "New User? ",
                                style: TextStyle(
                                    fontFamily: 'karla', fontSize: 15),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              SignUpScreen())));
                                },
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontFamily: 'karla',
                                      fontSize: 16,
                                      color: Color(0xffFEAF3E)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
                // SizedBox(
                //   height: 20,
                // ),
                //  Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       "New User? ",
                //       style: TextStyle(fontFamily: 'karla', fontSize: 15),
                //     ),
                //     InkWell(
                //       onTap: () {
                //         Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //                 builder: ((context) => SignUpScreen())));
                //       },
                //       child: Text(
                //         'Create Account',
                //         style: TextStyle(
                //             fontFamily: 'karla',
                //             fontSize: 16,
                //             color: Color(0xffFEAF3E)),
                //       ),
                //     )
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment
//               .start, // Aligns children to the start of the column
//           crossAxisAlignment:
//               CrossAxisAlignment.stretch, // Stretches children horizontally
//           children: [
//             Image.asset(
//               'assets/images/Group.png',
//               width: MediaQuery.of(context).size.width,
//               fit: BoxFit
//                   .cover, // Fill the width, may crop some parts if the aspect ratio doesn't match
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';

// void main() => runApp(MaterialApp(home: SignInScreen()));

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({Key? key}) : super(key: key);

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             Container(
//               width: 360,
//               height: 358,
//               child: Stack(
//                 children: [
//                   CustomPaint(
//                     size: Size(360, 358),
//                     painter: CustomSVGPainter(),
//                   ),
//                   Positioned(
//                     top: 0,
//                     right:
//                         0, // Adjust this value as needed to push the image more to the right
//                     child: Image.asset(
//                       'assets/images/Frame.png',
//                     ),
//                   ),

//                   // Positioned.fill(
//                   //   top: 0,
//                   //   right: 0,
//                   //   child: Image.asset(
//                   //     'assets/images/Frame.png',
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CustomSVGPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint mainShapePaint = Paint()..color = Color(0xffFEAF3E);
//     final Paint rectPaint = Paint()..color = Color(0xff8FCA7C);

//     // Main irregular shape
//     Path mainShape = Path()
//       ..moveTo(-24.7675, 93.7822)
//       ..cubicTo(-42.2171, 80.2345, -44.1787, 56.127, -29.1488, 39.9364)
//       ..lineTo(145.435, -148.13)
//       ..cubicTo(160.465, -164.32, 186.795, -166.462, 204.245, -152.915)
//       ..lineTo(512.042, 86.0561)
//       ..cubicTo(529.492, 99.6038, 531.453, 123.711, 516.423, 139.902)
//       ..lineTo(341.839, 327.968)
//       ..cubicTo(326.809, 344.158, 300.479, 346.301, 283.03, 332.753)
//       ..lineTo(-24.7675, 93.7822)
//       ..close();

//     canvas.drawPath(mainShape, mainShapePaint);

//     // Rectangle
//     Path rect = Path()
//       ..addRRect(RRect.fromRectAndRadius(
//         Rect.fromLTWH(0, 0, 22.4134, 342.9),
//         Radius.circular(11.2067),
//       ));

//     // Transforming the rectangle as per the SVG matrix transform
//     rect = rect.transform(Matrix4(
//       0.68035,
//       -0.732888,
//       0,
//       0,
//       0.789883,
//       0.613258,
//       0,
//       0,
//       0,
//       0,
//       1,
//       0,
//       -16.4039,
//       140.346,
//       0,
//       1,
//     ).storage);

//     canvas.drawPath(rect, rectPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }


// import 'package:flutter/material.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({Key? key}) : super(key: key);

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             CustomPaint(
//               size: Size(360, 358),
//               painter: CustomSVGPainter(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CustomSVGPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint mainShapePaint = Paint()..color = Color(0xffFEAF3E);
//     final Paint rectPaint = Paint()..color = Color(0xff8FCA7C);

//     // Main irregular shape
//     Path mainShape = Path()
//       ..moveTo(-24.7675, 93.7822)
//       ..cubicTo(-42.2171, 80.2345, -44.1787, 56.127, -29.1488, 39.9364)
//       ..lineTo(145.435, -148.13)
//       ..cubicTo(160.465, -164.32, 186.795, -166.462, 204.245, -152.915)
//       ..lineTo(512.042, 86.0561)
//       ..cubicTo(529.492, 99.6038, 531.453, 123.711, 516.423, 139.902)
//       ..lineTo(341.839, 327.968)
//       ..cubicTo(326.809, 344.158, 300.479, 346.301, 283.03, 332.753)
//       ..lineTo(-24.7675, 93.7822)
//       ..close();

//     canvas.drawPath(mainShape, mainShapePaint);

//     // Rectangle
//     Path rect = Path()
//       ..addRRect(RRect.fromRectAndRadius(
//         Rect.fromLTWH(0, 0, 22.4134, 342.9),
//         Radius.circular(11.2067),
//       ));

//     // Transforming the rectangle as per the SVG matrix transform
//     rect = rect.transform(Matrix4(
//       0.68035,
//       -0.732888,
//       0,
//       0,
//       0.789883,
//       0.613258,
//       0,
//       0,
//       0,
//       0,
//       1,
//       0,
//       -16.4039,
//       140.346,
//       0,
//       1,
//     ).storage);

//     canvas.drawPath(rect, rectPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
