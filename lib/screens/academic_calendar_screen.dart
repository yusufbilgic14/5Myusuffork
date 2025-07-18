import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../l10n/app_localizations.dart';

/// Akademik Takvim Sayfası / Academic Calendar Screen
class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Arama ve filtreleme / Search and filtering
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Tümü'; // Tümü, Mevcut, Yaklaşan, Geçmiş

  // Akademik takvim etkinlikleri / Academic calendar events
  final List<AcademicEvent> _allEvents = [
    AcademicEvent(
      title: 'Applications for Double Major/Minor Programs',
      titleTr: 'Çift Anadal/Yan Dal Başvuruları',
      startDate: DateTime(2024, 8, 19),
      endDate: DateTime(2024, 9, 2),
      category: EventCategory.registration,
      description: 'Çift anadal ve yan dal programlarına başvuru dönemi',
    ),
    AcademicEvent(
      title: 'Evaluation of Major/Minor Programme Applications',
      titleTr: 'Anadal/Yan Dal Başvuruları Değerlendirme',
      startDate: DateTime(2024, 9, 3),
      endDate: DateTime(2024, 9, 5),
      category: EventCategory.evaluation,
      description: 'Başvuruların değerlendirilmesi ve sonuçların belirlenmesi',
    ),
    AcademicEvent(
      title: 'Announcement of Major/Minor Programme Results',
      titleTr: 'Anadal/Yan Dal Sonuçları Açıklanması',
      startDate: DateTime(2024, 9, 6),
      endDate: null,
      category: EventCategory.announcement,
      description: 'Program sonuçlarının öğrencilere duyurulması',
    ),
    AcademicEvent(
      title:
          'Registration Procedures on Double Major/Minor Programs for students',
      titleTr: 'Öğrenciler için Çift Anadal/Yan Dal Kayıt İşlemleri',
      startDate: DateTime(2024, 9, 10),
      endDate: DateTime(2024, 9, 12),
      category: EventCategory.registration,
      description: 'Kabul edilen öğrencilerin kayıt işlemleri',
    ),
    AcademicEvent(
      title:
          'Registration Procedures on Double Major/Minor Programs for substitute students',
      titleTr: 'Yedek Öğrenciler için Çift Anadal/Yan Dal Kayıt İşlemleri',
      startDate: DateTime(2024, 9, 17),
      endDate: DateTime(2024, 9, 19),
      category: EventCategory.registration,
      description: 'Yedek listeden kabul edilen öğrencilerin kayıt işlemleri',
    ),
    AcademicEvent(
      title: 'English Proficiency and Level Determination Exams (Written)',
      titleTr: 'İngilizce Yeterlik ve Seviye Belirleme Sınavları (Yazılı)',
      startDate: DateTime(2024, 9, 24),
      endDate: null,
      category: EventCategory.exam,
      description: 'İngilizce dil yeterlik sınavının yazılı bölümü',
    ),
    AcademicEvent(
      title: 'English Proficiency and Level Determination Exams (Oral)',
      titleTr: 'İngilizce Yeterlik ve Seviye Belirleme Sınavları (Sözlü)',
      startDate: DateTime(2024, 9, 26),
      endDate: null,
      category: EventCategory.exam,
      description: 'İngilizce dil yeterlik sınavının sözlü bölümü',
    ),
    AcademicEvent(
      title: 'FALL SEMESTER (Beginning-Ending Course)',
      titleTr: 'GÜZ DÖNEMİ (Başlangıç-Bitiş Dersleri)',
      startDate: DateTime(2024, 9, 30),
      endDate: DateTime(2025, 1, 10),
      category: EventCategory.semester,
      description: 'Güz döneminin başlangıç ve bitiş tarihleri',
    ),
    AcademicEvent(
      title:
          'Fall Semester-Course Selection (For Associate and Undergraduate Programs)',
      titleTr: 'Güz Dönemi Ders Seçimi (Ön Lisans ve Lisans Programları)',
      startDate: DateTime(2024, 9, 24),
      endDate: DateTime(2024, 10, 4),
      category: EventCategory.courseSelection,
      description: 'Güz dönemi için ders seçim işlemleri',
    ),
    AcademicEvent(
      title:
          'Fall Semester Add-Drop (For Associate and Undergraduate Programs)',
      titleTr: 'Güz Dönemi Ders Ekleme-Çıkarma (Ön Lisans ve Lisans)',
      startDate: DateTime(2024, 10, 5),
      endDate: DateTime(2024, 10, 11),
      category: EventCategory.courseSelection,
      description: 'Ders ekleme ve çıkarma işlemleri',
    ),
    AcademicEvent(
      title: 'Mid-term Exams',
      titleTr: 'Ara Sınavlar',
      startDate: DateTime(2024, 11, 16),
      endDate: DateTime(2024, 11, 24),
      category: EventCategory.exam,
      description: 'Güz dönemi ara sınavları',
    ),
    AcademicEvent(
      title: 'General Exams',
      titleTr: 'Genel Sınavlar',
      startDate: DateTime(2025, 1, 13),
      endDate: DateTime(2025, 1, 24),
      category: EventCategory.exam,
      description: 'Güz dönemi final sınavları',
    ),
    AcademicEvent(
      title: 'Make-up Exams',
      titleTr: 'Bütünleme Sınavları',
      startDate: DateTime(2025, 2, 3),
      endDate: DateTime(2025, 2, 7),
      category: EventCategory.exam,
      description: 'Bütünleme sınavları dönemi',
    ),
    AcademicEvent(
      title: 'SPRING SEMESTER (Beginning-Ending Course)',
      titleTr: 'BAHAR DÖNEMİ (Başlangıç-Bitiş Dersleri)',
      startDate: DateTime(2025, 2, 10),
      endDate: DateTime(2025, 5, 30),
      category: EventCategory.semester,
      description: 'Bahar döneminin başlangıç ve bitiş tarihleri',
    ),
    AcademicEvent(
      title: 'GRADUATION PARTY',
      titleTr: 'MEZUNIYET PARTİ',
      startDate: DateTime(2025, 8, 10),
      endDate: null,
      category: EventCategory.semester,
      description: 'Geleneksel mezuniyet partisi',
    ),
    AcademicEvent(
      title:
          'Spring Semester Course Selection (For Associate and Undergraduate Programs)',
      titleTr: 'Bahar Dönemi Ders Seçimi (Ön Lisans ve Lisans Programları)',
      startDate: DateTime(2025, 2, 8),
      endDate: DateTime(2025, 2, 14),
      category: EventCategory.courseSelection,
      description: 'Bahar dönemi için ders seçim işlemleri',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filtrelenmiş etkinlikleri getir / Get filtered events
  List<AcademicEvent> get _filteredEvents {
    final now = DateTime.now();
    List<AcademicEvent> filtered = _allEvents;

    // Filtre uygula / Apply filter
    switch (_selectedFilter) {
      case 'Mevcut':
        filtered = _allEvents.where((event) {
          return event.startDate.isAfter(now);
        }).toList();
        break;
      case 'Yaklaşan':
        filtered = _allEvents.where((event) {
          return event.startDate.isAfter(now);
        }).toList();
        break;
      case 'Geçmiş':
        filtered = _allEvents.where((event) {
          return event.startDate != null && event.startDate!.isBefore(now);
        }).toList();
        break;
      default:
        filtered = _allEvents;
    }

    // Arama uygula / Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            event.titleTr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            event.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Tarihe göre sırala / Sort by date
    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppThemes.getBackgroundColor(context),
      // Navy renkli AppBar / Navy colored AppBar
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textColorLight,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.academicCalendar,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const Icon(Icons.menu, color: Colors.white, size: 24),
            );
          },
        ),
      ),

      // Ana sayfa drawer'ı / Main drawer
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants
            .navIndexHome, // Academic Calendar için özel indeks yok, home kullanıyoruz
      ),

      body: Column(
        children: [
          // Filtre çubuğu / Filter bar
          _buildFilterBar(),

          // Ana içerik / Main content
          Expanded(
            child: _filteredEvents.isEmpty
                ? _buildEmptyState()
                : _buildEventsList(),
          ),
        ],
      ),

      // Alt navigasyon çubuğu / Bottom navigation bar
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex:
            AppConstants.navIndexHome, // Academic Calendar için özel indeks yok
      ),
    );
  }

  // Filtre çubuğu widget'ı / Filter bar widget
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // Arama kutusu / Search box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Etkinlik ara... / Search events...',
              prefixIcon: Icon(
                Icons.search,
                color: AppThemes.getSecondaryTextColor(context),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: AppThemes.getSecondaryTextColor(
                    context,
                  ).withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: AppThemes.getSecondaryTextColor(
                    context,
                  ).withValues(alpha: 0.3),
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Filtre butonları / Filter buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tümü', 'Mevcut', 'Yaklaşan', 'Geçmiş'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(
                    right: AppConstants.paddingSmall,
                  ),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppThemes.getTextColor(context),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppThemes.getPrimaryColor(context),
                    backgroundColor: AppThemes.getSurfaceColor(context),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    side: BorderSide(
                      color: isSelected
                          ? AppThemes.getPrimaryColor(context)
                          : AppThemes.getSecondaryTextColor(
                              context,
                            ).withValues(alpha: 0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Etkinlikler listesi widget'ı / Events list widget
  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  // Etkinlik kartı widget'ı / Event card widget
  Widget _buildEventCard(AcademicEvent event) {
    final now = DateTime.now();
    final isActive =
        event.startDate.isBefore(now.add(const Duration(days: 1))) &&
        (event.endDate == null ||
            event.endDate!.isAfter(now.subtract(const Duration(days: 1))));
    final isPast = event.endDate != null && event.endDate!.isBefore(now);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppShadows.card,
        border: isActive
            ? Border.all(color: event.category.color, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: Kategori badge ve durum / Top row: Category badge and status
            Row(
              children: [
                // Kategori badge / Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: event.category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                    border: Border.all(
                      color: event.category.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        event.category.icon,
                        size: 14,
                        color: event.category.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.category.name,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: event.category.color,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Durum badge / Status badge
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  )
                else if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: const Text(
                      'Geçmiş',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Etkinlik başlığı / Event title
            Text(
              event.titleTr,
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppThemes.getTextColor(context),
              ),
            ),

            const SizedBox(height: 4),

            // İngilizce başlık / English title
            Text(
              event.title,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: AppThemes.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Açıklama / Description
            Text(
              event.description,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppThemes.getSecondaryTextColor(context),
              ),
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Tarih bilgileri / Date information
            Row(
              children: [
                // Başlangıç tarihi / Start date
                Expanded(
                  child: _buildDateInfo(
                    AppLocalizations.of(context)!.startDate,
                    event.startDate,
                    Icons.event_available,
                    Colors.blue,
                  ),
                ),

                if (event.endDate != null) ...[
                  const SizedBox(width: AppConstants.paddingMedium),
                  // Bitiş tarihi / End date
                  Expanded(
                    child: _buildDateInfo(
                      AppLocalizations.of(context)!.endDate,
                      event.endDate!,
                      Icons.event_busy,
                      Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tarih bilgisi widget'ı / Date info widget
  Widget _buildDateInfo(
    String label,
    DateTime date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Boş durum widget'ı / Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: AppThemes.getSecondaryTextColor(context),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              AppLocalizations.of(context)!.noEventsFound,
              style: TextStyle(
                fontSize: AppConstants.fontSizeXLarge,
                fontWeight: FontWeight.bold,
                color: AppThemes.getTextColor(context),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              AppLocalizations.of(context)!.noEventsFilter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppThemes.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'Tümü';
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.clearFilters,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarihi formatla / Format date
  String _formatDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Akademik etkinlik veri modeli / Academic event data model
class AcademicEvent {
  final String title;
  final String titleTr;
  final DateTime startDate;
  final DateTime? endDate;
  final EventCategory category;
  final String description;

  const AcademicEvent({
    required this.title,
    required this.titleTr,
    required this.startDate,
    this.endDate,
    required this.category,
    required this.description,
  });
}

// Etkinlik kategorileri / Event categories
enum EventCategory {
  registration('Kayıt', Icons.how_to_reg, Color(0xFF3B82F6)),
  evaluation('Değerlendirme', Icons.assessment, Color(0xFF8B5CF6)),
  announcement('Duyuru', Icons.campaign, Color(0xFF10B981)),
  exam('Sınav', Icons.quiz, Color(0xFFEF4444)),
  semester('Dönem', Icons.school, Color(0xFF6366F1)),
  courseSelection('Ders Seçimi', Icons.edit_note, Color(0xFFF59E0B));

  const EventCategory(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;
}
