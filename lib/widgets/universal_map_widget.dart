import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// Mobil için
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class UniversalMapWidget extends StatelessWidget {
  const UniversalMapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web için harita desteği yoksa bilgilendirme göster
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kampüs Haritası'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.map_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Web için harita desteği yakında!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Mobil uygulamada harita tam fonksiyoneldir.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      // Mobil için Google Maps widget
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kampüs Haritası'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: gmaps.GoogleMap(
          initialCameraPosition: const gmaps.CameraPosition(
            target: gmaps.LatLng(41.0886, 29.0892),
            zoom: 16,
          ),
        ),
      );
    }
  }
}
