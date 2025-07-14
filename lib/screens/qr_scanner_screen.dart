import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  String? _errorMessage;

  // Tarama animasyonu için / For scanning animation
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initializeScanAnimation();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  // Tarama animasyonunu başlat / Initialize scan animation
  void _initializeScanAnimation() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animasyonu sürekli tekrarla / Repeat animation continuously
    _scanAnimationController.repeat(reverse: true);
  }

  // Kamerayı başlat / Initialize camera
  Future<void> _initializeCamera() async {
    try {
      // Önce hata mesajını temizle / Clear error message first
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }

      // Kamera iznini kontrol et / Check camera permission
      final status = await Permission.camera.request();

      if (!mounted)
        return; // Widget dispose olmuşsa çık / Exit if widget is disposed

      if (status.isGranted) {
        setState(() {
          _isPermissionGranted = true;
        });

        try {
          // Kullanılabilir kameraları al / Get available cameras
          _cameras = await availableCameras();

          if (!mounted)
            return; // Widget dispose olmuşsa çık / Exit if widget is disposed

          if (_cameras != null && _cameras!.isNotEmpty) {
            // Arka kamerayı seç / Select back camera
            final backCamera = _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first,
            );

            // Kamera kontrolcüsünü başlat / Initialize camera controller
            _cameraController = CameraController(
              backCamera,
              ResolutionPreset.high,
              enableAudio: false,
            );

            await _cameraController!.initialize();

            if (mounted) {
              setState(() {
                _isCameraInitialized = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _errorMessage = 'Kamera bulunamadı';
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Kamera başlatılamadı: $e';
            });
          }
        }
      } else if (status.isDenied) {
        if (mounted) {
          setState(() {
            _isPermissionGranted = false;
            _errorMessage = 'Kamera izni reddedildi';
          });
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _isPermissionGranted = false;
            _errorMessage =
                'Kamera izni kalıcı olarak reddedildi. Ayarlardan izin verin.';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isPermissionGranted = false;
            _errorMessage = 'Kamera iznine ihtiyaç var';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Bir hata oluştu: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'QR Kod Tarayıcısı',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: _buildCameraView(),
    );
  }

  // Kamera görünümü / Camera view
  Widget _buildCameraView() {
    if (!_isPermissionGranted) {
      return _buildPermissionView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return _buildLoadingView();
    }

    return Stack(
      children: [
        // Kamera önizlemesi / Camera preview
        Positioned.fill(child: CameraPreview(_cameraController!)),

        // Tarama çerçevesi ve animasyonu / Scanning frame and animation
        _buildScanningOverlay(),

        // Alt bilgi paneli / Bottom info panel
        _buildBottomPanel(),
      ],
    );
  }

  // İzin görünümü / Permission view
  Widget _buildPermissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              _errorMessage?.contains('kalıcı') == true
                  ? 'Kamera İzni Kalıcı Olarak Reddedildi'
                  : 'Kamera İzni Gerekli',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage?.contains('kalıcı') == true
                  ? 'Ayarlardan kamera iznini etkinleştirin.'
                  : 'QR kod taramak için kamera iznine ihtiyacımız var.',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorMessage =
                      'Kamera başlatılıyor...'; // Loading durumunu göster / Show loading state
                });

                try {
                  await _initializeCamera();
                } catch (e) {
                  // Hata yönetimi zaten _initializeCamera içinde yapılıyor / Error handling is already done in _initializeCamera
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: _errorMessage?.contains('başlatılıyor') == true
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _errorMessage?.contains('kalıcı') == true
                          ? 'Ayarlara Git'
                          : 'İzin Ver',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Hata görünümü / Error view
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeCamera();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  // Yükleme görünümü / Loading view
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1E3A8A)),
          SizedBox(height: 24),
          Text(
            'Kamera başlatılıyor...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Tarama çerçevesi / Scanning overlay
  Widget _buildScanningOverlay() {
    final size = MediaQuery.of(context).size;
    final scanArea = size.width * 0.7;

    return Center(
      child: Container(
        width: scanArea,
        height: scanArea,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Köşe indikatorları / Corner indicators
            ..._buildCornerIndicators(),

            // Tarama çizgisi animasyonu / Scanning line animation
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 8,
                  right: 8,
                  top: 8 + (scanArea - 32) * _scanAnimation.value,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Köşe indikatorları / Corner indicators
  List<Widget> _buildCornerIndicators() {
    const cornerSize = 20.0;
    const cornerThickness = 3.0;
    const corners = [
      // Sol üst / Top left
      Positioned(
        top: -cornerThickness,
        left: -cornerThickness,
        child: Icon(
          Icons.crop_free,
          size: cornerSize,
          color: Color(0xFF1E3A8A),
        ),
      ),
      // Sağ üst / Top right
      Positioned(
        top: -cornerThickness,
        right: -cornerThickness,
        child: Icon(
          Icons.crop_free,
          size: cornerSize,
          color: Color(0xFF1E3A8A),
        ),
      ),
      // Sol alt / Bottom left
      Positioned(
        bottom: -cornerThickness,
        left: -cornerThickness,
        child: Icon(
          Icons.crop_free,
          size: cornerSize,
          color: Color(0xFF1E3A8A),
        ),
      ),
      // Sağ alt / Bottom right
      Positioned(
        bottom: -cornerThickness,
        right: -cornerThickness,
        child: Icon(
          Icons.crop_free,
          size: cornerSize,
          color: Color(0xFF1E3A8A),
        ),
      ),
    ];

    return corners;
  }

  // Alt panel / Bottom panel
  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              const Text(
                'QR Kodu Çerçeve İçine Hizalayın',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'QR kod otomatik olarak taranacaktır',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
