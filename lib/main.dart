
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:tech_feed/pages/feedDetailById.dart';
import 'package:tech_feed/pages/login.dart';
import 'package:tech_feed/pages/root_app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  //await Firebase.initializeApp();

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyDQASvtacJRQY0pOoYmpP5f0JiwXGKCVms",
        authDomain: "tech-feed-21310.firebaseapp.com",
        projectId: "tech-feed-21310",
        storageBucket: "tech-feed-21310.appspot.com",
        messagingSenderId: "638998345431",
        appId: "1:638998345431:web:150baeefd5557ea533a292",
        measurementId: "G-R3VEZY7QDK"
    ),
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? emailId= prefs.getString('emailId');
  print(emailId);
  Widget home ;
  if(emailId==null){
    home = Login();
  }else{
    home = RootApp();
  }
  // Check if a parameter is passed in the route
  String initialRoute = '/';
  if (Uri.base.queryParameters.containsKey('id')) {
    String? id= Uri.base.queryParameters['id'];
     home= FeedDetailByIdPage(feedId: id);
    //initialRoute = '/otherPage/${Uri.base.queryParameters['id']}';
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/', // Set the initial route to '/'
    // onGenerateRoute: (settings) {
    //   if (settings.name == '/feedDetail/:id') {
    //     // Extract the parameter from the route
    //     final String param = settings.arguments.toString();
    //     return MaterialPageRoute(
    //       builder: (context) => FeedDetailByIdPage(feedId: param),
    //     );
    //   }
    //   // If the route is not recognized, you can use a default route or handle it as needed.
    //   return null;
    // },
    home: home,
  ));

}