import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_app/screens/editProfile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Get the current user
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Text('User not signed in');
    }

    // Create a reference to the playerProfile collection
    CollectionReference profiles =
        FirebaseFirestore.instance.collection('playerProfile');

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Column(
            children: [
              Image(image: AssetImage('assets/images/signupTopImage.png')),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: FutureBuilder<DocumentSnapshot>(
                  future: profiles.doc(user!.uid).get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return Column(
                        children: [
                          Row(
                            children: [
                              // Check if the image URL exists before trying to use it.
                              if (data.containsKey('profileImageUrl') &&
                                  data['profileImageUrl'] != null)
                                // Image.network(data['profileImageUrl']),
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(data['profileImageUrl']),
                                  radius: 60,
                                ),
                              SizedBox(width: 20),
                              // Check if the name exists before trying to use it.
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data.containsKey('name') &&
                                      data['name'] != null)
                                    Text(
                                      data['name'],
                                      style: TextStyle(
                                          fontFamily: 'karla',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Welcome To Tournament App',
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_border_outlined,
                                      color: Color(0xffFEAF3E),
                                      size: 40,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    if (data.containsKey('role') &&
                                        data['role'] != null)
                                      Text(
                                        data['role'],
                                        style: TextStyle(
                                            fontFamily: 'karla',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.height_outlined,
                                      color: Color(0xffFEAF3E),
                                      size: 40,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    if (data.containsKey('height') &&
                                        data['height'] != null)
                                      Text(
                                        ('${data['height']} cm'),
                                        style: TextStyle(
                                            fontFamily: 'karla',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_2,
                                      color: Color(0xffFEAF3E),
                                      size: 40,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    if (data.containsKey('jerseyNo') &&
                                        data['jerseyNo'] != null)
                                      Text(
                                        ('${data['jerseyNo']}'),
                                        style: TextStyle(
                                            fontFamily: 'karla',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
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
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.deepPurpleAccent)),
                                    onPressed: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  EditProfile(
                                                    userProfileData: data,
                                                  ))));
                                    },
                                    child: Text(
                                      'Edit Profile',
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
                        ],
                      );
                    }

                    // Display a progress indicator while waiting for the data
                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                    ));
                  },
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5.0,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color(0xffFEAF3E))),
                                onPressed: () {
                                  // Handle button click
                                },
                                child: Text(
                                  "Last week",
                                  style: TextStyle(color: Colors.black),
                                )),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color(0xffD9D9D9))),
                                onPressed: () {
                                  // Handle button click
                                },
                                child: Text("Last month",
                                    style: TextStyle(color: Colors.black))),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color(0xffD9D9D9))),
                                onPressed: () {
                                  // Handle button click
                                },
                                child: Text("Last 3 days",
                                    style: TextStyle(color: Colors.black))),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Played Matches',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'kalra',
                                    fontSize: 18)),
                            // Add your data here:
                            Text('10',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'kalra',
                                    fontSize: 18)),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Matches won',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'kalra',
                                    fontSize: 18)),
                            // Add your data here:
                            Text('7',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'kalra',
                                    fontSize: 18)),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Upcoming matches',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'kalra',
                                    fontSize: 18)),
                            // Add your data here:
                            Text('3',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'kalra',
                                    fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
