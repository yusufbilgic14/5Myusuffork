import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/notification_service.dart';
import '../../services/user_club_following_service.dart';
import '../../providers/authentication_provider.dart';
import '../../screens/club_chat_screen.dart';
import '../../models/user_interaction_models.dart';

/// App wrapper that handles notification initialization and navigation
/// Bildirim başlatma ve navigasyonu işleyen uygulama sarmalayıcısı
class NotificationAppWrapper extends StatefulWidget {
  final Widget child;

  const NotificationAppWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NotificationAppWrapper> createState() => _NotificationAppWrapperState();
}

class _NotificationAppWrapperState extends State<NotificationAppWrapper> {
  final NotificationService _notificationService = NotificationService();
  final UserClubFollowingService _clubService = UserClubFollowingService();
  bool _isNotificationInitialized = false;
  AuthenticationProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    debugPrint('🔔 NotificationWrapper: initState called, setting up notification service');
    _setupNotificationService();
  }

  /// Setup notification service with authentication listener
  /// Kimlik doğrulama dinleyicisi ile bildirim servisini ayarla
  void _setupNotificationService() {
    debugPrint('🔔 NotificationWrapper: _setupNotificationService called');
    // Listen to authentication changes
    // Kimlik doğrulama değişikliklerini dinle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔔 NotificationWrapper: PostFrameCallback executed');
      if (!mounted) {
        debugPrint('🔔 NotificationWrapper: Widget not mounted, skipping setup');
        return;
      }
      
      _authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      debugPrint('🔔 NotificationWrapper: Got authProvider, isAuthenticated: ${_authProvider!.isAuthenticated}');
      
      // Setup initial state
      if (_authProvider!.isAuthenticated && !_isNotificationInitialized) {
        debugPrint('🔔 NotificationWrapper: User is authenticated, initializing notifications');
        _initializeNotifications();
      } else {
        debugPrint('🔔 NotificationWrapper: User not authenticated or already initialized (auth: ${_authProvider!.isAuthenticated}, initialized: $_isNotificationInitialized)');
      }

      // Listen for authentication state changes
      _authProvider!.addListener(_onAuthStateChanged);
      debugPrint('🔔 NotificationWrapper: Auth listener added');
    });
  }

  /// Handle authentication state changes
  /// Kimlik doğrulama durumu değişikliklerini işle
  void _onAuthStateChanged() {
    debugPrint('🔔 NotificationWrapper: _onAuthStateChanged called');
    if (!mounted || _authProvider == null) {
      debugPrint('🔔 NotificationWrapper: Widget not mounted or authProvider null');
      return;
    }
    
    debugPrint('🔔 NotificationWrapper: Auth state - authenticated: ${_authProvider!.isAuthenticated}, initialized: $_isNotificationInitialized');
    
    if (_authProvider!.isAuthenticated && !_isNotificationInitialized) {
      // User logged in, initialize notifications
      debugPrint('🔔 NotificationWrapper: User logged in, initializing notifications');
      _initializeNotifications();
    } else if (!_authProvider!.isAuthenticated && _isNotificationInitialized) {
      // User logged out, cleanup notifications
      debugPrint('🔔 NotificationWrapper: User logged out, cleaning up notifications');
      _cleanupNotifications();
    }
  }

  /// Initialize notification service
  /// Bildirim servisini başlat
  Future<void> _initializeNotifications() async {
    if (!mounted) return;
    
    try {
      debugPrint('🔔 NotificationWrapper: Initializing notification service');
      
      final success = await _notificationService.initialize(
        onNavigateToChat: _navigateToChat,
      );
      
      if (mounted) {
        if (success) {
          setState(() {
            _isNotificationInitialized = true;
          });
          debugPrint('✅ NotificationWrapper: Notification service initialized');
        } else {
          debugPrint('❌ NotificationWrapper: Failed to initialize notification service');
        }
      }
    } catch (e) {
      debugPrint('❌ NotificationWrapper: Notification initialization error: $e');
    }
  }

  /// Cleanup notification service
  /// Bildirim servisini temizle
  Future<void> _cleanupNotifications() async {
    try {
      debugPrint('🧹 NotificationWrapper: Cleaning up notifications');
      
      // Clear user tokens on logout
      await _notificationService.clearUserTokens();
      
      if (mounted) {
        setState(() {
          _isNotificationInitialized = false;
        });
      }
      
      debugPrint('✅ NotificationWrapper: Notifications cleaned up');
    } catch (e) {
      debugPrint('❌ NotificationWrapper: Notification cleanup error: $e');
    }
  }

  /// Navigate to chat screen from notification
  /// Bildirimden sohbet ekranına geç
  void _navigateToChat(String clubId, String clubName) {
    if (!mounted) return;
    
    _navigateToChatAsync(clubId, clubName);
  }

  /// Navigate to chat screen asynchronously (fetch club data first)
  /// Sohbet ekranına asenkron olarak git (önce kulüp verilerini getir)
  Future<void> _navigateToChatAsync(String clubId, String clubName) async {
    try {
      debugPrint('📱 NotificationWrapper: Navigating to chat: $clubName');
      
      // First try to get club data from service
      Club club;
      try {
        final fetchedClub = await _clubService.getClubById(clubId);
        club = fetchedClub ?? Club(
          clubId: clubId,
          name: clubName,
          displayName: clubName,
          description: 'Club accessed via notification',
          category: 'general',
          createdBy: 'system',
        );
      } catch (e) {
        debugPrint('⚠️ NotificationWrapper: Could not find club by ID: $e');
        // Create a minimal club object if we can't find it
        club = Club(
          clubId: clubId,
          name: clubName,
          displayName: clubName,
          description: 'Club accessed via notification',
          category: 'general',
          createdBy: 'system',
        );
      }
      
      if (!mounted) return;
      
      // Navigate to chat screen with club object
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ClubChatScreen(
            club: club,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ NotificationWrapper: Navigation error: $e');
    }
  }

  @override
  void dispose() {
    // Remove authentication listener safely
    try {
      _authProvider?.removeListener(_onAuthStateChanged);
    } catch (e) {
      debugPrint('❌ NotificationWrapper: Error removing auth listener: $e');
    }
    
    // Dispose notification service
    try {
      _notificationService.dispose();
    } catch (e) {
      debugPrint('❌ NotificationWrapper: Error disposing notification service: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}