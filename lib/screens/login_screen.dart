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
  bool _isLanguageDropdownOpen = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _languageDropdownController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _languageDropdownAnimation;

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

    _languageDropdownController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _languageDropdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _languageDropdownController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animasyonları başlat / Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  /// Dil dropdown menüsünü aç/kapat / Toggle language dropdown
  void _toggleLanguageDropdown() {
    setState(() {
      _isLanguageDropdownOpen = !_isLanguageDropdownOpen;
    });

    if (_isLanguageDropdownOpen) {
      _languageDropdownController.forward();
    } else {
      _languageDropdownController.reverse();
    }
  }

  /// Dil seçimi yap / Select language
  void _selectLanguage(Locale locale) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    languageProvider.setLocale(locale);
    _toggleLanguageDropdown();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? [
            const Color(0xFF181F2A),
            const Color(0xFF232B3E),
            const Color(0xFF1A2233),
          ]
        : [
            const Color(0xFFF3F6FB),
            const Color(0xFFE9F0FA),
            const Color(0xFFD6E4F0),
          ];
    final cardColor = isDark ? const Color(0xFF232B3E) : Colors.white;
    final inputFill = isDark ? const Color(0xFF232B3E) : Colors.white;
    final inputBorder = isDark ? Colors.white12 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.grey.shade400;
    final labelColor = isDark ? Colors.white : AppConstants.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181F2A) : Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgGradient,
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
                        // Logo ve dil seçici aynı satırda
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            // Dil seçici dropdown
                            _buildLanguageDropdown(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF232B3E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2634) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sade başlık bölümü / Simple header section
              Center(
                child: Column(
                  children: [
                    Text(
                      l10n.loginTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : AppConstants.primaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Öğrenci numarası alanı / Student ID field
              _buildCleanInputField(
                controller: _studentIdController,
                label: l10n.studentId,
                hint: AppLocalizations.of(context)!.studentIdHint,
                icon: Icons.person_outline,
                textInputType: TextInputType.text,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Şifre alanı / Password field
              _buildCleanInputField(
                controller: _passwordController,
                label: l10n.password,
                hint: l10n.password,
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Şifremi unuttum linki / Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _launchPasswordResetUrl,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    l10n.forgotPassword,
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sade giriş butonu / Clean login button
              _buildCleanLoginButton(l10n),
              const SizedBox(height: 20),

              // Ayırıcı çizgi / Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.or,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sade Microsoft OAuth giriş butonu / Clean Microsoft OAuth login button
              _buildCleanMicrosoftButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// Sade input alanı oluşturucu / Clean input field builder
  Widget _buildCleanInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType textInputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFill = isDark
        ? const Color(0xFF2A3441)
        : const Color(0xFFF8FAFC);
    final inputBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.shade200;
    final labelColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark
        ? Colors.white.withOpacity(0.4)
        : Colors.grey.shade500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: textInputType,
          validator: validator,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.grey.shade500,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Sade giriş butonu oluşturucu / Clean login button builder
  Widget _buildCleanLoginButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppConstants.primaryColor.withOpacity(0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.loginButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }

  /// Sade Microsoft OAuth giriş butonu / Clean Microsoft OAuth login button
  Widget _buildCleanMicrosoftButton(AppLocalizations l10n) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () => _handleMicrosoftLogin(authProvider),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0078D4),
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Color(0xFF0078D4), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: authProvider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0078D4),
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/images/microsoft-logo-png_seeklogo-258454.png',
                    width: 16,
                    height: 16,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.business,
                        size: 16,
                        color: Color(0xFF0078D4),
                      );
                    },
                  ),
            label: Text(
              authProvider.isLoading
                  ? 'Giriş yapılıyor...'
                  : l10n.loginWithMicrosoft,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
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

  /// Dil seçici dropdown widget'ı / Language selector dropdown widget
  Widget _buildLanguageDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = Provider.of<LanguageProvider>(context).locale;
    final isTurkish = currentLocale.languageCode == 'tr';

    return Column(
      children: [
        // Languages butonu
        GestureDetector(
          onTap: _toggleLanguageDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Languages',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isLanguageDropdownOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dropdown menü
        AnimatedBuilder(
          animation: _languageDropdownAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _languageDropdownAnimation.value,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: _languageDropdownAnimation.value,
                child: _isLanguageDropdownOpen
                    ? Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A3441)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguageOption(
                              imagePath: 'assets/images/turkey.png',
                              label: 'Türkçe',
                              isSelected: isTurkish,
                              onTap: () => _selectLanguage(const Locale('tr')),
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade200,
                            ),
                            _buildLanguageOption(
                              imagePath: 'assets/images/uk.png',
                              label: 'English',
                              isSelected: !isTurkish,
                              onTap: () => _selectLanguage(const Locale('en')),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Dil seçenek widget'ı / Language option widget
  Widget _buildLanguageOption({
    required String imagePath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppConstants.primaryColor.withOpacity(0.2)
                    : AppConstants.primaryColor.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 24, height: 18, fit: BoxFit.cover),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppConstants.primaryColor)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check,
                size: 16,
                color: isDark ? Colors.white : AppConstants.primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
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
    _languageDropdownController.dispose();
    super.dispose();
  }
}
