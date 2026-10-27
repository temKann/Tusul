import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(const AstroApp());

class AstroApp extends StatelessWidget {
  const AstroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASTRA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ink,
        colorScheme: const ColorScheme.dark(
          primary: lilac,
          surface: panel,
          secondary: Color(0xFFF3BBD5),
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
