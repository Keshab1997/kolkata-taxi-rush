import 'package:flutter/material.dart';

import 'game/kolkata_taxi_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KolkataTaxiRushApp());
}

class KolkataTaxiRushApp extends StatelessWidget {
  const KolkataTaxiRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kolkata Taxi Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC52E),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF081824),
      ),
      home: const KolkataTaxiGame(),
    );
  }
}
