import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/PushNotificationService.dart';
import '../theme/colors.dart';
import 'accountPage.dart';
import 'feed_page.dart';


class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //push notification related stuff
    PushNotificationService pushNotificationService = PushNotificationService(context);
    pushNotificationService.initialize();
    pushNotificationService.initPushNotification();
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Scaffold(
          body: getBody(size),
          bottomNavigationBar: getFooter(),
        )
      ),
    );

  }

  Widget getBody(size) {
    List<Widget> pages = [
      FeedPage(key: new Key(""),category: "All"),
      Center(
        child: Text(
          "Coming soon..",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: black),
        ),
      ),
      AccountPage(key: new Key(""))

    ];
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getFooter() {
    List bottomItems = [
      "assets/images/home_icon.svg",
      "assets/images/love_icon.svg",
      "assets/images/account_icon.svg"
    ];
    List textItems = ["Home", "Blogs", "Account"];
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(width: 2, color: Colors.white.withOpacity(0.06)))),
      child: Padding(
        padding:
        const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(textItems.length, (index) {
            return InkWell(
                onTap: () {
                  selectedTab(index);
                },
                child: Column(
                  children: [
                    SvgPicture.asset(
                      bottomItems[index],
                      width: 18,
                      color: pageIndex == index
                          ? Theme.of(context).iconTheme.color
                          : Colors.grey,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      textItems[index],
                      style: TextStyle(
                          fontSize: 10,
                          color: pageIndex == index
                              ? Theme.of(context).textTheme.bodyText1?.color
                              : Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.color
                              ?.withOpacity(0.5)),
                    )
                  ],
                ));
          }),
        ),
      ),
    );
  }




  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
