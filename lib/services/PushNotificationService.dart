import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/feedDetailById.dart';

class PushNotificationService {
  final BuildContext context;

  PushNotificationService(this.context);

  Future initialize() async {
    FirebaseMessaging _fcm = FirebaseMessaging.instance;
    _fcm.requestPermission();
    String? token = await _fcm.getToken();
    print('Token: $token');
  }

  Future initPushNotification() async {
    // app was terminated and now open
    FirebaseMessaging.instance.getInitialMessage().then(handleNotification);
    // notification opens the app case
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotification);
  }

  handleNotification(RemoteMessage? message) {
    String feedId = message?.data['feedId'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedDetailByIdPage(
          feedId: feedId,
        ),
      ),
    );
  }
}
