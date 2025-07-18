import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
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
  String? _darkMapStyle;

  @override
  void initState() {
    super.initState();
    // Koyu tema için map style yükle
    rootBundle.loadString('assets/map_styles/dark_map_style.json').then((
      string,
    ) {
      _darkMapStyle = string;
    });
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildMapWidget(theme),
            _buildTopOverlay(theme),
            _buildBackButton(theme),
            _buildShuttleToggle(theme),
            if (_showRoutePanel) _buildRoutePanel(theme),
            _buildBottomNavigation(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOverlay(ThemeData theme) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 60,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Bina veya konum ara...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: theme.colorScheme.primary),
              onPressed: () => _showFilterDialog(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildShuttleToggle(ThemeData theme) {
    return Positioned(
      bottom: _showRoutePanel ? 240 : 140,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: _showShuttleLayer
            ? theme.colorScheme.primary
            : theme.cardColor,
        foregroundColor: _showShuttleLayer
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary,
        onPressed: () {
          setState(() {
            _showShuttleLayer = !_showShuttleLayer;
          });
        },
        child: Icon(
          Icons.directions_bus,
          color: _showShuttleLayer
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildRoutePanel(ThemeData theme) {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rota Bilgisi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.iconTheme.color),
                  onPressed: () {
                    setState(() {
                      _showRoutePanel = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.radio_button_checked, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Mevcut Konumunuz',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                Container(width: 2, height: 20, color: theme.dividerColor),
                const Spacer(),
                Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Mühendislik Fakültesi',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTravelModeChip(
                  Icons.directions_walk,
                  'Yürüyüş',
                  '8 dk',
                  true,
                  theme,
                ),
                const SizedBox(width: 12),
                _buildTravelModeChip(
                  Icons.directions_bus,
                  'Servis',
                  '3 dk',
                  false,
                  theme,
                ),
                const SizedBox(width: 12),
                _buildTravelModeChip(
                  Icons.directions_bike,
                  'Bisiklet',
                  '5 dk',
                  false,
                  theme,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Navigasyonu Başlat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelModeChip(
    IconData icon,
    String mode,
    String time,
    bool isSelected,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.iconTheme.color,
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
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'Bina Türlerini Filtrele',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Tümü', theme),
              _buildFilterOption('Akademik Binalar', theme),
              _buildFilterOption('İdari Binalar', theme),
              _buildFilterOption('Sosyal Alanlar', theme),
              _buildFilterOption('Spor Tesisleri', theme),
              _buildFilterOption('Servis Durakları', theme),
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

  Widget _buildFilterOption(String option, ThemeData theme) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      ),
      value: option,
      groupValue: _selectedBuildingType,
      activeColor: theme.colorScheme.primary,
      onChanged: (String? value) {
        setState(() {
          _selectedBuildingType = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMapWidget(ThemeData theme) {
    if (kIsWeb) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: theme.iconTheme.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Web için harita desteği yakında!',
              style: TextStyle(
                fontSize: 20,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mobil uygulamada harita tam fonksiyoneldir.',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    if (_mapError) {
      return _buildMapErrorWidget(theme);
    }
    if (_isInitializing) {
      return Container(
        color: theme.cardColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Harita yükleniyor...',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
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
            if (theme.brightness == Brightness.dark && _darkMapStyle != null) {
              controller.setMapStyle(_darkMapStyle);
            } else {
              controller.setMapStyle(null);
            }
            debugPrint('Google Maps initialized successfully on iOS');
          }
        } catch (e) {
          debugPrint('Google Maps initialization error: $e');
          if (mounted) {
            setState(() {
              _mapError = true;
              _isInitializing = false;
            });
          }
        }
      },
      onCameraMove: (CameraPosition position) {},
      initialCameraPosition: const CameraPosition(
        target: _medipolCenter,
        zoom: 16.0,
      ),
      markers: _showShuttleLayer
          ? {..._buildingMarkers, ..._shuttleStops}
          : _buildingMarkers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Widget _buildMapErrorWidget(ThemeData theme) {
    return Container(
      color: theme.cardColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: theme.iconTheme.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Harita Yüklenemedi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Google Maps yüklenemedi.',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'API anahtarı yapılandırmasını kontrol edin veya internet bağlantınızı doğrulayın.',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
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
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
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
                _buildBottomNavItem(Icons.location_on, 'Navigation', 0, theme),
                _buildBottomNavItem(Icons.calendar_today, 'Calendar', 1, theme),
                _buildBottomNavItem(Icons.home, 'Home', 2, theme),
                _buildBottomNavItem(Icons.qr_code_scanner, 'Scan', 3, theme),
                _buildBottomNavItem(Icons.person, 'Profile', 4, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    int index,
    ThemeData theme,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index != _selectedIndex) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const QRAccessScreen()),
              );
              break;
            case 4:
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
            color: isSelected
                ? theme.colorScheme.primary
                : theme.iconTheme.color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
