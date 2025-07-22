import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../models/user_event_models.dart';
import '../../services/user_events_service.dart';
import '../../services/firebase_auth_service.dart';

/// Dialog for adding new events
/// Yeni etkinlik ekleme dialog'u
class AddEventDialog extends StatefulWidget {
  final Function()? onEventAdded;

  const AddEventDialog({
    super.key,
    this.onEventAdded,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  final UserEventsService _eventsService = UserEventsService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  DateTime _startDateTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endDateTime = DateTime.now().add(const Duration(hours: 2));
  String _selectedEventType = 'social';
  String _selectedCategory = 'student';
  String _selectedOrganizerType = 'student_organization';
  bool _requiresRegistration = false;
  int? _maxCapacity;
  DateTime? _registrationDeadline;
  List<String> _tags = [];
  bool _isLoading = false;

  final List<String> _eventTypes = [
    'conference',
    'workshop', 
    'social',
    'sports',
    'cultural',
    'academic',
    'career'
  ];

  final List<String> _categories = [
    'student',
    'academic',
    'cultural',
    'sports',
    'career',
    'technology',
    'health'
  ];

  final List<String> _organizerTypes = [
    'university',
    'club', 
    'department',
    'student_organization'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    _imageUrlController.dispose();
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
        constraints: const BoxConstraints(maxHeight: 600),
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
                    'Yeni Etkinlik Oluştur',
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
                      // Title / Başlık
                      _buildTextField(
                        controller: _titleController,
                        label: 'Etkinlik Adı',
                        hint: 'Etkinliğin adını girin',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Etkinlik adı gerekli' : null,
                        icon: Icons.event,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Description / Açıklama
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Açıklama',
                        hint: 'Etkinlik hakkında detaylar',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Açıklama gerekli' : null,
                        icon: Icons.description,
                        maxLines: 3,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Event Type & Category / Etkinlik Türü & Kategori
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              value: _selectedEventType,
                              label: 'Etkinlik Türü',
                              items: _eventTypes.map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(_getEventTypeLabel(type)),
                              )).toList(),
                              onChanged: (value) => setState(() {
                                _selectedEventType = value!;
                              }),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildDropdown<String>(
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
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Location Details / Konum Detayları
                      _buildTextField(
                        controller: _locationController,
                        label: 'Konum',
                        hint: 'Etkinlik konumu',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Konum gerekli' : null,
                        icon: Icons.location_on,
                      ),

                      const SizedBox(height: AppConstants.paddingSmall),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _buildingController,
                              label: 'Bina',
                              hint: 'Bina adı (opsiyonel)',
                              icon: Icons.business,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: _buildTextField(
                              controller: _roomController,
                              label: 'Oda',
                              hint: 'Oda numarası (opsiyonel)',
                              icon: Icons.room,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Date & Time / Tarih & Saat
                      _buildDateTimePicker(
                        label: 'Başlangıç Tarihi & Saati',
                        dateTime: _startDateTime,
                        onChanged: (dateTime) => setState(() {
                          _startDateTime = dateTime;
                          // Bitiş saati otomatik olarak 1 saat sonra ayarla
                          if (_endDateTime.isBefore(_startDateTime)) {
                            _endDateTime = _startDateTime.add(const Duration(hours: 1));
                          }
                        }),
                      ),

                      const SizedBox(height: AppConstants.paddingSmall),

                      _buildDateTimePicker(
                        label: 'Bitiş Tarihi & Saati',
                        dateTime: _endDateTime,
                        onChanged: (dateTime) => setState(() {
                          _endDateTime = dateTime;
                        }),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Registration Settings / Kayıt Ayarları
                      CheckboxListTile(
                        value: _requiresRegistration,
                        onChanged: (value) => setState(() {
                          _requiresRegistration = value ?? false;
                        }),
                        title: const Text('Kayıt Gerekli'),
                        subtitle: const Text('Etkinliğe katılım için önceden kayıt'),
                        contentPadding: EdgeInsets.zero,
                      ),

                      if (_requiresRegistration) ...[
                        _buildTextField(
                          controller: TextEditingController(
                            text: _maxCapacity?.toString() ?? '',
                          ),
                          label: 'Maksimum Kapasite',
                          hint: 'Katılımcı sayısı limiti (opsiyonel)',
                          icon: Icons.people,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _maxCapacity = int.tryParse(value),
                        ),
                      ],

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Image URL / Görsel URL'i
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'Görsel URL\'i (Opsiyonel)',
                        hint: 'https://example.com/image.jpg',
                        icon: Icons.image,
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
                    onPressed: _isLoading ? null : _createEvent,
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

  Widget _buildDateTimePicker({
    required String label,
    required DateTime dateTime,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppThemes.getTextColor(context),
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        GestureDetector(
          onTap: () => _selectDateTime(dateTime, onChanged),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              color: AppThemes.getBackgroundColor(context),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(DateTime initialDate, Function(DateTime) onChanged) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onChanged(newDateTime);
      }
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endDateTime.isBefore(_startDateTime)) {
      _showErrorSnackBar('Bitiş tarihi başlangıç tarihinden önce olamaz');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentAppUser;
      if (user == null) {
        _showErrorSnackBar('Kullanıcı bulunamadı');
        return;
      }

      // Etkinlik ID oluştur
      final eventId = FirebaseFirestore.instance.collection('events').doc().id;

      // Event nesnesini oluştur
      final event = Event(
        eventId: eventId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        eventType: _selectedEventType,
        category: _selectedCategory,
        location: _locationController.text.trim(),
        building: _buildingController.text.trim().isEmpty ? null : _buildingController.text.trim(),
        room: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        maxCapacity: _maxCapacity,
        requiresRegistration: _requiresRegistration,
        registrationDeadline: _requiresRegistration ? _startDateTime.subtract(const Duration(hours: 1)) : null,
        organizerId: user.id,
        organizerName: user.displayName.isEmpty ? 'Anonymous' : user.displayName,
        organizerType: _selectedOrganizerType,
        createdBy: user.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: _tags,
        keywords: _titleController.text.trim().toLowerCase().split(' '),
      );

      // Firebase'e kaydet
      await _eventsService.createEvent(event);

      if (mounted) {
        _showSuccessSnackBar('Etkinlik başarıyla oluşturuldu');
        widget.onEventAdded?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Etkinlik oluşturulurken hata: $e');
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

  String _getEventTypeLabel(String type) {
    switch (type) {
      case 'conference': return 'Konferans';
      case 'workshop': return 'Workshop';
      case 'social': return 'Sosyal';
      case 'sports': return 'Spor';
      case 'cultural': return 'Kültürel';
      case 'academic': return 'Akademik';
      case 'career': return 'Kariyer';
      default: return type;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'student': return 'Öğrenci';
      case 'academic': return 'Akademik';
      case 'cultural': return 'Kültürel';
      case 'sports': return 'Spor';
      case 'career': return 'Kariyer';
      case 'technology': return 'Teknoloji';
      case 'health': return 'Sağlık';
      default: return category;
    }
  }
}