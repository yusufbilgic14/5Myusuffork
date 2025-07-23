import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import '../models/club_chat_models.dart';
import '../models/user_profile_model.dart';
import 'firebase_auth_service.dart';
import 'user_profile_service.dart';
import 'club_chat_service.dart';

/// Firebase Cloud Messaging notification service for push notifications
/// Anında bildirimler için Firebase Cloud Messaging bildirim servisi
class NotificationService {
  // Singleton pattern implementation
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Firebase instances
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserProfileService _profileService = UserProfileService();
  final ClubChatService _chatService = ClubChatService();

  // Notification handlers
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  String? _currentFCMToken;
  
  // Navigate to chat callback
  Function(String clubId, String clubName)? _onNavigateToChat;
  
  /// Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // INITIALIZATION / BAŞLATMA
  // ==========================================

  /// Initialize notification service
  /// Bildirim servisini başlat
  Future<bool> initialize({
    Function(String clubId, String clubName)? onNavigateToChat,
  }) async {
    try {
      debugPrint('🔔 NotificationService: Initializing notification service');
      
      _onNavigateToChat = onNavigateToChat;

      // Request notification permissions
      final permissionGranted = await _requestPermissions();
      if (!permissionGranted) {
        debugPrint('❌ NotificationService: Notification permissions denied');
        return false;
      }

      // Get and store FCM token
      final tokenSet = await _setupFCMToken();
      if (!tokenSet) {
        debugPrint('❌ NotificationService: Failed to setup FCM token');
        return false;
      }

      // Setup message handlers
      await _setupMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

      debugPrint('✅ NotificationService: Service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ NotificationService: Initialization error: $e');
      return false;
    }
  }

  /// Request notification permissions
  /// Bildirim izinlerini iste
  Future<bool> _requestPermissions() async {
    try {
      debugPrint('📋 NotificationService: Requesting notification permissions');

      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized;
      debugPrint('🔔 NotificationService: Permission status: ${settings.authorizationStatus}');
      
      return granted;
    } catch (e) {
      debugPrint('❌ NotificationService: Permission request error: $e');
      return false;
    }
  }

  /// Setup FCM token and store in user profile
  /// FCM token'ı ayarla ve kullanıcı profilinde sakla
  Future<bool> _setupFCMToken() async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        debugPrint('❌ NotificationService: User not authenticated for token setup');
        return false;
      }

      debugPrint('🔑 NotificationService: Setting up FCM token');

      // Get current FCM token
      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        debugPrint('❌ NotificationService: Failed to get FCM token');
        return false;
      }

      _currentFCMToken = token;
      debugPrint('✅ NotificationService: FCM token obtained: ${token.substring(0, 20)}...');

      // Store token in user profile
      await _storeTokenInProfile(token);

      return true;
    } catch (e) {
      debugPrint('❌ NotificationService: FCM token setup error: $e');
      return false;
    }
  }

  /// Store FCM token in user profile
  /// FCM token'ı kullanıcı profilinde sakla
  Future<void> _storeTokenInProfile(String token) async {
    try {
      if (!isAuthenticated || currentUserId == null) return;

      debugPrint('💾 NotificationService: Storing FCM token in profile');

      // Get current profile
      final profile = await _profileService.getUserProfile();
      if (profile == null) {
        debugPrint('❌ NotificationService: User profile not found');
        return;
      }

      // Update device tokens (store multiple tokens for multi-device support)
      final currentTokens = profile.deviceTokens ?? [];
      final updatedTokens = [...currentTokens];
      
      // Remove old token if exists and add new one
      updatedTokens.removeWhere((t) => t == token);
      updatedTokens.add(token);
      
      // Keep only last 5 tokens per user
      if (updatedTokens.length > 5) {
        updatedTokens.removeRange(0, updatedTokens.length - 5);
      }

      // Update profile with new tokens
      final updatedProfile = profile.copyWith(
        deviceTokens: updatedTokens,
        updatedAt: DateTime.now(),
      );

      await _profileService.updateUserProfile(updatedProfile);
      debugPrint('✅ NotificationService: FCM token stored in profile');
    } catch (e) {
      debugPrint('❌ NotificationService: Error storing token: $e');
    }
  }

  /// Handle token refresh
  /// Token yenilenmesini işle
  Future<void> _onTokenRefresh(String token) async {
    try {
      debugPrint('🔄 NotificationService: FCM token refreshed');
      _currentFCMToken = token;
      await _storeTokenInProfile(token);
    } catch (e) {
      debugPrint('❌ NotificationService: Token refresh error: $e');
    }
  }

  // ==========================================
  // MESSAGE HANDLERS / MESAJ İŞLEYİCİLERİ
  // ==========================================

  /// Setup message handlers for different app states
  /// Farklı uygulama durumları için mesaj işleyicilerini ayarla
  Future<void> _setupMessageHandlers() async {
    try {
      debugPrint('📱 NotificationService: Setting up message handlers');

      // Handle messages when app is terminated
      // Uygulama kapatıldığında mesajları işle
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 NotificationService: App opened from terminated state via notification');
        await _handleNotificationTap(initialMessage);
      }

      // Handle messages when app is in background
      // Uygulama arka plandayken mesajları işle
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📱 NotificationService: App opened from background via notification');
        _handleNotificationTap(message);
      });

      // Handle messages when app is in foreground
      // Uygulama ön plandayken mesajları işle
      _foregroundSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📱 NotificationService: Received foreground message');
        _handleForegroundMessage(message);
      });

      debugPrint('✅ NotificationService: Message handlers setup complete');
    } catch (e) {
      debugPrint('❌ NotificationService: Message handler setup error: $e');
    }
  }

  /// Handle notification tap (from background/terminated state)
  /// Bildirim dokunmasını işle (arka plan/kapatılmış durumdan)
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    try {
      debugPrint('👆 NotificationService: Handling notification tap');
      
      final data = message.data;
      final notificationType = data['type'];

      if (notificationType == 'chat_message') {
        final clubId = data['clubId'];
        final clubName = data['clubName'];
        
        if (clubId != null && clubName != null && _onNavigateToChat != null) {
          debugPrint('💬 NotificationService: Navigating to chat: $clubName');
          _onNavigateToChat!(clubId, clubName);
        }
      }
    } catch (e) {
      debugPrint('❌ NotificationService: Notification tap handling error: $e');
    }
  }

  /// Handle foreground message
  /// Ön plan mesajını işle
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      debugPrint('📱 NotificationService: Processing foreground message');
      
      // For chat messages, we might want to show an in-app notification
      // Sohbet mesajları için uygulama içi bildirim gösterebiliriz
      final data = message.data;
      final notificationType = data['type'];

      if (notificationType == 'chat_message') {
        // Could show a snackbar or custom in-app notification
        // Snackbar veya özel uygulama içi bildirim gösterilebilir
        debugPrint('💬 NotificationService: Chat message received in foreground');
      }
    } catch (e) {
      debugPrint('❌ NotificationService: Foreground message handling error: $e');
    }
  }

  // ==========================================
  // NOTIFICATION SENDING / BİLDİRİM GÖNDERME
  // ==========================================

  /// Send chat message notification to club participants
  /// Kulüp katılımcılarına sohbet mesajı bildirimi gönder
  Future<bool> sendChatMessageNotification({
    required String clubId,
    required String clubName,
    required ChatMessage message,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        debugPrint('❌ NotificationService: User not authenticated');
        return false;
      }

      debugPrint('📤 NotificationService: Sending chat notification for club $clubName');

      // Get club chat participants
      final participants = await _getChatParticipants(clubId);
      if (participants.isEmpty) {
        debugPrint('📭 NotificationService: No participants to notify');
        return true;
      }

      // Get recipient FCM tokens (exclude sender)
      final recipientTokens = await _getRecipientTokens(participants, message.senderId);
      if (recipientTokens.isEmpty) {
        debugPrint('📭 NotificationService: No recipient tokens found');
        return true;
      }

      // Check notification preferences for each recipient
      final enabledTokens = await _filterByNotificationPreferences(recipientTokens);
      if (enabledTokens.isEmpty) {
        debugPrint('📭 NotificationService: All recipients have notifications disabled');
        return true;
      }

      // Create notification payload
      final notificationPayload = _createChatNotificationPayload(
        clubId: clubId,
        clubName: clubName,
        message: message,
      );

      // Note: In a real implementation, you would send this to your backend
      // which would use Firebase Admin SDK to send push notifications
      // Gerçek uygulamada, bunu backend'e gönderirsiniz ve backend
      // Firebase Admin SDK kullanarak push bildirimleri gönderir
      
      debugPrint('📱 NotificationService: Notification payload prepared for ${enabledTokens.length} recipients');
      debugPrint('📋 NotificationService: Payload: ${jsonEncode(notificationPayload)}');
      
      // For development, you can log the notification details
      // Geliştirme için bildirim detaylarını loglayabilirsiniz
      debugPrint('✅ NotificationService: Chat notification would be sent to ${enabledTokens.length} devices');

      return true;
    } catch (e) {
      debugPrint('❌ NotificationService: Error sending chat notification: $e');
      return false;
    }
  }

  /// Get chat participants for notification
  /// Bildirim için sohbet katılımcılarını getir
  Future<List<ChatParticipant>> _getChatParticipants(String clubId) async {
    try {
      // Get participants from chat service
      final participantsStream = _chatService.streamChatParticipants(clubId);
      final participants = await participantsStream.first;
      return participants;
    } catch (e) {
      debugPrint('❌ NotificationService: Error getting participants: $e');
      return [];
    }
  }

  /// Get FCM tokens for recipients (excluding sender)
  /// Alıcılar için FCM token'larını getir (gönderici hariç)
  Future<List<String>> _getRecipientTokens(List<ChatParticipant> participants, String senderId) async {
    try {
      final List<String> tokens = [];
      
      for (final participant in participants) {
        if (participant.userId == senderId) continue; // Skip sender
        
        // Get user profile to fetch FCM tokens
        final profile = await _profileService.getSpecificUserProfile(participant.userId);
        if (profile?.deviceTokens != null) {
          tokens.addAll(profile!.deviceTokens!);
        }
      }

      return tokens;
    } catch (e) {
      debugPrint('❌ NotificationService: Error getting recipient tokens: $e');
      return [];
    }
  }

  /// Filter tokens by notification preferences
  /// Bildirim tercihlerine göre token'ları filtrele
  Future<List<String>> _filterByNotificationPreferences(List<String> tokens) async {
    try {
      // For this implementation, we'll assume users with tokens want notifications
      // In a more sophisticated system, you'd check each user's notification preferences
      // Bu uygulama için, token'ı olan kullanıcıların bildirim istediğini varsayıyoruz
      // Daha gelişmiş bir sistemde, her kullanıcının bildirim tercihlerini kontrol edersiniz
      
      return tokens;
    } catch (e) {
      debugPrint('❌ NotificationService: Error filtering by preferences: $e');
      return tokens;
    }
  }

  /// Create chat notification payload
  /// Sohbet bildirimi payload'ı oluştur
  Map<String, dynamic> _createChatNotificationPayload({
    required String clubId,
    required String clubName,
    required ChatMessage message,
  }) {
    // Truncate message content for notification
    String notificationContent = message.content;
    if (notificationContent.length > 100) {
      notificationContent = '${notificationContent.substring(0, 100)}...';
    }

    return {
      'notification': {
        'title': clubName,
        'body': '${message.senderName}: $notificationContent',
        'icon': 'ic_notification',
        'sound': 'default',
        'badge': '1',
      },
      'data': {
        'type': 'chat_message',
        'clubId': clubId,
        'clubName': clubName,
        'messageId': message.messageId,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'content': message.content,
        'timestamp': message.createdAt.toIso8601String(),
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'android': {
        'notification': {
          'channel_id': 'chat_messages',
          'priority': 'high',
          'visibility': 'public',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      'apns': {
        'payload': {
          'aps': {
            'alert': {
              'title': clubName,
              'body': '${message.senderName}: $notificationContent',
            },
            'badge': 1,
            'sound': 'default',
            'category': 'CHAT_MESSAGE',
          },
        },
      },
    };
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METODLAR
  // ==========================================

  /// Get current FCM token
  /// Mevcut FCM token'ını getir
  Future<String?> getCurrentToken() async {
    try {
      return _currentFCMToken ?? await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ NotificationService: Error getting current token: $e');
      return null;
    }
  }

  /// Check if notifications are enabled for user
  /// Kullanıcı için bildirimlerin etkin olup olmadığını kontrol et
  Future<bool> areNotificationsEnabled() async {
    try {
      if (!isAuthenticated) return false;

      final profile = await _profileService.getUserProfile();
      return profile?.notificationPreferences?.messageNotifications ?? true;
    } catch (e) {
      debugPrint('❌ NotificationService: Error checking notification status: $e');
      return false;
    }
  }

  /// Update notification preferences
  /// Bildirim tercihlerini güncelle
  Future<bool> updateNotificationPreferences({
    required bool messageNotifications,
    required bool clubNotifications,
    required bool pushNotificationsEnabled,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) return false;

      debugPrint('⚙️ NotificationService: Updating notification preferences');

      final profile = await _profileService.getUserProfile();
      if (profile == null) return false;

      final updatedPreferences = (profile.notificationPreferences ?? UserNotificationPreferences())
          .copyWith(
        messageNotifications: messageNotifications,
        clubNotifications: clubNotifications,
        pushNotificationsEnabled: pushNotificationsEnabled,
      );

      final updatedProfile = profile.copyWith(
        notificationPreferences: updatedPreferences,
        updatedAt: DateTime.now(),
      );

      await _profileService.updateUserProfile(updatedProfile);
      
      debugPrint('✅ NotificationService: Notification preferences updated');
      return true;
    } catch (e) {
      debugPrint('❌ NotificationService: Error updating preferences: $e');
      return false;
    }
  }

  /// Clear user's FCM tokens (on logout)
  /// Kullanıcının FCM token'larını temizle (çıkış yaparken)
  Future<void> clearUserTokens() async {
    try {
      if (!isAuthenticated || currentUserId == null) return;

      debugPrint('🧹 NotificationService: Clearing user FCM tokens');

      final profile = await _profileService.getUserProfile();
      if (profile == null) return;

      final updatedProfile = profile.copyWith(
        deviceTokens: [],
        updatedAt: DateTime.now(),
      );

      await _profileService.updateUserProfile(updatedProfile);
      _currentFCMToken = null;
      
      debugPrint('✅ NotificationService: User FCM tokens cleared');
    } catch (e) {
      debugPrint('❌ NotificationService: Error clearing tokens: $e');
    }
  }

  /// Dispose service and cancel subscriptions
  /// Servisi kapat ve abonelikleri iptal et
  void dispose() {
    _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
    _currentFCMToken = null;
    _onNavigateToChat = null;
    debugPrint('🔥 NotificationService: Service disposed');
  }
}

/// Background message handler (must be top-level function)
/// Arka plan mesaj işleyicisi (üst düzey fonksiyon olmalı)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received: ${message.messageId}');
  
  // Handle background message processing here
  // Arka plan mesaj işlemelerini burada yapın
  
  // You can update local database, show local notification, etc.
  // Yerel veritabanını güncelleyebilir, yerel bildirim gösterebilirsiniz, vb.
}