import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DonExpressApp());
}

class DonExpressApp extends StatelessWidget {
  const DonExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonExpress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}