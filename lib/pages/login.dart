import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tech_feed/pages/root_app.dart';

import '../components/authentication.dart';
import '../components/google_social_button.dart';
import '../constant/constants.dart';
import 'home_page.dart';


class Login extends StatefulWidget {

  @override
  _StoreDetailPageState createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Scaffold(
            body: getBody(),
          )
      ),
    );
  }


  Widget getBody() {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding:
        const EdgeInsets.only(left: 15, right: 15,top:15),
        child: Column(
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: ApiConstants.baseUrl + "/feed/images/0",
                  imageBuilder: (context, imageProvider) => Container(
                    height: 350,
                    // margin: const EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: imageProvider,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Add padding
                        child: Container(
                          width: double.infinity,
                          height: 200, // Adjust the image height
                          color: Colors.white, // Customize the skeleton item's appearance
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),


              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Tech Feed", // Display the title from the API response
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "#Daily Short Tech News App", // Display the title from the API response
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            signInWithText('Sign In for personalized feed'),
            SizedBox(
              height: size.height * 0.03,
            ),
            GestureDetector(
                onTap: () {
                  signup(context);
                },
                child: GoogleSocialButton()),
            SizedBox(
              height: size.height * 0.03,
            ),
            signInWithText('Or'),
            SizedBox(
              height: size.height * 0.02,
            ),
            TextButton(  onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => RootApp()));
            }, child: const Text('Skip to home page')),
          ],
        ),

      ),
    );
  }

  Widget emailTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 14,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextField(
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            labelText: 'Email/ Phone number',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
            ),
            border: InputBorder.none),
      ),
    );
  }
  Widget signInWithText(text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: Divider()),
        const SizedBox(
          width: 16,
        ),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFF969AA8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          width: 16,
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
  Widget signInButton(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: const Color(0xFF21899C),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C2E84).withOpacity(0.2),
            offset: const Offset(0, 15.0),
            blurRadius: 60.0,
          ),
        ],
      ),
      child: Text(
        'Sign in',
        style: GoogleFonts.inter(
          fontSize: 14.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  void skip(){

  }
}
