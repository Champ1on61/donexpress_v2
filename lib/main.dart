import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart'; //  ЗАМЕНИ на точное имя твоего файла входа!

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
      home: const AuthCheck(), // ← Запускает проверку входа
    );
  }
}

// 🔥 ЭКРАН ПРОВЕРКИ АВТОРИЗАЦИИ (вместо чёрного экрана)
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});
  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Небольшая задержка для плавности (можно убрать)
      await Future.delayed(const Duration(milliseconds: 800));
      
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isLoggedIn ? const HomeScreen() : const AuthScreen(),
          ),
        );
      }
    } catch (e) {
      // Если ошибка чтения настроек → идём на вход
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF9C27B0), // Цвет фона сплэша
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist, size: 72, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'DonExpress',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}