import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../models/user_event_models.dart';
import '../../services/user_events_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../l10n/app_localizations.dart';

/// Dialog for editing existing events
/// Mevcut etkinlikleri düzenleme dialog'u
class EditEventDialog extends StatefulWidget {
  final Event event;
  final Function()? onEventUpdated;

  const EditEventDialog({
    super.key,
    required this.event,
    this.onEventUpdated,
  });

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  final UserEventsService _eventsService = UserEventsService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  late DateTime _startDateTime;
  late DateTime _endDateTime;
  late String _selectedEventType;
  late String _selectedCategory;
  late String _selectedOrganizerType;
  late bool _requiresRegistration;
  int? _maxCapacity;
  DateTime? _registrationDeadline;
  late List<String> _tags;
  bool _isLoading = false;

  final List<String> _eventTypes = [
    'conference',
    'workshop', 
    'social',
    'sports',
    'competition',
    'seminar',
    'meeting',
    'training',
    'other',
  ];

  final List<String> _categories = [
    'student',
    'academic',
    'career',
    'cultural',
    'technology',
    'science',
    'arts',
    'volunteer',
    'other',
  ];

  final List<String> _organizerTypes = [
    'student_organization',
    'university_department',
    'faculty',
    'career_center',
    'library',
    'student_affairs',
    'external_partner',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromEvent();
  }

  /// Initialize form fields from existing event
  /// Mevcut etkinlikten form alanlarını başlat
  void _initializeFromEvent() {
    final event = widget.event;
    
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    // _buildingController.text = event.buildingNumber ?? ''; // Not available in current Event model
    // _roomController.text = event.roomNumber ?? ''; // Not available in current Event model
    _imageUrlController.text = event.imageUrl ?? '';
    
    _startDateTime = event.startDateTime;
    _endDateTime = event.endDateTime ?? event.startDateTime.add(const Duration(hours: 1));
    _selectedEventType = event.eventType;
    _selectedCategory = event.category;
    _selectedOrganizerType = event.organizerType;
    _requiresRegistration = event.requiresRegistration;
    _maxCapacity = event.maxCapacity;
    _registrationDeadline = event.registrationDeadline;
    _tags = List<String>.from(event.tags);
  }

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppThemes.getPrimaryColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusMedium),
                  topRight: Radius.circular(AppConstants.radiusMedium),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      'Etkinliği Düzenle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Etkinlik Başlığı *',
                          hintText: 'Etkinlik adını girin...',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Başlık gereklidir';
                          }
                          if (value.length < 3) {
                            return 'Başlık en az 3 karakter olmalıdır';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama *',
                          hintText: 'Etkinlik detaylarını yazın...',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Açıklama gereklidir';
                          }
                          if (value.length < 10) {
                            return 'Açıklama en az 10 karakter olmalıdır';
                          }
                          return null;
                        },
                        maxLength: 500,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Event Type and Category
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedEventType,
                              decoration: const InputDecoration(
                                labelText: 'Etkinlik Türü',
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _eventTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getEventTypeDisplayName(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEventType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Kategori',
                                prefixIcon: Icon(Icons.label),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(_getCategoryDisplayName(category)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectStartDateTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Başlangıç Tarihi',
                                  prefixIcon: Icon(Icons.event),
                                ),
                                child: Text(
                                  _formatDateTime(_startDateTime),
                                  style: TextStyle(
                                    color: AppThemes.getTextColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: InkWell(
                              onTap: _selectEndDateTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Bitiş Tarihi',
                                  prefixIcon: Icon(Icons.event_busy),
                                ),
                                child: Text(
                                  _formatDateTime(_endDateTime),
                                  style: TextStyle(
                                    color: AppThemes.getTextColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Konum *',
                          hintText: 'Etkinlik yerini girin...',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konum gereklidir';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Building and Room
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _buildingController,
                              decoration: const InputDecoration(
                                labelText: 'Bina No',
                                hintText: 'A1, B2, vs.',
                                prefixIcon: Icon(Icons.business),
                              ),
                              maxLength: 10,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: TextFormField(
                              controller: _roomController,
                              decoration: const InputDecoration(
                                labelText: 'Oda No',
                                hintText: '101, 205, vs.',
                                prefixIcon: Icon(Icons.meeting_room),
                              ),
                              maxLength: 10,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Registration settings
                      SwitchListTile(
                        title: Text('Registration Required'),
                        subtitle: Text('Participants need to register in advance'),
                        value: _requiresRegistration,
                        onChanged: (value) {
                          setState(() {
                            _requiresRegistration = value;
                            if (!value) {
                              _maxCapacity = null;
                              _registrationDeadline = null;
                            }
                          });
                        },
                      ),

                      if (_requiresRegistration) ...[
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // Max capacity
                        TextFormField(
                          initialValue: _maxCapacity?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Maksimum Katılımcı',
                            hintText: 'Katılımcı sayısı sınırı...',
                            prefixIcon: Icon(Icons.people),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxCapacity = int.tryParse(value);
                          },
                          validator: (value) {
                            if (_requiresRegistration && 
                                (value == null || value.isEmpty)) {
                              return 'Kayıt gerekiyorsa maksimum katılımcı belirtmelisiniz';
                            }
                            if (value != null && value.isNotEmpty) {
                              final capacity = int.tryParse(value);
                              if (capacity == null || capacity <= 0) {
                                return 'Geçerli bir sayı girin';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.paddingMedium),

                        // Registration deadline
                        InkWell(
                          onTap: _selectRegistrationDeadline,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Kayıt Son Tarihi',  
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _registrationDeadline != null
                                  ? _formatDateTime(_registrationDeadline!)
                                  : 'Tarih seçin...',
                              style: TextStyle(
                                color: _registrationDeadline != null
                                    ? AppThemes.getTextColor(context)
                                    : AppThemes.getSecondaryTextColor(context),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Etkinlik Görseli (URL)',
                          hintText: 'https://example.com/image.jpg',
                          prefixIcon: Icon(Icons.image),
                        ),
                        validator: (value) {
                          if (value != null && 
                              value.isNotEmpty && 
                              !Uri.tryParse(value)!.isAbsolute) {
                            return 'Geçerli bir URL girin';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context), 
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.getPrimaryColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.updateEvent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods

  String _getEventTypeDisplayName(String type) {
    const displayNames = {
      'conference': 'Konferans',
      'workshop': 'Workshop',
      'social': 'Sosyal',
      'sports': 'Spor',
      'competition': 'Yarışma',
      'seminar': 'Seminer',
      'meeting': 'Toplantı',
      'training': 'Eğitim',
      'other': 'Diğer',
    };
    return displayNames[type] ?? type;
  }

  String _getCategoryDisplayName(String category) {
    const displayNames = {
      'student': 'Öğrenci',
      'academic': 'Akademik',
      'career': 'Kariyer',
      'cultural': 'Kültürel',
      'technology': 'Teknoloji',
      'science': 'Bilim',
      'arts': 'Sanat',
      'volunteer': 'Gönüllülük',
      'other': 'Diğer',
    };  
    return displayNames[category] ?? category;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDateTime),
      );
      if (time != null) {
        setState(() {
          _startDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          // Ensure end time is after start time
          if (_endDateTime.isBefore(_startDateTime)) {
            _endDateTime = _startDateTime.add(const Duration(hours: 1));
          }
        });
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDateTime,
      firstDate: _startDateTime,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDateTime),
      );
      if (time != null) {
        final newEndDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (newEndDateTime.isAfter(_startDateTime)) {
          setState(() {
            _endDateTime = newEndDateTime;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End date must be after start date'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectRegistrationDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _registrationDeadline ?? _startDateTime.subtract(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: _startDateTime,
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _registrationDeadline != null 
            ? TimeOfDay.fromDateTime(_registrationDeadline!)
            : const TimeOfDay(hour: 23, minute: 59),
      );
      if (time != null) {
        setState(() {
          _registrationDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.currentAppUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Create updated event object
      final updatedEvent = widget.event.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        // Note: buildingNumber and roomNumber are not currently in Event model
        // These fields would need to be added to the Event model if needed
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        eventType: _selectedEventType,
        category: _selectedCategory,
        organizerType: _selectedOrganizerType,
        requiresRegistration: _requiresRegistration,
        maxCapacity: _maxCapacity,
        registrationDeadline: _registrationDeadline,
        imageUrl: _imageUrlController.text.trim().isNotEmpty 
            ? _imageUrlController.text.trim() 
            : null,
        tags: _tags,
        updatedAt: DateTime.now(),
        updatedBy: currentUser.id,
      );

      await _eventsService.updateEvent(widget.event.eventId, updatedEvent);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.eventUpdated),
            backgroundColor: Colors.green,
          ),
        );
        widget.onEventUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
}