import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'campus_map_screen.dart';
import 'qr_access_screen.dart';
import 'profile_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedIndex = -1; // Feedback screen - no bottom nav selection

  // Form controllers / Form kontrolleri
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  // Form state variables / Form durum değişkenleri
  String _selectedCategory = '';
  String _selectedDepartment = '';
  String _selectedPriority = 'Medium';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  String _selectedType =
      ''; // 'talep' veya 'geri_bildirim' / 'request' or 'feedback'
  List<String> _attachedFiles = []; // Eklenen dosyalar / Attached files

  // Talep kategorileri / Request categories
  final List<Map<String, dynamic>> _talepCategories = [
    {'name': 'Akademik Destek', 'icon': Icons.school, 'color': Colors.blue},
    {'name': 'Teknik Yardım', 'icon': Icons.build, 'color': Colors.orange},
    {
      'name': 'Kütüphane Hizmetleri',
      'icon': Icons.library_books,
      'color': Colors.green,
    },
    {
      'name': 'Yemekhane Hizmetleri',
      'icon': Icons.restaurant,
      'color': Colors.red,
    },
    {
      'name': 'Ulaşım Talebi',
      'icon': Icons.directions_bus,
      'color': Colors.purple,
    },
    {
      'name': 'Güvenlik Desteği',
      'icon': Icons.security,
      'color': Colors.red[700],
    },
    {
      'name': 'Mali İşler',
      'icon': Icons.account_balance_wallet,
      'color': Colors.indigo,
    },
    {
      'name': 'Genel Talep',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.grey[600],
    },
  ];

  // Geri bildirim kategorileri / Feedback categories
  final List<Map<String, dynamic>> _geriBildirimCategories = [
    {'name': 'Hata Bildirimi', 'icon': Icons.bug_report, 'color': Colors.red},
    {'name': 'Öneri', 'icon': Icons.lightbulb, 'color': Colors.orange},
    {'name': 'Şikayet', 'icon': Icons.error_outline, 'color': Colors.red[700]},
    {'name': 'Takdir', 'icon': Icons.thumb_up, 'color': Colors.green},
    {
      'name': 'Özellik İsteği',
      'icon': Icons.add_circle_outline,
      'color': Colors.blue,
    },
    {
      'name': 'Uygulama Yorumu',
      'icon': Icons.rate_review,
      'color': Colors.purple,
    },
    {
      'name': 'Genel Geri Bildirim',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.grey[600],
    },
  ];

  // Departman listesi / Department list
  final List<String> _departments = [
    'Information Technology',
    'Academic Affairs',
    'Student Services',
    'Facilities Management',
    'Library Services',
    'Cafeteria Services',
    'Transportation',
    'Security',
    'Financial Aid',
    'General Administration',
  ];

  // Öncelik seviyeleri / Priority levels
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Sidebar drawer oluştur / Build sidebar drawer
  Widget _buildSideDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1E3A8A),
      child: SafeArea(
        child: Column(
          children: [
            // Üst profil bölümü / Top profile section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profil resmi / Profile picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/elifyılmaz.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Kullanıcı adı / Username
                  const Text(
                    'Elif Yılmaz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Bölüm bilgisi / Department info
                  const Text(
                    'MIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Text(
                    '3rd Grade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Ayırıcı çizgi / Divider line
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white.withValues(alpha: 0.3),
            ),

            const SizedBox(height: 20),

            // Menü öğeleri / Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.event,
                    title: 'Upcoming Events',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Upcoming Events sayfasına git
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.school,
                    title: 'Course Grades',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Course Grades sayfasına git
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.restaurant,
                    title: 'Cafeteria Menu',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Cafeteria Menu sayfasına git
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Notifications sayfasına git
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.feedback,
                    title: 'Feedbacks',
                    isSelected: true, // Bu sayfa seçili / This page is selected
                    onTap: () {
                      Navigator.pop(context);
                      // Zaten feedback sayfasındayız / Already on feedback page
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Settings sayfasına git
                    },
                  ),
                ],
              ),
            ),

            // Alt bölüm - Help ve Logout / Bottom section - Help and Logout
            Column(
              children: [
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Help sayfasına git
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red[300],
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Logout işlemi
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Drawer menü öğesi oluştur / Build drawer menu item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.white, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  // Tip seçim widget'ı (Talep/Geri Bildirim) / Type selection widget (Request/Feedback)
  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ne yapmak istiyorsunuz?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'talep';
                    _selectedCategory =
                        ''; // Kategori seçimini sıfırla / Reset category selection
                    _isAnonymous =
                        false; // Talep için anonim seçeneği sıfırla / Reset anonymous for request
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedType == 'talep'
                        ? const Color(0xFF1E3A8A)
                        : Colors.white,
                    border: Border.all(
                      color: _selectedType == 'talep'
                          ? const Color(0xFF1E3A8A)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _selectedType == 'talep'
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF1E3A8A,
                              ).withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.request_page,
                        color: _selectedType == 'talep'
                            ? Colors.white
                            : const Color(0xFF1E3A8A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Talep',
                        style: TextStyle(
                          color: _selectedType == 'talep'
                              ? Colors.white
                              : const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'geri_bildirim';
                    _selectedCategory =
                        ''; // Kategori seçimini sıfırla / Reset category selection
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedType == 'geri_bildirim'
                        ? const Color(0xFF1E3A8A)
                        : Colors.white,
                    border: Border.all(
                      color: _selectedType == 'geri_bildirim'
                          ? const Color(0xFF1E3A8A)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _selectedType == 'geri_bildirim'
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF1E3A8A,
                              ).withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.feedback,
                        color: _selectedType == 'geri_bildirim'
                            ? Colors.white
                            : const Color(0xFF1E3A8A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Geri Bildirim',
                        style: TextStyle(
                          color: _selectedType == 'geri_bildirim'
                              ? Colors.white
                              : const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Kategori seçim widget'ı / Category selection widget
  Widget _buildCategorySelection() {
    if (_selectedType.isEmpty) {
      return const SizedBox.shrink(); // Tip seçilmemişse gösterme / Don't show if type not selected
    }

    final categories = _selectedType == 'talep'
        ? _talepCategories
        : _geriBildirimCategories;
    final title = _selectedType == 'talep'
        ? 'Talep Kategorisi Seçin'
        : 'Geri Bildirim Kategorisi Seçin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF1E3A8A,
                            ).withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : category['color'],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Uygulama puanlama tıklama metni widget'ı / App rating clickable text widget
  Widget _buildAppRatingText() {
    return GestureDetector(
      onTap: () {
        // TODO: App Store veya Play Store'a yönlendir / Redirect to App Store or Play Store
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uygulama mağazasına yönlendirileceksiniz...'),
            backgroundColor: Color(0xFF1E3A8A),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_rate, color: Color(0xFF1E3A8A), size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Uygulamayı puanlamak ve yorum yapmak için tıklayınız',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A8A),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF1E3A8A),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Form alanları widget'ı / Form fields widget
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Anonim geri bildirim seçeneği - sadece geri bildirim türü için / Anonymous feedback option - only for feedback type
        if (_selectedType != 'talep') ...[
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anonim Geri Bildirim',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Text(
                      'Kimliğim gizli kalsın, anonim olarak geri bildirim göndermek istiyorum.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                    if (_isAnonymous) {
                      _emailController.clear();
                    }
                  });
                },
                activeColor: const Color(0xFF1E3A8A),
              ),
            ],
          ),
          const SizedBox(height: 20), // Spacing after anonymous section
        ],
        // Departman seçimi / Department selection
        const Text(
          'İlgili Departman',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDepartment.isEmpty ? null : _selectedDepartment,
          decoration: InputDecoration(
            hintText: 'Departman seçin',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _departments.map((department) {
            return DropdownMenuItem(value: department, child: Text(department));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDepartment = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen bir departman seçin';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Öncelik seviyesi / Priority level
        const Text(
          'Öncelik Seviyesi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _priorities.map((priority) {
            final isSelected = _selectedPriority == priority;
            final color = priority == 'Low'
                ? Colors.green
                : priority == 'Medium'
                ? Colors.orange
                : priority == 'High'
                ? Colors.red
                : Colors.red[800]!;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // E-posta adresi (anonim değilse veya talep türü seçildiyse) / Email address (if not anonymous or request type selected)
        if (!_isAnonymous || _selectedType == 'talep') ...[
          const Text(
            'E-posta Adresi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'ornek@medipol.edu.tr',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1E3A8A),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (!_isAnonymous || _selectedType == 'talep')
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta adresi gerekli';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 20),
        ],

        // Konu / Subject
        const Text(
          'Konu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          decoration: InputDecoration(
            hintText: 'Geri bildirim konusu',
            prefixIcon: const Icon(Icons.subject),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konu gerekli';
            }
            if (value.length < 5) {
              return 'Konu en az 5 karakter olmalı';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Mesaj / Message
        const Text(
          'Detaylı Açıklama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 6,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: 'Geri bildiriminizi detaylı olarak açıklayın...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Açıklama gerekli';
            }
            if (value.length < 20) {
              return 'Açıklama en az 20 karakter olmalı';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Dosya ekleme bölümü / File attachment section
        _buildFileAttachment(),
      ],
    );
  }

  // Dosya ekleme widget'ı / File attachment widget
  Widget _buildFileAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotoğraf veya Belge Ekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),

        // Dosya ekleme butonu / File add button
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dosya seçmek için tıklayın',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'JPG, PNG, PDF (Maksimum 10MB)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),

        // Seçilen dosyalar listesi / Selected files list
        if (_attachedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seçilen Dosyalar:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                ...(_attachedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final fileName = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(fileName),
                          size: 16,
                          color: const Color(0xFF1E3A8A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeFile(index),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Dosya seçme işlevi / File picking function
  void _pickFile() async {
    // Simülasyon için örnek dosya ekleme / Add example file for simulation
    final fileName = 'ornek_dosya_${_attachedFiles.length + 1}.pdf';
    setState(() {
      _attachedFiles.add(fileName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$fileName dosyası eklendi'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Dosya kaldırma işlevi / File removal function
  void _removeFile(int index) {
    setState(() {
      final fileName = _attachedFiles[index];
      _attachedFiles.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName dosyası kaldırıldı'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  // Dosya tipi ikonu / File type icon
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.attach_file;
    }
  }

  // Gönderme işlemi / Submit function
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen talep veya geri bildirim türünü seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedType == 'talep'
                ? 'Lütfen bir talep kategorisi seçin'
                : 'Lütfen bir geri bildirim kategorisi seçin',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simülasyon için bekle / Wait for simulation
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    // Başarı mesajı göster / Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Geri bildiriminiz başarıyla gönderildi! Teşekkür ederiz.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Formu temizle / Clear form
      _clearForm();
    }
  }

  // Formu temizle / Clear form
  void _clearForm() {
    _subjectController.clear();
    _messageController.clear();
    _emailController.clear();
    setState(() {
      _selectedCategory = '';
      _selectedDepartment = '';
      _selectedPriority = 'Medium';
      _selectedType = '';
      _isAnonymous = false;
      _attachedFiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: _buildSideDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: const Text(
          'Talep-Geri Bildirim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh),
            tooltip: 'Formu Temizle',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve açıklama / Title and description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          color: Color(0xFF1E3A8A),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Görüşleriniz Bizim İçin Değerli',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Medipol uygulamasını daha iyi hale getirmek için görüşlerinizi ve önerilerinizi bizimle paylaşın.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Uygulama puanlama metni / App rating text
              _buildAppRatingText(),

              const SizedBox(height: 24),

              // Tip seçimi (Talep/Geri Bildirim) / Type selection (Request/Feedback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _buildTypeSelection(),
              ),

              // Kategori seçimi - sadece tip seçildiyse göster / Category selection - only show if type is selected
              if (_selectedType.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: _buildCategorySelection(),
                ),
              ],

              const SizedBox(height: 24),

              // Form alanları / Form fields
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _buildFormFields(),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 32),

              // Gönder ve temizle butonları / Submit and clear buttons
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _clearForm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Temizle',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Gönderiliyor...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Geri Bildirim Gönder',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

      // Alt navigasyon çubuğu / Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
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
                _buildBottomNavItem(Icons.location_on, 'Navigation', 0),
                _buildBottomNavItem(Icons.calendar_today, 'Calendar', 1),
                _buildBottomNavItem(Icons.home, 'Home', 2),
                _buildBottomNavItem(Icons.qr_code_scanner, 'Scan', 3),
                _buildBottomNavItem(Icons.person, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Alt navigasyon öğesi oluşturucu / Bottom navigation item builder
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Farklı bir tab seçildiyse navigasyon yap / Navigate if different tab is selected
        switch (index) {
          case 0: // Navigation / Campus Map
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CampusMapScreen()),
            );
            break;
          case 1: // Calendar
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
            break;
          case 2: // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            break;
          case 3: // Scan / QR Access
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const QRAccessScreen()),
            );
            break;
          case 4: // Profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
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
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
