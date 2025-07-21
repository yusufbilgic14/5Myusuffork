# 🎯 User-Specific Backend Implementation Roadmap

**Project**: MedipolApp - Personalized User Experience with Firebase Backend  
**Date**: July 21, 2025  
**Status**: ⏳ **IN PROGRESS**

---

## 📋 **OVERVIEW**

Transform MedipolApp from static data display to a fully personalized, user-specific experience where each user has their own:
- Custom course schedules (empty for new users)
- Personal event participation
- Individual preferences and settings
- Stored notifications and data
- Cross-device synchronization

---

## 🎯 **MAIN OBJECTIVES**

### **Phase 1: User Courses System**
- [ ] Replace static course data with user-specific courses
- [ ] Implement course creation functionality with add button in calendar
- [ ] Allow users to manage their course schedule
- [ ] Store course data per user in Firebase

### **Phase 2: Event Participation System**
- [ ] Make event joining/leaving functional with Firebase storage
- [ ] Implement "My Events" functionality to show joined events
- [ ] Store user event participation data
- [ ] Enable event notifications and reminders

### **Phase 3: User Preferences & Settings**
- [ ] Store all user preferences in Firebase (theme, language, notifications)
- [ ] Implement settings synchronization across devices
- [ ] Allow users to customize their experience
- [ ] Remember user choices persistently

### **Phase 4: Personalized Content**
- [ ] Show personalized announcements based on user profile
- [ ] Filter cafeteria menu based on dietary preferences
- [ ] Customize dashboard based on user role and preferences
- [ ] Implement smart recommendations

---

## 🗄️ **FIREBASE COLLECTIONS DESIGN**

### **1. User Courses Collection** 
```javascript
/users/{uid}/courses/{courseId}
├── courseCode: string        // "CS101", "MTH301"
├── courseName: string        // "Visual Programming"
├── instructor: string        // "Dr. Ahmet Yılmaz"
├── room: string             // "B201"
├── schedule: {              // Weekly schedule
│   ├── dayOfWeek: number    // 1=Monday, 2=Tuesday, etc.
│   ├── startTime: string    // "08:00"
│   ├── endTime: string      // "10:00"
│   ├── startHour: number    // 8
│   └── duration: number     // 2.0
├── color: string            // Hex color for UI
├── credits: number          // Course credits
├── semester: string         // "2024-2025 Fall"
├── isActive: boolean        // Currently taking
├── createdAt: timestamp
└── updatedAt: timestamp
```

### **2. User Events Collection**
```javascript
/users/{uid}/events/{eventId}
├── eventId: string          // Reference to main event
├── joinedAt: timestamp      // When user joined
├── status: string           // 'joined', 'interested', 'declined'
├── notificationsEnabled: boolean
├── reminderSettings: {      // Custom reminders
│   ├── beforeEventHours: number[]  // [24, 2, 0.5] (24h, 2h, 30min before)
│   └── reminderType: string        // 'push', 'email', 'both'
└── notes: string           // User's personal notes
```

### **3. User Preferences Collection**
```javascript
/users/{uid}/preferences/settings
├── theme: string            // 'light', 'dark', 'system'
├── language: string         // 'tr', 'en'
├── notifications: {         // Notification preferences
│   ├── announcements: boolean
│   ├── grades: boolean
│   ├── calendar: boolean
│   ├── cafeteria: boolean
│   ├── events: boolean
│   ├── pushEnabled: boolean
│   ├── emailEnabled: boolean
│   ├── quietHoursStart: string    // "22:00"
│   └── quietHoursEnd: string      // "07:00"
├── dashboard: {             // Dashboard customization
│   ├── showTodaysCourses: boolean
│   ├── showUpcomingEvents: boolean
│   ├── showAnnouncements: boolean
│   ├── showCafeteriaMenu: boolean
│   └── widgetOrder: string[]      // Order of dashboard widgets
├── calendar: {              // Calendar preferences
│   ├── defaultView: string        // 'timeline', 'grid'
│   ├── startHour: number          // 7
│   ├── endHour: number            // 21
│   ├── showWeekends: boolean
│   └── courseColors: Map<String, String>  // Custom course colors
├── privacy: {               // Privacy settings
│   ├── profileVisibility: string  // 'public', 'friends', 'private'
│   ├── showInLeaderboards: boolean
│   └── allowEventInvites: boolean
└── updatedAt: timestamp
```

### **4. Global Events Collection** (For all users)
```javascript
/events/{eventId}
├── id: string
├── clubId: string           // Reference to organizing club
├── title: string
├── description: string
├── eventDate: timestamp
├── location: string
├── imageUrl: string
├── tags: string[]
├── type: string             // 'workshop', 'conference', etc.
├── maxParticipants: number
├── currentParticipants: number
├── isActive: boolean
├── createdBy: string        // User ID of creator
├── createdAt: timestamp
├── updatedAt: timestamp
└── participants: {          // Quick lookup for participants
    └── {userId}: timestamp  // When they joined
}
```

---

## 🚀 **IMPLEMENTATION PHASES**

### **Phase 1: Foundation Setup** (Days 1-2)
**Tasks:**
1. ✅ Create roadmap document
2. [ ] Design Firebase collection schemas
3. [ ] Create user courses service class
4. [ ] Create user events service class  
5. [ ] Create user preferences service class
6. [ ] Update existing Firestore service with new collections

**Deliverables:**
- Service classes for all user-specific data
- Firebase collection structures implemented
- Basic CRUD operations working

### **Phase 2: Course Management** (Days 3-4)
**Tasks:**
1. [ ] Replace static courses with Firebase-loaded courses
2. [ ] Add "Add Course" button to calendar screen
3. [ ] Create course creation dialog/form
4. [ ] Implement course editing and deletion
5. [ ] Update home screen to show user's courses
6. [ ] Add course color customization

**Deliverables:**
- Users can create, edit, delete their own courses
- Calendar shows personalized schedule
- Empty state for new users
- Course management fully functional

### **Phase 3: Event Participation** (Days 5-6)
**Tasks:**
1. [ ] Make event join/leave buttons functional
2. [ ] Store user event participation in Firebase
3. [ ] Implement "My Events" screen functionality
4. [ ] Add event notification preferences
5. [ ] Create event reminder system
6. [ ] Update event cards to show real participation status

**Deliverables:**
- Functional event joining/leaving
- "My Events" shows actual joined events
- Event notifications working
- Persistent event participation data

### **Phase 4: User Preferences** (Days 7-8)
**Tasks:**
1. [ ] Create comprehensive settings screen
2. [ ] Store all preferences in Firebase
3. [ ] Implement cross-device settings sync
4. [ ] Add dashboard customization options
5. [ ] Create privacy settings
6. [ ] Implement quiet hours for notifications

**Deliverables:**
- Complete settings screen
- All preferences stored in Firebase
- Cross-device synchronization
- Customizable user experience

### **Phase 5: Personalization** (Days 9-10)
**Tasks:**
1. [ ] Implement personalized announcements
2. [ ] Add user role-based content filtering
3. [ ] Create smart recommendations system
4. [ ] Add dietary preferences for cafeteria
5. [ ] Implement dashboard widget customization
6. [ ] Add usage analytics (privacy-compliant)

**Deliverables:**
- Fully personalized user experience
- Role-based content
- Smart recommendations
- Customizable dashboard

### **Phase 6: Testing & Polish** (Days 11-12)
**Tasks:**
1. [ ] Comprehensive testing with multiple users
2. [ ] Performance optimization
3. [ ] Error handling improvements
4. [ ] UI/UX polish
5. [ ] Documentation updates
6. [ ] Migration guide for existing users

**Deliverables:**
- Fully tested system
- Performance optimized
- Production ready
- Complete documentation

---

## 🛠️ **NEW SERVICE CLASSES TO CREATE**

### **1. UserCoursesService**
```dart
class UserCoursesService {
  // CRUD operations for user courses
  Future<List<UserCourse>> getUserCourses(String userId);
  Future<void> addCourse(String userId, UserCourse course);
  Future<void> updateCourse(String userId, String courseId, UserCourse course);
  Future<void> deleteCourse(String userId, String courseId);
  Stream<List<UserCourse>> watchUserCourses(String userId);
  
  // Schedule helpers
  Future<List<UserCourse>> getCoursesForDay(String userId, DateTime date);
  Future<List<UserCourse>> getTodaysCourses(String userId);
  Future<bool> hasScheduleConflict(String userId, UserCourse newCourse);
}
```

### **2. UserEventsService**
```dart
class UserEventsService {
  // Event participation
  Future<void> joinEvent(String userId, String eventId);
  Future<void> leaveEvent(String userId, String eventId);
  Future<List<String>> getUserJoinedEventIds(String userId);
  Future<List<EventPost>> getUserJoinedEvents(String userId);
  Stream<List<EventPost>> watchUserEvents(String userId);
  
  // Event preferences
  Future<void> setEventNotificationPreference(String userId, String eventId, bool enabled);
  Future<void> setEventReminders(String userId, String eventId, List<int> hoursBeforeEvent);
}
```

### **3. UserPreferencesService**
```dart
class UserPreferencesService {
  // Preferences management
  Future<UserPreferences> getUserPreferences(String userId);
  Future<void> updatePreference(String userId, String key, dynamic value);
  Future<void> updatePreferences(String userId, Map<String, dynamic> preferences);
  Stream<UserPreferences> watchUserPreferences(String userId);
  
  // Specific preference helpers
  Future<void> setTheme(String userId, String theme);
  Future<void> setLanguage(String userId, String language);
  Future<void> setNotificationPreference(String userId, String type, bool enabled);
  Future<void> setDashboardWidgetOrder(String userId, List<String> widgetOrder);
}
```

---

## 📱 **UI/UX IMPROVEMENTS**

### **New Screens to Add:**
1. **Course Creation Screen** - Add/edit course details
2. **Settings Screen Expansion** - Comprehensive user preferences
3. **Event Management Screen** - Manage joined events and reminders
4. **Dashboard Customization Screen** - Reorder and toggle widgets
5. **Privacy Settings Screen** - Control data sharing and visibility

### **Enhanced Existing Screens:**
1. **Calendar Screen** - Add course creation button, empty states
2. **Home Screen** - Show user's actual courses and preferences
3. **Upcoming Events Screen** - Functional join/leave, real "My Events"
4. **Profile Screen** - Show user statistics and preferences

---

## 🔒 **SECURITY & PRIVACY**

### **Firebase Security Rules:**
```javascript
// User can only access their own data
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   (resource == null || resource.data.createdBy == request.auth.uid);
    }
  }
}
```

### **Privacy Features:**
- Users control their data visibility
- Option to hide from leaderboards
- Granular notification preferences
- Data export functionality
- Account deletion with data cleanup

---

## 📊 **SUCCESS METRICS**

### **Technical Metrics:**
- [ ] 100% of static data replaced with user-specific data
- [ ] All CRUD operations working smoothly
- [ ] Cross-device synchronization functional
- [ ] Performance: Data loads < 2 seconds
- [ ] Error rate: < 1% for data operations

### **User Experience Metrics:**
- [ ] New users can create their first course in < 30 seconds
- [ ] Event joining works 100% of the time
- [ ] Settings changes sync across devices within 5 seconds
- [ ] Empty states are informative and actionable
- [ ] Users can customize their experience completely

---

## 🏁 **COMPLETION CRITERIA**

**Phase 1 Complete When:**
- [ ] All service classes created and tested
- [ ] Firebase collections properly structured
- [ ] Basic CRUD operations working

**Phase 2 Complete When:**
- [ ] Users can manage their own courses
- [ ] Calendar shows personalized schedule
- [ ] Course creation fully functional

**Phase 3 Complete When:**
- [ ] Event participation fully functional
- [ ] "My Events" shows real joined events
- [ ] Event notifications working

**Final Project Complete When:**
- [ ] No static data remains in the app
- [ ] Every user has personalized experience
- [ ] All preferences stored in Firebase
- [ ] Cross-device synchronization working
- [ ] Comprehensive testing completed

---

## 📝 **NOTES & CONSIDERATIONS**

### **Data Migration:**
- Existing users need smooth transition
- Provide default data during migration
- Clear migration logs and rollback plan

### **Performance:**
- Implement proper data caching
- Use Firestore offline capabilities
- Optimize queries and batch operations
- Monitor Firebase usage and costs

### **Scalability:**
- Design for thousands of users
- Consider data archiving for old courses/events
- Plan for feature expansion
- Monitor Firebase limits and quotas

---

**🎉 This roadmap will transform MedipolApp into a truly personalized, backend-driven application where every user has their own unique experience!**

---

*Last Updated: July 21, 2025*
*Next Review: Daily during implementation*