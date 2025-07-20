import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchMaps(String address) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    void Function()? onTap,
  }) {
    final isPhone = label.toLowerCase().contains('telefon');
    final phoneNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 12),
        Expanded(
          child: isPhone
              ? GestureDetector(
                  onTap: () => _launchPhone(phoneNumber),
                  child: Text(
                    '$label $value',
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: onTap,
                  child: Text(
                    '$label $value',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : null,
                      color: onTap != null
                          ? const Color(0xFF1E3A8A)
                          : Colors.black,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.helpSupport,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menü',
            );
          },
        ),
      ),
      drawer: const AppDrawerWidget(currentPageIndex: -1),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: -1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.contact,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.contactDesc,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Kavacık Kuzey Yerleşkesi
            Text(
              AppLocalizations.of(context)!.kavacikNorth,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.kavacikNorthDesc,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            _buildContactRow(
              icon: Icons.phone,
              label: 'Telefon:',
              value: '444 85 44',
              onTap: () => _launchPhone('4448544'),
            ),
            _buildContactRow(
              icon: Icons.print,
              label: AppLocalizations.of(context)!.faxRectorate,
              value: '0212 531 75 55',
            ),
            _buildContactRow(
              icon: Icons.print,
              label: AppLocalizations.of(context)!.faxAccounting,
              value: '0212 521 28 52',
            ),
            _buildContactRow(
              icon: Icons.print,
              label: AppLocalizations.of(context)!.faxFaculties,
              value: '0212 521 23 77',
            ),
            _buildContactRow(
              icon: Icons.email,
              label: 'Kep Adresi:',
              value: 'medipoluniversitesi@hs03.kep.tr',
              onTap: () => _launchEmail('medipoluniversitesi@hs03.kep.tr'),
            ),
            _buildContactRow(
              icon: Icons.location_on,
              label: AppLocalizations.of(context)!.address,
              value:
                  'Kavacık Mah. Ekinciler Cad. No: 19, Kavacık Kavşağı, 34810 Beykoz, İstanbul',
              onTap: () => _launchMaps(
                'Kavacık Mah. Ekinciler Cad. No: 19, Kavacık Kavşağı, 34810 Beykoz, İstanbul',
              ),
            ),
            const SizedBox(height: 32),
            // Haliç Yerleşkesi
            Text(
              AppLocalizations.of(context)!.halicCampus,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.halicCampusDesc,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            _buildContactRow(
              icon: Icons.phone,
              label: 'Telefon:',
              value: '444 85 44',
              onTap: () => _launchPhone('4448544'),
            ),
            _buildContactRow(
              icon: Icons.print,
              label: AppLocalizations.of(context)!.faxRectorate,
              value: '0212 531 75 55',
            ),
            _buildContactRow(
              icon: Icons.print,
              label: AppLocalizations.of(context)!.faxAccounting,
              value: '0212 521 28 52',
            ),
            _buildContactRow(
              icon: Icons.print,
              label: AppLocalizations.of(context)!.faxFaculties,
              value: '0212 521 23 77',
            ),
            _buildContactRow(
              icon: Icons.location_on,
              label: AppLocalizations.of(context)!.address,
              value:
                  'Cibali Mah. Atatürk Bulvarı No: 25, 34083 Fatih, İstanbul',
              onTap: () => _launchMaps(
                'Cibali Mah. Atatürk Bulvarı No: 25, 34083 Fatih, İstanbul',
              ),
            ),
            const SizedBox(height: 32),
            // Bağcılar Yerleşkesi
            Text(
              AppLocalizations.of(context)!.bagcilarCampus,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.bagcilarCampusDesc,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            _buildContactRow(
              icon: Icons.phone,
              label: 'Telefon:',
              value: '444 70 44',
              onTap: () => _launchPhone('4447044'),
            ),
            _buildContactRow(
              icon: Icons.phone,
              label: AppLocalizations.of(context)!.phoneInternal,
              value: '0212 460 77 77 - (7578)',
            ),
            _buildContactRow(
              icon: Icons.print,
              label: AppLocalizations.of(context)!.faxFaculties,
              value: '0212 521 23 77',
            ),
            _buildContactRow(
              icon: Icons.location_on,
              label: AppLocalizations.of(context)!.address,
              value:
                  'TEM Avrupa Otoyolu Göztepe Çıkışı No: 1, 34214 Bağcılar, İstanbul',
              onTap: () => _launchMaps(
                'TEM Avrupa Otoyolu Göztepe Çıkışı No: 1, 34214 Bağcılar, İstanbul',
              ),
            ),
            const SizedBox(height: 32),
            // Sağlık Uygulama Araştırma Merkezleri
            ExpansionTile(
              title: Text(
                AppLocalizations.of(context)!.healthResearchCenters,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              children: [
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.healthResearchCentersDent,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactRow(
                        icon: Icons.phone,
                        label: 'Telefon:',
                        value: '444 63 44',
                        onTap: () => _launchPhone('4446344'),
                      ),
                      _buildContactRow(
                        icon: Icons.print,
                        label: 'Faks:',
                        value: '0212 5317555',
                      ),
                      _buildContactRow(
                        icon: Icons.location_on,
                        label: AppLocalizations.of(context)!.address,
                        value:
                            'Unkapanı, Atatürk Bulvarı No:27 34083 Fatih-İstanbul',
                        onTap: () => _launchMaps(
                          'Unkapanı, Atatürk Bulvarı No:27 34083 Fatih-İstanbul',
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.healthResearchCentersVatan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactRow(
                        icon: Icons.phone,
                        label: 'Telefon:',
                        value: '0212 631 2050',
                        onTap: () => _launchPhone('02126312050'),
                      ),
                      _buildContactRow(
                        icon: Icons.print,
                        label: 'Faks:',
                        value: '0212 5212783',
                      ),
                      _buildContactRow(
                        icon: Icons.language,
                        label: AppLocalizations.of(context)!.website,
                        value: 'http://vatan.medipol.edu.tr/',
                        onTap: () async {
                          final url = Uri.parse('http://vatan.medipol.edu.tr/');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                      ),
                      _buildContactRow(
                        icon: Icons.location_on,
                        label: AppLocalizations.of(context)!.address,
                        value:
                            'Vatan Cad. Halıcılar Köşkü Sk. No:11 Aksaray, Fatih-İstanbul',
                        onTap: () => _launchMaps(
                          'Vatan Cad. Halıcılar Köşkü Sk. No:11 Aksaray, Fatih-İstanbul',
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.healthResearchCentersEsenler,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactRow(
                        icon: Icons.phone,
                        label: 'Telefon:',
                        value: '0212 440 1000',
                        onTap: () => _launchPhone('02124401000'),
                      ),
                      _buildContactRow(
                        icon: Icons.location_on,
                        label: AppLocalizations.of(context)!.address,
                        value: 'Birlik Mah. Bahçeler Cd. No:5 ESENLER/İSTANBUL',
                        onTap: () => _launchMaps(
                          'Birlik Mah. Bahçeler Cd. No:5 ESENLER/İSTANBUL',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
