import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../l10n/app_localizations.dart';
import '../services/user_events_service.dart';
import '../services/user_interactions_service.dart';
import '../models/user_event_models.dart';
import '../widgets/events/realtime_event_card.dart';
import '../widgets/dialogs/add_event_dialog.dart';
import '../widgets/dialogs/edit_event_dialog.dart';
import 'event_comments_screen.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final UserEventsService _eventsService = UserEventsService();
  final UserInteractionsService _interactionsService =
      UserInteractionsService();

  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, today, week, month
  String? _selectedEventType;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSearchVisible = true;

  List<Event> _events = [];
  List<UserMyEvent> _myEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    _eventsService.dispose();
    _interactionsService.dispose();
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

  /// Load data from Firebase
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load events and user data in parallel
      final results = await Future.wait([
        _eventsService.getUpcomingEvents(limit: 30),
        _eventsService.getMyEvents(),
      ]);

      setState(() {
        _events = results[0] as List<Event>;
        _myEvents = results[1] as List<UserMyEvent>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('❌ UpcomingEventsScreen: Failed to load data - $e');
    }
  }

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
                _buildMyEventsTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: -1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptionsDialog(context),
        backgroundColor: AppThemes.getPrimaryColor(context),
        tooltip: 'Yeni Oluştur',
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


  /// Etkinliklerim sekmesi / My events tab
  Widget _buildMyEventsTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Etkinlikler yüklenirken hata oluştu',
              style: TextStyle(
                color: AppThemes.getSecondaryTextColor(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_myEvents.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _myEvents.length,
        itemBuilder: (context, index) {
          final myEvent = _myEvents[index];
          return _buildMyEventCard(context, myEvent);
        },
      ),
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
                _buildEventTypeFilter('workshop', 'Workshop'),
                _buildEventTypeFilter('conference', 'Konferans'),
                _buildEventTypeFilter('social', 'Sosyal'),
                _buildEventTypeFilter('competition', 'Yarışma'),
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
  Widget _buildEventTypeFilter(String type, String label) {
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Etkinlikler yüklenirken hata oluştu',
              style: TextStyle(
                color: AppThemes.getSecondaryTextColor(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    // Filtreleme / Filtering
    List<Event> filteredEvents = _events.where((event) {
      // Arama filtresi / Search filter
      bool matchesSearch =
          _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery) ||
          event.description.toLowerCase().contains(_searchQuery) ||
          event.organizerName.toLowerCase().contains(_searchQuery) ||
          event.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));

      // Tarih filtresi / Date filter
      bool matchesDate = true;
      final now = DateTime.now();
      switch (_selectedFilter) {
        case 'today':
          matchesDate = _isSameDay(event.startDateTime, now);
          break;
        case 'week':
          matchesDate = event.startDateTime.difference(now).inDays <= 7;
          break;
        case 'month':
          matchesDate = event.startDateTime.difference(now).inDays <= 30;
          break;
      }

      // Etkinlik türü filtresi / Event type filter
      bool matchesType =
          _selectedEventType == null || event.eventType == _selectedEventType;

      return matchesSearch &&
          matchesDate &&
          matchesType &&
          event.startDateTime.isAfter(now);
    }).toList();

    // Tarihe göre sırala / Sort by date
    filteredEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return RealTimeEventCard(
            event: event,
            club: null,
            onLike: () => _toggleLike(event),
            onJoin: () => _toggleJoin(event),
            onComment: () => _showComments(context, event),
            onShare: () => _shareEvent(event),
            onMoreOptions: () => _showEventOptions(context, event),
            onEdit: () => _editEvent(context, event),
            onDelete: () => _deleteEvent(context, event),
          );
        },
      ),
    );
  }


  /// My Event kartı / My Event card
  Widget _buildMyEventCard(BuildContext context, UserMyEvent myEvent) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              myEvent.eventTitle,
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppThemes.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatEventDate(context, myEvent.eventStartDate),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    myEvent.eventLocation,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 16,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  myEvent.organizerName,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                ),
              ],
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

  /// Aynı gün mü kontrol et / Check if same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Etkileşim metotları / Interaction methods

  /// Beğeni durumunu değiştir / Toggle like
  Future<void> _toggleLike(Event event) async {
    try {
      final wasLiked = await _eventsService.toggleEventLike(event.eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasLiked ? 'Etkinlik beğenildi' : 'Beğeni kaldırıldı',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Katılım durumunu değiştir / Toggle join
  Future<void> _toggleJoin(Event event) async {
    try {
      final hasJoined = await _eventsService.toggleEventJoin(event.eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasJoined ? 'Etkinliğe katıldınız' : 'Etkinlikten çıkıldı',
            ),
            backgroundColor: hasJoined ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );

        // Refresh data to update My Events tab
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  /// Yorumları göster / Show comments
  void _showComments(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventCommentsScreen(event: event),
      ),
    );
  }


  /// Etkinlik seçeneklerini göster / Show event options
  void _showEventOptions(BuildContext context, Event event) {
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

  /// Create options dialog / Oluştur seçenekleri dialog'u
  void _showCreateOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusMedium),
          topRight: Radius.circular(AppConstants.radiusMedium),
        ),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header / Başlık
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              
              Text(
                'Ne oluşturmak istiyorsunuz?',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.getTextColor(context),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),

              // Event Option / Etkinlik Seçeneği
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppThemes.getPrimaryColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Icon(
                    Icons.event,
                    color: AppThemes.getPrimaryColor(context),
                  ),
                ),
                title: const Text('Yeni Etkinlik'),
                subtitle: const Text('Konferans, workshop, sosyal etkinlik vb.'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateEventDialog(context);
                },
              ),

              const Divider(),

              
              const SizedBox(height: AppConstants.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }

  /// Show create event dialog / Etkinlik oluştur dialog'unu göster
  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onEventAdded: () {
          // Etkinlik eklendikten sonra verileri yenile
          _loadData();
        },
      ),
    );
  }


  /// Etkinliği paylaş / Share event
  Future<void> _shareEvent(Event event) async {
    try {
      await _eventsService.shareEvent(event.eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Etkinlik paylaşıldı'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Etkinliği kaydet / Save event
  void _saveEvent(Event event) {
    // This could be implemented as a favorites feature
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favoriler özelliği yakında eklenecek'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Etkinliği şikayet et / Report event
  void _reportEvent(Event event) {
    // This would integrate with a reporting system
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şikayet sistemi yakında eklenecek'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Etkinliği düzenle / Edit event
  void _editEvent(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => EditEventDialog(
        event: event,
        onEventUpdated: () {
          // Etkinlik güncellendikten sonra verileri yenile
          _loadData();
        },
      ),
    );
  }

  /// Etkinliği sil / Delete event
  Future<void> _deleteEvent(BuildContext context, Event event) async {
    try {
      await _eventsService.deleteEvent(event.eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Etkinlik başarıyla silindi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh data to update the list
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme hatası: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
