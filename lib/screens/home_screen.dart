import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import 'inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'cafeteria_menu_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common/app_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentAnnouncementIndex = 0;
  late PageController _pageController;
  Timer? _autoAdvanceTimer;
  bool _showNotifications = false;
  bool _showCafeteriaMenu = false;

  // Duyuru listesi
  final List<Map<String, String>> _announcements = [
    {
      'title': 'Mezuniyet Töreni 2025',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '20.06.2025',
      'description': 'Mezuniyet törenimiz 20 Haziran\'da yapılacaktır.',
    },
    {
      'title': 'Bahar Dönemi Final Sınavları',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '18.06.2025',
      'description': 'Final sınavları 18 Haziran\'da başlayacaktır.',
    },
    {
      'title': 'Yaz Okulu Kayıtları Başladı',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '15.06.2025',
      'description': 'Yaz okulu kayıtları için son tarih 15 Haziran.',
    },
    {
      'title': 'Kariyer Günleri 2025',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '12.06.2025',
      'description': 'Kariyer günleri etkinliği 12 Haziran\'da.',
    },
    {
      'title': 'Burs Başvuruları Son Tarih',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '10.06.2025',
      'description': 'Burs başvuruları için son tarih 10 Haziran.',
    },
    {
      'title': 'Öğrenci Konseyi Seçimleri',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '08.06.2025',
      'description': 'Öğrenci konseyi seçimleri 8 Haziran\'da.',
    },
    {
      'title': 'Sosyal Etkinlik: Konser',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '05.06.2025',
      'description': 'Müzik konserimiz 5 Haziran\'da yapılacaktır.',
    },
  ];

  // Bildirim listesi
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Öğrenci Belgesi Talebiniz Hakkında',
      'message': 'Öğrenci İşleri müdürlüğünden yeni bir mesaj aldınız.',
      'time': '2 saat önce',
      'isRead': false,
      'type': 'email',
      'inboxId': 1,
    },
    {
      'title': 'Burs Başvuru Sonucu',
      'message': 'Burs ve Yardım İşleri müdürlüğünden yeni bir mesaj aldınız.',
      'time': '1 gün önce',
      'isRead': false,
      'type': 'email',
      'inboxId': 2,
    },
    {
      'title': 'Dönem Sonu Sınav Programı',
      'message': 'Akademik Birim müdürlüğünden yeni bir mesaj aldınız.',
      'time': '4 gün önce',
      'isRead': true,
      'type': 'email',
      'inboxId': 3,
    },
    {
      'title': 'Kütüphane Kitap İade Hatırlatması',
      'message': 'Kütüphane müdürlüğünden yeni bir mesaj aldınız.',
      'time': '5 gün önce',
      'isRead': true,
      'type': 'email',
      'inboxId': 4,
    },
    {
      'title': 'Mezuniyet Töreni Davetiyesi',
      'message': 'Protokol biriminden yeni bir mesaj aldınız.',
      'time': '1 hafta önce',
      'isRead': true,
      'type': 'email',
      'inboxId': 5,
    },
    {
      'title': 'Visual Programming Final Notunuz Paylaşılmıştır',
      'message':
          'Visual Programming dersi final sınavı notunuz sisteme yüklenmiştir.',
      'time': '2 saat önce',
      'isRead': false,
      'type': 'grade',
    },
    {
      'title': 'Kütüphane Kitap İade Hatırlatması',
      'message':
          'Ödünç aldığınız "Algorithm Design" kitabının iade tarihi yaklaşmaktadır.',
      'time': '5 saat önce',
      'isRead': false,
      'type': 'reminder',
    },
    {
      'title': 'Dönem Sonu Proje Teslim Tarihi',
      'message':
          'Database Management Systems dersi dönem sonu projesi için son teslim tarihi: 25 Haziran 2025',
      'time': '1 gün önce',
      'isRead': true,
      'type': 'assignment',
    },
    {
      'title': 'Burs Başvuru Sonucu',
      'message': 'Başarı bursu başvurunuz değerlendirme aşamasındadır.',
      'time': '2 gün önce',
      'isRead': true,
      'type': 'scholarship',
    },
    {
      'title': 'Yeni Duyuru: Mezuniyet Töreni',
      'message': 'Mezuniyet töreni için kayıt işlemleri başlamıştır.',
      'time': '3 gün önce',
      'isRead': true,
      'type': 'announcement',
    },
  ];

  // Günün dersleri
  final List<Map<String, dynamic>> _todaysCourses = [
    {
      'name': 'Visual Programming',
      'code': '3B06',
      'time': '08:00 - 10:00',
      'instructor': 'Dr. Ahmet Yılmaz',
      'room': 'B201',
      'type': 'lecture',
      'color': AppConstants.primaryColor,
    },
    {
      'name': 'OOP Quiz-1',
      'code': '',
      'time': '09:00 - 09:30',
      'instructor': 'Dr. Mehmet Özkan',
      'room': 'C105',
      'type': 'quiz',
      'color': Colors.orange[700]!,
    },
    {
      'name': 'Database Management',
      'code': '4A12',
      'time': '10:00 - 12:00',
      'instructor': 'Prof. Dr. Fatma Kara',
      'room': 'A301',
      'type': 'lecture',
      'color': Colors.green[700]!,
    },
    {
      'name': 'Software Engineering',
      'code': '5C08',
      'time': '14:00 - 16:00',
      'instructor': 'Doç. Dr. Ali Demir',
      'room': 'B105',
      'type': 'lecture',
      'color': Colors.purple[700]!,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_pageController.hasClients) {
        int nextPage = (_currentAnnouncementIndex + 1) % _announcements.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _goToAnnouncement(int index) {
    if (!mounted || !_pageController.hasClients) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants.navIndexHome,
      ),
      appBar: ModernAppBar(
        title: l10n.homeWelcome,
        subtitle: AppConstants.userName,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menü',
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant, color: Colors.white),
            tooltip: l10n.cafeteriaMenu,
            onPressed: () {
              setState(() {
                _showCafeteriaMenu = !_showCafeteriaMenu;
                _showNotifications = false;
              });
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_rounded, color: Colors.white),
                if (_notifications.where((n) => !n['isRead']).isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red[500],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_notifications.where((n) => !n['isRead']).length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Bildirimler',
            onPressed: () {
              setState(() {
                _showNotifications = !_showNotifications;
                _showCafeteriaMenu = false;
              });
            },
          ),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Bildirim paneli
          AnimatedContainer(
            duration: AppConstants.animationNormal,
            curve: Curves.easeInOut,
            height: _showNotifications ? 350 : 0,
            child: _showNotifications ? _buildNotificationPanel(context) : null,
          ),
          // Cafeteria paneli
          AnimatedContainer(
            duration: AppConstants.animationNormal,
            curve: Curves.easeInOut,
            height: _showCafeteriaMenu ? 400 : 0,
            child: _showCafeteriaMenu ? _buildCafeteriaPanel(context) : null,
          ),
          // Ana içerik
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Duyurular bölümü
                  _buildAnnouncementsSection(context),
                  const SizedBox(height: 32),
                  // Günün dersleri bölümü
                  _buildTodaysCoursesSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexHome,
      ),
    );
  }

  // Duyurular bölümü
  Widget _buildAnnouncementsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        Row(
          children: [
            Icon(
              Icons.campaign_outlined,
              color: AppThemes.getPrimaryColor(context),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.announcements,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppThemes.getTextColor(context),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final url = Uri.parse('https://www.medipol.edu.tr/duyurular');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                l10n.seeAll,
                style: TextStyle(
                  color: AppThemes.getPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Duyuru kartları
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentAnnouncementIndex = index;
              });
            },
            itemCount: _announcements.length,
            itemBuilder: (context, index) {
              final announcement = _announcements[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppThemes.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppThemes.getSecondaryTextColor(
                      context,
                    ).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Arka plan resmi
                      Positioned.fill(
                        child: Image.asset(
                          announcement['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppThemes.getPrimaryColor(context),
                                    AppThemes.getPrimaryColor(
                                      context,
                                    ).withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.campaign_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Tarih etiketi
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            announcement['date']!,
                            style: TextStyle(
                              color: AppThemes.getPrimaryColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // İçerik
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                announcement['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                announcement['description'] ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Sayfa göstergeleri
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_announcements.length, (index) {
            return GestureDetector(
              onTap: () => _goToAnnouncement(index),
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _currentAnnouncementIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == _currentAnnouncementIndex
                      ? AppThemes.getPrimaryColor(context)
                      : AppThemes.getSecondaryTextColor(
                          context,
                        ).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Günün dersleri bölümü
  Widget _buildTodaysCoursesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              color: AppThemes.getPrimaryColor(context),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.todaysCourses,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppThemes.getTextColor(context),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppThemes.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.todayDate,
                style: TextStyle(
                  color: AppThemes.getPrimaryColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Ders kartları
        ...List.generate(_todaysCourses.length, (index) {
          final course = _todaysCourses[index];
          return _buildCourseCard(context, course, index);
        }),
      ],
    );
  }

  // Ders kartı
  Widget _buildCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    int index,
  ) {
    final isQuiz = course['type'] == 'quiz';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemes.getSecondaryTextColor(context).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Zaman göstergesi
            SizedBox(
              width: 50,
              child: Text(
                course['time'].split(' - ')[0],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppThemes.getSecondaryTextColor(context),
                ),
              ),
            ),

            // Renk çubuğu
            Container(
              width: 3,
              height: 50,
              decoration: BoxDecoration(
                color: course['color'],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(width: 12),

            // Ders ikonu
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: course['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isQuiz ? Icons.quiz_outlined : Icons.book_outlined,
                color: course['color'],
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Ders bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.getTextColor(context),
                    ),
                  ),
                  if (course['code'].isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      course['code'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: course['color'],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: AppThemes.getSecondaryTextColor(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          course['instructor'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemes.getSecondaryTextColor(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppThemes.getSecondaryTextColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course['room'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemes.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Süre bilgisi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: course['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                course['time'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: course['color'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bildirim paneli
  Widget _buildNotificationPanel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppThemes.getSecondaryTextColor(context).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppThemes.getPrimaryColor(context),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.notifications,
                    style: TextStyle(
                      color: AppThemes.getPrimaryColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var notification in _notifications) {
                        notification['isRead'] = true;
                      }
                    });
                  },
                  child: Text(
                    l10n.markAllRead,
                    style: TextStyle(
                      color: AppThemes.getPrimaryColor(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showNotifications = false;
                    });
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_up_outlined,
                    color: AppThemes.getPrimaryColor(context),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Bildirim listesi
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(context, notification, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Bildirim öğesi
  Widget _buildNotificationItem(
    BuildContext context,
    Map<String, dynamic> notification,
    int index,
  ) {
    IconData getNotificationIcon(String type) {
      switch (type) {
        case 'grade':
          return Icons.grade_outlined;
        case 'reminder':
          return Icons.schedule_outlined;
        case 'assignment':
          return Icons.assignment_outlined;
        case 'scholarship':
          return Icons.account_balance_wallet_outlined;
        case 'announcement':
          return Icons.campaign_outlined;
        case 'email':
          return Icons.email_outlined;
        default:
          return Icons.notifications_outlined;
      }
    }

    Color getNotificationColor(String type) {
      switch (type) {
        case 'grade':
          return Colors.green[600]!;
        case 'reminder':
          return Colors.orange[600]!;
        case 'assignment':
          return Colors.blue[600]!;
        case 'scholarship':
          return Colors.purple[600]!;
        case 'announcement':
          return Colors.red[600]!;
        case 'email':
          return Colors.teal[600]!;
        default:
          return Colors.grey[600]!;
      }
    }

    return InkWell(
      onTap: () {
        setState(() {
          _notifications[index]['isRead'] = true;
        });

        if (notification['type'] == 'email' &&
            notification['inboxId'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  InboxScreen(selectedMessageId: notification['inboxId']),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['isRead']
              ? AppThemes.getSurfaceColor(context)
              : AppThemes.getPrimaryColor(context).withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: AppThemes.getSecondaryTextColor(context).withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bildirim ikonu
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: getNotificationColor(
                  notification['type'],
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                getNotificationIcon(notification['type']),
                color: getNotificationColor(notification['type']),
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            // Bildirim içeriği
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification['isRead']
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: AppThemes.getTextColor(context),
                          ),
                        ),
                      ),
                      if (!notification['isRead'])
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppThemes.getPrimaryColor(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppThemes.getSecondaryTextColor(context),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    notification['time'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppThemes.getSecondaryTextColor(
                        context,
                      ).withOpacity(0.7),
                      fontWeight: FontWeight.w400,
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

  // Cafeteria paneli
  Widget _buildCafeteriaPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 4,
      color: theme.cardColor,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Stack(
        children: [
          SizedBox(height: 400, child: _buildCafeteriaMenuSummary(context)),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.close_outlined, color: theme.iconTheme.color),
              onPressed: () {
                setState(() {
                  _showCafeteriaMenu = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Cafeteria menü özeti
  Widget _buildCafeteriaMenuSummary(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final weekdayNames = [
      AppLocalizations.of(context)!.mondayShort,
      AppLocalizations.of(context)!.tuesdayShort,
      AppLocalizations.of(context)!.wednesdayShort,
      AppLocalizations.of(context)!.thursdayShort,
      AppLocalizations.of(context)!.fridayShort,
      AppLocalizations.of(context)!.saturdayShort,
      AppLocalizations.of(context)!.sundayShort,
    ];

    final menus = [
      [
        'Naneli Yoğurt Çorba 171 KCAL',
        'Köfteli Izgara Patlıcan Beğendi ile 378 KCAL',
        'Soslu Piliç But 335 KCAL',
        'Sade Pirinç Pilavı 330 KCAL',
        'Soslu Spagetti 276 KCAL',
        'Kolatalı Vanilyalı Dondurma 207 KCAL',
        'Salata Bar',
        'Göbek Salata',
        'Karışık Turşu',
      ],
      [
        'Ezogelin Çorba 150 KCAL',
        'Izgara Tavuk 320 KCAL',
        'Fırın Makarna 250 KCAL',
        'Pirinç Pilavı 300 KCAL',
        'Mevsim Salata',
        'Ayran',
      ],
      [
        'Mercimek Çorba 140 KCAL',
        'Etli Türlü 350 KCAL',
        'Bulgur Pilavı 280 KCAL',
        'Yoğurt',
        'Çoban Salata',
      ],
      [
        'Domates Çorba 120 KCAL',
        'Karnıyarık 400 KCAL',
        'Şehriyeli Pilav 290 KCAL',
        'Cacık',
        'Mevsim Meyve',
      ],
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (i) {
            final date = now.add(Duration(days: i));
            final weekday = weekdayNames[date.weekday - 1];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      color: AppThemes.getPrimaryColor(context),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.cafeteriaMenu,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} $weekday',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.lunch,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...menus[i % menus.length].map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                if (i < 3) const Divider(height: 24),
              ],
            );
          }),
        ),
      ),
    );
  }
}
