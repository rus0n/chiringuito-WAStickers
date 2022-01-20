import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KTextStyles {
  static final TextStyle h1 = GoogleFonts.ptSans(
    fontSize: 58,
    letterSpacing: 2,
    wordSpacing: 2,
    height: 1.5,
    fontWeight: FontWeight.w900,
  );
  static final TextStyle headerStyle = GoogleFonts.ptSans(
      fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white);
  static final TextStyle h3 = h1.copyWith(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      wordSpacing: 0.8);
}
