import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../constants/app_constants.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../widgets/common/user_info_widget.dart';
import 'home_screen.dart';
import 'campus_map_screen.dart';
import 'qr_access_screen.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart';

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
      'title': 'Visual Programming',
      'room': '3B06',
      'instructor': 'Dr. Ahmet Yılmaz',
      'startTime': '08:00',
      'endTime': '10:00',
      'startHour': 8,
      'duration': 2.0,
    },
    {
      'code': 'CS202',
      'title': 'Data Structures',
      'room': '2A15',
      'instructor': 'Prof. Fatma Kaya',
      'startTime': '10:15',
      'endTime': '12:15',
      'startHour': 10,
      'duration': 2.0,
    },
    {
      'code': 'MTH301',
      'title': 'Discrete Mathematics',
      'room': '1C22',
      'instructor': 'Dr. Mehmet Özkan',
      'startTime': '13:30',
      'endTime': '15:30',
      'startHour': 13,
      'duration': 2.0,
    },
    {
      'code': 'ENG201',
      'title': 'Technical English',
      'room': '4A08',
      'instructor': 'Ms. Sarah Johnson',
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
    // Eğer locale henüz yüklenmemişse loading göster / Show loading if locale not loaded yet
    if (!_isLocaleInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Calendar'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,

      // Navy renkli AppBar / Navy colored AppBar
      appBar: CommonAppBar(
        title: DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_timeline : Icons.calendar_view_month,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),

      // Sidebar drawer (mevcut home screen'den kopyalanabilir)
      drawer: _buildSideDrawer(),

      body: Column(
        children: [
          // Yatay tarih seçici (sadece timeline view'da) / Horizontal date picker (only in timeline view)
          if (!_isGridView) _buildHorizontalDatePicker(),

          // Ana takvim görünümü / Main calendar view
          Expanded(
            child: _isGridView ? _buildGridView() : _buildTimelineView(),
          ),
        ],
      ),

      // Alt navigasyon çubuğu / Bottom navigation bar
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexCalendar,
      ),
    );
  }

  // Yatay tarih seçici widget'ı / Horizontal date picker widget
  Widget _buildHorizontalDatePicker() {
    final today = DateTime.now();
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
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
                    ? AppConstants.primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: isToday && !isSelected
                    ? Border.all(color: AppConstants.primaryColor, width: 1)
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
                          ? AppConstants.textColorLight
                          : isToday
                          ? AppConstants.primaryColor
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? AppConstants.textColorLight
                          : isToday
                          ? AppConstants.primaryColor
                          : AppConstants.textColorDark,
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

  // Dikey zaman çizelgesi görünümü / Vertical timeline view
  Widget _buildTimelineView() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // Saat dilimleri / Time slots
                ...List.generate(15, (index) {
                  final hour =
                      7 + index; // 07:00'dan başlayarak / Starting from 07:00
                  return _buildTimeSlot(hour);
                }),
              ],
            ),

            // Ders kartları (tüm zaman çizelgesi üzerinde pozisyonlanmış) / Course cards positioned over entire timeline
            ..._buildAllCourseCards(),

            // Eğer bugünü görüntülüyorsak "Şimdi" göstergesini ekle / Add "Now" indicator if viewing today
            if (_isViewingToday()) _buildNowIndicator(),
          ],
        ),
      ),
    );
  }

  // Grid takvim görünümü / Grid calendar view
  Widget _buildGridView() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Ay navigasyonu / Month navigation
          _buildMonthNavigation(),

          const SizedBox(height: 16),

          // Haftanın günleri başlıkları / Days of week headers
          _buildWeekdayHeaders(),

          const SizedBox(height: 8),

          // Takvim grid'i / Calendar grid
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }

  // Ay navigasyonu / Month navigation
  Widget _buildMonthNavigation() {
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
          color: AppConstants.primaryColor,
        ),
        Text(
          DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
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
          color: AppConstants.primaryColor,
        ),
      ],
    );
  }

  // Haftanın günleri başlıkları / Days of week headers
  Widget _buildWeekdayHeaders() {
    final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

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
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // Takvim grid'i / Calendar grid
  Widget _buildCalendarGrid() {
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
    final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7; // Pazartesi = 0
    final daysInMonth = lastDayOfMonth.day;

    // Takvim için toplam hücre sayısı / Total cells needed for calendar
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

        // Boş hücreler (ay başından önce) / Empty cells before month start
        if (index < firstDayWeekday) {
          return Container();
        }

        // Geçerli ay günleri / Valid days of current month
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
                _isGridView =
                    false; // Grid'den timeline'a geç / Switch from grid to timeline
              });
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryColor
                    : isToday
                    ? AppConstants.primaryColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday && !isSelected
                    ? Border.all(color: AppConstants.primaryColor, width: 1)
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
                          ? Colors.white
                          : isToday
                          ? AppConstants.primaryColor
                          : AppConstants.textColorDark,
                    ),
                  ),
                  if (hasEvents) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : AppConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Ay sonundan sonraki boş hücreler / Empty cells after month end
        return Container();
      },
    );
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

  // Tüm ders kartlarını oluştur / Build all course cards
  List<Widget> _buildAllCourseCards() {
    return _courses.map((course) {
      final startHour = course['startHour'] as int;
      final duration = (course['duration'] as num).toDouble();

      // Dersin başlangıç pozisyonunu hesapla / Calculate course start position
      final topPosition =
          (startHour - 7) * 60.0 + 6; // 7 saatten itibaren, 6px üst padding
      final cardHeight =
          duration * 60.0 - 12; // Duration * 60px per hour, minus padding

      return Positioned(
        left: 68, // Saat etiketinden sonra / After time label
        right: 8,
        top: topPosition,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
              // Ders kodu ve başlığı / Course code and title
              Text(
                '${course['code']} - ${course['title']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Oda bilgisi / Room information
              Row(
                children: [
                  const Icon(Icons.room, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    course['room'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Öğretmen bilgisi / Instructor information
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course['instructor'],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Saat bilgisi / Time information
              Text(
                '${course['startTime']} - ${course['endTime']}',
                style: const TextStyle(
                  color: Colors.white,
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

  // Saat dilimi widget'ı / Time slot widget
  Widget _buildTimeSlot(int hour) {
    final timeString = '${hour.toString().padLeft(2, '0')}:00';

    return Container(
      height: 60,
      child: Row(
        children: [
          // Saat etiketi / Time label
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              timeString,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Dikey ayırıcı çizgi / Vertical divider line
          Container(width: 1, height: 60, color: Colors.grey[300]),

          // Ders kartları alanı / Course cards area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "Şimdi" göstergesi / "Now" indicator
  Widget _buildNowIndicator() {
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
          color: Colors.red,
          borderRadius: BorderRadius.circular(1),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
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
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.red,
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
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      );
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
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
