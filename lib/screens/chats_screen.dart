import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../l10n/app_localizations.dart';
import '../services/user_club_following_service.dart';
import '../services/club_chat_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/user_interaction_models.dart';
import 'club_chat_screen.dart';

/// Chats screen showing all clubs for chat access
/// Sohbet erişimi için tüm kulüpleri gösteren sohbet ekranı
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserClubFollowingService _clubService = UserClubFollowingService();
  final ClubChatService _chatService = ClubChatService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _searchQuery = '';
  List<Club> _clubs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _clubService.dispose();
    _chatService.dispose();
    super.dispose();
  }

  /// Load clubs from Firebase
  /// Firebase'den kulüpleri yükle
  Future<void> _loadClubs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final clubs = await _clubService.getAllClubs(limit: 50);
      setState(() {
        _clubs = clubs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('❌ ChatsScreen: Failed to load clubs - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.chats,
        subtitle: 'Sohbet odalarına katılın',
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
          // Search bar
          _buildSearchBar(context),
          
          // Clubs list
          Expanded(child: _buildClubsList(context)),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: -1),
    );
  }

  /// Build search bar
  /// Arama çubuğunu oluştur
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: AppThemes.getSurfaceColor(context),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Kulüp ara...',
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
    );
  }

  /// Build clubs list
  /// Kulüpler listesini oluştur
  Widget _buildClubsList(BuildContext context) {
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
              'Kulüpler yüklenirken hata oluştu',
              style: TextStyle(
                color: AppThemes.getSecondaryTextColor(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadClubs,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    // Filter clubs based on search query
    List<Club> filteredClubs = _clubs.where((club) {
      if (_searchQuery.isEmpty) return true;
      return club.displayName.toLowerCase().contains(_searchQuery) ||
             club.description.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredClubs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz kulüp bulunamadı',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClubs,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: filteredClubs.length,
        itemBuilder: (context, index) {
          final club = filteredClubs[index];
          return _buildClubCard(context, club);
        },
      ),
    );
  }

  /// Build club card for chat access
  /// Sohbet erişimi için kulüp kartı oluştur
  Widget _buildClubCard(BuildContext context, Club club) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          onTap: () => _handleClubTap(context, club),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                // Club logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: club.colors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Center(
                    child: club.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium,
                            ),
                            child: Image.network(
                              club.logoUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.group, size: 30);
                              },
                            ),
                          )
                        : const Icon(Icons.group, size: 30),
                  ),
                ),

                const SizedBox(width: AppConstants.paddingMedium),

                // Club info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              club.displayName,
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: AppThemes.getTextColor(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (club.verificationStatus ==
                              VerificationStatus.verified) ...[
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: AppThemes.getSecondaryTextColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${club.followerCount} takipçi',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmall,
                              color: AppThemes.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chat access indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemes.getPrimaryColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppThemes.getPrimaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle club tap - navigate to chat or show request dialog
  /// Kulüp dokunma işlemi - sohbete git veya talep dialog'u göster
  Future<void> _handleClubTap(BuildContext context, Club club) async {
    try {
      // Check if user is the creator
      final currentUserId = _authService.currentAppUser?.id;
      final isCreator = currentUserId != null && currentUserId == club.createdBy;
      
      if (isCreator) {
        // Creator has direct access
        _navigateToChat(context, club);
        return;
      }

      // Check if user has chat access
      final hasChatAccess = await _chatService.checkChatAccess(club.clubId);
      
      if (hasChatAccess) {
        // User has chat access, navigate directly
        _navigateToChat(context, club);
      } else {
        // Check if user is following the club
        final isFollowing = await _clubService.isFollowingClub(club.clubId);
        
        if (!isFollowing) {
          // User must follow club first
          _showFollowFirstDialog(context, club);
        } else {
          // User is following but needs chat permission
          _showRequestChatAccessDialog(context, club);
        }
      }
    } catch (e) {
      debugPrint('❌ ChatsScreen: Error handling club tap: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to club chat
  /// Kulüp sohbetine git
  void _navigateToChat(BuildContext context, Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubChatScreen(club: club),
      ),
    );
  }

  /// Show follow first dialog
  /// Önce takip et dialog'unu göster
  void _showFollowFirstDialog(BuildContext context, Club club) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kulübü Takip Et'),
        content: Text(
          '${club.displayName} kulübünün sohbet odasına erişmek için önce kulübü takip etmelisiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _followClubAndRequestAccess(context, club);
            },
            child: const Text('Takip Et ve Sohbet Erişimi İste'),
          ),
        ],
      ),
    );
  }

  /// Follow club and request chat access
  /// Kulübü takip et ve sohbet erişimi iste
  Future<void> _followClubAndRequestAccess(BuildContext context, Club club) async {
    try {
      // Follow the club first
      await _clubService.toggleClubFollow(club.clubId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${club.displayName} takip edildi'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Then show chat access request dialog
        _showRequestChatAccessDialog(context, club);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show request chat access dialog
  /// Sohbet erişimi talep dialog'unu göster
  void _showRequestChatAccessDialog(BuildContext context, Club club) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Sohbet Erişimi İste'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${club.displayName} kulübünün sohbet odasına erişim talebiniz kulüp kurucusuna gönderilecek.',
                style: TextStyle(
                  color: AppThemes.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'İsteğe bağlı mesaj (örn: neden katılmak istiyorsunuz)...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _requestChatAccess(context, club, controller.text.trim());
              },
              child: const Text('Talep Gönder'),
            ),
          ],
        );
      },
    );
  }

  /// Request chat access
  /// Sohbet erişimi talep et
  Future<void> _requestChatAccess(BuildContext context, Club club, String message) async {
    try {
      final success = await _chatService.requestChatAccess(
        clubId: club.clubId,
        requestMessage: message.isEmpty ? null : message,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sohbet erişim talebi gönderildi!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talep gönderilemedi. Zaten talep göndermişsiniz olabilirsiniz.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}