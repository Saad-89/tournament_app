import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPaswordScreen extends StatefulWidget {
  const ForgetPaswordScreen({super.key});

  @override
  State<ForgetPaswordScreen> createState() => _ForgetPaswordScreenState();
}

class _ForgetPaswordScreenState extends State<ForgetPaswordScreen> {
  String? email;
  bool isLoading = false;

  Future passwordReset() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('password reset email sent check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff6555FE),
        title: Text(
          'Reset Password',
          style: TextStyle(
              fontFamily: 'karla', fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email and we will send you a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'karla',
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
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
                hintText: 'Enter your email',
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
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xff6555FE),
              ),
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Color(0xff6555FE),
                      ),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  onPressed: isLoading
                      ? null
                      : () {
                          passwordReset();
                        },
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text(
                          'Submit',
                          style: TextStyle(
                            fontFamily: 'karla',
                            fontSize: 18,
                          ),
                        )

                  // Text(
                  //   'Submit',
                  //   style: TextStyle(
                  //     fontFamily: 'karla',
                  //     fontSize: 18,
                  //   ),
                  // ),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
