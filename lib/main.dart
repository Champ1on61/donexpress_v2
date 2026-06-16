import 'services/ad_service.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().init();
  runApp(DonExpressApp());
}

class DonExpressApp extends StatelessWidget {
  DonExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonExpress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      home: SplashScreen(),
    );
  }
}

extension on DonExpressApp {
  Widget? SplashScreen() {}
}