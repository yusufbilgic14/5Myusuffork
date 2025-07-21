import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../l10n/app_localizations.dart';
import '../services/user_events_service.dart';
import '../services/user_interactions_service.dart';
import '../services/user_club_following_service.dart';
import '../models/user_event_models.dart';
import '../models/user_interaction_models.dart';

// Helper class to combine event data with user interactions
class EventWithInteraction {
  final Event event;
  final UserEventInteraction? interaction;
  final Club? club;

  EventWithInteraction({
    required this.event,
    this.interaction,
    this.club,
  });

  bool get isLiked => interaction?.hasLiked ?? false;
  bool get isJoined => interaction?.hasJoined ?? false;
  bool get hasShared => interaction?.hasShared ?? false;
  bool get isFavorited => interaction?.isFavorited ?? false;
}

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, today, week, month
  EventType? _selectedEventType;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSearchVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 100 && _isSearchVisible) {
      setState(() {
        _isSearchVisible = false;
      });
      _animationController.reverse();
    } else if (_scrollController.offset <= 100 && !_isSearchVisible) {
      setState(() {
        _isSearchVisible = true;
      });
      _animationController.forward();
    }
  }

  // Örnek kulüpler / Sample clubs
  final List<UniversityClub> _clubs = [
    UniversityClub(
      id: 'cs_club',
      name: 'Bilgisayar Kulübü',
      description: 'Teknoloji ve yazılım geliştirme topluluğu',
      logo: '💻',
      primaryColor: Colors.blue,
      memberCount: 245,
      isVerified: true,
    ),
    UniversityClub(
      id: 'debate_club',
      name: 'Münazara Topluluğu',
      description: 'Düşünce ve ifade özgürlüğü platformu',
      logo: '🎤',
      primaryColor: Colors.orange,
      memberCount: 156,
      isVerified: true,
    ),
    UniversityClub(
      id: 'photo_club',
      name: 'Fotoğrafçılık Kulübü',
      description: 'Yaratıcı görsel sanatlar topluluğu',
      logo: '📸',
      primaryColor: Colors.purple,
      memberCount: 189,
    ),
    UniversityClub(
      id: 'volunteer_club',
      name: 'Gönüllülük Topluluğu',
      description: 'Sosyal sorumluluk ve yardımlaşma',
      logo: '❤️',
      primaryColor: Colors.red,
      memberCount: 312,
      isVerified: true,
    ),
    UniversityClub(
      id: 'music_club',
      name: 'Müzik Topluluğu',
      description: 'Müzikal etkinlikler ve performanslar',
      logo: '🎵',
      primaryColor: Colors.green,
      memberCount: 198,
    ),
  ];

  // Örnek etkinlik gönderileri / Sample event posts
  late final List<EventPost> _eventPosts = [
    EventPost(
      id: 'event_1',
      club: _clubs[0],
      title: 'Flutter & Dart Workshop',
      description:
          'Mobil uygulama geliştirme workshop\'u. Başlangıç seviyesinden ileri seviyeye Flutter teknolojisi öğrenin. Katılım ücretsizdir!',
      eventDate: DateTime.now().add(const Duration(days: 3)),
      postDate: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'Bilgisayar Mühendisliği Lab - B201',
      imageUrl: 'assets/images/upcoming_events_post_photos/flutter.png',
      tags: ['Flutter', 'Mobile', 'Programming', 'Free'],
      likeCount: 45,
      commentCount: 12,
      participantCount: 28,
      maxParticipants: 50,
      type: EventType.workshop,
    ),
    EventPost(
      id: 'event_2',
      club: _clubs[1],
      title: 'Yapay Zeka ve Etik Münazarası',
      description:
          'AI teknolojilerinin toplumsal etkilerini tartışacağımız münazara etkinliği. Uzman konuşmacılar ve interaktif oturumlar.',
      eventDate: DateTime.now().add(const Duration(days: 5)),
      postDate: DateTime.now().subtract(const Duration(hours: 8)),
      location: 'Konferans Salonu - Ana Kampüs',
      imageUrl: 'assets/images/upcoming_events_post_photos/ai_convention.png',
      tags: ['AI', 'Ethics', 'Debate', 'Technology'],
      likeCount: 67,
      commentCount: 23,
      participantCount: 45,
      maxParticipants: 100,
      type: EventType.conference,
    ),
    EventPost(
      id: 'event_3',
      club: _clubs[2],
      title: 'Kampüs Fotoğraf Yarışması',
      description:
          'Medipol kampüsünün en güzel fotoğraflarını çekme yarışması! Kazananlara ödüller ve sürprizler var.',
      eventDate: DateTime.now().add(const Duration(days: 7)),
      postDate: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Tüm Kampüs Alanı',
      imageUrl: 'assets/images/upcoming_events_post_photos/photo.png',
      tags: ['Photography', 'Competition', 'Art', 'Campus'],
      likeCount: 89,
      commentCount: 31,
      participantCount: 67,
      maxParticipants: 200,
      type: EventType.competition,
    ),
    EventPost(
      id: 'event_4',
      club: _clubs[3],
      title: 'Kitap Bağışı Kampanyası',
      description:
          'Muhtaç çocuklar için kitap toplama kampanyası. Okuduğunuz kitapları bağışlayın, bilgiyi paylaşın!',
      eventDate: DateTime.now().add(const Duration(days: 1)),
      postDate: DateTime.now().subtract(const Duration(hours: 12)),
      location: 'Öğrenci Merkezi Lobi',
      imageUrl: 'assets/images/upcoming_events_post_photos/photo_competition.png',
      tags: ['Charity', 'Books', 'Social Responsibility'],
      likeCount: 123,
      commentCount: 45,
      participantCount: 89,
      maxParticipants: 500,
      type: EventType.charity,
    ),
    EventPost(
      id: 'event_5',
      club: _clubs[4],
      title: 'Akustik Müzik Gecesi',
      description:
          'Öğrenci müzisyenlerimizin performanslarıyla unutulmaz bir akşam. Kahve ve tatlılar eşliğinde müzik keyfi.',
      eventDate: DateTime.now().add(const Duration(days: 10)),
      postDate: DateTime.now().subtract(const Duration(hours: 18)),
      location: 'Kafeterya - Açık Hava Sahnesi',
      imageUrl: 'assets/images/upcoming_events_post_photos/book_donation.png',
      tags: ['Music', 'Performance', 'Social', 'Culture'],
      likeCount: 78,
      commentCount: 19,
      participantCount: 56,
      maxParticipants: 150,
      type: EventType.cultural,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.upcomingEvents,
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
      drawer: const AppDrawerWidget(currentPageIndex: -1),
      body: Column(
        children: [
          // Üst sekme çubuğu / Top tab bar
          _buildTabBar(context),

          // İçerik / Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsTab(context),
                _buildClubsTab(context),
                _buildMyEventsTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: -1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context),
        backgroundColor: AppThemes.getPrimaryColor(context),
        tooltip: 'Etkinlik Oluştur',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Sekme çubuğu / Tab bar
  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: AppThemes.getSurfaceColor(context),
      child: TabBar(
        controller: _tabController,
        labelColor: AppThemes.getPrimaryColor(context),
        unselectedLabelColor: AppThemes.getSecondaryTextColor(context),
        indicatorColor: AppThemes.getPrimaryColor(context),
        tabs: [
          Tab(
            icon: const Icon(Icons.event),
            text: AppLocalizations.of(context)!.events,
          ),
          Tab(
            icon: const Icon(Icons.groups),
            text: AppLocalizations.of(context)!.clubs,
          ),
          Tab(
            icon: const Icon(Icons.bookmark),
            text: AppLocalizations.of(context)!.myEvents,
          ),
        ],
      ),
    );
  }

  /// Etkinlikler sekmesi / Events tab
  Widget _buildEventsTab(BuildContext context) {
    return Column(
      children: [
        // Arama ve filtreler / Search and filters
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _animation,
              child: _buildSearchAndFilters(context),
            );
          },
        ),

        // Etkinlik listesi / Events list
        Expanded(child: _buildEventsList(context)),
      ],
    );
  }

  /// Kulüpler sekmesi / Clubs tab
  Widget _buildClubsTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _clubs.length,
      itemBuilder: (context, index) {
        final club = _clubs[index];
        return _buildClubCard(context, club);
      },
    );
  }

  /// Etkinliklerim sekmesi / My events tab
  Widget _buildMyEventsTab(BuildContext context) {
    final joinedEvents = _eventPosts.where((event) => event.isJoined).toList();

    if (joinedEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz katıldığınız etkinlik yok.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Etkinliklere katılmaya başlayın!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: joinedEvents.length,
      itemBuilder: (context, index) {
        return _buildEventCard(context, joinedEvents[index]);
      },
    );
  }

  /// Arama ve filtreler / Search and filters
  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: AppThemes.getSurfaceColor(context),
      child: Column(
        children: [
          // Arama kutusu / Search box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Etkinlik ara...',
              prefixIcon: const Icon(Icons.search),
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
              ),
              filled: true,
              fillColor: AppThemes.getBackgroundColor(context),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Filtreler / Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tümü', 'all'),
                _buildFilterChip('Bugün', 'today'),
                _buildFilterChip('Bu Hafta', 'week'),
                _buildFilterChip('Bu Ay', 'month'),
                const SizedBox(width: AppConstants.paddingSmall),
                _buildEventTypeFilter(EventType.workshop, 'Workshop'),
                _buildEventTypeFilter(EventType.conference, 'Konferans'),
                _buildEventTypeFilter(EventType.social, 'Sosyal'),
                _buildEventTypeFilter(EventType.competition, 'Yarışma'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Filtre chip'i / Filter chip
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
        selectedColor: AppThemes.getPrimaryColor(
          context,
        ).withValues(alpha: 0.2),
        checkmarkColor: AppThemes.getPrimaryColor(context),
      ),
    );
  }

  /// Etkinlik türü filtresi / Event type filter
  Widget _buildEventTypeFilter(EventType type, String label) {
    final isSelected = _selectedEventType == type;
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedEventType = selected ? type : null;
          });
        },
        selectedColor: AppThemes.getPrimaryColor(
          context,
        ).withValues(alpha: 0.2),
        checkmarkColor: AppThemes.getPrimaryColor(context),
      ),
    );
  }

  /// Etkinlik listesi / Events list
  Widget _buildEventsList(BuildContext context) {
    // Filtreleme / Filtering
    List<EventPost> filteredEvents = _eventPosts.where((event) {
      // Arama filtresi / Search filter
      bool matchesSearch =
          _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery) ||
          event.description.toLowerCase().contains(_searchQuery) ||
          event.club.name.toLowerCase().contains(_searchQuery) ||
          event.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));

      // Tarih filtresi / Date filter
      bool matchesDate = true;
      final now = DateTime.now();
      switch (_selectedFilter) {
        case 'today':
          matchesDate = _isSameDay(event.eventDate, now);
          break;
        case 'week':
          matchesDate = event.eventDate.difference(now).inDays <= 7;
          break;
        case 'month':
          matchesDate = event.eventDate.difference(now).inDays <= 30;
          break;
      }

      // Etkinlik türü filtresi / Event type filter
      bool matchesType =
          _selectedEventType == null || event.type == _selectedEventType;

      return matchesSearch &&
          matchesDate &&
          matchesType &&
          event.eventDate.isAfter(now);
    }).toList();

    // Tarihe göre sırala / Sort by date
    filteredEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));

    if (filteredEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Arama kriterlerinize uygun etkinlik bulunamadı.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        return _buildEventCard(context, filteredEvents[index]);
      },
    );
  }

  /// Etkinlik kartı / Event card
  Widget _buildEventCard(BuildContext context, EventPost event) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kulüp başlığı / Club header
          _buildEventHeader(context, event),

          // Etkinlik içeriği / Event content
          _buildEventContent(context, event),

          // Etkileşim butonları / Interaction buttons
          _buildEventActions(context, event),
        ],
      ),
    );
  }

  /// Etkinlik başlığı / Event header
  Widget _buildEventHeader(BuildContext context, EventPost event) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          // Kulüp logosu / Club logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: event.club.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Center(
              child: Text(
                event.club.logo,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Kulüp bilgisi / Club info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.club.name,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.getTextColor(context),
                      ),
                    ),
                    if (event.club.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                    ],
                  ],
                ),
                Text(
                  _formatPostTime(event.postDate),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),

          // Daha fazla seçeneği / More options
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showEventOptions(context, event),
          ),
        ],
      ),
    );
  }

  /// Etkinlik içeriği / Event content
  Widget _buildEventContent(BuildContext context, EventPost event) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık / Title
          Text(
            event.title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppThemes.getTextColor(context),
            ),
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Açıklama / Description
          Text(
            event.description,
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppThemes.getTextColor(context),
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Etkinlik görseli / Event image
          if (event.imageUrl != null) _buildEventImage(context, event),

          // Etkinlik detayları / Event details
          _buildEventDetails(context, event),

          const SizedBox(height: AppConstants.paddingMedium),

          // Etiketler / Tags
          if (event.tags.isNotEmpty) _buildEventTags(context, event),
        ],
      ),
    );
  }

  /// Etkinlik görseli / Event image
  Widget _buildEventImage(BuildContext context, EventPost event) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: Image.asset(
          event.imageUrl!,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Etkinlik detayları / Event details
  Widget _buildEventDetails(BuildContext context, EventPost event) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Column(
        children: [
          // Tarih ve saat / Date and time
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: AppThemes.getPrimaryColor(context),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                _formatEventDate(context, event.eventDate),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                  color: AppThemes.getTextColor(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Konum / Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: AppThemes.getPrimaryColor(context),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  event.location,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Katılımcı sayısı / Participant count
          Row(
            children: [
              Icon(
                Icons.people,
                size: 20,
                color: AppThemes.getPrimaryColor(context),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                '${event.participantCount}/${event.maxParticipants} katılımcı',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppThemes.getTextColor(context),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: LinearProgressIndicator(
                  value: event.participantCount / event.maxParticipants,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppThemes.getPrimaryColor(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Etkinlik etiketleri / Event tags
  Widget _buildEventTags(BuildContext context, EventPost event) {
    return Wrap(
      spacing: AppConstants.paddingSmall,
      runSpacing: AppConstants.paddingSmall,
      children: event.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: event.club.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: event.club.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Etkinlik etkileşim butonları / Event action buttons
  Widget _buildEventActions(BuildContext context, EventPost event) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          // İstatistikler / Statistics
          Row(
            children: [
              Text(
                '${event.likeCount} beğeni',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppThemes.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Text(
                '${event.commentCount} yorum',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppThemes.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          const Divider(height: 1),

          const SizedBox(height: AppConstants.paddingSmall),

          // Aksiyon butonları / Action buttons
          Row(
            children: [
              // Beğen butonu / Like button
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _toggleLike(event),
                  icon: Icon(
                    event.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: event.isLiked
                        ? Colors.red
                        : AppThemes.getSecondaryTextColor(context),
                  ),
                  label: Text(
                    'Beğen',
                    style: TextStyle(
                      color: event.isLiked
                          ? Colors.red
                          : AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ),

              // Yorum butonu / Comment button
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showComments(context, event),
                  icon: Icon(
                    Icons.comment_outlined,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                  label: Text(
                    'Yorum',
                    style: TextStyle(
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ),

              // Katıl butonu / Join button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: event.participantCount >= event.maxParticipants
                      ? null
                      : () => _toggleJoin(event),
                  icon: Icon(
                    event.isJoined ? Icons.check : Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    event.isJoined ? 'Katıldım' : 'Katıl',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: event.isJoined
                        ? Colors.green[600]
                        : AppThemes.getPrimaryColor(context),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kulüp kartı / Club card
  Widget _buildClubCard(BuildContext context, UniversityClub club) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // Kulüp logosu / Club logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: club.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Center(
                child: Text(club.logo, style: const TextStyle(fontSize: 24)),
              ),
            ),

            const SizedBox(width: AppConstants.paddingMedium),

            // Kulüp bilgisi / Club info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        club.name,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: AppThemes.getTextColor(context),
                        ),
                      ),
                      if (club.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 18,
                          color: AppThemes.getPrimaryColor(context),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club.description,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${club.memberCount} üye',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Takip et butonu / Follow button
            ElevatedButton(
              onPressed: () => _followClub(club),
              style: ElevatedButton.styleFrom(
                backgroundColor: club.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
              ),
              child: const Text('Takip Et'),
            ),
          ],
        ),
      ),
    );
  }

  // Yardımcı metotlar / Helper methods

  /// Tarih formatla / Format date
  String _formatEventDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Bugün, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yarın, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final days = [
        AppLocalizations.of(context)!.monday,
        AppLocalizations.of(context)!.tuesday,
        AppLocalizations.of(context)!.wednesday,
        AppLocalizations.of(context)!.thursday,
        AppLocalizations.of(context)!.friday,
        AppLocalizations.of(context)!.saturday,
        AppLocalizations.of(context)!.sunday,
      ];
      return '${days[date.weekday - 1]}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Gönderi zamanını formatla / Format post time
  String _formatPostTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  /// Aynı gün mü kontrol et / Check if same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Etkileşim metotları / Interaction methods

  /// Beğeni durumunu değiştir / Toggle like
  void _toggleLike(EventPost event) {
    setState(() {
      // Gerçek uygulamada API çağrısı olacak / In real app, this would be an API call
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          event.isLiked ? 'Beğeni kaldırıldı' : 'Etkinlik beğenildi',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Katılım durumunu değiştir / Toggle join
  void _toggleJoin(EventPost event) {
    setState(() {
      // Gerçek uygulamada API çağrısı olacak / In real app, this would be an API call
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          event.isJoined ? 'Etkinlikten çıkıldı' : 'Etkinliğe katıldınız',
        ),
        backgroundColor: event.isJoined ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Kulübü takip et / Follow club
  void _followClub(UniversityClub club) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${club.name} takip edildi'),
        backgroundColor: club.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Yorumları göster / Show comments
  void _showComments(BuildContext context, EventPost event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppThemes.getSurfaceColor(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: Column(
          children: [
            // Başlık / Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppThemes.getSecondaryTextColor(
                      context,
                    ).withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Yorumlar',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.getTextColor(context),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Yorumlar listesi / Comments list
            const Expanded(
              child: Center(
                child: Text(
                  'Yorumlar yakında eklenecek...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Etkinlik seçeneklerini göster / Show event options
  void _showEventOptions(BuildContext context, EventPost event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Paylaş'),
              onTap: () {
                Navigator.pop(context);
                _shareEvent(event);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Kaydet'),
              onTap: () {
                Navigator.pop(context);
                _saveEvent(event);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Şikayet Et'),
              onTap: () {
                Navigator.pop(context);
                _reportEvent(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Etkinlik oluştur dialog'u / Create event dialog
  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinlik Oluştur'),
        content: const Text(
          'Etkinlik oluşturma özelliği yakında kullanıma sunulacak.\n\n'
          'Kulüp yöneticileri ve yetkili kişiler etkinlik oluşturabilecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Etkinliği paylaş / Share event
  void _shareEvent(EventPost event) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Etkinlik paylaşma özelliği yakında eklenecek'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Etkinliği kaydet / Save event
  void _saveEvent(EventPost event) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Etkinlik kaydedildi'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Etkinliği şikayet et / Report event
  void _reportEvent(EventPost event) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şikayet gönderildi'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
