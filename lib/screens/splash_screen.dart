import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../utils/app_data.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'seller_dashboard.dart';
import 'courier_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showFireworks = false;
  
  final List<FireworkParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // 🔥 Через 2 секунды запускаем салют
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _showFireworks = true);
        _launchFireworks();
      }
    });

    // Через 3.5 секунды переходим дальше
    Timer(const Duration(milliseconds: 3500), () {
      _navigate();
    });
  }

  void _launchFireworks() {
    // Создаём несколько залпов салюта
    for (int i = 0; i < 3; i++) {
      Timer(Duration(milliseconds: i * 300), () {
        _createFireworkExplosion();
      });
    }
  }

  void _createFireworkExplosion() {
    final centerX = MediaQuery.of(context).size.width / 2;
    final centerY = MediaQuery.of(context).size.height / 2 - 50;
    
    setState(() {
      _particles.clear();
      // Создаём 30 частиц
      for (int i = 0; i < 30; i++) {
        _particles.add(FireworkParticle(
          x: centerX,
          y: centerY,
          angle: (2 * pi * i) / 30,
          speed: _random.nextDouble() * 3 + 2,
          color: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.orange,
            Colors.purple,
            Colors.pink,
          ][_random.nextInt(7)],
          size: _random.nextDouble() * 4 + 2,
        ));
      }
    });
    
    // Анимация частиц
    for (int i = 0; i < 20; i++) {
      Timer(Duration(milliseconds: i * 20), () {
        if (mounted) {
          setState(() {
            for (var particle in _particles) {
              particle.x += cos(particle.angle) * particle.speed;
              particle.y += sin(particle.angle) * particle.speed;
              particle.size *= 0.95;
            }
          });
        }
      });
    }
  }

  void _navigate() async {
    final user = AppData().user;
    
    if (!mounted) return;
    
    Widget nextScreen;
    if (user == null) {
      nextScreen = const AuthScreen();
    } else if (user.role == 'seller') {
      nextScreen = const SellerDashboard();
    } else if (user.role == 'courier') {
      nextScreen = const CourierDashboard();
    } else {
      nextScreen = const HomeScreen();
    }
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Анимированные круги на фоне
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (_controller.value * 0.3),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1 * _controller.value),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (_controller.value * 0.2),
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08 * _controller.value),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Салют (частицы)
            if (_showFireworks)
              ..._particles.map((particle) => Positioned(
                left: particle.x,
                top: particle.y,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: particle.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: particle.color.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              )),
            // Центральное содержимое
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_florist,
                              size: 80,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'DonExpress',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Доставка цветов',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 50),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Свежие цветы с доставкой',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Класс частицы салюта
class FireworkParticle {
  double x;
  double y;
  final double angle;
  final double speed;
  final Color color;
  double size;

  FireworkParticle({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}