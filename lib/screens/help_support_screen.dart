import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '4448544');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchMaps() async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=İstanbul+Medipol+Üniversitesi+Kavacık+Güney+Yerleşkesi+Beykoz+İstanbul',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'destekhizmetleri@medipol.edu.tr',
      // subject ve body eklenebilir
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım ve Destek'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İletişim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Her türlü soru, görüş ve destek talepleriniz için aşağıdaki iletişim kanallarını kullanabilirsiniz.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _launchPhone,
                    child: const Text(
                      'Telefon: 444 85 44 ',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.email, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _launchEmail,
                    child: const Text(
                      'E-posta: destekhizmetleri@medipol.edu.tr',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _launchMaps,
                    child: const Text(
                      'Adres: İstanbul Medipol Üniversitesi, Kavacık Güney Yerleşkesi, Giriş Katı, Beykoz/İstanbul',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
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
