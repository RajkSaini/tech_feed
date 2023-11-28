
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:tech_feed/pages/feedDetailById.dart';
import 'package:tech_feed/pages/login.dart';
import 'package:tech_feed/pages/root_app.dart';
import 'package:tech_feed/services/PushNotificationService.dart';

import 'model/ThemeNotifier.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  usePathUrlStrategy();
  if(!kIsWeb){
    await Firebase.initializeApp();
  }else{
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
  }

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

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: MyApp(home: home),
    ),
  );
}
class MyApp extends StatelessWidget {
  final Widget home;

  MyApp({required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: Provider.of<ThemeNotifier>(context).currentTheme,
      home: home,
    );
  }
}