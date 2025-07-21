import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/user_event_models.dart';
import 'firebase_auth_service.dart';

/// User-specific events management service
/// Kullanıcıya özel etkinlik yönetim servisi
class UserEventsService {
  // Singleton pattern implementation
  static final UserEventsService _instance = UserEventsService._internal();
  factory UserEventsService() => _instance;
  UserEventsService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Stream subscriptions for memory management
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache for frequently accessed data
  final Map<String, List<Event>> _eventsCache = {};
  final Map<String, UserEventInteraction> _interactionsCache = {};
  Timer? _cacheExpireTimer;

  /// Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // EVENTS OPERATIONS / ETKİNLİK İŞLEMLERİ
  // ==========================================

  /// Get all events / Tüm etkinlikleri getir
  Future<List<Event>> getEvents({
    String? eventType,
    String? organizerType,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      debugPrint('🔍 UserEventsService: Fetching events');
      
      Query query = _firestore
          .collection('events')
          .where('status', isEqualTo: 'published')
          .where('isVisible', isEqualTo: true)
          .orderBy('startDateTime', descending: false);

      if (eventType != null) {
        query = query.where('eventType', isEqualTo: eventType);
      }

      if (organizerType != null) {
        query = query.where('organizerType', isEqualTo: organizerType);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      final events = querySnapshot.docs.map((doc) {
        return Event.fromFirestoreData(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      debugPrint('✅ UserEventsService: Retrieved ${events.length} events');
      return events;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to get events - $e');
      return [];
    }
  }

  /// Get upcoming events / Yaklaşan etkinlikleri getir
  Future<List<Event>> getUpcomingEvents({int limit = 20}) async {
    try {
      final now = Timestamp.now();
      
      final querySnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'published')
          .where('isVisible', isEqualTo: true)
          .where('startDateTime', isGreaterThan: now)
          .orderBy('startDateTime', descending: false)
          .limit(limit)
          .get();

      final events = querySnapshot.docs.map((doc) {
        return Event.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      debugPrint('✅ UserEventsService: Retrieved ${events.length} upcoming events');
      return events;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to get upcoming events - $e');
      return [];
    }
  }

  /// Get featured events / Öne çıkan etkinlikleri getir
  Future<List<Event>> getFeaturedEvents({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'published')
          .where('isVisible', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('startDateTime', descending: false)
          .limit(limit)
          .get();

      final events = querySnapshot.docs.map((doc) {
        return Event.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      debugPrint('✅ UserEventsService: Retrieved ${events.length} featured events');
      return events;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to get featured events - $e');
      return [];
    }
  }

  /// Search events / Etkinlik ara
  Future<List<Event>> searchEvents(String query, {int limit = 30}) async {
    try {
      if (query.isEmpty) return [];

      // For a simple implementation, we'll get all events and filter client-side
      // In production, you might want to use Algolia or similar service for better search
      final events = await getEvents(limit: 100);
      
      final searchQuery = query.toLowerCase();
      final filteredEvents = events.where((event) {
        return event.title.toLowerCase().contains(searchQuery) ||
               event.description.toLowerCase().contains(searchQuery) ||
               event.organizerName.toLowerCase().contains(searchQuery) ||
               event.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).take(limit).toList();

      debugPrint('✅ UserEventsService: Found ${filteredEvents.length} events for query: $query');
      return filteredEvents;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to search events - $e');
      return [];
    }
  }

  // ==========================================
  // USER INTERACTIONS / KULLANICI ETKİLEŞİMLERİ
  // ==========================================

  /// Get user's event interaction / Kullanıcının etkinlik etkileşimini getir
  Future<UserEventInteraction?> getUserEventInteraction(String eventId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        debugPrint('❌ UserEventsService: User not authenticated');
        return null;
      }

      // Check cache first
      final cacheKey = '${uid}_$eventId';
      if (_interactionsCache.containsKey(cacheKey)) {
        return _interactionsCache[cacheKey];
      }

      debugPrint('🔍 UserEventsService: Fetching interaction for event $eventId');
      
      final interactionDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventInteractions')
          .doc(eventId)
          .get();

      if (!interactionDoc.exists) {
        return null;
      }

      final interaction = UserEventInteraction.fromFirestoreData(
        interactionDoc.data()!, 
        interactionDoc.id
      );

      // Cache the result
      _interactionsCache[cacheKey] = interaction;
      _startCacheExpireTimer();

      return interaction;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to get user event interaction - $e');
      return null;
    }
  }

  /// Like/Unlike event / Etkinliği beğen/beğenme
  Future<bool> toggleEventLike(String eventId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 UserEventsService: Toggling like for event $eventId');

      final batch = _firestore.batch();
      
      // Get current interaction
      final interaction = await getUserEventInteraction(eventId, uid);
      final isCurrentlyLiked = interaction?.hasLiked ?? false;
      
      // Update user interaction
      final interactionRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('eventInteractions')
          .doc(eventId);

      final newInteraction = UserEventInteraction(
        eventId: eventId,
        userId: uid,
        hasLiked: !isCurrentlyLiked,
        hasJoined: interaction?.hasJoined ?? false,
        hasShared: interaction?.hasShared ?? false,
        isFavorited: interaction?.isFavorited ?? false,
        joinStatus: interaction?.joinStatus ?? JoinStatus.notJoined,
        notifyBeforeEvent: interaction?.notifyBeforeEvent ?? true,
        notifyDayBefore: interaction?.notifyDayBefore ?? true,
        notifyHourBefore: interaction?.notifyHourBefore ?? true,
        likedAt: !isCurrentlyLiked ? DateTime.now() : interaction?.likedAt,
        createdAt: interaction?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(interactionRef, newInteraction.toFirestoreData());

      // Update event like count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'likeCount': FieldValue.increment(!isCurrentlyLiked ? 1 : -1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Update cache
      final cacheKey = '${uid}_$eventId';
      _interactionsCache[cacheKey] = newInteraction;

      debugPrint('✅ UserEventsService: Event like toggled successfully');
      return !isCurrentlyLiked;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to toggle event like - $e');
      rethrow;
    }
  }

  /// Join/Leave event / Etkinliğe katıl/ayrıl
  Future<bool> toggleEventJoin(String eventId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 UserEventsService: Toggling join for event $eventId');

      final batch = _firestore.batch();
      
      // Get current interaction
      final interaction = await getUserEventInteraction(eventId, uid);
      final isCurrentlyJoined = interaction?.hasJoined ?? false;
      
      // Update user interaction
      final interactionRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('eventInteractions')
          .doc(eventId);

      final newInteraction = UserEventInteraction(
        eventId: eventId,
        userId: uid,
        hasLiked: interaction?.hasLiked ?? false,
        hasJoined: !isCurrentlyJoined,
        hasShared: interaction?.hasShared ?? false,
        isFavorited: interaction?.isFavorited ?? false,
        joinStatus: !isCurrentlyJoined ? JoinStatus.joined : JoinStatus.notJoined,
        notifyBeforeEvent: interaction?.notifyBeforeEvent ?? true,
        notifyDayBefore: interaction?.notifyDayBefore ?? true,
        notifyHourBefore: interaction?.notifyHourBefore ?? true,
        joinedAt: !isCurrentlyJoined ? DateTime.now() : null,
        leftAt: isCurrentlyJoined ? DateTime.now() : interaction?.leftAt,
        createdAt: interaction?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(interactionRef, newInteraction.toFirestoreData());

      // Update event join count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'joinCount': FieldValue.increment(!isCurrentlyJoined ? 1 : -1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add/Remove from user's my events
      final myEventRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('myEvents')
          .doc(eventId);

      if (!isCurrentlyJoined) {
        // Get event details for my events
        final eventDoc = await _firestore.collection('events').doc(eventId).get();
        if (eventDoc.exists) {
          final eventData = eventDoc.data()!;
          final myEvent = UserMyEvent(
            eventId: eventId,
            userId: uid,
            eventTitle: eventData['title'],
            eventStartDate: eventData['startDateTime'],
            eventEndDate: eventData['endDateTime'],
            eventLocation: eventData['location'],
            organizerName: eventData['organizerName'],
            joinedAt: DateTime.now(),
            joinMethod: JoinMethod.direct,
            participationStatus: ParticipationStatus.confirmed,
            customReminders: const CustomReminders(
              enabled: true,
              beforeMinutes: [15, 60],
            ),
            addedToCalendar: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          batch.set(myEventRef, myEvent.toFirestoreData());
        }
      } else {
        // Remove from my events
        batch.delete(myEventRef);
      }

      await batch.commit();

      // Update cache
      final cacheKey = '${uid}_$eventId';
      _interactionsCache[cacheKey] = newInteraction;

      debugPrint('✅ UserEventsService: Event join toggled successfully');
      return !isCurrentlyJoined;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to toggle event join - $e');
      rethrow;
    }
  }

  /// Share event / Etkinliği paylaş
  Future<void> shareEvent(String eventId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 UserEventsService: Sharing event $eventId');

      final batch = _firestore.batch();
      
      // Get current interaction
      final interaction = await getUserEventInteraction(eventId, uid);
      
      // Update user interaction
      final interactionRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('eventInteractions')
          .doc(eventId);

      final newInteraction = UserEventInteraction(
        eventId: eventId,
        userId: uid,
        hasLiked: interaction?.hasLiked ?? false,
        hasJoined: interaction?.hasJoined ?? false,
        hasShared: true,
        isFavorited: interaction?.isFavorited ?? false,
        joinStatus: interaction?.joinStatus ?? JoinStatus.notJoined,
        notifyBeforeEvent: interaction?.notifyBeforeEvent ?? true,
        notifyDayBefore: interaction?.notifyDayBefore ?? true,
        notifyHourBefore: interaction?.notifyHourBefore ?? true,
        createdAt: interaction?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(interactionRef, newInteraction.toFirestoreData());

      // Update event share count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'shareCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Update cache
      final cacheKey = '${uid}_$eventId';
      _interactionsCache[cacheKey] = newInteraction;

      debugPrint('✅ UserEventsService: Event shared successfully');
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to share event - $e');
      rethrow;
    }
  }

  // ==========================================
  // MY EVENTS / ETKİNLİKLERİM
  // ==========================================

  /// Get user's joined events / Kullanıcının katıldığı etkinlikleri getir
  Future<List<UserMyEvent>> getMyEvents([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        debugPrint('❌ UserEventsService: User not authenticated');
        return [];
      }

      debugPrint('🔍 UserEventsService: Fetching my events for user $uid');
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('myEvents')
          .orderBy('eventStartDate', descending: false)
          .get();

      final myEvents = querySnapshot.docs.map((doc) {
        return UserMyEvent.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      debugPrint('✅ UserEventsService: Retrieved ${myEvents.length} my events');
      return myEvents;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to get my events - $e');
      return [];
    }
  }

  /// Get upcoming my events / Yaklaşan etkinliklerim
  Future<List<UserMyEvent>> getUpcomingMyEvents([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        return [];
      }

      final now = Timestamp.now();
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('myEvents')
          .where('eventStartDate', isGreaterThan: now)
          .where('participationStatus', isEqualTo: 'confirmed')
          .orderBy('eventStartDate', descending: false)
          .get();

      final myEvents = querySnapshot.docs.map((doc) {
        return UserMyEvent.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      return myEvents;
    } catch (e) {
      debugPrint('❌ UserEventsService: Failed to get upcoming my events - $e');
      return [];
    }
  }

  // ==========================================
  // REAL-TIME OPERATIONS / GERÇEK ZAMANLI İŞLEMLER
  // ==========================================

  /// Watch events in real-time / Etkinlikleri gerçek zamanlı dinle
  Stream<List<Event>> watchEvents({
    String? eventType,
    String? organizerType,
    int limit = 50,
  }) {
    debugPrint('👁️ UserEventsService: Starting to watch events');
    
    Query query = _firestore
        .collection('events')
        .where('status', isEqualTo: 'published')
        .where('isVisible', isEqualTo: true)
        .orderBy('startDateTime', descending: false);

    if (eventType != null) {
      query = query.where('eventType', isEqualTo: eventType);
    }

    if (organizerType != null) {
      query = query.where('organizerType', isEqualTo: organizerType);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      final events = snapshot.docs.map((doc) {
        return Event.fromFirestoreData(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return events;
    }).handleError((error) {
      debugPrint('❌ UserEventsService: Error watching events - $error');
    });
  }

  /// Watch my events in real-time / Etkinliklerimi gerçek zamanlı dinle
  Stream<List<UserMyEvent>> watchMyEvents([String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      debugPrint('❌ UserEventsService: Cannot watch my events - user not authenticated');
      return Stream.value([]);
    }

    debugPrint('👁️ UserEventsService: Starting to watch my events for user $uid');
    
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('myEvents')
        .orderBy('eventStartDate', descending: false)
        .snapshots()
        .map((snapshot) {
          final myEvents = snapshot.docs.map((doc) {
            return UserMyEvent.fromFirestoreData(doc.data(), doc.id);
          }).toList();

          return myEvents;
        })
        .handleError((error) {
          debugPrint('❌ UserEventsService: Error watching my events - $error');
        });
  }

  // ==========================================
  // REAL-TIME COUNTERS / GERÇEK ZAMANLI SAYAÇLAR
  // ==========================================

  /// Watch event engagement counters in real-time / Etkinlik etkileşim sayaçlarını gerçek zamanlı dinle
  Stream<EventCounters> watchEventCounters(String eventId) {
    debugPrint('👁️ UserEventsService: Starting to watch counters for event $eventId');
    
    return _firestore
        .collection('events')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return const EventCounters(
              likeCount: 0,
              commentCount: 0,
              joinCount: 0,
              shareCount: 0,
            );
          }

          final data = snapshot.data()!;
          return EventCounters(
            likeCount: data['likeCount'] ?? 0,
            commentCount: data['commentCount'] ?? 0,
            joinCount: data['joinCount'] ?? 0,
            shareCount: data['shareCount'] ?? 0,
          );
        })
        .handleError((error) {
          debugPrint('❌ UserEventsService: Error watching event counters - $error');
        });
  }

  /// Watch multiple events counters / Birden fazla etkinlik sayacını dinle
  Stream<Map<String, EventCounters>> watchMultipleEventCounters(List<String> eventIds) {
    if (eventIds.isEmpty) {
      return Stream.value({});
    }

    debugPrint('👁️ UserEventsService: Starting to watch counters for ${eventIds.length} events');
    
    return _firestore
        .collection('events')
        .where(FieldPath.documentId, whereIn: eventIds)
        .snapshots()
        .map((snapshot) {
          final countersMap = <String, EventCounters>{};
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            countersMap[doc.id] = EventCounters(
              likeCount: data['likeCount'] ?? 0,
              commentCount: data['commentCount'] ?? 0,
              joinCount: data['joinCount'] ?? 0,
              shareCount: data['shareCount'] ?? 0,
            );
          }
          
          return countersMap;
        })
        .handleError((error) {
          debugPrint('❌ UserEventsService: Error watching multiple event counters - $error');
        });
  }

  /// Watch user's event interaction status in real-time / Kullanıcının etkinlik etkileşim durumunu gerçek zamanlı dinle
  Stream<UserEventInteraction?> watchUserEventInteraction(String eventId, [String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      debugPrint('❌ UserEventsService: Cannot watch interaction - user not authenticated');
      return Stream.value(null);
    }

    debugPrint('👁️ UserEventsService: Starting to watch interaction for event $eventId');
    
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('eventInteractions')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }

          return UserEventInteraction.fromFirestoreData(snapshot.data()!, snapshot.id);
        })
        .handleError((error) {
          debugPrint('❌ UserEventsService: Error watching user interaction - $error');
        });
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METODLAR
  // ==========================================

  /// Clear cache / Cache'i temizle
  void clearCache() {
    _eventsCache.clear();
    _interactionsCache.clear();
    _cacheExpireTimer?.cancel();
    debugPrint('🧹 UserEventsService: Cache cleared');
  }

  /// Start cache expire timer / Cache süre dolumu timer'ını başlat
  void _startCacheExpireTimer() {
    _cacheExpireTimer?.cancel();
    _cacheExpireTimer = Timer(const Duration(minutes: 5), () {
      clearCache();
    });
  }

  /// Cancel all subscriptions / Tüm subscription'ları iptal et
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    debugPrint('🔌 UserEventsService: All subscriptions cancelled');
  }

  /// Dispose service / Servisi temizle
  void dispose() {
    cancelAllSubscriptions();
    clearCache();
    debugPrint('🧹 UserEventsService: Service disposed');
  }
}