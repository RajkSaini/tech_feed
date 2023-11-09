import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/categorySelector.dart';
import '../pages/home_page.dart';
import '../services/api_service.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

Future<void> signup(BuildContext context) async {
  print("starting auth....");
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount != null) {
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    print("authCredential : "+ authCredential.providerId);
    // Getting users credential
    UserCredential result = await auth.signInWithCredential(authCredential);
    print("user :"+result.user.toString());

    User? user = result.user;
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString('emailId',user?.email as String);
    prefs.setString('userName',user?.displayName as String);
    if (result != null) {
      // Call the isUserExist method to check if the user exists
      Map<String, dynamic> userData = await ApiService().isUserExist(user?.email);

      if (userData != null) {
        // Check if the "id" field exists in the response data
        if (userData.containsKey("id")) {
          // User exists, navigate to the HomePage
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          // User does not exist, navigate to the TechNewsCategorySelector
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => TechNewsCategorySelector()));
        }
      } else {
        // Handle the case where the ApiService returned null (e.g., an error occurred)
        // You can add error handling logic here if needed
      }
    }
    // if result not null we simply call the MaterialpageRoute,
    // for go to the HomePage screen
  }
}