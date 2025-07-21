import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../models/user_course_model.dart';
import 'firebase_auth_service.dart';

/// Kullanıcıya özel ders programı yönetim servisi
/// User-specific course management service
class UserCoursesService {
  // Singleton pattern implementation
  static final UserCoursesService _instance = UserCoursesService._internal();
  factory UserCoursesService() => _instance;
  UserCoursesService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Stream subscriptions for memory management
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache for frequently accessed data
  final Map<String, List<UserCourse>> _courseCache = {};
  Timer? _cacheExpireTimer;

  /// Mevcut kullanıcının Firebase UID'sini getir / Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Kullanıcının kimlik doğrulaması yapılmış mı kontrol et / Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // COURSE CRUD OPERATIONS / DERS CRUD İŞLEMLERİ
  // ==========================================

  /// Kullanıcının tüm derslerini getir / Get all user courses
  Future<List<UserCourse>> getUserCourses([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserCoursesService: User not authenticated');
        return [];
      }

      // Check cache first
      if (_courseCache.containsKey(uid)) {
        print('📋 UserCoursesService: Returning cached courses for $uid');
        return _courseCache[uid]!;
      }

      print('🔍 UserCoursesService: Fetching courses for user $uid');
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .get();

      final courses = querySnapshot.docs.map((doc) {
        return UserCourse.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      // Sort by course code on client side
      courses.sort((a, b) => a.courseCode.compareTo(b.courseCode));

      // Cache the results
      _courseCache[uid] = courses;
      _startCacheExpireTimer();

      print('✅ UserCoursesService: Retrieved ${courses.length} courses');
      return courses;
    } catch (e) {
      print('❌ UserCoursesService: Failed to get user courses - $e');
      return [];
    }
  }

  /// Belirli bir dersi getir / Get a specific course
  Future<UserCourse?> getCourse(String courseId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserCoursesService: User not authenticated');
        return null;
      }

      print('🔍 UserCoursesService: Fetching course $courseId for user $uid');
      
      final courseDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseId)
          .get();

      if (!courseDoc.exists) {
        print('⚠️ UserCoursesService: Course $courseId not found');
        return null;
      }

      final course = UserCourse.fromFirestoreData(courseDoc.data()!, courseDoc.id);
      
      print('✅ UserCoursesService: Course retrieved successfully');
      return course;
    } catch (e) {
      print('❌ UserCoursesService: Failed to get course - $e');
      return null;
    }
  }

  /// Yeni ders ekle / Add new course
  Future<String?> addCourse(UserCourse course, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      print('🔄 UserCoursesService: Adding course ${course.courseCode} for user $uid');

      // Check for schedule conflicts
      final hasConflict = await hasScheduleConflict(course, uid);
      if (hasConflict) {
        throw Exception('Schedule conflict detected. Please check your existing courses.');
      }

      // Create course document
      final courseRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc();

      final courseWithTimestamps = course.copyWith(
        courseId: courseRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        enrolledAt: DateTime.now(),
      );

      await courseRef.set(courseWithTimestamps.toFirestoreData());

      // Clear cache to force refresh
      _courseCache.remove(uid);

      print('✅ UserCoursesService: Course added successfully with ID: ${courseRef.id}');
      return courseRef.id;
    } catch (e) {
      print('❌ UserCoursesService: Failed to add course - $e');
      rethrow;
    }
  }

  /// Dersi güncelle / Update course
  Future<void> updateCourse(String courseId, UserCourse course, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      print('🔄 UserCoursesService: Updating course $courseId for user $uid');

      // Check for schedule conflicts (excluding current course)
      final hasConflict = await hasScheduleConflict(course, uid, excludeCourseId: courseId);
      if (hasConflict) {
        throw Exception('Schedule conflict detected. Please check your existing courses.');
      }

      final courseRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseId);

      final updatedCourse = course.copyWith(
        courseId: courseId,
        updatedAt: DateTime.now(),
      );

      await courseRef.update(updatedCourse.toFirestoreData());

      // Clear cache to force refresh
      _courseCache.remove(uid);

      print('✅ UserCoursesService: Course updated successfully');
    } catch (e) {
      print('❌ UserCoursesService: Failed to update course - $e');
      rethrow;
    }
  }

  /// Dersi sil / Delete course
  Future<void> deleteCourse(String courseId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      print('🔄 UserCoursesService: Deleting course $courseId for user $uid');

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseId)
          .delete();

      // Clear cache to force refresh
      _courseCache.remove(uid);

      print('✅ UserCoursesService: Course deleted successfully');
    } catch (e) {
      print('❌ UserCoursesService: Failed to delete course - $e');
      rethrow;
    }
  }

  /// Dersi tamamlanmış olarak işaretle / Mark course as completed
  Future<void> markCourseAsCompleted(String courseId, String? grade, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      print('🔄 UserCoursesService: Marking course $courseId as completed');

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(courseId)
          .update({
        'isCompleted': true,
        'isActive': false,
        'grade': grade,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear cache to force refresh
      _courseCache.remove(uid);

      print('✅ UserCoursesService: Course marked as completed');
    } catch (e) {
      print('❌ UserCoursesService: Failed to mark course as completed - $e');
      rethrow;
    }
  }

  // ==========================================
  // SCHEDULE OPERATIONS / PROGRAM İŞLEMLERİ
  // ==========================================

  /// Bugünün derslerini getir / Get today's courses
  Future<List<UserCourse>> getTodaysCourses([String? userId]) async {
    try {
      final courses = await getUserCourses(userId);
      final today = DateTime.now().weekday;
      
      final todaysCourses = courses.where((course) {
        return course.hasClassOnDay(today);
      }).toList();

      // Sort by start time
      todaysCourses.sort((a, b) {
        final aSchedule = a.getSchedulesForDay(today).first;
        final bSchedule = b.getSchedulesForDay(today).first;
        return aSchedule.startHour.compareTo(bSchedule.startHour);
      });

      print('✅ UserCoursesService: Found ${todaysCourses.length} courses for today');
      return todaysCourses;
    } catch (e) {
      print('❌ UserCoursesService: Failed to get today\'s courses - $e');
      return [];
    }
  }

  /// Belirli bir gün için dersleri getir / Get courses for a specific day
  Future<List<UserCourse>> getCoursesForDay(int dayOfWeek, [String? userId]) async {
    try {
      final courses = await getUserCourses(userId);
      
      final dayCourses = courses.where((course) {
        return course.hasClassOnDay(dayOfWeek);
      }).toList();

      // Sort by start time
      dayCourses.sort((a, b) {
        final aSchedule = a.getSchedulesForDay(dayOfWeek).first;
        final bSchedule = b.getSchedulesForDay(dayOfWeek).first;
        return aSchedule.startHour.compareTo(bSchedule.startHour);
      });

      return dayCourses;
    } catch (e) {
      print('❌ UserCoursesService: Failed to get courses for day $dayOfWeek - $e');
      return [];
    }
  }

  /// Belirli bir tarih için dersleri getir / Get courses for a specific date
  Future<List<UserCourse>> getCoursesForDate(DateTime date, [String? userId]) async {
    return getCoursesForDay(date.weekday, userId);
  }

  /// Program çakışması kontrol et / Check for schedule conflicts
  Future<bool> hasScheduleConflict(UserCourse newCourse, String userId, {String? excludeCourseId}) async {
    try {
      final existingCourses = await getUserCourses(userId);
      
      for (final existingCourse in existingCourses) {
        // Skip if this is the course being updated
        if (excludeCourseId != null && existingCourse.courseId == excludeCourseId) {
          continue;
        }

        // Check each schedule slot of the new course against existing courses
        for (final newSchedule in newCourse.schedule) {
          for (final existingSchedule in existingCourse.schedule) {
            if (newSchedule.conflictsWith(existingSchedule)) {
              print('⚠️ UserCoursesService: Schedule conflict detected between ${newCourse.courseCode} and ${existingCourse.courseCode}');
              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      print('❌ UserCoursesService: Error checking schedule conflicts - $e');
      return true; // Assume conflict on error for safety
    }
  }

  /// Haftalık program getir / Get weekly schedule
  Future<Map<int, List<UserCourse>>> getWeeklySchedule([String? userId]) async {
    try {
      final courses = await getUserCourses(userId);
      final weeklySchedule = <int, List<UserCourse>>{};

      for (int day = 1; day <= 7; day++) {
        final dayCourses = courses.where((course) {
          return course.hasClassOnDay(day);
        }).toList();

        // Sort by start time
        dayCourses.sort((a, b) {
          final aSchedule = a.getSchedulesForDay(day).first;
          final bSchedule = b.getSchedulesForDay(day).first;
          return aSchedule.startHour.compareTo(bSchedule.startHour);
        });

        weeklySchedule[day] = dayCourses;
      }

      return weeklySchedule;
    } catch (e) {
      print('❌ UserCoursesService: Failed to get weekly schedule - $e');
      return {};
    }
  }

  // ==========================================
  // REAL-TIME OPERATIONS / GERÇEK ZAMANLI İŞLEMLER
  // ==========================================

  /// Kullanıcı derslerini real-time dinle / Listen to user courses in real-time
  Stream<List<UserCourse>> watchUserCourses([String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      print('❌ UserCoursesService: Cannot watch courses - user not authenticated');
      return Stream.value([]);
    }

    print('👁️ UserCoursesService: Starting to watch courses for user $uid');
    
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final courses = snapshot.docs.map((doc) {
            return UserCourse.fromFirestoreData(doc.data(), doc.id);
          }).toList();

          // Sort by course code on client side
          courses.sort((a, b) => a.courseCode.compareTo(b.courseCode));

          // Update cache
          _courseCache[uid] = courses;

          return courses;
        })
        .handleError((error) {
          print('❌ UserCoursesService: Error watching user courses - $error');
        });
  }

  /// Bugünün derslerini real-time dinle / Watch today's courses in real-time
  Stream<List<UserCourse>> watchTodaysCourses([String? userId]) {
    return watchUserCourses(userId).map((courses) {
      final today = DateTime.now().weekday;
      final todaysCourses = courses.where((course) {
        return course.hasClassOnDay(today);
      }).toList();

      // Sort by start time
      todaysCourses.sort((a, b) {
        final aSchedule = a.getSchedulesForDay(today).first;
        final bSchedule = b.getSchedulesForDay(today).first;
        return aSchedule.startHour.compareTo(bSchedule.startHour);
      });

      return todaysCourses;
    });
  }

  // ==========================================
  // SEARCH AND FILTER / ARAMA VE FİLTRELEME
  // ==========================================

  /// Ders ara / Search courses
  Future<List<UserCourse>> searchCourses(String query, [String? userId]) async {
    try {
      final courses = await getUserCourses(userId);
      final searchQuery = query.toLowerCase();

      final filteredCourses = courses.where((course) {
        return course.courseCode.toLowerCase().contains(searchQuery) ||
               course.courseName.toLowerCase().contains(searchQuery) ||
               course.instructor.name.toLowerCase().contains(searchQuery) ||
               course.department.toLowerCase().contains(searchQuery) ||
               (course.alias?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();

      return filteredCourses;
    } catch (e) {
      print('❌ UserCoursesService: Failed to search courses - $e');
      return [];
    }
  }

  /// Favori dersleri getir / Get favorite courses
  Future<List<UserCourse>> getFavoriteCourses([String? userId]) async {
    try {
      final courses = await getUserCourses(userId);
      return courses.where((course) => course.favorited).toList();
    } catch (e) {
      print('❌ UserCoursesService: Failed to get favorite courses - $e');
      return [];
    }
  }

  /// Bölüme göre dersleri filtrele / Filter courses by department
  Future<List<UserCourse>> getCoursesByDepartment(String department, [String? userId]) async {
    try {
      final courses = await getUserCourses(userId);
      return courses.where((course) => 
          course.department.toLowerCase() == department.toLowerCase()).toList();
    } catch (e) {
      print('❌ UserCoursesService: Failed to get courses by department - $e');
      return [];
    }
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METODLAR
  // ==========================================

  /// Varsayılan ders oluştur / Create default course
  UserCourse createDefaultCourse({
    required String courseCode,
    required String courseName,
    required String instructorName,
    required List<CourseSchedule> schedule,
    int credits = 3,
    String department = 'Computer Engineering',
    String faculty = 'Engineering and Natural Sciences',
    String color = '#1E3A8A',
  }) {
    return UserCourse(
      courseId: '',
      courseCode: courseCode,
      courseName: courseName,
      instructor: CourseInstructor(name: instructorName),
      schedule: schedule,
      credits: credits,
      semester: '${DateTime.now().year}-${DateTime.now().month <= 6 ? 'Spring' : 'Fall'}',
      year: DateTime.now().year,
      semesterNumber: DateTime.now().month <= 6 ? 2 : 1,
      department: department,
      faculty: faculty,
      level: 'undergraduate',
      color: color,
      notifications: const CourseNotifications(),
    );
  }

  /// Örnek program oluştur / Create sample schedule
  CourseSchedule createSchedule({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String room,
    String building = 'Engineering Building',
    String classType = 'lecture',
  }) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startHour = int.parse(startParts[0]);
    final endHour = int.parse(endParts[0]);
    final duration = (endHour - startHour).toDouble();

    return CourseSchedule(
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      startHour: startHour,
      duration: duration,
      room: room,
      building: building,
      classType: classType,
    );
  }

  /// Cache'i temizle / Clear cache
  void clearCache() {
    _courseCache.clear();
    _cacheExpireTimer?.cancel();
    print('🧹 UserCoursesService: Cache cleared');
  }

  /// Cache expire timer başlat / Start cache expire timer
  void _startCacheExpireTimer() {
    _cacheExpireTimer?.cancel();
    _cacheExpireTimer = Timer(const Duration(minutes: 5), () {
      clearCache();
    });
  }

  /// Tüm subscription'ları iptal et / Cancel all subscriptions
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    print('🔌 UserCoursesService: All subscriptions cancelled');
  }

  /// Servisi temizle / Dispose service
  void dispose() {
    cancelAllSubscriptions();
    clearCache();
    print('🧹 UserCoursesService: Service disposed');
  }
}