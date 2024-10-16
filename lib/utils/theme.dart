import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
 
   static const Color darkPurple = Color(0xFF392548);

  // For now we will only use dark theme but it seems simple enough to implement an alternative 
  // theme overriding the material theme TODO: Add the light theme with a switch button to change somewhere in settings
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primarySwatch: Colors.purple,
    primaryColor: Colors.purple,
    colorScheme: ColorScheme.dark(
      primary: Colors.purple,       // Primary color for components
      secondary: Colors.purple,     
      onPrimary: Colors.white,      // Text color on primary
      onSecondary: Colors.white,    // Text color on secondary
      surface: Colors.black,        
    ),
    iconTheme: const IconThemeData( // TODO: Find out how to import the icons from the design
      color: Colors.white, 
    ),
    textTheme: GoogleFonts.outfitTextTheme( // Outfit font from google fonts TODO: I think its free to use but gotta check the license 
      ThemeData.dark().textTheme, 
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black, 
      selectedItemColor: Colors.purple, 
      unselectedItemColor: Colors.white, 
      selectedIconTheme: const IconThemeData(color: Colors.purple),
      unselectedIconTheme: const IconThemeData(color: Colors.white),
      elevation: 0, // Apparently removes shadow
      type: BottomNavigationBarType.fixed, 
    ),
  );
}
