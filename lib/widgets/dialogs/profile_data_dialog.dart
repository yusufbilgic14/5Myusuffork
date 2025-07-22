import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile_model.dart';
import '../../services/user_profile_service.dart';

/// Profil veri toplama dialog'u / Profile data collection dialog
class ProfileDataDialog extends StatefulWidget {
  final UserProfile? currentProfile;
  final List<String> missingFields;
  final VoidCallback? onProfileUpdated;

  const ProfileDataDialog({
    super.key,
    this.currentProfile,
    this.missingFields = const [],
    this.onProfileUpdated,
  });

  @override
  State<ProfileDataDialog> createState() => _ProfileDataDialogState();
}

class _ProfileDataDialogState extends State<ProfileDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = UserProfileService();

  // Form controllers
  late TextEditingController _studentIdController;
  late TextEditingController _departmentController;
  late TextEditingController _facultyController;
  late TextEditingController _gradeController;
  late TextEditingController _gpaController;

  bool _isLoading = false;
  String? _selectedGrade;

  // Grade options
  final List<String> _gradeOptions = [
    '1. Sınıf',
    '2. Sınıf',
    '3. Sınıf',
    '4. Sınıf',
    'Yüksek Lisans',
    'Doktora',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final academicInfo = widget.currentProfile?.academicInfo;
    
    _studentIdController = TextEditingController(
      text: academicInfo?.studentId ?? '',
    );
    _departmentController = TextEditingController(
      text: academicInfo?.department ?? '',
    );
    _facultyController = TextEditingController(
      text: academicInfo?.faculty ?? '',
    );
    _gradeController = TextEditingController(
      text: academicInfo?.grade ?? '',
    );
    _gpaController = TextEditingController(
      text: academicInfo?.gpa?.toString() ?? '',
    );

    _selectedGrade = academicInfo?.grade;
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _departmentController.dispose();
    _facultyController.dispose();
    _gradeController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated academic info
      final updatedAcademicInfo = UserAcademicInfo(
        studentId: _studentIdController.text.trim(),
        department: _departmentController.text.trim(),
        faculty: _facultyController.text.trim(),
        grade: _selectedGrade,
        gpa: double.tryParse(_gpaController.text.trim()),
        // Keep existing values
        academicYear: widget.currentProfile?.academicInfo?.academicYear,
        totalCredits: widget.currentProfile?.academicInfo?.totalCredits,
        completedCredits: widget.currentProfile?.academicInfo?.completedCredits,
        enrollmentDate: widget.currentProfile?.academicInfo?.enrollmentDate,
        expectedGraduationDate: widget.currentProfile?.academicInfo?.expectedGraduationDate,
      );

      // Update academic info
      final success = await _profileService.updateAcademicInfo(updatedAcademicInfo);

      if (success) {
        // Refresh stats after profile update
        await _profileService.refreshStats();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Call callback and close dialog
          widget.onProfileUpdated?.call();
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppThemes.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppThemes.getPrimaryColor(context),
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    'Profili Tamamla',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.getTextColor(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Description
            Text(
              'Profilinizi tamamlamak için aşağıdaki bilgileri doldurun.',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppThemes.getSecondaryTextColor(context),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student ID
                      if (widget.missingFields.contains('student_id'))
                        _buildTextFormField(
                          controller: _studentIdController,
                          label: 'Öğrenci Numarası',
                          icon: Icons.badge,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bu alan zorunludur';
                            }
                            return null;
                          },
                        ),
                      
                      // Department
                      if (widget.missingFields.contains('department'))
                        _buildTextFormField(
                          controller: _departmentController,
                          label: 'Bölüm',
                          icon: Icons.school,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bu alan zorunludur';
                            }
                            return null;
                          },
                        ),
                      
                      // Faculty
                      if (widget.missingFields.contains('faculty'))
                        _buildTextFormField(
                          controller: _facultyController,
                          label: 'Fakülte',
                          icon: Icons.account_balance,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bu alan zorunludur';
                            }
                            return null;
                          },
                        ),
                      
                      // Grade
                      if (widget.missingFields.contains('grade'))
                        _buildDropdownField(
                          value: _selectedGrade,
                          onChanged: (value) {
                            setState(() {
                              _selectedGrade = value;
                              _gradeController.text = value ?? '';
                            });
                          },
                          items: _gradeOptions,
                          label: 'Sınıf',
                          icon: Icons.stairs,
                          isRequired: true,
                        ),
                      
                      // GPA (Optional)
                      _buildTextFormField(
                        controller: _gpaController,
                        label: 'Not Ortalaması (İsteğe bağlı)',
                        icon: Icons.grade,
                        isRequired: false,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final gpa = double.tryParse(value);
                            if (gpa == null || gpa < 0.0 || gpa > 4.0) {
                              return 'Geçerli bir not ortalaması girin (0.0 - 4.0)';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'İptal',
                    style: TextStyle(
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isRequired,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            borderSide: BorderSide(
              color: AppThemes.getPrimaryColor(context),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required void Function(String?) onChanged,
    required List<String> items,
    required String label,
    required IconData icon,
    required bool isRequired,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Bu alan zorunludur';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            borderSide: BorderSide(
              color: AppThemes.getPrimaryColor(context),
              width: 2,
            ),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}