import 'package:flutter/material.dart';
import 'package:mobile/utils/route_generator.dart';
import 'package:mobile/utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChronoLens',
      theme: AppTheme.darkTheme, // Default is dark theme, add a switch later
      initialRoute: "/login",
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
