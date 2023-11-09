import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSocialButton extends StatelessWidget {
  GoogleSocialButton(
      {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconPath="assets/images/google_logo.svg";
    final text= "Sign in with Google";
    return Container(
      height: size.height / 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFF134140),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: SvgPicture.asset(iconPath),
          ),
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: const Color(0xFF134140),
              ),
            ),
          ),
        ],

      ),

    );
  }
}