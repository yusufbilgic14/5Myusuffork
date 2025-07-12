import 'package:flutter/material.dart';
import 'dart:async';
import 'calendar_screen.dart';
import 'campus_map_screen.dart';
import 'qr_access_screen.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart';
import 'inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Home tab is selected (index 2)
  int _currentAnnouncementIndex = 0;
  late PageController _pageController;
  Timer? _autoAdvanceTimer;
  bool _showNotifications =
      false; // Bildirim popup'ını kontrol etmek için / To control notification popup

  // Duyuru listesi / Announcements list
  final List<Map<String, String>> _announcements = [
    {
      'title': 'Mezuniyet Töreni 2025',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '20.06.2025',
    },
    {
      'title': 'Bahar Dönemi Final Sınavları',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '18.06.2025',
    },
    {
      'title': 'Yaz Okulu Kayıtları Başladı',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '15.06.2025',
    },
    {
      'title': 'Kariyer Günleri 2025',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '12.06.2025',
    },
    {
      'title': 'Burs Başvuruları Son Tarih',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '10.06.2025',
    },
    {
      'title': 'Öğrenci Konseyi Seçimleri',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '08.06.2025',
    },
    {
      'title': 'Sosyal Etkinlik: Konser',
      'image': 'assets/images/announcement-image.jpeg',
      'date': '05.06.2025',
    },
  ];

  // Bildirim listesi / Notifications list
  final List<Map<String, dynamic>> _notifications = [
    // Inbox mesajları / Inbox messages
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
    // Ek bildirimler / Additional notifications
    {
      'title': 'Visual Programming Final Notunuz Paylaşılmıştır',
      'message':
          'Visual Programming dersi final sınavı notunuz sisteme yüklenmiştir. Notunuzu kontrol edebilirsiniz.',
      'time': '2 saat önce',
      'isRead': false,
      'type': 'grade',
    },
    {
      'title': 'Kütüphane Kitap İade Hatırlatması',
      'message':
          'Ödünç aldığınız "Algorithm Design" kitabının iade tarihi yaklaşmaktadır. Lütfen 3 gün içinde iade ediniz.',
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
      'message':
          'Başarı bursu başvurunuz değerlendirme aşamasındadır. Sonuç 1 hafta içinde bildirilecektir.',
      'time': '2 gün önce',
      'isRead': true,
      'type': 'scholarship',
    },
    {
      'title': 'Yeni Duyuru: Mezuniyet Töreni',
      'message':
          'Mezuniyet töreni için kayıt işlemleri başlamıştır. Detaylı bilgi için öğrenci işleri ile iletişime geçiniz.',
      'time': '3 gün önce',
      'isRead': true,
      'type': 'announcement',
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

  // Otomatik duyuru geçişini başlat / Start auto-advance
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

  // Belirli bir duyuruya git / Go to specific announcement
  void _goToAnnouncement(int index) {
    if (!mounted || !_pageController.hasClients) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Bildirim panelini oluştur / Build notification panel
  Widget _buildNotificationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel başlığı / Panel header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications,
                  color: Color(0xFF1E3A8A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bildirimler',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      // Tüm bildirimleri okundu olarak işaretle / Mark all notifications as read
                      for (var notification in _notifications) {
                        notification['isRead'] = true;
                      }
                    });
                  },
                  child: const Text(
                    'Tümünü Okundu İşaretle',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showNotifications = false;
                    });
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Color(0xFF1E3A8A),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Bildirim listesi / Notification list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Bildirim öğesi oluştur / Build notification item
  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    IconData getNotificationIcon(String type) {
      switch (type) {
        case 'grade':
          return Icons.grade;
        case 'reminder':
          return Icons.schedule;
        case 'assignment':
          return Icons.assignment;
        case 'scholarship':
          return Icons.account_balance_wallet;
        case 'announcement':
          return Icons.campaign;
        case 'email':
          return Icons.email;
        default:
          return Icons.notifications;
      }
    }

    Color getNotificationColor(String type) {
      switch (type) {
        case 'grade':
          return Colors.green;
        case 'reminder':
          return Colors.orange;
        case 'assignment':
          return Colors.blue;
        case 'scholarship':
          return Colors.purple;
        case 'announcement':
          return Colors.red;
        case 'email':
          return Colors.teal;
        default:
          return Colors.grey;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _notifications[index]['isRead'] = true;
        });

        // E-posta tipindeki bildirimler için inbox'a git / Navigate to inbox for email notifications
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
          color: notification['isRead'] ? Colors.grey[50] : Colors.blue[50],
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bildirim ikonu / Notification icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: getNotificationColor(
                  notification['type'],
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                getNotificationIcon(notification['type']),
                color: getNotificationColor(notification['type']),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Bildirim içeriği / Notification content
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
                                : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (!notification['isRead'])
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E3A8A),
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
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    notification['time'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
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
                    icon: Icons.mail,
                    title: 'Message Box',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InboxScreen(),
                        ),
                      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildSideDrawer(), // Sidebar eklendi / Sidebar added
      body: Stack(
        children: [
          Column(
            children: [
              // Mavi üst header / Blue header section
              Container(
                color: const Color(0xFF1E3A8A),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Hamburger menu ve hoşgeldin metni / Hamburger menu and welcome text
                        Row(
                          children: [
                            Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  child: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Elif Yılmaz',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bildirim ikonu / Notification icon
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showNotifications = !_showNotifications;
                                });
                              },
                              child: Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  // Okunmamış bildirim sayısı / Unread notification count
                                  if (_notifications
                                      .where((n) => !n['isRead'])
                                      .isNotEmpty)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 12,
                                          minHeight: 12,
                                        ),
                                        child: Text(
                                          '${_notifications.where((n) => !n['isRead']).length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bildirim paneli / Notification panel
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _showNotifications ? 350 : 0,
                child: _showNotifications ? _buildNotificationPanel() : null,
              ),

              // Ana içerik alanı / Main content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Duyuru kartı / Announcement card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Duyuru kartı PageView / Announcement card PageView
                            SizedBox(
                              width: double.infinity,
                              height: 160,
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
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          // Arka plan resmi / Background image
                                          Positioned.fill(
                                            child: Image.asset(
                                              announcement['image']!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.campaign,
                                                          size: 48,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),

                                          // Üst tarih etiketi / Top date label
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.7,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                announcement['date']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Alt overlay ve metin / Bottom overlay and text
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              child: Text(
                                                announcement['title']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
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

                            const SizedBox(height: 12),

                            // Nokta göstergeleri / Dot indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_announcements.length, (
                                index,
                              ) {
                                return GestureDetector(
                                  onTap: () => _goToAnnouncement(index),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index == _currentAnnouncementIndex
                                          ? const Color(0xFF1E3A8A)
                                          : Colors.grey[300],
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 24),

                            // Gün navigasyonu / Day navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.chevron_left),
                                  color: Colors.grey[600],
                                ),
                                const Text(
                                  'Friday, 24th',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.chevron_right),
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Program/Takvim bölümü / Schedule/Calendar section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Zaman çizelgesi / Time schedule
                            SizedBox(
                              height: 400,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sol taraf zaman göstergeleri / Left side time indicators
                                  SizedBox(
                                    width: 50,
                                    child: Column(
                                      children: [
                                        for (int hour = 8; hour <= 11; hour++)
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Text(
                                                  '${hour.toString().padLeft(2, '0')}:00',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Sağ taraf program kartları / Right side schedule cards
                                  Expanded(
                                    child: Column(
                                      children: [
                                        // İlk ders kartı / First course card
                                        Container(
                                          height: 120,
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E3A8A),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                // Ders ikonu / Course icon
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.code,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                // Ders bilgileri / Course information
                                                const Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Visual Programming',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '3B06',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '08:00 - 10:00',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // İkinci ders kartı (kısmi görünür) / Second course card (partially visible)
                                        Container(
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E3A8A),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                // Quiz ikonu / Quiz icon
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.quiz,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                // Quiz bilgileri / Quiz information
                                                const Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'OOP Quiz-1',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 80,
                      ), // Alt navigasyon için boşluk / Space for bottom navigation
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Alt navigasyon çubuğu / Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.location_on, 'Navigation', 0),
                _buildBottomNavItem(Icons.calendar_today, 'Calendar', 1),
                _buildBottomNavItem(Icons.home, 'Home', 2),
                _buildBottomNavItem(Icons.qr_code_scanner, 'Scan', 3),
                _buildBottomNavItem(Icons.person, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Alt navigasyon öğesi oluşturucu / Bottom navigation item builder
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Eğer farklı bir tab seçildiyse navigasyon yap / Navigate if different tab is selected
        if (index != _selectedIndex) {
          switch (index) {
            case 0: // Navigation / Campus Map
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CampusMapScreen(),
                ),
              );
              break;
            case 1: // Calendar
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
              break;
            case 2: // Home - zaten buradayız / Already here
              break;
            case 3: // Scan / QR Access
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRAccessScreen()),
              );
              break;
            case 4: // Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        }

        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
