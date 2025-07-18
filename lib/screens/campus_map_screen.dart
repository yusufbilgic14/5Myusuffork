import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'qr_access_screen.dart';
import 'profile_screen.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  GoogleMapController? _mapController;
  bool _showShuttleLayer = false;
  bool _showRoutePanel = false;
  String _selectedBuildingType = 'Tümü';
  int _selectedIndex = 0; // Navigation tab is selected
  bool _mapError = false; // Google Maps error state
  bool _isInitializing = true; // Map initialization state

  @override
  void initState() {
    super.initState();
    // iOS için timeout mekanizması / Timeout mechanism for iOS
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isInitializing) {
        setState(() {
          _mapError = true;
          _isInitializing = false; // Set error state if still initializing
        });
        debugPrint('Google Maps initialization timeout on iOS');
      }
    });
  }

  // İstanbul Medipol Üniversitesi koordinatları / Medipol University coordinates
  static const LatLng _medipolCenter = LatLng(
    41.088612162240274,
    29.08920602676745,
  );

  // Kampüs binaları / Campus buildings
  final Set<Marker> _buildingMarkers = {
    const Marker(
      markerId: MarkerId('main_building'),
      position: LatLng(41.08852308584411, 29.088860275782068),
      infoWindow: InfoWindow(
        title: 'Main Building',
        snippet: 'Kavacık South Campus',
      ),
    ),
    const Marker(
      markerId: MarkerId('north_campus'),
      position: LatLng(41.091203723712844, 29.091344541914122),
      infoWindow: InfoWindow(
        title: 'North Campus',
        snippet: 'Kavacık North Campus',
      ),
    ),
  };

  // Servis durakları / Shuttle stops
  final Set<Marker> _shuttleStops = {
    Marker(
      markerId: const MarkerId('shuttle_main_gate'),
      position: const LatLng(41.08958242494858, 29.0899021494668),
      infoWindow: const InfoWindow(
        title: 'Kavacık Köprüsü Bus Stop',
        snippet: 'Asia Road',
      ),
    ),
    Marker(
      markerId: const MarkerId('shuttle_europe'),
      position: const LatLng(41.08764623193279, 29.093379648637885),
      infoWindow: const InfoWindow(
        title: 'Kavacık Köprüsü Bus Stop',
        snippet: 'Europe Road',
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_kavacik_towardsbeykoz'),
      position: const LatLng(41.08915705000439, 29.088976773261635),
      infoWindow: const InfoWindow(
        title: 'Kavacık Bus Stop',
        snippet: 'Ataturk Street/Beykoz',
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_kavacik_towardsüsküdar'),
      position: const LatLng(41.088994338829686, 29.088191740305337),
      infoWindow: const InfoWindow(
        title: 'Kavacık Bus Stop',
        snippet: 'Ataturk Street/Beykoz',
      ),
    ),
     Marker(
      markerId: const MarkerId('bus_stop_kavaciksapagi_towardsüsküdar'),
      position: const LatLng(41.08860600008406, 29.090652087795732),
      infoWindow: const InfoWindow(
        title: 'Kavacık Sapağı Bus Stop',
        snippet: 'Kavacik Junction/Beykoz',
      ),
    ),
     Marker(
      markerId: const MarkerId('bus_stop_kavaciksapagi_towardsbeykoz'),
      position: const LatLng(41.08958640369496, 29.092962204616487),
      infoWindow: const InfoWindow(
        title: 'Kavacık Sapağı Bus Stop',
        snippet: 'Kavacik Junction/Beykoz',
      ),
    ),
      Marker(
      markerId: const MarkerId('bus_stop_yenirivayolu_towardsmecidiyeköy'),
      position: const LatLng(41.09133388881714, 29.094193858716775),
      infoWindow: const InfoWindow(
        title: 'Yeni Riva Yolu Bus Stop',
        snippet: 'Kavacik Junction/Beykoz',
      ),
    ),
     Marker(
      markerId: const MarkerId('bus_stop_yenirivayolu_towardsbeykoz'),
      position: const LatLng(41.090414530513, 29.09395214590087),
      infoWindow: const InfoWindow(
        title: 'Yeni Riva Yolu Bus Stop',
        snippet: 'Kavacik Junction/Beykoz',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Ana Google Maps widget'ı / Main Google Maps widget
            _buildMapWidget(),

            // Üst overlay - Arama çubuğu ve filtre / Top overlay - Search bar and filter
            _buildTopOverlay(),

            // Sol üst - Geri butonu / Top left - Back button
            _buildBackButton(),

            // Sağ alt - Servis katmanı toggle / Bottom right - Shuttle layer toggle
            _buildShuttleToggle(),

            // Alt overlay - Rota paneli / Bottom overlay - Route panel
            if (_showRoutePanel) _buildRoutePanel(),

            // Alt navigasyon çubuğu / Bottom navigation bar
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // Üst overlay widget'ı / Top overlay widget
  Widget _buildTopOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 60, // Geri butonundan sonra / After back button
      right: 16,
      child: Row(
        children: [
          // Arama çubuğu / Search bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Bina veya konum ara...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  // TODO: Arama fonksiyonalitesi / Search functionality
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Filtre butonu / Filter button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF1E3A8A)),
              onPressed: () => _showFilterDialog(),
            ),
          ),
        ],
      ),
    );
  }

  // Geri butonu / Back button
  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1E3A8A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // Servis katmanı toggle butonu / Shuttle layer toggle button
  Widget _buildShuttleToggle() {
    return Positioned(
      bottom: _showRoutePanel
          ? 240
          : 140, // Rota paneli varsa yukarı taşı / Move up if route panel exists
      right: 16,
      child: FloatingActionButton(
        backgroundColor: _showShuttleLayer
            ? const Color(0xFF1E3A8A)
            : Colors.white,
        foregroundColor: _showShuttleLayer
            ? Colors.white
            : const Color(0xFF1E3A8A),
        onPressed: () {
          setState(() {
            _showShuttleLayer = !_showShuttleLayer;
          });
        },
        child: const Icon(Icons.directions_bus),
      ),
    );
  }

  // Rota paneli / Route panel
  Widget _buildRoutePanel() {
    return Positioned(
      bottom: 60, // Alt navigasyon üzerinde / Above bottom navigation
      left: 0,
      right: 0,
      child: Container(
        height: 180,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel başlığı / Panel header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rota Bilgisi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showRoutePanel = false;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Başlangıç ve bitiş noktaları / Start and end points
            Row(
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('Mevcut Konumunuz', style: TextStyle(fontSize: 14)),
                const Spacer(),
                Container(width: 2, height: 20, color: Colors.grey[300]),
                const Spacer(),
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Mühendislik Fakültesi',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Yolculuk modları / Travel modes
            Row(
              children: [
                _buildTravelModeChip(
                  Icons.directions_walk,
                  'Yürüyüş',
                  '8 dk',
                  true,
                ),
                const SizedBox(width: 12),
                _buildTravelModeChip(
                  Icons.directions_bus,
                  'Servis',
                  '3 dk',
                  false,
                ),
                const SizedBox(width: 12),
                _buildTravelModeChip(
                  Icons.directions_bike,
                  'Bisiklet',
                  '5 dk',
                  false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Navigasyon başlat butonu / Start navigation button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigasyon başlat / Start navigation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Navigasyonu Başlat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yolculuk modu chip'i / Travel mode chip
  Widget _buildTravelModeChip(
    IconData icon,
    String mode,
    String time,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        // TODO: Yolculuk modunu değiştir / Change travel mode
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Filtre dialog'u / Filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Bina Türlerini Filtrele',
            style: TextStyle(color: Color(0xFF1E3A8A)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Tümü'),
              _buildFilterOption('Akademik Binalar'),
              _buildFilterOption('İdari Binalar'),
              _buildFilterOption('Sosyal Alanlar'),
              _buildFilterOption('Spor Tesisleri'),
              _buildFilterOption('Servis Durakları'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  // Filtre seçeneği / Filter option
  Widget _buildFilterOption(String option) {
    return RadioListTile<String>(
      title: Text(option),
      value: option,
      groupValue: _selectedBuildingType,
      activeColor: const Color(0xFF1E3A8A),
      onChanged: (String? value) {
        setState(() {
          _selectedBuildingType = value!;
        });
        Navigator.pop(context);
        // TODO: Filtreleme uygula / Apply filtering
      },
    );
  }

  // Google Maps widget'ı hata kontrolü ile / Google Maps widget with error handling
  Widget _buildMapWidget() {
    if (_mapError) {
      return _buildMapErrorWidget();
    }

    // iOS için initialization loading göster / Show initialization loading for iOS
    if (_isInitializing) {
      return Container(
        color: Colors.grey[100],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1E3A8A)),
              SizedBox(height: 16),
              Text(
                'Harita yükleniyor...',
                style: TextStyle(fontSize: 16, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        try {
          if (mounted) {
            _mapController = controller;
            setState(() {
              _isInitializing = false;
            });
            debugPrint('Google Maps initialized successfully on iOS');
          }
        } catch (e) {
          // API anahtarı veya yapılandırma hataları için / For API key or configuration errors
          debugPrint('Google Maps initialization error: $e');
          if (mounted) {
            setState(() {
              _mapError = true;
              _isInitializing = false;
            });
          }
        }
      },
      onCameraMove: (CameraPosition position) {
        // Hareket sırasında herhangi bir hata varsa yakala / Catch any errors during movement
        try {
          // Bu callback normalde hata vermez, ama güvenlik için / This callback normally doesn't error, but for safety
        } catch (e) {
          debugPrint('Camera move error: $e');
        }
      },
      initialCameraPosition: const CameraPosition(
        target: _medipolCenter,
        zoom: 16.0,
      ),
      markers: _showShuttleLayer
          ? {..._buildingMarkers, ..._shuttleStops}
          : _buildingMarkers,
      myLocationEnabled: true,
      myLocationButtonEnabled:
          false, // Kendi butonumuzu kullanacağız / We'll use our own button
      zoomControlsEnabled: false, // Zoom butonlarını gizle / Hide zoom buttons
      mapToolbarEnabled: false,
    );
  }

  // Map hata widget'ı / Map error widget
  Widget _buildMapErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Harita Yüklenemedi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Google Maps yüklenemedi.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'API anahtarı yapılandırmasını kontrol edin veya internet bağlantınızı doğrulayın.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _mapError = false;
                });
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

  // Alt navigasyon widget'ı / Bottom navigation widget
  Widget _buildBottomNavigation() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.location_on, 'Navigation', 0),
                _buildBottomNavItem(Icons.calendar_today, 'Calendar', 1),
                _buildBottomNavItem(Icons.home, 'Home', 2),
                _buildBottomNavItem(Icons.qr_code_scanner, 'Scan', 3),
                _buildBottomNavItem(Icons.person, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Alt navigasyon öğesi oluşturucu / Bottom navigation item builder
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Eğer farklı bir tab seçildiyse navigasyon yap / Navigate if different tab is selected
        if (index != _selectedIndex) {
          switch (index) {
            case 0: // Navigation / Campus Map - zaten buradayız / Already here
              break;
            case 1: // Calendar
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
              break;
            case 2: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 3: // Scan / QR Access
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const QRAccessScreen()),
              );
              break;
            case 4: // Profile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        }

        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
