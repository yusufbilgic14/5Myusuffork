import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Medipol üniversitesi logo widget'ı / Medipol university logo widget
class MedipolLogoWidget extends StatelessWidget {
  final double size;
  final bool isRounded;
  final bool showFallbackText;
  final double borderRadius;

  const MedipolLogoWidget({
    super.key,
    this.size = 100.0,
    this.isRounded = true,
    this.showFallbackText = true,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isRounded
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(borderRadius),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: isRounded
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(borderRadius),
        child: Image.asset(
          AppConstants.logoPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback logo painter / Yedek logo çizici
            return _buildFallbackLogo();
          },
        ),
      ),
    );
  }

  /// Fallback logo oluşturucu / Fallback logo builder
  Widget _buildFallbackLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: isRounded
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(borderRadius),
      ),
      child: CustomPaint(
        painter: _MedipolLogoPainter(),
        child: showFallbackText
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size * 0.3),
                    Text(
                      'MEDİPOL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (size >
                        80) // Sadece büyük logolarda alt yazıyı göster / Show subtitle only for large logos
                      Text(
                        size > 100
                            ? 'ISTANBUL MEDIPOL UNIVERSITY'
                            : 'UNIVERSITY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.05,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

/// Özel logo çizici / Custom logo painter
class _MedipolLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2 - (size.height * 0.15);
    final radius = size.width * 0.12;

    // X sembolü çiz / Draw X symbol
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
