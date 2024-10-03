import 'package:flutter/material.dart';
import 'package:mobile/utils/route_generator.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: "/login",
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}