import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
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
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
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
          _showSnackBar('URL açılamadı / Could not open URL', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Bir hata oluştu / An error occurred', isError: true);
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
      child: const Icon(
        Icons.school,
        color: Colors.white,
        size: 80,
      ),
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
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
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
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.white,
                             AppConstants.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height - safeAreaTop - keyboardHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingXLarge,
                  vertical: AppConstants.paddingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo bölümü / Logo section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLogoSection(),
                    ),
                    
                                         SizedBox(height: screenSize.height * 0.06),
                    
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
    );
  }

  /// Logo bölümü widget'ı / Logo section widget
  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo resmi - Standalone büyük logo / Standalone large logo
        Image.asset(
          'assets/images/loginlogo.png',
          width: 180,
          height: 180,
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
        
        const SizedBox(height: AppConstants.paddingXLarge),
        
        // Hoş geldin metni / Welcome text
        Text(
          'Hoş Geldiniz',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingSmall),
        
        Text(
          'Medipol Öğrenci Portalı',
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Giriş kartı widget'ı / Login card widget
  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: [
          BoxShadow(
                         color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge * 1.5),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık / Title
              Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              Text(
                'Öğrenci bilgilerinizle giriş yapın',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              // Öğrenci numarası alanı / Student ID field
              _buildModernTextField(
                controller: _studentIdController,
                label: 'Öğrenci Numarası',
                hint: '2024520001',
                icon: Icons.person_outline,
                textInputType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen öğrenci numaranızı girin';
                  }
                  if (value.length < 6) {
                    return 'Geçerli bir öğrenci numarası girin';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Şifre alanı / Password field
              _buildModernTextField(
                controller: _passwordController,
                label: 'Şifre',
                hint: 'Şifrenizi girin',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  }
                  if (value.length < 3) {
                    return 'Şifre en az 3 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Şifremi unuttum linki / Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _launchPasswordResetUrl,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: AppConstants.paddingSmall,
                    ),
                  ),
                  child: Text(
                    'Şifremi Unuttum',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              // Giriş butonu / Login button
              _buildModernButton(),
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
            fontSize: AppConstants.fontSizeMedium,
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
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
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
  Widget _buildModernButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
                     disabledBackgroundColor: AppConstants.primaryColor.withValues(alpha: 0.7),
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
            : const Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
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
    super.dispose();
  }
}
