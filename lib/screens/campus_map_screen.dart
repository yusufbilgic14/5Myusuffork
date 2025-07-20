import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:async';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'qr_access_screen.dart';
import 'profile_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/app_bar_widget.dart';

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
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _loadDarkMapStyle();

    // Set timeout for map initialization
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _mapError = true;
          _isInitializing = false;
        });
        debugPrint('Google Maps initialization timeout');
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  // Koyu tema map style'ını yükle - hata durumunda sessizce devam et
  Future<void> _loadDarkMapStyle() async {
    try {
      _darkMapStyle = await rootBundle.loadString(
        'assets/map_styles/dark_map_style.json',
      );
    } catch (e) {
      debugPrint('Dark map style could not be loaded: $e');
      _darkMapStyle = null;
    }
  }

  // İstanbul Medipol Üniversitesi koordinatları / Medipol University coordinates
  static const LatLng _medipolCenter = LatLng(
    41.088612162240274,
    29.08920602676745,
  );

  // Kampüs binaları / Campus buildings
  Set<Marker> _buildingMarkers(BuildContext context) => {
    Marker(
      markerId: const MarkerId('main_building'),
      position: const LatLng(41.08852308584411, 29.088860275782068),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.mainBuilding,
        snippet: 'Kavacık South Campus',
      ),
    ),
    Marker(
      markerId: const MarkerId('north_campus'),
      position: const LatLng(41.091203723712844, 29.091344541914122),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.northCampus,
        snippet: 'Kavacık North Campus',
      ),
    ),
  };

  // Servis durakları / Shuttle stops
  Set<Marker> _shuttleStops(BuildContext context) => {
    Marker(
      markerId: const MarkerId('shuttle_main_gate'),
      position: const LatLng(41.08958242494858, 29.0899021494668),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.kavacikBridgeBusStop,
        snippet: AppLocalizations.of(context)!.asiaRoad,
      ),
    ),
    Marker(
      markerId: const MarkerId('shuttle_europe'),
      position: const LatLng(41.08764623193279, 29.093379648637885),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.kavacikBridgeBusStop,
        snippet: AppLocalizations.of(context)!.europeRoad,
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_kavacik_towardsbeykoz'),
      position: const LatLng(41.08915705000439, 29.088976773261635),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.kavacikBusStop,
        snippet: AppLocalizations.of(context)!.ataturkStreetBeykoz,
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_kavacik_towardsüsküdar'),
      position: const LatLng(41.088994338829686, 29.088191740305337),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.kavacikBusStop,
        snippet: AppLocalizations.of(context)!.ataturkStreetBeykoz,
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_kavaciksapagi_towardsüsküdar'),
      position: const LatLng(41.08860600008406, 29.090652087795732),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.kavacikJunctionBusStop,
        snippet: AppLocalizations.of(context)!.kavacikJunctionBeykoz,
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_kavaciksapagi_towardsbeykoz'),
      position: const LatLng(41.08958640369496, 29.092962204616487),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.kavacikJunctionBusStop,
        snippet: AppLocalizations.of(context)!.kavacikJunctionBeykoz,
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_yenirivayolu_towardsmecidiyeköy'),
      position: const LatLng(41.09133388881714, 29.094193858716775),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.yeniRivaYoluBusStop,
        snippet: AppLocalizations.of(context)!.kavacikJunctionBeykoz,
      ),
    ),
    Marker(
      markerId: const MarkerId('bus_stop_yenirivayolu_towardsbeykoz'),
      position: const LatLng(41.090414530513, 29.09395214590087),
      infoWindow: InfoWindow(
        title: AppLocalizations.of(context)!.yeniRivaYoluBusStop,
        snippet: AppLocalizations.of(context)!.kavacikJunctionBeykoz,
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar kaldırıldı
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
                    color: theme.shadowColor.withValues(alpha: 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  )!.searchBuildingOrLocation,
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
                  color: theme.shadowColor.withValues(alpha: 0.08),
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
              color: theme.shadowColor.withValues(alpha: 0.08),
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
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
                  AppLocalizations.of(context)!.routeInfo,
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
                  AppLocalizations.of(context)!.yourCurrentLocation,
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
                  AppLocalizations.of(context)!.engineeringFaculty,
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
                  AppLocalizations.of(context)!.walking,
                  '8 dk',
                  true,
                  theme,
                ),
                const SizedBox(width: 12),
                _buildTravelModeChip(
                  Icons.directions_bus,
                  AppLocalizations.of(context)!.shuttle,
                  '3 dk',
                  false,
                  theme,
                ),
                const SizedBox(width: 12),
                _buildTravelModeChip(
                  Icons.directions_bike,
                  AppLocalizations.of(context)!.bike,
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
                child: Text(
                  AppLocalizations.of(context)!.startNavigation,
                  style: const TextStyle(
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
            AppLocalizations.of(context)!.filterBuildingTypes,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(AppLocalizations.of(context)!.all, theme),
              _buildFilterOption(
                AppLocalizations.of(context)!.academicBuildings,
                theme,
              ),
              _buildFilterOption(
                AppLocalizations.of(context)!.administrativeBuildings,
                theme,
              ),
              _buildFilterOption(
                AppLocalizations.of(context)!.socialAreas,
                theme,
              ),
              _buildFilterOption(
                AppLocalizations.of(context)!.sportsFacilities,
                theme,
              ),
              _buildFilterOption(
                AppLocalizations.of(context)!.shuttleStops,
                theme,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
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
              color: theme.iconTheme.color?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Web için harita desteği yakında!',
              style: TextStyle(
                fontSize: 20,
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mobil uygulamada harita tam fonksiyoneldir.',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_mapError) {
      return _buildMapErrorWidget(theme);
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: _medipolCenter,
        zoom: 15.0,
      ),
      style: theme.brightness == Brightness.dark ? _darkMapStyle : null,
      markers: _showShuttleLayer
          ? <Marker>{..._buildingMarkers(context), ..._shuttleStops(context)}
          : _buildingMarkers(context),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  // Google Maps controller callback / Google Maps kontrolcü geri çağırması
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (mounted) {
      setState(() {
        _isInitializing = false;
        _mapError = false;
      });
    }
    _timeoutTimer?.cancel();
  }

  // Harita yeniden başlatma metodu / Map reinitialization method
  void _initializeMap() {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _mapError = false;
      });
    }

    // Timeout timer'ını yeniden başlat / Restart timeout timer
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _mapError = true;
          _isInitializing = false;
        });
        debugPrint('Google Maps reinitialization timeout');
      }
    });
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
              color: theme.iconTheme.color?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.mapNotLoaded,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.googleMapsNotLoaded,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.checkApiKeyOrInternet,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _initializeMap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(AppLocalizations.of(context)!.tryAgain),
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
              color: theme.shadowColor.withValues(alpha: 0.2),
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
                _buildBottomNavItem(
                  Icons.location_on,
                  AppLocalizations.of(context)!.navigation,
                  0,
                  theme,
                ),
                _buildBottomNavItem(
                  Icons.calendar_today,
                  AppLocalizations.of(context)!.calendar,
                  1,
                  theme,
                ),
                _buildBottomNavItem(
                  Icons.home,
                  AppLocalizations.of(context)!.home,
                  2,
                  theme,
                ),
                _buildBottomNavItem(
                  Icons.qr_code_scanner,
                  AppLocalizations.of(context)!.scan,
                  3,
                  theme,
                ),
                _buildBottomNavItem(
                  Icons.person,
                  AppLocalizations.of(context)!.profile,
                  4,
                  theme,
                ),
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
    final Color unselectedColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : theme.iconTheme.color ?? Colors.black;
    final Color unselectedTextColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : theme.textTheme.bodyMedium?.color ?? Colors.black;
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
            color: isSelected ? theme.colorScheme.primary : unselectedColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : unselectedTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
