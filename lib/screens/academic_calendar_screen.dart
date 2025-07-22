import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/app_bar_widget.dart';

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
      title: 'Applications for Double Major/Minor',
      titleTr: 'Çift Anadal / Yandal Başvuruları',
      startDate: DateTime(2025, 8, 25),
      endDate: DateTime(2025, 9, 1),
      category: EventCategory.registration,
      description: '',
    ),
    AcademicEvent(
      title: 'Evaluation of Double Major/Minor',
      titleTr: 'Çift Anadal / Yandal Değerlendirme',
      startDate: DateTime(2025, 9, 2),
      endDate: DateTime(2025, 9, 4),
      category: EventCategory.evaluation,
      description: '',
    ),
    AcademicEvent(
      title: 'Announcement of Double Major/Minor Results',
      titleTr: 'Çift Anadal / Yandal Sonuç İlanı',
      startDate: DateTime(2025, 9, 5),
      endDate: null,
      category: EventCategory.announcement,
      description: '',
    ),
    AcademicEvent(
      title: 'Definite Registration for Main Double Major/Minor',
      titleTr: 'Asil Çift Anadal / Yandal Kesin Kayıt İşlemleri',
      startDate: DateTime(2025, 9, 9),
      endDate: DateTime(2025, 9, 11),
      category: EventCategory.registration,
      description: '',
    ),
    AcademicEvent(
      title: 'Definite Registration for Substitute Double Major/Minor',
      titleTr: 'Yedek Çiftanadal / Yandal Kesin Kayıt İşlemleri',
      startDate: DateTime(2025, 9, 16),
      endDate: DateTime(2025, 9, 18),
      category: EventCategory.registration,
      description: '',
    ),
    AcademicEvent(
      title: 'English Proficiency and Placement Exams (Written)',
      titleTr: 'İngilizce Yeterlilik ve Seviye Tespit Sınavları (Yazılı)',
      startDate: null,
      endDate: null,
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'English Proficiency and Placement Exams (Oral)',
      titleTr: 'İngilizce Yeterlilik ve Seviye Tespit Sınavları (Sözlü)',
      startDate: null,
      endDate: null,
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Turkish Exam for Foreigners (Written)',
      titleTr: 'Yabancı Uyruklular Türkçe Sınavı (Yazılı)',
      startDate: null,
      endDate: null,
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Turkish Exam for Foreigners (Oral)',
      titleTr: 'Yabancı Uyruklular Türkçe Sınavı (Sözlü)',
      startDate: null,
      endDate: null,
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Start of Prep Program Courses',
      titleTr: 'Hazırlık Programı Derslerin Başlaması',
      startDate: null,
      endDate: null,
      category: EventCategory.semester,
      description: '',
    ),
    AcademicEvent(
      title: 'FALL SEMESTER (Course Start-End)',
      titleTr: 'GÜZ YARIYILI (Ders Başlama-Bitiş)',
      startDate: DateTime(2025, 9, 22),
      endDate: DateTime(2026, 1, 2),
      category: EventCategory.semester,
      description: '',
    ),
    AcademicEvent(
      title: 'Fall Semester Course Selection (Associate-Bachelor)',
      titleTr: 'Güz Dönemi Ders Seçimi (Önlisans-Lisans)',
      startDate: DateTime(2025, 9, 16),
      endDate: DateTime(2025, 9, 26),
      category: EventCategory.courseSelection,
      description: '',
    ),
    AcademicEvent(
      title: 'Fall Semester Add/Drop (Associate-Bachelor)',
      titleTr: 'Güz Dönemi Ders Alma - Dersten Çekilme (Önlisans-Lisans)',
      startDate: DateTime(2025, 9, 27),
      endDate: DateTime(2025, 10, 3),
      category: EventCategory.courseSelection,
      description: '',
    ),
    AcademicEvent(
      title: 'Midterm Exams',
      titleTr: 'Ara Sınavlar',
      startDate: DateTime(2025, 11, 8),
      endDate: DateTime(2025, 11, 16),
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Midterm Make-up Exams',
      titleTr: 'Ara Sınavların Mazeret Sınav Dönemi',
      startDate: null,
      endDate: null,
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'End of Term General Exams',
      titleTr: 'Yarıyıl Sonu Genel Sınavları',
      startDate: DateTime(2026, 1, 5),
      endDate: DateTime(2026, 1, 16),
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Make-up Exams',
      titleTr: 'Bütünleme Sınavları',
      startDate: DateTime(2026, 1, 26),
      endDate: DateTime(2026, 1, 30),
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'SPRING SEMESTER (Course Start-End)',
      titleTr: 'BAHAR YARIYILI (Ders Başlama-Bitiş)',
      startDate: DateTime(2026, 2, 9),
      endDate: DateTime(2026, 5, 22),
      category: EventCategory.semester,
      description: '',
    ),
    AcademicEvent(
      title: 'Spring Semester Course Selection (Associate-Bachelor)',
      titleTr: 'Bahar Dönemi Ders Seçimi (Önlisans-Lisans)',
      startDate: DateTime(2026, 2, 7),
      endDate: DateTime(2026, 2, 13),
      category: EventCategory.courseSelection,
      description: '',
    ),
    AcademicEvent(
      title: 'Spring Semester Add/Drop (Associate-Bachelor)',
      titleTr: 'Bahar Dönemi Ders Alma - Dersten Çekilme (Önlisans-Lisans)',
      startDate: DateTime(2026, 2, 14),
      endDate: DateTime(2026, 2, 20),
      category: EventCategory.courseSelection,
      description: '',
    ),
    AcademicEvent(
      title: 'Spring Midterm Exams',
      titleTr: 'Ara Sınavlar',
      startDate: DateTime(2026, 3, 28),
      endDate: DateTime(2026, 4, 5),
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Spring Midterm Make-up Exams',
      titleTr: 'Ara Sınavların Mazeret Sınav Dönemi',
      startDate: null,
      endDate: null,
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Spring End of Term General Exams',
      titleTr: 'Yarıyıl Sonu Genel Sınavları',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 12),
      category: EventCategory.exam,
      description: '',
    ),
    AcademicEvent(
      title: 'Spring Make-up Exams',
      titleTr: 'Bütünleme Sınavları',
      startDate: DateTime(2026, 6, 22),
      endDate: DateTime(2026, 6, 28),
      category: EventCategory.exam,
      description: '',
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
          return event.startDate != null && event.startDate!.isAfter(now);
        }).toList();
        break;
      case 'Yaklaşan':
        filtered = _allEvents.where((event) {
          return event.startDate != null && event.startDate!.isAfter(now);
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
    filtered.sort((a, b) {
      if (a.startDate == null && b.startDate == null) return 0;
      if (a.startDate == null) return 1;
      if (b.startDate == null) return -1;
      return a.startDate!.compareTo(b.startDate!);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppThemes.getBackgroundColor(context),
      // Navy renkli AppBar / Navy colored AppBar
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.academicCalendar,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menü',
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              '2025-2026 Yılı Akademik Takvim',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppThemes.getPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
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

  // Etkinlikler listesi widget'ı / Events list widget
  Widget _buildEventsList() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemCount: _filteredEvents.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Başlık satırı
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: AppThemes.getPrimaryColor(
                  context,
                ).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.announcements,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      l10n.startDate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      l10n.endDate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final event = _filteredEvents[index - 1];
          String formatDate(DateTime? date) {
            if (date == null) return '-';
            return MaterialLocalizations.of(context).formatFullDate(date);
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'tr'
                          ? event.titleTr
                          : event.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      formatDate(event.startDate),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      formatDate(event.endDate),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Etkinlik kartı widget'ı / Event card widget
  Widget _buildEventCard(AcademicEvent event) {
    final now = DateTime.now();
    final isActive =
        (event.startDate != null &&
            event.startDate!.isBefore(now.add(const Duration(days: 1)))) &&
        (event.endDate == null ||
            (event.endDate != null &&
                event.endDate!.isAfter(now.subtract(const Duration(days: 1)))));
    final isPast = event.endDate != null && event.endDate!.isBefore(now);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppShadows.card,
        border: isActive
            ? Border.all(
                color: AppThemes.getEventTypeColor(
                  context,
                  event.category.name,
                ),
                width: 2,
              )
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
                    color: AppThemes.getEventTypeColor(
                      context,
                      event.category.name,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                    border: Border.all(
                      color: AppThemes.getEventTypeColor(
                        context,
                        event.category.name,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        event.category.icon,
                        size: 14,
                        color: AppThemes.getEventTypeColor(
                          context,
                          event.category.name,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.category.name,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: AppThemes.getEventTypeColor(
                            context,
                            event.category.name,
                          ),
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
    DateTime? date,
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
                  date == null ? '-' : _formatDate(date),
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
  final DateTime? startDate;
  final DateTime? endDate;
  final EventCategory category;
  final String description;

  const AcademicEvent({
    required this.title,
    required this.titleTr,
    this.startDate,
    this.endDate,
    required this.category,
    required this.description,
  });
}

// Etkinlik kategorileri / Event categories
enum EventCategory {
  registration('Kayıt', Icons.how_to_reg),
  evaluation('Değerlendirme', Icons.assessment),
  announcement('Duyuru', Icons.campaign),
  exam('Sınav', Icons.quiz),
  semester('Dönem', Icons.school),
  courseSelection('Ders Seçimi', Icons.edit_note);

  const EventCategory(this.name, this.icon);
  final String name;
  final IconData icon;
}
