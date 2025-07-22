import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../models/user_interaction_models.dart';
import '../../services/user_club_following_service.dart';
import '../../services/firebase_auth_service.dart';

/// Dialog for adding new clubs
/// Yeni kulüp ekleme dialog'u
class AddClubDialog extends StatefulWidget {
  final Function()? onClubAdded;

  const AddClubDialog({
    super.key,
    this.onClubAdded,
  });

  @override
  State<AddClubDialog> createState() => _AddClubDialogState();
}

class _AddClubDialogState extends State<AddClubDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _bannerUrlController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _facebookController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _primaryColorController = TextEditingController(text: '#1E3A8A');
  final _secondaryColorController = TextEditingController(text: '#3B82F6');

  final UserClubFollowingService _clubService = UserClubFollowingService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _selectedCategory = 'technology';
  String? _selectedDepartment;
  String? _selectedFaculty;
  int? _establishedYear;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'technology',
    'sports',
    'cultural',
    'academic',
    'social',
    'career',
    'arts',
    'music',
    'science',
    'literature',
    'volunteering',
    'business'
  ];

  final List<String> _departments = [
    'Bilgisayar Mühendisliği',
    'Endüstri Mühendisliği',
    'Elektrik-Elektronik Mühendisliği',
    'İnşaat Mühendisliği',
    'Makine Mühendisliği',
    'Tıp',
    'Hukuk',
    'İşletme',
    'İktisat',
    'Psikoloji',
    'İletişim',
    'Mimarlık',
    'Diğer'
  ];

  final List<String> _faculties = [
    'Mühendislik Fakültesi',
    'Tıp Fakültesi',
    'Hukuk Fakültesi',
    'İktisadi ve İdari Bilimler Fakültesi',
    'İletişim Fakültesi',
    'Güzel Sanatlar Fakültesi',
    'Eğitim Fakültesi',
    'Fen Edebiyat Fakültesi',
    'Sağlık Bilimleri Fakültesi',
    'Diğer'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
    _bannerUrlController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppThemes.getSurfaceColor(context),
      insetPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header / Başlık
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppThemes.getPrimaryColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusMedium),
                  topRight: Radius.circular(AppConstants.radiusMedium),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yeni Kulüp Oluştur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Content / Form İçeriği
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information / Temel Bilgiler
                      _buildSectionHeader('Temel Bilgiler'),
                      
                      _buildTextField(
                        controller: _nameController,
                        label: 'Kulüp Adı',
                        hint: 'Kulübün resmi adı',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Kulüp adı gerekli' : null,
                        icon: Icons.group,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: _displayNameController,
                        label: 'Görüntülenecek Ad',
                        hint: 'Kulübün kısa adı (opsiyonel)',
                        icon: Icons.badge,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Açıklama',
                        hint: 'Kulüp hakkında kısa bilgi',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Açıklama gerekli' : null,
                        icon: Icons.description,
                        maxLines: 3,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Category & Academic Info / Kategori & Akademik Bilgi
                      _buildSectionHeader('Kategori & Akademik Bilgi'),

                      _buildDropdown<String>(
                        value: _selectedCategory,
                        label: 'Kategori',
                        items: _categories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryLabel(category)),
                        )).toList(),
                        onChanged: (value) => setState(() {
                          _selectedCategory = value!;
                        }),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String?>(
                              value: _selectedFaculty,
                              label: 'Fakülte',
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Seçiniz'),
                                ),
                                ..._faculties.map((faculty) => DropdownMenuItem(
                                  value: faculty,
                                  child: Text(faculty),
                                )),
                              ],
                              onChanged: (value) => setState(() {
                                _selectedFaculty = value;
                              }),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildDropdown<String?>(
                              value: _selectedDepartment,
                              label: 'Bölüm',
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Seçiniz'),
                                ),
                                ..._departments.map((dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                )),
                              ],
                              onChanged: (value) => setState(() {
                                _selectedDepartment = value;
                              }),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: TextEditingController(
                          text: _establishedYear?.toString() ?? '',
                        ),
                        label: 'Kuruluş Yılı (Opsiyonel)',
                        hint: 'örn: 2020',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _establishedYear = int.tryParse(value),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Contact Information / İletişim Bilgileri
                      _buildSectionHeader('İletişim Bilgileri'),

                      _buildTextField(
                        controller: _emailController,
                        label: 'E-posta (Opsiyonel)',
                        hint: 'kulup@medipol.edu.tr',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: _websiteController,
                        label: 'Website (Opsiyonel)',
                        hint: 'https://kulup.medipol.edu.tr',
                        icon: Icons.language,
                        keyboardType: TextInputType.url,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Social Media / Sosyal Medya
                      _buildSectionHeader('Sosyal Medya (Opsiyonel)'),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _instagramController,
                              label: 'Instagram',
                              hint: '@kulupadi',
                              icon: Icons.camera_alt,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildTextField(
                              controller: _twitterController,
                              label: 'Twitter',
                              hint: '@kulupadi',
                              icon: Icons.alternate_email,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _facebookController,
                              label: 'Facebook',
                              hint: 'kulup.adi',
                              icon: Icons.facebook,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildTextField(
                              controller: _linkedinController,
                              label: 'LinkedIn',
                              hint: 'kulup-adi',
                              icon: Icons.business,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Visual Identity / Görsel Kimlik
                      _buildSectionHeader('Görsel Kimlik (Opsiyonel)'),

                      _buildTextField(
                        controller: _logoUrlController,
                        label: 'Logo URL\'i',
                        hint: 'https://example.com/logo.png',
                        icon: Icons.image,
                        keyboardType: TextInputType.url,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildTextField(
                        controller: _bannerUrlController,
                        label: 'Banner URL\'i',
                        hint: 'https://example.com/banner.jpg',
                        icon: Icons.panorama,
                        keyboardType: TextInputType.url,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Colors / Renkler
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _primaryColorController,
                              label: 'Ana Renk',
                              hint: '#1E3A8A',
                              icon: Icons.palette,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildTextField(
                              controller: _secondaryColorController,
                              label: 'İkinci Renk',
                              hint: '#3B82F6',
                              icon: Icons.color_lens,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Status / Durum
                      CheckboxListTile(
                        value: _isActive,
                        onChanged: (value) => setState(() {
                          _isActive = value ?? true;
                        }),
                        title: const Text('Aktif Kulüp'),
                        subtitle: const Text('Kulüp şu anda aktif mi?'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons / Aksiyon Butonları
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createClub,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.getPrimaryColor(context),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Oluştur'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppThemes.getPrimaryColor(context),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        filled: true,
        fillColor: AppThemes.getBackgroundColor(context),
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        filled: true,
        fillColor: AppThemes.getBackgroundColor(context),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentAppUser;
      if (user == null) {
        _showErrorSnackBar('Kullanıcı bulunamadı');
        return;
      }

      // Kulüp ID oluştur
      final clubId = FirebaseFirestore.instance.collection('clubs').doc().id;

      // Club nesnesini oluştur
      final club = Club(
        clubId: clubId,
        name: _nameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty 
            ? _nameController.text.trim() 
            : _displayNameController.text.trim(),
        description: _descriptionController.text.trim(),
        logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
        bannerUrl: _bannerUrlController.text.trim().isEmpty ? null : _bannerUrlController.text.trim(),
        colors: ClubColors(
          primary: _primaryColorController.text.trim(),
          secondary: _secondaryColorController.text.trim(),
        ),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        socialMedia: SocialMedia(
          instagram: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
          twitter: _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
          facebook: _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
          linkedin: _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
        ),
        category: _selectedCategory,
        department: _selectedDepartment,
        faculty: _selectedFaculty,
        establishedYear: _establishedYear,
        isActive: _isActive,
        adminIds: [user.id], // Kulüp oluşturan kişiyi admin yap
        status: ClubStatus.active, // Aktif durumu
        verificationStatus: VerificationStatus.pending,
        createdBy: user.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Firebase'e kaydet
      await _clubService.createClub(club);

      if (mounted) {
        _showSuccessSnackBar('Kulüp başarıyla oluşturuldu ve onay için gönderildi');
        widget.onClubAdded?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Kulüp oluşturulurken hata: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'technology': return 'Teknoloji';
      case 'sports': return 'Spor';
      case 'cultural': return 'Kültürel';
      case 'academic': return 'Akademik';
      case 'social': return 'Sosyal';
      case 'career': return 'Kariyer';
      case 'arts': return 'Sanat';
      case 'music': return 'Müzik';
      case 'science': return 'Bilim';
      case 'literature': return 'Edebiyat';
      case 'volunteering': return 'Gönüllülük';
      case 'business': return 'İşletme';
      default: return category;
    }
  }
}