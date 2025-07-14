import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../widgets/common/medipol_logo_widget.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Şifre sıfırlama URL'sini aç / Open password reset URL
  Future<void> _launchPasswordResetUrl() async {
    final Uri url = Uri.parse('https://mebis.medipol.edu.tr/PasswordReset');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('URL açılamadı / Could not open URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bir hata oluştu / An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          // Logo ve şirket bilgileri / Logo and company information
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
            child: Row(
              children: [
                // Logo
                const MedipolLogoWidget(
                  size: 63,
                  isRounded: false,
                  showFallbackText: false,
                  borderRadius: AppConstants.radiusMedium,
                ),

                const SizedBox(width: AppConstants.radiusMedium),
                // Şirket metinleri / Company texts
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'MEDIPOL',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: screenWidth < 350
                                ? 20
                                : AppConstants.fontSizeXXLarge,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ÜNV-İSTANBUL',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: screenWidth < 350 ? 18 : 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'İSTANBUL MEDİPOL ÜNİVERSİTESİ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth < 350 ? 9 : 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Mavi eğri ve login alanı - Kalan tüm alanı kapla / Blue curve and login area - Fill remaining space
          Expanded(
            child: ClipPath(
              clipper: CurvedTopClipper(),
              child: Container(
                width: double.infinity,
                color: AppConstants.primaryColor,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          screenHeight -
                          147, // Status bar + logo alanı - spacing / Status bar + logo area - spacing
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
                      child: Column(
                        children: [
                          // Login başlığı / Login title
                          const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Student ID alanı / Student ID field
                          _buildInputField(
                            label: 'Student ID',
                            controller: _studentIdController,
                            isPassword: false,
                          ),

                          const SizedBox(height: AppConstants.paddingXLarge),

                          // Password alanı ve şifremi unuttum linki yan yana
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Password input alanı (genişleyecek)
                              Expanded(
                                child: _buildInputField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  isPassword: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Login butonu / Login button
                          _buildActionButton(
                            text: 'Login',
                            onPressed: () {
                              // Şimdilik doğrudan ana sayfaya yönlendir / Navigate directly to home page for now
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: AppConstants.paddingLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Giriş alanı oluşturucu / Input field builder
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isPassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isPassword) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _launchPasswordResetUrl,
                child: Text(
                  '(Forgotten Password?)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall + 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Aksiyon butonu oluşturucu / Action button builder
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Şifremi unuttum bağlantısı ve butonları kaldırıldı, sadece label yanında küçük link olarak kaldı.

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Mavi alanın üst kısmı için eğri şekil / Curved shape for top of blue area
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 60);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
