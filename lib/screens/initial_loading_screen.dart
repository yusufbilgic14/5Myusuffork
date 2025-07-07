import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // 3 saniye sonra login ekranına geç
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo ortada
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(75),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
                              child: ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.asset(
                    'assets/images/medipol_logo.png', // Boşluksuz dosya adı kullan
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Eğer görsel yüklenemezse, debug bilgisi yazdır ve fallback logo kullan
                      print('Logo yükleme hatası: $error');
                      return Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(75),
                        ),
                        child: CustomPaint(
                          painter: MedipolLogoPainter(),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 40),
                                Text(
                                  'MEDİPOL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'ISTANBUL MEDIPOL UNIVERSITY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ),
          ),
          // Alt copyright metni
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Copyrighted 2025® Tüm Hakları Saklıdır',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fallback logo painter - eğer görsel yüklenemezse kullanılacak
class MedipolLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2 - 20;
    final radius = 15.0;

    // X sembolü çiz
    canvas.drawLine(
      Offset(centerX - radius, centerY - radius),
      Offset(centerX + radius, centerY + radius),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + radius, centerY - radius),
      Offset(centerX - radius, centerY + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 