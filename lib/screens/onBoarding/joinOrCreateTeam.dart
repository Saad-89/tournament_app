import 'package:flutter/material.dart';
import 'package:user_app/screens/addNewTeam.dart';
import 'package:user_app/screens/home.dart';
import 'package:user_app/screens/onBoarding/joinTeams.dart';

import '../../util/bottomNavigational.dart';
import '../seeAll/teamScreen.dart';

class JoinORcreateTeam extends StatefulWidget {
  JoinORcreateTeam({super.key});

  @override
  State<JoinORcreateTeam> createState() => _JoinORcreateTeamState();
}

class _JoinORcreateTeamState extends State<JoinORcreateTeam> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Image(image: AssetImage('assets/images/signinTopImage.png')),
            Column(
              children: [
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
                    Text('Join OR Create New Team',
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'karla',
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                SizedBox(
                  height: 200,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 340,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green[400]),
                          shape: MaterialStateProperty.all(
                            // Applying shape to ElevatedButton
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // Matching border radius
                            ),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          Future.delayed(Duration(seconds: 1));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => joinTeams()));
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Join Team',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'karla',
                                    fontSize: 16),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'OR',
                      style: TextStyle(
                          fontFamily: 'karla',
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 50,
                      width: 340,
                      decoration: BoxDecoration(
                        color: Colors.amber[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.amber[300],
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNewTeam()));
                        },
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Create New Team',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'karla',
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  'you can continue without joining or creating team',
                  style: TextStyle(
                      fontFamily: 'karla',
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 8,
                ),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavigationalBar()));
                    },
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'karla',
                                fontSize: 16),
                          ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
