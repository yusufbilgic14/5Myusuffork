import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../l10n/app_localizations.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
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
    {
      'nameKey': 'requestCategoryAcademicSupport',
      'icon': Icons.school,
      'color': Colors.blue,
    },
    {
      'nameKey': 'requestCategoryTechnicalHelp',
      'icon': Icons.build,
      'color': Colors.orange,
    },
    {
      'nameKey': 'requestCategoryLibrary',
      'icon': Icons.library_books,
      'color': Colors.green,
    },
    {
      'nameKey': 'requestCategoryCafeteria',
      'icon': Icons.restaurant,
      'color': Colors.red,
    },
    {
      'nameKey': 'requestCategoryTransport',
      'icon': Icons.directions_bus,
      'color': Colors.purple,
    },
    {
      'nameKey': 'requestCategorySecurity',
      'icon': Icons.security,
      'color': Colors.red[700],
    },
    {
      'nameKey': 'requestCategoryFinance',
      'icon': Icons.account_balance_wallet,
      'color': Colors.indigo,
    },
    {
      'nameKey': 'requestCategoryGeneral',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.grey[600],
    },
  ];

  // Geri bildirim kategorileri / Feedback categories
  final List<Map<String, dynamic>> _geriBildirimCategories = [
    {
      'nameKey': 'feedbackCategoryBugReport',
      'icon': Icons.bug_report,
      'color': Colors.red,
    },
    {
      'nameKey': 'feedbackCategorySuggestion',
      'icon': Icons.lightbulb,
      'color': Colors.orange,
    },
    {
      'nameKey': 'feedbackCategoryComplaint',
      'icon': Icons.error_outline,
      'color': Colors.red[700],
    },
    {
      'nameKey': 'feedbackCategoryAppreciation',
      'icon': Icons.thumb_up,
      'color': Colors.green,
    },
    {
      'nameKey': 'feedbackCategoryFeatureRequest',
      'icon': Icons.add_circle_outline,
      'color': Colors.blue,
    },
    {
      'nameKey': 'feedbackCategoryAppReview',
      'icon': Icons.rate_review,
      'color': Colors.purple,
    },
    {
      'nameKey': 'feedbackCategoryGeneral',
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

  // Tip seçim widget'ı (Talep/Geri Bildirim) / Type selection widget (Request/Feedback)
  Widget _buildTypeSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.what_do_you_want_to_do,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
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
                        ? theme.colorScheme.primary
                        : theme.cardColor,
                    border: Border.all(
                      color: _selectedType == 'talep'
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _selectedType == 'talep'
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
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
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.request,
                        style: TextStyle(
                          color: _selectedType == 'talep'
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
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
                        ? theme.colorScheme.primary
                        : theme.cardColor,
                    border: Border.all(
                      color: _selectedType == 'geri_bildirim'
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _selectedType == 'geri_bildirim'
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
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
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.feedback,
                        style: TextStyle(
                          color: _selectedType == 'geri_bildirim'
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
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
  Widget _buildCategorySelection(ThemeData theme) {
    if (_selectedType.isEmpty) {
      return const SizedBox.shrink(); // Tip seçilmemişse gösterme / Don't show if type not selected
    }

    final categories = _selectedType == 'talep'
        ? _talepCategories
        : _geriBildirimCategories;
    final title = _selectedType == 'talep'
        ? AppLocalizations.of(context)!.select_request_category
        : AppLocalizations.of(context)!.select_feedback_category;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
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
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.cardColor,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
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
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : category['color'],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _localizedCategoryName(context, category['nameKey']),
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.textTheme.bodyMedium?.color,
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
  Widget _buildAppRatingText(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // TODO: App Store veya Play Store'a yönlendir / Redirect to App Store or Play Store
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.redirect_to_app_store),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.star_rate, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.rate_and_comment_app,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Form alanları widget'ı / Form fields widget
  Widget _buildFormFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Anonim geri bildirim seçeneği - sadece geri bildirim türü için / Anonymous feedback option - only for feedback type
        if (_selectedType != 'talep') ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.anonymous_feedback,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.keep_my_identity_private,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
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
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 20), // Spacing after anonymous section
        ],
        // Departman seçimi / Department selection
        Text(
          AppLocalizations.of(context)!.relevant_department,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDepartment.isEmpty ? null : _selectedDepartment,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.select_department,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
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
              return AppLocalizations.of(context)!.please_select_department;
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Öncelik seviyesi / Priority level
        Text(
          AppLocalizations.of(context)!.priority_level,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
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
                    color: isSelected ? color : theme.cardColor,
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.onPrimary : color,
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
          Text(
            AppLocalizations.of(context)!.email_address,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.example_email,
              prefixIcon: Icon(Icons.email, color: theme.iconTheme.color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
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
                      return AppLocalizations.of(
                        context,
                      )!.email_address_required;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)!.valid_email_address;
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 20),
        ],

        // Konu / Subject
        Text(
          AppLocalizations.of(context)!.subject,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.feedback_subject,
            prefixIcon: Icon(Icons.subject, color: theme.iconTheme.color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.subject_required;
            }
            if (value.length < 5) {
              return AppLocalizations.of(context)!.subject_min_length;
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Mesaj / Message
        Text(
          AppLocalizations.of(context)!.detailed_description,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 6,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.describe_your_feedback,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.description_required;
            }
            if (value.length < 20) {
              return AppLocalizations.of(context)!.description_min_length;
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Dosya ekleme bölümü / File attachment section
        _buildFileAttachment(theme),
      ],
    );
  }

  // Dosya ekleme widget'ı / File attachment widget
  Widget _buildFileAttachment(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.add_photo_or_document,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
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
              color: theme.cardColor,
              border: Border.all(
                color: theme.dividerColor,
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
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.click_to_select_file,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.file_types_max_size,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
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
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selected_files,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
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
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeFile(index),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.error,
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
        content: Text('${AppLocalizations.of(context)!.file_added} $fileName'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
          content: Text(
            '${AppLocalizations.of(context)!.file_removed} $fileName',
          ),
          backgroundColor:
              Theme.of(context).colorScheme.tertiary ??
              Theme.of(context).colorScheme.secondary,
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
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.please_select_feedback_or_request_type,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedType == 'talep'
                ? AppLocalizations.of(context)!.please_select_request_category
                : AppLocalizations.of(context)!.please_select_feedback_category,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.your_feedback_submitted_successfully,
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          duration: const Duration(seconds: 3),
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

  String _localizedCategoryName(BuildContext context, String key) {
    switch (key) {
      case 'requestCategoryAcademicSupport':
        return AppLocalizations.of(context)!.requestCategoryAcademicSupport;
      case 'requestCategoryTechnicalHelp':
        return AppLocalizations.of(context)!.requestCategoryTechnicalHelp;
      case 'requestCategoryLibrary':
        return AppLocalizations.of(context)!.requestCategoryLibrary;
      case 'requestCategoryCafeteria':
        return AppLocalizations.of(context)!.requestCategoryCafeteria;
      case 'requestCategoryTransport':
        return AppLocalizations.of(context)!.requestCategoryTransport;
      case 'requestCategorySecurity':
        return AppLocalizations.of(context)!.requestCategorySecurity;
      case 'requestCategoryFinance':
        return AppLocalizations.of(context)!.requestCategoryFinance;
      case 'requestCategoryGeneral':
        return AppLocalizations.of(context)!.requestCategoryGeneral;
      case 'feedbackCategoryBugReport':
        return AppLocalizations.of(context)!.feedbackCategoryBugReport;
      case 'feedbackCategorySuggestion':
        return AppLocalizations.of(context)!.feedbackCategorySuggestion;
      case 'feedbackCategoryComplaint':
        return AppLocalizations.of(context)!.feedbackCategoryComplaint;
      case 'feedbackCategoryAppreciation':
        return AppLocalizations.of(context)!.feedbackCategoryAppreciation;
      case 'feedbackCategoryFeatureRequest':
        return AppLocalizations.of(context)!.feedbackCategoryFeatureRequest;
      case 'feedbackCategoryAppReview':
        return AppLocalizations.of(context)!.feedbackCategoryAppReview;
      case 'feedbackCategoryGeneral':
        return AppLocalizations.of(context)!.feedbackCategoryGeneral;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawerWidget(
        currentPageIndex: -1,
      ), // Feedback sayfası navigasyon dışında / Feedback page is outside navigation
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.feedback,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            tooltip: AppLocalizations.of(context)!.clear_form,
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
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.your_feedback_is_valuable,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.share_your_opinions_and_suggestions_for_better_app,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Uygulama puanlama metni / App rating text
              _buildAppRatingText(theme),

              const SizedBox(height: 24),

              // Tip seçimi (Talep/Geri Bildirim) / Type selection (Request/Feedback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _buildTypeSelection(theme),
              ),

              // Kategori seçimi - sadece tip seçildiyse göster / Category selection - only show if type is selected
              if (_selectedType.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.08),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: _buildCategorySelection(theme),
                ),
              ],

              const SizedBox(height: 24),

              // Form alanları / Form fields
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _buildFormFields(theme),
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
                        side: BorderSide(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.clear,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
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
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.submitting,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              AppLocalizations.of(context)!.send_feedback,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
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
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex:
            -1, // Feedback sayfası navigasyon dışında / Feedback page is outside navigation
      ),
    );
  }
}
