import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../constants/app_constants.dart';

class KampuseUlasimScreen extends StatelessWidget {
  const KampuseUlasimScreen({Key? key}) : super(key: key);

  Widget _buildTable(List<List<String>> rows) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFE5EAF2)),
          children: const [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'KALKIŞ YERİ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'HAT İSMİ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'HAT GÜZERGAHI',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ...rows.map(
          (row) => TableRow(
            children: row
                .map(
                  (cell) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(cell),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final avrupaRows = [
      ['AVRUPA YAKASI', '500T', 'TUZLA-CEVİZLİBAĞ'],
      ['', '121A', 'MECİDİYEKÖY-BEYKOZ'],
      ['', '121B', 'MECİDİYEKÖY-KAVACIK'],
      ['', '121BS', 'MECİDİYEKÖY-SOĞUKSU-SULTANİYE'],
      ['', '122C', 'MECİDİYEKÖY-TEPEÜSTÜ'],
      ['', '129L', '4.LEVENT-KOZYATAĞI'],
      ['', '122M', 'MECİDİYEKÖY-ŞAHİNBEY'],
      ['', '122Y', 'MECİDİYEKÖY-ÇEKMEKÖY'],
      ['', '122D', 'MECİDİYEKÖY-ATATÜRK MAHALLESİ'],
      ['', '122H', '4.LEVENT-SABİHA GÖKÇEN H.L.'],
      ['', '122V', '4.LEVENT-VEYSEL KARANİ'],
      ['', '522B', 'MECİDİYEKÖY-YENİDOĞAN'],
      ['', '522ST', 'MECİDİYEKÖY-SULTANBEYLİ'],
      ['', '622', 'MECİDİYEKÖY-YENİDOĞAN'],
      ['', 'E-3', '4.LEVENT-SABİHA GÖKÇEN H.L.'],
    ];
    final anadoluRows = [
      ['ANADOLU YAKASI', '15BK', 'DERESEKİ-KADIKÖY'],
      ['', '15TK', 'TOKATKÖY-KADIKÖY'],
      ['', '15SD', 'BEYKOZ-DUDULLU İMES'],
      ['', '15TA', 'KAVACIK TÜRK ALMAN Ü.'],
      ['', '15A', 'KAVACIK-ANADOLU KAVAĞI'],
      ['', '15M', 'KAVACIK YENİ CAMİİ-ÜSKÜDAR'],
      ['', '15TY', 'TOKATKÖY-YENİ MAHALLE'],
      ['', '15E', 'ÜSKÜDAR-SİTELER'],
      ['', '15Ç', 'ÜSKÜDAR-ÇAVUŞBAŞI'],
      ['', '15KB', 'KAVACIK-KOZYATAĞI'],
      ['', '122ÇK', 'KAVACIK-ŞAHİNBEY'],
      ['', '136B', 'HEKİMBAŞI-BEYKOZ TAŞOCAKLARI'],
      ['', '135A', 'KAVACIK-ACARKENT'],
      ['', '135T', 'ARKBOYU-TOKATKÖY'],
      ['', '136R', 'KAVACIK-RİVA'],
      ['', '11ÇB', 'KAVACIK-ÜMRANİYE E.A.H'],
      ['', '14M', 'KAVACIK YENİ CAMİİ-KADIKÖY'],
    ];
    return Scaffold(
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.campusTransport,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 220,
              child: Image.asset(
                'assets/images/medipol_kampus.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.campusTransportDesc,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ExpansionTile(
                    title: Text(
                      AppLocalizations.of(context)!.europeanSide,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [_buildTable(avrupaRows)],
                  ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(
                      AppLocalizations.of(context)!.anatolianSide,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [_buildTable(anadoluRows)],
                  ),
                  const SizedBox(height: 80), // Alt navigasyon için boşluk
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexProfile,
      ),
    );
  }
}
