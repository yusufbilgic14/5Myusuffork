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
import '../services/user_courses_service.dart';
import '../models/user_course_model.dart';

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

  // Firebase services
  final UserCoursesService _coursesService = UserCoursesService();
  
  // User courses data
  List<UserCourse> _userCourses = [];
  bool _isLoadingCourses = false;
  String? _coursesError;

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
    _loadUserCourses();
  }

  void _initializeLocale() async {
    await initializeDateFormatting('tr_TR', null);
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
      _animationController.forward();
      _scrollToCurrentTime();
    }
  }

  /// Kullanıcının derslerini yükle / Load user's courses
  Future<void> _loadUserCourses() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingCourses = true;
      _coursesError = null;
    });

    try {
      final courses = await _coursesService.getUserCourses();
      if (mounted) {
        setState(() {
          _userCourses = courses;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _coursesError = e.toString();
          _isLoadingCourses = false;
        });
      }
    }
  }

  /// Ders ekleme dialog'u göster / Show add course dialog
  Future<void> _showAddCourseDialog() async {
    final result = await showDialog<UserCourse>(
      context: context,
      builder: (context) => const AddCourseDialog(),
    );

    if (result != null) {
      await _addCourse(result);
    }
  }

  /// Ders ekle / Add course
  Future<void> _addCourse(UserCourse course) async {
    try {
      await _coursesService.addCourse(course);
      await _loadUserCourses();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${course.courseCode} dersi başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ders eklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          // Add Course button
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: theme.colorScheme.onPrimary,
            ),
            tooltip: 'Ders Ekle',
            onPressed: _showAddCourseDialog,
          ),
          // View toggle button
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
    if (_isLoadingCourses) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Dersler yükleniyor...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_coursesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Dersler yüklenirken hata oluştu',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _coursesError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserCourses,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_userCourses.isEmpty) {
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
              'Henüz ders eklememişsiniz',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ders programınızı oluşturmak için yukarıdaki + butonuna basın.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text('İlk Dersinizi Ekleyin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
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
    // Get courses for the selected day
    final selectedDayOfWeek = _selectedDate.weekday;
    final coursesToday = _userCourses.where((course) {
      return course.hasClassOnDay(selectedDayOfWeek);
    }).toList();

    return coursesToday.expand((course) {
      // Get all schedules for this day (a course might have multiple sessions per day)
      final todaySchedules = course.getSchedulesForDay(selectedDayOfWeek);
      
      return todaySchedules.map((schedule) {
        final startHour = schedule.startHour;
        final duration = schedule.duration;
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
                    course.colorAsColor,
                    course.colorAsColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: course.colorAsColor.withValues(alpha: 0.3),
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
                      '${course.courseCode} - ${course.displayName}',
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
                          schedule.room,
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
                            course.instructor.name,
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
                        schedule.timeString,
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
    }).toList();
  }

  void _showCourseDetails(BuildContext context, UserCourse course, 
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
                    course.courseCode,
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
              course.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              Icons.person_rounded,
              'Instructor',
              course.instructor.name,
              theme,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.location_on_rounded,
              'Room',
              course.schedule.isNotEmpty ? course.schedule.first.room : 'TBA',
              theme,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.access_time_rounded,
              'Time',
              course.schedule.isNotEmpty ? course.schedule.first.timeString : 'TBA',
              theme,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.timelapse_rounded,
              'Credits',
              '${course.credits} credits',
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
    final dayOfWeek = date.weekday;
    return _userCourses.any((course) => course.hasClassOnDay(dayOfWeek));
  }
}

/// Dialog for adding new courses / Ders ekleme dialog'u
class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _instructorNameController = TextEditingController();
  final _roomController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  
  int _selectedDay = 1; // Monday
  int _credits = 3;
  Color _selectedColor = const Color(0xFF1E3A8A);

  final List<String> _weekDays = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
  ];

  final List<String> _weekDaysShort = [
    'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'
  ];

  final List<Color> _courseColors = [
    const Color(0xFF1E3A8A), // Blue
    const Color(0xFF059669), // Green
    const Color(0xFFDC2626), // Red
    const Color(0xFF7C2D12), // Brown
    const Color(0xFF6B21A8), // Purple
    const Color(0xFFEA580C), // Orange
    const Color(0xFF0D9488), // Teal
    const Color(0xFFBE123C), // Pink
  ];

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _instructorNameController.dispose();
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _createCourse() {
    if (!_formKey.currentState!.validate()) return;
    
    // Parse start and end times
    final startParts = _startTimeController.text.split(':');
    final endParts = _endTimeController.text.split(':');
    
    if (startParts.length != 2 || endParts.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir saat formatı girin (ÖR: 09:00)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final startHour = int.tryParse(startParts[0]);
    final endHour = int.tryParse(endParts[0]);
    
    if (startHour == null || endHour == null || startHour >= endHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Başlangıç saati bitiş saatinden önce olmalıdır'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final duration = (endHour - startHour).toDouble();
    
    // Create course schedule
    final schedule = CourseSchedule(
      dayOfWeek: _selectedDay,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      startHour: startHour,
      duration: duration,
      room: _roomController.text,
      building: 'Campus',
      classType: 'lecture',
    );

    // Create course instructor
    final instructor = CourseInstructor(
      name: _instructorNameController.text,
    );

    // Create user course
    final course = UserCourse(
      courseId: '', // Will be set by Firebase
      courseCode: _courseCodeController.text.toUpperCase(),
      courseName: _courseNameController.text,
      instructor: instructor,
      schedule: [schedule],
      credits: _credits,
      semester: '${DateTime.now().year}-${DateTime.now().month <= 6 ? 'Spring' : 'Fall'}',
      year: DateTime.now().year,
      semesterNumber: DateTime.now().month <= 6 ? 2 : 1,
      department: 'Computer Engineering',
      faculty: 'Engineering and Natural Sciences',
      level: 'undergraduate',
      color: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      notifications: const CourseNotifications(),
    );

    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ders Ekle',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Course Code
                      TextFormField(
                        controller: _courseCodeController,
                        decoration: InputDecoration(
                          labelText: 'Ders Kodu *',
                          hintText: 'CS101',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.code),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ders kodu gerekli';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      
                      // Course Name
                      TextFormField(
                        controller: _courseNameController,
                        decoration: InputDecoration(
                          labelText: 'Ders Adı *',
                          hintText: 'Görsel Programlama',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.book),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ders adı gerekli';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      
                      // Instructor
                      TextFormField(
                        controller: _instructorNameController,
                        decoration: InputDecoration(
                          labelText: 'Öğretim Görevlisi *',
                          hintText: 'Dr. Ahmet Yılmaz',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Öğretim görevlisi adı gerekli';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      
                      // Day and Room Row
                      Row(
                        children: [
                          // Day
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedDay,
                              decoration: InputDecoration(
                                labelText: 'Gün',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              isExpanded: true,
                              items: _weekDaysShort.asMap().entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key + 1,
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDay = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Room
                          Expanded(
                            child: TextFormField(
                              controller: _roomController,
                              decoration: InputDecoration(
                                labelText: 'Sınıf *',
                                hintText: 'B201',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.location_on),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Sınıf gerekli';
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Time Row
                      Row(
                        children: [
                          // Start Time
                          Expanded(
                            child: TextFormField(
                              controller: _startTimeController,
                              decoration: InputDecoration(
                                labelText: 'Başlangıç *',
                                hintText: '09:00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.access_time),
                              ),
                              readOnly: true,
                              onTap: () => _selectTime(_startTimeController),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Başlangıç saati gerekli';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // End Time
                          Expanded(
                            child: TextFormField(
                              controller: _endTimeController,
                              decoration: InputDecoration(
                                labelText: 'Bitiş *',
                                hintText: '11:00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.schedule),
                              ),
                              readOnly: true,
                              onTap: () => _selectTime(_endTimeController),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Bitiş saati gerekli';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Credits
                      DropdownButtonFormField<int>(
                        value: _credits,
                        decoration: InputDecoration(
                          labelText: 'Kredi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.star),
                        ),
                        items: List.generate(8, (index) {
                          final credits = index + 1;
                          return DropdownMenuItem(
                            value: credits,
                            child: Text('$credits Kredi'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _credits = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Color Picker
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Renk',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _courseColors.map((color) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = color;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: _selectedColor == color
                                        ? Border.all(
                                            color: theme.colorScheme.outline,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                  child: _selectedColor == color
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createCourse,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ekle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
