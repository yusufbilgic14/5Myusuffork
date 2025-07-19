import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/authentication_provider.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcülerini başlat / Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Animasyonları başlat / Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  /// Şifre sıfırlama URL'sini aç / Open password reset URL
  Future<void> _launchPasswordResetUrl() async {
    final Uri url = Uri.parse('https://mebis.medipol.edu.tr/PasswordReset');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showSnackBar(
            AppLocalizations.of(context)!.urlCouldNotOpen,
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context)!.anErrorOccurred,
          isError: true,
        );
      }
    }
  }

  /// SnackBar gösterici / SnackBar helper
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
    );
  }

  /// Yedek logo widget'ı / Fallback logo widget
  Widget _buildFallbackLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
      ),
      child: const Icon(Icons.school, color: Colors.white, size: 80),
    );
  }

  /// Giriş işlemi / Login process
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simülasyon için kısa bekleme / Short wait for simulation
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // Ana sayfaya yönlendir / Navigate to home page
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppConstants.animationNormal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaTop = MediaQuery.of(context).padding.top;

    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF3F6FB),
                  Color(0xFFE9F0FA),
                  Color(0xFFD6E4F0),
                ],
              ),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 4),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height - safeAreaTop - keyboardHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingXLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 0), // Üst boşluk minimum
                        // Logo ve bayraklar aynı satırda
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // Ortaya hizala
                          children: [
                            Expanded(
                              child: Image.asset(
                                'assets/images/loginlogo.png',
                                width: 320,
                                height: 210,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackLogo();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Bayraklar ortalanmış şekilde
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    _buildFlagButton(
                                      imagePath: 'assets/images/turkey.png',
                                      isSelected:
                                          languageProvider
                                              .locale
                                              .languageCode ==
                                          'tr',
                                      onTap: () => languageProvider.setLocale(
                                        const Locale('tr'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildFlagButton(
                                      imagePath: 'assets/images/uk.png',
                                      isSelected:
                                          languageProvider
                                              .locale
                                              .languageCode ==
                                          'en',
                                      onTap: () => languageProvider.setLocale(
                                        const Locale('en'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Form kartı / Form card
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildLoginCard(),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingXLarge),
                        // Alt bölüm / Footer section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildFooterSection(),
                        ),
                      ],
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

  /// Logo bölümü widget'ı / Logo section widget
  Widget _buildLogoSection({bool showFlags = true}) {
    return Column(
      children: [
        // Logo resmi - Standalone büyük logo / Standalone large logo
        Image.asset(
          'assets/images/loginlogo.png',
          width: 280,
          height: 280,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('=== LOGO ERROR DEBUG ===');
            print('Error: $error');
            print('StackTrace: $stackTrace');
            print('Trying to load: assets/images/loginlogo.png');
            print('========================');
            return _buildFallbackLogo();
          },
        ),
        if (showFlags) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bayraklar burada gösterilecek (ama artık yukarıda gösteriliyor)
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFlagButton({
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.asset(imagePath, width: 38, height: 28, fit: BoxFit.cover),
      ),
    );
  }

  /// Giriş kartı widget'ı / Login card widget
  Widget _buildLoginCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 40,
            offset: const Offset(0, 18),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık / Title
              Center(
                child: Text(
                  l10n.loginTitle,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXXLarge,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.primaryColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              // Öğrenci numarası alanı / Student ID field
              _buildModernTextField(
                controller: _studentIdController,
                label: l10n.studentId,
                hint: AppLocalizations.of(context)!.studentIdHint,
                icon: Icons.person_outline,
                textInputType: TextInputType.text,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Şifre alanı / Password field
              _buildModernTextField(
                controller: _passwordController,
                label: l10n.password,
                hint: l10n.password,
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Şifremi unuttum linki / Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _launchPasswordResetUrl,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                  ),
                  child: Text(
                    l10n.forgotPassword,
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Giriş butonu / Login button
              _buildModernButton(l10n),
              const SizedBox(height: 10),
              // Ayırıcı çizgi / Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.or,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: AppConstants.fontSizeSmall,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Microsoft OAuth giriş butonu / Microsoft OAuth login button
              _buildMicrosoftLoginButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern metin alanı oluşturucu / Modern text field builder
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType textInputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: textInputType,
          validator: validator,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(
              icon,
              color: AppConstants.primaryColor.withValues(alpha: 0.7),
              size: 22,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppConstants.primaryColor.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingLarge,
            ),
          ),
        ),
      ],
    );
  }

  /// Modern buton oluşturucu / Modern button builder
  Widget _buildModernButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          disabledBackgroundColor: AppConstants.primaryColor.withValues(
            alpha: 0.7,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.loginButton,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Microsoft OAuth giriş butonu / Microsoft OAuth login button
  Widget _buildMicrosoftLoginButton(AppLocalizations l10n) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () => _handleMicrosoftLogin(authProvider),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0078D4), // Microsoft blue color
              side: const BorderSide(color: Color(0xFF0078D4), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: Colors.white,
              shadowColor: Colors.black.withOpacity(0.08),
              elevation: 2,
            ),
            icon: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0078D4),
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/images/microsoft-logo-png_seeklogo-258454.png', // Doğru Microsoft logosu
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.business,
                        size: 20,
                        color: Color(0xFF0078D4),
                      );
                    },
                  ),
            label: Text(
              authProvider.isLoading
                  ? 'Giriş yapılıyor...'
                  : l10n.loginWithMicrosoft,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0078D4),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Microsoft OAuth giriş işlemi / Microsoft OAuth login process
  Future<void> _handleMicrosoftLogin(
    AuthenticationProvider authProvider,
  ) async {
    try {
      final success = await authProvider.signInWithMicrosoft();

      if (success && mounted) {
        // Başarılı giriş, ana sayfaya yönlendir / Successful login, navigate to home
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: AppConstants.animationNormal,
          ),
        );
      } else if (mounted && authProvider.hasError) {
        // Hata durumunda kullanıcıya bilgi ver / Show error to user
        _showSnackBar(
          authProvider.errorMessage ??
              'Microsoft giriş hatası / Microsoft sign in error',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Microsoft giriş işlemi başarısız / Microsoft sign in failed: $e',
          isError: true,
        );
      }
    }
  }

  /// Alt bölüm widget'ı / Footer section widget
  Widget _buildFooterSection() {
    return Column(
      children: [
        Text(
          'Medipol Üniversitesi',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: AppConstants.paddingSmall),

        Text(
          'Öğrenci Bilgi Sistemi',
          style: TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
