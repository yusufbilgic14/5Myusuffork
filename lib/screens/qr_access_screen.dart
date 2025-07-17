import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../constants/app_constants.dart';

import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import 'qr_scanner_screen.dart';

class QRAccessScreen extends StatefulWidget {
  const QRAccessScreen({super.key});

  @override
  State<QRAccessScreen> createState() => _QRAccessScreenState();
}

class _QRAccessScreenState extends State<QRAccessScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _countdownTimer;
  Duration _timeRemaining = const Duration(minutes: 5); // 5 dakika / 5 minutes
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // QR kod verisi oluştur / Generate QR code data
  void _generateQRCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = 'ELIF_YILMAZ_2025'; // Örnek kullanıcı ID / Sample user ID
    _qrData = 'MEDIPOL_ACCESS:$userId:$timestamp';
  }

  // Geri sayım başlat / Start countdown
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timeRemaining.inSeconds > 0) {
        setState(() {
          _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        });
      } else {
        // Süre dolduğunda QR kodu yenile / Refresh QR code when time expires
        _refreshQRCode();
      }
    });
  }

  // QR kodu yenile / Refresh QR code
  void _refreshQRCode() {
    if (!mounted) return;

    setState(() {
      _timeRemaining = const Duration(minutes: 5);
      _generateQRCode();
    });

    // Kullanıcıya bilgi ver / Notify user
  }

  // Kalan süreyi formatla / Format remaining time
  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Navy renkli AppBar / Navy colored AppBar
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textColorLight,
        elevation: 0,
        title: const Text(
          'QR Access',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const Icon(Icons.menu, color: Colors.white, size: 24),
            );
          },
        ),
        automaticallyImplyLeading: false,
      ),

      // Ana sayfa drawer'ı / Main drawer
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants.navIndexScan,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Ana QR kod kartı / Main QR code card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // QR kod başlığı / QR code title
                    const Text(
                      'Kampüs Giriş QR Kodu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // QR kod / QR code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        foregroundColor: AppConstants.primaryColor,
                        embeddedImage: const AssetImage(
                          'assets/images/medipol_logo.png',
                        ),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(30, 30),
                        ),
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Geri sayım zamanlayıcısı / Countdown timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _timeRemaining.inMinutes < 1
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _timeRemaining.inMinutes < 1
                              ? Colors.red
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: _timeRemaining.inMinutes < 1
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Geçerli süre: ${_formatTime(_timeRemaining)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _timeRemaining.inMinutes < 1
                                  ? Colors.red
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Yenile butonu / Refresh button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _refreshQRCode,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Yenile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConstants.primaryColor,
                          side: BorderSide(color: AppConstants.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // QR Kod Tarama butonu / QR Code Scanner button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRScannerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('QR Kodu Tarat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Açıklama metni / Explanation text
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bu QR kodu kampüs giriş tarayıcılarında kullanın. Güvenlik için kod otomatik olarak yenilenir.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Alt kullanım bilgisi / Bottom usage info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Güvenli kampüs erişimi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Alt navigasyon çubuğu / Bottom navigation bar
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexScan,
      ),
    );
  }
}
