import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/colors.dart';
import 'accountPage.dart';
import 'feed_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeMenu = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
        child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Scaffold(
              backgroundColor: white,
              body: getBody(),
            )));
  }
  Widget getBody() {
    var size = MediaQuery.of(context).size;
    List<Widget> pages = [
      FeedPage(key: new Key(""),category: "All"),
      Center(
        child: Text(
          "Blogs",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: black),
        ),
      ),
      AccountPage(key: new Key(""))

    ];
    return IndexedStack(
      index: activeMenu,
      children: pages,
    );
  }

}
