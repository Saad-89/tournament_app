// import 'package:flutter/material.dart';
// import 'package:user_app/screens/authScreens/signUp.dart';

// class GettingStartedScreen extends StatefulWidget {
//   GettingStartedScreen({super.key});

//   @override
//   State<GettingStartedScreen> createState() => _GettingStartedScreenState();
// }

// class _GettingStartedScreenState extends State<GettingStartedScreen> {
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Color(0xffFEAF3E),
//         body: Container(
//           width: MediaQuery.of(context).size.width,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment
//                 .spaceBetween, // Distributes space between children
//             children: [
//               Image.asset(
//                 'assets/images/gettingStarted.png',
//                 width: MediaQuery.of(context).size.width,
//                 fit: BoxFit.cover,
//               ),
//               Image.asset(
//                 'assets/images/startedScreenPic.png',
//                 fit: BoxFit.cover,
//               ),
//               Container(
//                 width: 300,
//                 height: 50,
//                 margin: EdgeInsets.only(
//                     bottom: 20), // Add margin for space at the bottom
//                 decoration: BoxDecoration(
//                     color: Color(0xff6555FE),
//                     borderRadius: BorderRadius.circular(15)),
//                 child: ElevatedButton(
//                     style: ButtonStyle(
//                         shape: MaterialStatePropertyAll(RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15))),
//                         backgroundColor:
//                             MaterialStatePropertyAll(Color(0xff6555FE))),
//                     onPressed: () async {
//                       setState(() {
//                         _isLoading = true;
//                       });
//                       await Future.delayed(Duration(seconds: 1));
//                       Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: ((context) => SignUpScreen())));
//                       setState(() {
//                         _isLoading = false;
//                       });
//                     },
//                     child: Text(
//                       'Get Started',
//                       style: TextStyle(fontFamily: 'karla', fontSize: 20),
//                     )),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:user_app/screens/authScreens/signUp.dart';

class GettingStartedScreen extends StatefulWidget {
  GettingStartedScreen({super.key});

  @override
  State<GettingStartedScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffFEAF3E),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/gettingStarted.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Image.asset(
                'assets/images/startedScreenPic.png',
                fit: BoxFit.cover,
              ),
              Container(
                width: 300,
                height: 50,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Color(0xff6555FE),
                    borderRadius: BorderRadius.circular(15)),
                child: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xff6555FE))),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await Future.delayed(Duration(seconds: 2));
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => SignUpScreen())));
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Get Started',
                            style: TextStyle(fontFamily: 'karla', fontSize: 20),
                          )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
