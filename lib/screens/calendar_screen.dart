import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../themes/app_themes.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLocaleInitialized = false;
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _timelineScrollController;
  DateTime _currentWeekStart = DateTime.now();

  // Örnek ders verisi / Sample course data
  static const List<Map<String, dynamic>> _courses = [
    {
      'code': 'CS101',
      'title': 'courseVisualProgramming',
      'room': '3B06',
      'instructor': 'instructorAhmetYilmaz',
      'startTime': '08:00',
      'endTime': '10:00',
      'startHour': 8,
      'duration': 2.0,
    },
    {
      'code': 'CS202',
      'title': 'courseDataStructures',
      'room': '2A15',
      'instructor': 'instructorFatmaKaya',
      'startTime': '10:15',
      'endTime': '12:15',
      'startHour': 10,
      'duration': 2.0,
    },
    {
      'code': 'MTH301',
      'title': 'courseDiscreteMathematics',
      'room': '1C22',
      'instructor': 'instructorMehmetOzkan',
      'startTime': '13:30',
      'endTime': '15:30',
      'startHour': 13,
      'duration': 2.0,
    },
    {
      'code': 'ENG201',
      'title': 'courseTechnicalEnglish',
      'room': '4A08',
      'instructor': 'instructorSarahJohnson',
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _timelineScrollController = ScrollController();
    _currentWeekStart = _getWeekStart(_selectedDate);
    _scrollToCurrentTime();
  }

  void _initializeLocale() async {
    await initializeDateFormatting('tr_TR', null);
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timelineScrollController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _scrollToCurrentTime() {
    if (_isViewingToday() && !_isGridView) {
      final now = DateTime.now();
      if (now.hour >= 7 && now.hour <= 21) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final position = (now.hour - 7) * 60.0 + (now.minute / 60.0 * 60.0);
          if (_timelineScrollController.hasClients) {
            _timelineScrollController.animateTo(
              position - 100,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    if (!_isLocaleInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          title: Text(l10n.calendar),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.mapLoading,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: ModernAppBar(
        title: l10n.calendar,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menü',
            );
          },
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isGridView ? Icons.view_agenda : Icons.calendar_month,
                key: ValueKey(_isGridView),
                color: theme.colorScheme.onPrimary,
              ),
            ),
            tooltip: _isGridView ? l10n.timelineView : l10n.monthView,
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
              if (!_isGridView) {
                _scrollToCurrentTime();
              }
            },
          ),
          
        ],
      ),
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants.navIndexCalendar,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildModernHeader(theme, l10n),
            if (!_isGridView) _buildWeeklyDatePicker(theme, l10n),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _isGridView
                    ? _buildModernGridView(theme, l10n)
                    : _buildModernTimelineView(theme, l10n),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexCalendar,
      ),
    );
  }

  Widget _buildModernHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy', Localizations.localeOf(context).toString())
                      .format(_selectedDate),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isGridView ? l10n.monthView : l10n.timelineView,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (_isGridView) ...[
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
              icon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.primary,
                size: 28,
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
              icon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyDatePicker(ThemeData theme, AppLocalizations l10n) {
    final today = DateTime.now();
    final weekdayShorts = [
      l10n.mondayShort,
      l10n.tuesdayShort,
      l10n.wednesdayShort,
      l10n.thursdayShort,
      l10n.fridayShort,
      l10n.saturdayShort,
      l10n.sundayShort,
    ];

    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
                _selectedDate = _currentWeekStart;
              });
            },
            icon: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = _currentWeekStart.add(Duration(days: index));
                final isSelected = _isSameDay(date, _selectedDate);
                final isToday = _isToday(date);
                final hasEvents = _hasEventsOnDate(date);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    _scrollToCurrentTime();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isToday
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdayShorts[date.weekday - 1],
                          style: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (hasEvents)
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
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
                _selectedDate = _currentWeekStart;
              });
            },
            icon: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTimelineView(ThemeData theme, AppLocalizations l10n) {
    if (_courses.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          controller: _timelineScrollController,
          child: Stack(
            children: [
              Column(
                children: [
                  ...List.generate(15, (index) {
                    final hour = 7 + index;
                    return _buildModernTimeSlot(hour, theme);
                  }),
                ],
              ),
              ..._buildModernCourseCards(theme, l10n),
              if (_isViewingToday()) _buildNowIndicator(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCoursesToday,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu tarih için herhangi bir ders planlanmamış.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernGridView(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildModernWeekdayHeaders(theme, l10n),
            Expanded(child: _buildModernCalendarGrid(theme, l10n)),
          ],
        ),
      ),
    );
  }


  Widget _buildModernWeekdayHeaders(ThemeData theme, AppLocalizations l10n) {
    final weekdays = [
      l10n.mondayShort,
      l10n.tuesdayShort,
      l10n.wednesdayShort,
      l10n.thursdayShort,
      l10n.fridayShort,
      l10n.saturdayShort,
      l10n.sundayShort,
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildModernCalendarGrid(ThemeData theme, AppLocalizations l10n) {
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
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
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
                _currentWeekStart = _getWeekStart(date);
              });
              _scrollToCurrentTime();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ]
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
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (hasEvents) ...[
                    const SizedBox(height: 4),
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

  List<Widget> _buildModernCourseCards(ThemeData theme, AppLocalizations l10n) {
    return _courses.map((course) {
      final startHour = course['startHour'] as int;
      final duration = (course['duration'] as num).toDouble();
      final topPosition = (startHour - 7) * 60.0 + 8;
      final cardHeight = duration * 60.0 - 16;
      
      return Positioned(
        left: 72,
        right: 16,
        top: topPosition,
        child: GestureDetector(
          onTap: () {
            _showCourseDetails(context, course, theme, l10n);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: cardHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${course['code']} - ${_localizedCourseTitle(context, course['title'])}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (cardHeight > 80) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course['room'],
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _localizedInstructor(context, course['instructor']),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course['startTime']} - ${course['endTime']}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showCourseDetails(BuildContext context, Map<String, dynamic> course, 
      ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course['code'],
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _localizedCourseTitle(context, course['title']),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              Icons.person_rounded,
              'Instructor',
              _localizedInstructor(context, course['instructor']),
              theme,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.location_on_rounded,
              'Room',
              course['room'],
              theme,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.access_time_rounded,
              'Time',
              '${course['startTime']} - ${course['endTime']}',
              theme,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.timelapse_rounded,
              'Duration',
              '${course['duration']} hours',
              theme,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _localizedCourseTitle(BuildContext context, String key) {
    switch (key) {
      case 'courseVisualProgramming':
        return AppLocalizations.of(context)!.courseVisualProgramming;
      case 'courseDataStructures':
        return AppLocalizations.of(context)!.courseDataStructures;
      case 'courseDiscreteMathematics':
        return AppLocalizations.of(context)!.courseDiscreteMathematics;
      case 'courseTechnicalEnglish':
        return AppLocalizations.of(context)!.courseTechnicalEnglish;
      default:
        return key;
    }
  }

  String _localizedInstructor(BuildContext context, String key) {
    switch (key) {
      case 'instructorAhmetYilmaz':
        return AppLocalizations.of(context)!.instructorAhmetYilmaz;
      case 'instructorFatmaKaya':
        return AppLocalizations.of(context)!.instructorFatmaKaya;
      case 'instructorMehmetOzkan':
        return AppLocalizations.of(context)!.instructorMehmetOzkan;
      case 'instructorSarahJohnson':
        return AppLocalizations.of(context)!.instructorSarahJohnson;
      default:
        return key;
    }
  }

  Widget _buildModernTimeSlot(int hour, ThemeData theme) {
    final timeString = '${hour.toString().padLeft(2, '0')}:00';
    final isCurrentHour = _isViewingToday() && DateTime.now().hour == hour;
    
    return Container(
      height: 60,
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              timeString,
              style: TextStyle(
                color: isCurrentHour
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 2,
            height: 60,
            decoration: BoxDecoration(
              color: isCurrentHour
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowIndicator(ThemeData theme) {
    if (!_isViewingToday()) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    if (currentHour < 7 || currentHour >= 21) {
      return const SizedBox.shrink();
    }

    final hoursSince7 = currentHour - 7;
    final minuteOffset = currentMinute / 60.0;
    final topPosition = (hoursSince7 + minuteOffset) * 60.0;

    return Positioned(
      left: 66,
      right: 16,
      top: topPosition,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade400,
              Colors.red.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isViewingToday() {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasEventsOnDate(DateTime date) {
    return date.weekday >= 1 && date.weekday <= 5;
  }
}
