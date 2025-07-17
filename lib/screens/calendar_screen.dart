import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../constants/app_constants.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../themes/app_themes.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLocaleInitialized = false;
  bool _isGridView = false; // Takvim görünüm modu / Calendar view mode

  // Örnek ders verisi / Sample course data
  final List<Map<String, dynamic>> _courses = [
    {
      'code': 'CS101',
      'title':
          AppLocalizations.of(context)?.courseVisualProgramming ??
          'Visual Programming',
      'room': '3B06',
      'instructor':
          AppLocalizations.of(context)?.instructorAhmetYilmaz ??
          'Dr. Ahmet Yılmaz',
      'startTime': '08:00',
      'endTime': '10:00',
      'startHour': 8,
      'duration': 2.0,
    },
    {
      'code': 'CS202',
      'title':
          AppLocalizations.of(context)?.courseDataStructures ??
          'Data Structures',
      'room': '2A15',
      'instructor':
          AppLocalizations.of(context)?.instructorFatmaKaya ??
          'Prof. Fatma Kaya',
      'startTime': '10:15',
      'endTime': '12:15',
      'startHour': 10,
      'duration': 2.0,
    },
    {
      'code': 'MTH301',
      'title':
          AppLocalizations.of(context)?.courseDiscreteMathematics ??
          'Discrete Mathematics',
      'room': '1C22',
      'instructor':
          AppLocalizations.of(context)?.instructorMehmetOzkan ??
          'Dr. Mehmet Özkan',
      'startTime': '13:30',
      'endTime': '15:30',
      'startHour': 13,
      'duration': 2.0,
    },
    {
      'code': 'ENG201',
      'title':
          AppLocalizations.of(context)?.courseTechnicalEnglish ??
          'Technical English',
      'room': '4A08',
      'instructor':
          AppLocalizations.of(context)?.instructorSarahJohnson ??
          'Ms. Sarah Johnson',
      'startTime': '16:00',
      'endTime': '17:30',
      'startHour': 16,
      'duration': 1.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  // Türkçe yerel ayarlarını başlat / Initialize Turkish locale
  void _initializeLocale() async {
    await initializeDateFormatting('tr_TR', null);
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    // Eğer locale henüz yüklenmemişse loading göster / Show loading if locale not loaded yet
    if (!_isLocaleInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.calendar),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: CommonAppBar(
        title: DateFormat('MMMM yyyy', locale).format(_selectedDate),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_timeline : Icons.calendar_view_month,
            ),
            tooltip: _isGridView
                ? AppLocalizations.of(context)!.timelineView
                : AppLocalizations.of(context)!.monthView,
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants.navIndexCalendar,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          if (!_isGridView) _buildHorizontalDatePicker(theme),
          Expanded(
            child: _isGridView
                ? _buildGridView(theme)
                : _buildTimelineView(theme),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexCalendar,
      ),
    );
  }

  Widget _buildHorizontalDatePicker(ThemeData theme) {
    final today = DateTime.now();
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);
          final isToday =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(today);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: isToday && !isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 1)
                    : isSelected
                    ? null
                    : Border.all(color: Colors.transparent, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'tr_TR').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isToday
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyLarge?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isToday
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTimelineView(ThemeData theme) {
    if (_courses.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noCoursesToday));
    }
    return Container(
      color: theme.cardColor,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                ...List.generate(15, (index) {
                  final hour = 7 + index;
                  return _buildTimeSlot(hour, theme);
                }),
              ],
            ),
            ..._buildAllCourseCards(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(ThemeData theme) {
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthNavigation(theme),
          const SizedBox(height: 16),
          _buildWeekdayHeaders(theme),
          const SizedBox(height: 8),
          Expanded(child: _buildCalendarGrid(theme)),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month - 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
          color: theme.colorScheme.primary,
        ),
        Text(
          DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month + 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right),
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(ThemeData theme) {
    final weekdays = [
      AppLocalizations.of(context)!.mondayShort,
      AppLocalizations.of(context)!.tuesdayShort,
      AppLocalizations.of(context)!.wednesdayShort,
      AppLocalizations.of(context)!.thursdayShort,
      AppLocalizations.of(context)!.fridayShort,
      AppLocalizations.of(context)!.saturdayShort,
      AppLocalizations.of(context)!.sundayShort,
    ];
    return Row(
      children: weekdays
          .map(
            (day) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );
    final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = (firstDayWeekday + daysInMonth);
    final rows = (totalCells / 7).ceil();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayIndex = index - firstDayWeekday + 1;
        if (index < firstDayWeekday) {
          return Container();
        }
        if (dayIndex <= daysInMonth) {
          final date = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            dayIndex,
          );
          final isToday = _isToday(date);
          final isSelected = _isSameDay(date, _selectedDate);
          final hasEvents = _hasEventsOnDate(date);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _isGridView = false;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday && !isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayIndex.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isToday
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (hasEvents) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  List<Widget> _buildAllCourseCards(ThemeData theme) {
    return _courses.map((course) {
      final startHour = course['startHour'] as int;
      final duration = (course['duration'] as num).toDouble();
      final topPosition = (startHour - 7) * 60.0 + 6;
      final cardHeight = duration * 60.0 - 12;
      return Positioned(
        left: 68,
        right: 8,
        top: topPosition,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${course['code']} - ${course['title']}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(
                    Icons.room,
                    color: theme.colorScheme.onPrimary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    course['room'],
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course['instructor'],
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                '${course['startTime']} - ${course['endTime']}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTimeSlot(int hour, ThemeData theme) {
    final timeString = '${hour.toString().padLeft(2, '0')}:00';
    return Container(
      height: 60,
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              timeString,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(width: 1, height: 60, color: theme.dividerColor),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "Şimdi" göstergesi / "Now" indicator
  Widget _buildNowIndicator(ThemeData theme) {
    // Sadece bugünü görüntülüyorsak göster / Only show if viewing today
    if (!_isViewingToday()) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    // Sadece 7-21 saatleri arasında göster / Only show between 7-21 hours
    if (currentHour < 7 || currentHour >= 21) {
      return const SizedBox.shrink();
    }

    // Göstergenin pozisyonunu hesapla / Calculate indicator position
    final hoursSince7 = currentHour - 7;
    final minuteOffset = currentMinute / 60.0;
    final topPosition = (hoursSince7 + minuteOffset) * 60.0;

    return Positioned(
      left: 61, // Saat etiketinden sonra / After time label
      right: 8, // Sağ kenardan boşluk / Margin from right
      top: topPosition,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(1),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withOpacity(0.3),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bugünü görüntülüyor mu kontrol et / Check if viewing today
  bool _isViewingToday() {
    final today = DateTime.now();
    // Tam tarih karşılaştırması (yıl, ay, gün) / Complete date comparison (year, month, day)
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  // Bugün mü kontrol et / Check if today
  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // Aynı gün mü kontrol et / Check if same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Tarihte etkinlik var mı kontrol et / Check if date has events
  bool _hasEventsOnDate(DateTime date) {
    // Basit örnek: hafta içi günlerde ders var varsayımı / Simple example: assume courses on weekdays
    return date.weekday >= 1 && date.weekday <= 5;
  }
}
