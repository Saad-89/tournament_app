import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      print('Error signing up: $e');
      return '';
    }
  }

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      print('Error signing in: $e');
      return '';
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
  // Future<void> signOut() async {
  //   try {
  //     // Clear the user session first

  //     // Then sign out the user
  //     await _auth.signOut();
  //     print('Sign out successful.');
  //   } catch (e) {
  //     print('Error signing out: $e');
  //   }
  // }

  Future<void> storeUserInfo(String userId, String name, String email,
      String phonenumber, bool isChecked, String deviceId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'name': name,
        'email': email,
        'phonenumber': phonenumber,
        'checked': isChecked,
        'role': 'user',
        'deviceId': deviceId
      });
      print('user information stored successfully.');
    } catch (e) {
      print('Error storing user information: $e');
    }
  }

  // check if current user is user.
  Future<bool> checkUserRole(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String role = data['role'];
        return (role == 'user');
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
    return false;
  }
}
