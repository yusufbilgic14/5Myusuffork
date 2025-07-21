# 🗄️ User-Specific Firebase Collections Schema

**Project**: MedipolApp - Personalized Data Architecture  
**Date**: July 21, 2025  
**Version**: 1.0

---

## 📋 **COLLECTION OVERVIEW**

This document defines the complete Firebase Firestore schema for storing user-specific data, enabling a personalized experience for each MedipolApp user.

### **Collection Hierarchy:**
```
/users/{uid}/
├── courses/{courseId}           - User's personal course schedule
├── events/{eventId}            - Events the user has joined
├── preferences/settings         - User's app preferences
├── notifications/{notifId}      - User's notification history
├── achievements/{achieveId}     - User's achievements and badges
└── analytics/usage             - User's app usage statistics
```

---

## 🎓 **USER COURSES COLLECTION**

**Path**: `/users/{uid}/courses/{courseId}`

### **Document Structure:**
```javascript
{
  // Course Identification
  "courseId": "cs101_fall2025",          // Unique identifier
  "courseCode": "CS101",                 // Official course code
  "courseName": "Visual Programming",    // Course title
  "courseNameEn": "Visual Programming",  // English title
  "courseNameTr": "Görsel Programlama", // Turkish title
  
  // Course Details
  "instructor": {
    "name": "Dr. Ahmet Yılmaz",
    "email": "ahmet.yilmaz@medipol.edu.tr",
    "office": "B201",
    "officeHours": "Monday 14:00-16:00"
  },
  
  // Schedule Information
  "schedule": [
    {
      "dayOfWeek": 1,              // 1=Monday, 2=Tuesday, ..., 7=Sunday
      "startTime": "08:00",        // Start time as string
      "endTime": "10:00",          // End time as string
      "startHour": 8,              // Start hour as number (for calculations)
      "duration": 2.0,             // Duration in hours
      "room": "B201",              // Classroom
      "building": "Engineering",   // Building name
      "floor": 2,                  // Floor number
      "classType": "lecture"       // 'lecture', 'lab', 'tutorial', 'exam'
    }
  ],
  
  // Academic Information
  "credits": 3,                    // Course credits
  "semester": "2025-Fall",         // Academic semester
  "year": 2025,                    // Academic year
  "semesterNumber": 1,             // 1=Fall, 2=Spring, 3=Summer
  "department": "Computer Engineering",
  "faculty": "Engineering and Natural Sciences",
  "level": "undergraduate",       // 'undergraduate', 'graduate', 'phd'
  "prerequisite": ["CS100"],      // Required prerequisite courses
  
  // User Customization
  "color": "#1E3A8A",            // User-chosen color for UI
  "alias": "Visual Prog",         // User's custom short name
  "notes": "Important for final project", // User's personal notes
  "priority": "high",            // 'high', 'medium', 'low'
  "favorited": false,            // User marked as favorite
  
  // Status & Settings
  "isActive": true,              // Currently enrolled
  "isCompleted": false,          // Course completed
  "grade": null,                 // Final grade when completed
  "attendance": {
    "attended": 24,              // Classes attended
    "total": 28,                 // Total classes
    "percentage": 85.7           // Attendance percentage
  },
  
  // Notifications
  "notifications": {
    "beforeClass": 15,           // Minutes before class to notify
    "classReminder": true,       // Enable class reminders
    "examReminder": true,        // Enable exam reminders
    "assignmentReminder": true   // Enable assignment reminders
  },
  
  // Timestamps
  "createdAt": "2025-07-21T10:00:00.000Z",
  "updatedAt": "2025-07-21T10:00:00.000Z",
  "enrolledAt": "2025-09-01T00:00:00.000Z"
}
```

### **Subcollections under courses:**
```javascript
// Assignments for this course
/users/{uid}/courses/{courseId}/assignments/{assignmentId}
{
  "title": "Database Design Project",
  "description": "Design a database for an e-commerce system",
  "dueDate": "2025-08-15T23:59:00.000Z",
  "maxScore": 100,
  "weight": 0.3,                 // 30% of final grade
  "status": "pending",           // 'pending', 'submitted', 'graded'
  "userScore": null,
  "feedback": "",
  "submittedAt": null,
  "createdAt": "2025-07-21T10:00:00.000Z"
}

// Exams for this course
/users/{uid}/courses/{courseId}/exams/{examId}
{
  "type": "midterm",            // 'quiz', 'midterm', 'final'
  "title": "Midterm Exam",
  "date": "2025-08-10T09:00:00.000Z",
  "duration": 120,              // Minutes
  "room": "C301",
  "maxScore": 100,
  "weight": 0.4,               // 40% of final grade
  "userScore": null,
  "status": "upcoming",        // 'upcoming', 'completed', 'missed'
  "createdAt": "2025-07-21T10:00:00.000Z"
}
```

---

## 🎪 **USER EVENTS COLLECTION**

**Path**: `/users/{uid}/events/{eventId}`

### **Document Structure:**
```javascript
{
  // Event Reference
  "eventId": "flutter_workshop_2025",   // Reference to global event
  "globalEventRef": "/events/flutter_workshop_2025", // Firestore reference
  
  // Participation Details
  "participationStatus": "joined",      // 'interested', 'joined', 'declined', 'attended'
  "joinedAt": "2025-07-21T10:00:00.000Z",
  "leftAt": null,                       // If user left the event
  "attendanceConfirmed": false,         // Did user actually attend?
  "attendanceConfirmedAt": null,
  
  // User-Specific Event Data
  "personalNotes": "Looking forward to learning Flutter basics",
  "rating": null,                       // User's rating after event (1-5)
  "review": "",                         // User's review after event
  "photos": [],                         // User's photos from event
  "connections": [],                    // Other users met at event
  
  // Notification Preferences
  "notifications": {
    "enabled": true,
    "reminderTimes": [1440, 120, 30],   // Minutes before event (24h, 2h, 30min)
    "reminderTypes": ["push", "email"], // Notification types
    "eventUpdates": true,               // Notify on event changes
    "beforeEventSurvey": true           // Send pre-event survey
  },
  
  // Event-Specific Preferences
  "dietaryRequirements": [],            // ['vegetarian', 'halal', 'gluten-free']
  "accessibilityNeeds": [],             // ['wheelchair', 'hearing-impaired']
  "tshirtSize": "M",                    // For events with merchandise
  "emergencyContact": {
    "name": "John Doe",
    "phone": "+90 555 123 4567",
    "relation": "parent"
  },
  
  // Social Features
  "visibility": "public",               // 'public', 'friends', 'private'
  "allowContact": true,                 // Allow other participants to contact
  "interestedInNetworking": true,       // Interested in meeting other attendees
  
  // Timestamps
  "createdAt": "2025-07-21T10:00:00.000Z",
  "updatedAt": "2025-07-21T10:00:00.000Z",
  "lastNotificationSent": null
}
```

---

## ⚙️ **USER PREFERENCES COLLECTION**

**Path**: `/users/{uid}/preferences/settings`

### **Document Structure:**
```javascript
{
  // App Appearance
  "theme": {
    "mode": "system",                   // 'light', 'dark', 'system'
    "accentColor": "#1E3A8A",          // Custom accent color
    "fontSize": "medium",              // 'small', 'medium', 'large'
    "highContrast": false,             // Accessibility option
    "reducedMotion": false             // Accessibility option
  },
  
  // Language & Localization
  "language": {
    "primary": "tr",                   // 'tr', 'en'
    "fallback": "en",                  // Fallback language
    "dateFormat": "dd.MM.yyyy",        // Date format preference
    "timeFormat": "24h",               // '12h' or '24h'
    "firstDayOfWeek": 1                // 1=Monday, 0=Sunday
  },
  
  // Notification Preferences
  "notifications": {
    // Global notification settings
    "enabled": true,
    "quietHours": {
      "enabled": true,
      "start": "22:00",
      "end": "07:00",
      "weekends": false                // Apply quiet hours on weekends
    },
    
    // Specific notification types
    "announcements": {
      "enabled": true,
      "push": true,
      "email": true,
      "sound": true,
      "vibration": true
    },
    "courses": {
      "enabled": true,
      "beforeClass": 15,               // Minutes before class
      "assignment": 24,                // Hours before assignment due
      "exam": 48,                      // Hours before exam
      "gradeUpdate": true
    },
    "events": {
      "enabled": true,
      "newEvents": true,               // Notify about new events
      "eventUpdates": true,            // Notify when joined events change
      "eventReminders": [1440, 60],    // Custom reminder times (minutes)
      "socialUpdates": false           // Notifications from friends' activities
    },
    "cafeteria": {
      "enabled": true,
      "menuUpdates": true,             // New menu notifications
      "specialOffers": true,           // Special deals/promotions
      "nutritionalAlerts": false       // Dietary restriction alerts
    },
    "system": {
      "appUpdates": true,              // App version updates
      "maintenance": true,             // Maintenance notifications
      "security": true                 // Security-related notifications
    }
  },
  
  // Dashboard Customization
  "dashboard": {
    "widgets": {
      "todaysCourses": {
        "enabled": true,
        "position": 1,
        "compact": false
      },
      "upcomingEvents": {
        "enabled": true,
        "position": 2,
        "maxItems": 3
      },
      "announcements": {
        "enabled": true,
        "position": 3,
        "autoPlay": true
      },
      "cafeteriaMenu": {
        "enabled": true,
        "position": 4,
        "showNutrition": true
      },
      "quickActions": {
        "enabled": true,
        "position": 0,
        "actions": ["scan_qr", "view_schedule", "join_event"]
      }
    },
    "refreshInterval": 300,            // Seconds between automatic refreshes
    "showWeather": true,               // Show weather widget
    "showQuickStats": true             // Show personal statistics
  },
  
  // Calendar Preferences
  "calendar": {
    "defaultView": "timeline",         // 'timeline', 'grid', 'agenda'
    "startHour": 7,                    // Calendar start hour
    "endHour": 21,                     // Calendar end hour
    "showWeekends": false,             // Show weekends in calendar
    "showLunchBreak": true,            // Highlight lunch break
    "compactMode": false,              // Compact course cards
    "showInstructor": true,            // Show instructor names
    "showRoom": true,                  // Show room numbers
    "colorCoding": "byDepartment",     // 'byDepartment', 'byType', 'custom'
    "weekStartsOn": 1                  // 1=Monday, 0=Sunday
  },
  
  // Privacy Settings
  "privacy": {
    "profileVisibility": "friends",    // 'public', 'friends', 'private'
    "showInDirectory": true,           // Appear in student directory
    "showInLeaderboards": true,        // Participate in leaderboards
    "shareActivityStatus": false,      // Share online status
    "allowEventInvites": true,         // Allow others to invite to events
    "showCourses": "friends",          // Who can see course schedule
    "showEvents": "public",            // Who can see event participation
    "showAchievements": true,          // Show badges/achievements
    "dataCollection": {
      "analytics": true,               // Allow anonymous usage analytics
      "personalization": true,         // Allow data for personalized experience
      "research": false                // Participate in research studies
    }
  },
  
  // Accessibility Settings
  "accessibility": {
    "screenReader": false,             // Screen reader optimizations
    "largeText": false,                // Large text mode
    "highContrast": false,             // High contrast mode
    "colorBlindSupport": "none",       // 'none', 'deuteranopia', 'protanopia', 'tritanopia'
    "reducedMotion": false,            // Reduce animations
    "voiceOver": false,                // VoiceOver support (iOS)
    "talkBack": false                  // TalkBack support (Android)
  },
  
  // Performance Settings
  "performance": {
    "imageQuality": "auto",            // 'low', 'medium', 'high', 'auto'
    "videoAutoplay": "wifi",           // 'never', 'wifi', 'always'
    "cacheSize": "auto",               // Cache size preference
    "backgroundSync": true,            // Allow background synchronization
    "lowDataMode": false               // Optimize for low data usage
  },
  
  // Experimental Features
  "experimental": {
    "betaFeatures": false,             // Enable beta features
    "aiRecommendations": true,         // AI-powered recommendations
    "smartNotifications": true,        // Intelligent notification timing
    "voiceCommands": false,            // Voice command support
    "gestureNavigation": false         // Gesture-based navigation
  },
  
  // Timestamps
  "createdAt": "2025-07-21T10:00:00.000Z",
  "updatedAt": "2025-07-21T10:00:00.000Z",
  "lastSyncedAt": "2025-07-21T10:00:00.000Z"
}
```

---

## 📱 **USER NOTIFICATIONS COLLECTION**

**Path**: `/users/{uid}/notifications/{notificationId}`

### **Document Structure:**
```javascript
{
  // Notification Identity
  "notificationId": "notif_20250721_001",
  "type": "course_reminder",         // 'announcement', 'course_reminder', 'event_update', etc.
  "category": "academic",           // 'academic', 'social', 'system', 'emergency'
  "priority": "medium",             // 'low', 'medium', 'high', 'urgent'
  
  // Content
  "title": "Visual Programming Class in 15 minutes",
  "body": "Your Visual Programming class starts at 08:00 in room B201",
  "titleTr": "Görsel Programlama dersi 15 dakika sonra",
  "bodyTr": "Görsel Programlama dersiniz 08:00'da B201 sınıfında başlıyor",
  
  // Rich Content
  "imageUrl": null,
  "actionUrl": "/calendar/course/cs101_fall2025",
  "actions": [
    {
      "id": "view_course",
      "title": "View Course",
      "titleTr": "Dersi Görüntüle",
      "action": "navigate",
      "params": {"route": "/calendar"}
    },
    {
      "id": "snooze",
      "title": "Snooze 5min",
      "action": "snooze",
      "params": {"minutes": 5}
    }
  ],
  
  // Targeting
  "sourceId": "cs101_fall2025",      // ID of course/event that triggered this
  "sourceType": "course",           // 'course', 'event', 'announcement', 'system'
  "tags": ["cs101", "reminder", "morning"],
  
  // Status
  "status": "delivered",            // 'pending', 'delivered', 'read', 'dismissed', 'failed'
  "readAt": null,
  "dismissedAt": null,
  "deliveredAt": "2025-07-21T07:45:00.000Z",
  
  // Delivery Channels
  "channels": {
    "push": {
      "sent": true,
      "sentAt": "2025-07-21T07:45:00.000Z",
      "delivered": true,
      "failed": false,
      "errorMessage": null
    },
    "email": {
      "sent": false,
      "reason": "user_preference"
    },
    "sms": {
      "sent": false,
      "reason": "not_enabled"
    }
  },
  
  // User Interaction
  "interaction": {
    "opened": false,
    "openedAt": null,
    "clicked": false,
    "clickedAt": null,
    "actionTaken": null,
    "feedback": null                // User feedback on notification
  },
  
  // Scheduling
  "scheduledFor": "2025-07-21T07:45:00.000Z",
  "expiresAt": "2025-07-21T09:00:00.000Z",
  "recurring": false,
  "recurringPattern": null,
  
  // Timestamps
  "createdAt": "2025-07-21T07:45:00.000Z",
  "updatedAt": "2025-07-21T07:45:00.000Z"
}
```

---

## 🏆 **USER ACHIEVEMENTS COLLECTION**

**Path**: `/users/{uid}/achievements/{achievementId}`

### **Document Structure:**
```javascript
{
  // Achievement Identity
  "achievementId": "first_week_attendance",
  "type": "attendance",             // 'attendance', 'academic', 'social', 'engagement'
  "category": "milestone",          // 'milestone', 'streak', 'completion', 'participation'
  "tier": "bronze",                 // 'bronze', 'silver', 'gold', 'platinum'
  
  // Achievement Details
  "title": "Perfect Week",
  "titleTr": "Mükemmel Hafta",
  "description": "Attended all classes for a full week",
  "descriptionTr": "Tam bir hafta boyunca tüm derslere katıldı",
  "icon": "calendar_check",
  "badgeUrl": "/badges/perfect_week_bronze.svg",
  
  // Progress & Completion
  "isCompleted": true,
  "completedAt": "2025-07-21T00:00:00.000Z",
  "progress": {
    "current": 7,                   // Days attended
    "target": 7,                    // Days required
    "percentage": 100.0
  },
  
  // Metadata
  "points": 50,                     // Points awarded
  "rarity": "common",               // 'common', 'rare', 'epic', 'legendary'
  "hidden": false,                  // Hidden until unlocked
  "seasonal": false,                // Limited-time achievement
  "repeatable": true,               // Can be earned multiple times
  
  // Context
  "triggerEvent": "attendance_check",
  "relatedData": {
    "weekStartDate": "2025-07-15",
    "coursesAttended": ["cs101_fall2025", "math201_fall2025"],
    "perfectDays": 5
  },
  
  // Social Features
  "shareEnabled": true,
  "sharedAt": null,
  "visibility": "public",           // 'public', 'friends', 'private'
  
  // Timestamps
  "createdAt": "2025-07-21T00:00:00.000Z"
}
```

---

## 📊 **USER ANALYTICS COLLECTION**

**Path**: `/users/{uid}/analytics/usage`

### **Document Structure:**
```javascript
{
  // Session Data
  "lastSession": {
    "startTime": "2025-07-21T08:00:00.000Z",
    "endTime": "2025-07-21T08:30:00.000Z",
    "duration": 1800,               // Seconds
    "screenTime": {
      "home": 600,                  // Seconds spent on home screen
      "calendar": 800,              // Seconds on calendar
      "events": 300,                // Seconds on events
      "profile": 100                // Seconds on profile
    },
    "actionsPerformed": 15,
    "crashCount": 0
  },
  
  // Usage Statistics
  "stats": {
    "totalSessions": 145,
    "totalTimeSpent": 87300,        // Total seconds in app
    "averageSessionTime": 602,      // Average session length
    "daysSinceFirstUse": 30,
    "consecutiveDaysUsed": 7,
    "mostActiveHour": 14,           // Hour of day (0-23)
    "mostActiveDay": 1,             // Day of week (1=Monday)
    "featuresUsed": {
      "calendar": 89,               // Times accessed
      "events": 23,
      "announcements": 45,
      "settings": 8,
      "qrScanner": 12
    }
  },
  
  // Engagement Metrics
  "engagement": {
    "coursesCreated": 5,
    "eventsJoined": 3,
    "announcementsRead": 12,
    "settingsChanged": 4,
    "achievementsUnlocked": 3,
    "feedbackSubmitted": 1,
    "bugsReported": 0,
    "appRating": 4.5,
    "npsScore": 9                   // Net Promoter Score (0-10)
  },
  
  // Performance Data
  "performance": {
    "averageLoadTime": 2.3,         // Seconds
    "crashFrequency": 0.001,        // Crashes per session
    "errorCount": 2,
    "offlineUsageTime": 300,        // Seconds used offline
    "syncFailures": 1,
    "apiResponseTime": 1.2          // Average API response time
  },
  
  // Device & Technical Info
  "device": {
    "platform": "android",         // 'ios', 'android', 'web'
    "appVersion": "1.2.0",
    "osVersion": "Android 13",
    "deviceModel": "Samsung Galaxy S23",
    "screenResolution": "1080x2340",
    "networkType": "wifi",          // 'wifi', 'cellular', 'offline'
    "batteryOptimizationEnabled": true
  },
  
  // Privacy-Compliant Analytics
  "anonymized": true,               // Personal data anonymized
  "consentGiven": true,             // User consented to analytics
  "retentionPeriod": 90,            // Days to keep data
  "dataProcessingPurpose": "app_improvement",
  
  // Timestamps
  "lastUpdated": "2025-07-21T08:30:00.000Z",
  "createdAt": "2025-06-21T10:00:00.000Z"
}
```

---

## 🌐 **GLOBAL COLLECTIONS**

### **Events Collection** (Shared across all users)
**Path**: `/events/{eventId}`

```javascript
{
  // Event Identity
  "eventId": "flutter_workshop_2025",
  "title": "Flutter & Dart Workshop",
  "titleTr": "Flutter & Dart Workshop'u",
  "slug": "flutter-dart-workshop-2025",
  
  // Organization
  "organizer": {
    "clubId": "cs_club",
    "clubName": "Bilgisayar Kulübü",
    "contactEmail": "cs.club@medipol.edu.tr",
    "contactPhone": "+90 212 444 0 997"
  },
  "createdBy": "user123",           // User ID of creator
  "moderators": ["user123", "user456"], // User IDs of moderators
  
  // Event Details
  "description": "Learn mobile app development with Flutter...",
  "descriptionTr": "Flutter ile mobil uygulama geliştirmeyi öğrenin...",
  "category": "workshop",           // 'workshop', 'conference', 'social', etc.
  "tags": ["flutter", "mobile", "programming", "beginner"],
  "level": "beginner",              // 'beginner', 'intermediate', 'advanced'
  
  // Schedule & Location
  "startDate": "2025-07-24T09:00:00.000Z",
  "endDate": "2025-07-24T17:00:00.000Z",
  "timezone": "Europe/Istanbul",
  "location": {
    "name": "Engineering Lab B201",
    "address": "Medipol University, Kavacık Campus",
    "building": "Engineering Building",
    "room": "B201",
    "capacity": 50,
    "accessibility": ["wheelchair", "hearing_loop"],
    "coordinates": {
      "latitude": 41.088612,
      "longitude": 29.089206
    }
  },
  
  // Registration
  "registration": {
    "required": true,
    "startDate": "2025-07-01T00:00:00.000Z",
    "endDate": "2025-07-23T23:59:00.000Z",
    "maxParticipants": 50,
    "currentParticipants": 28,
    "waitlistEnabled": true,
    "approvalRequired": false,
    "fee": {
      "amount": 0,                  // Free event
      "currency": "TRY",
      "refundable": false
    }
  },
  
  // Content & Media
  "images": [
    {
      "url": "/events/flutter_workshop/banner.jpg",
      "alt": "Flutter Workshop Banner",
      "type": "banner"
    }
  ],
  "documents": [
    {
      "name": "Workshop Agenda",
      "url": "/events/flutter_workshop/agenda.pdf",
      "type": "agenda"
    }
  ],
  "livestream": {
    "enabled": false,
    "url": null,
    "platform": null
  },
  
  // Status & Moderation
  "status": "published",            // 'draft', 'published', 'cancelled', 'completed'
  "isApproved": true,
  "approvedBy": "admin_user",
  "approvedAt": "2025-07-01T10:00:00.000Z",
  "featured": false,                // Featured on homepage
  "promoted": false,                // Promoted event
  
  // Engagement Statistics
  "stats": {
    "views": 156,
    "likes": 45,
    "shares": 12,
    "comments": 8,
    "participants": 28,
    "waitlisted": 5,
    "cancelled": 2
  },
  
  // SEO & Discovery
  "seo": {
    "metaTitle": "Flutter Workshop - Learn Mobile Development",
    "metaDescription": "Join our hands-on Flutter workshop...",
    "keywords": ["flutter", "mobile", "workshop", "programming"],
    "ogImage": "/events/flutter_workshop/og_image.jpg"
  },
  
  // Timestamps
  "createdAt": "2025-07-01T10:00:00.000Z",
  "updatedAt": "2025-07-21T15:30:00.000Z",
  "publishedAt": "2025-07-01T12:00:00.000Z"
}
```

---

## 🔒 **FIREBASE SECURITY RULES**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's subcollections
      match /{subcollection}/{documentId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Global events are readable by all authenticated users
    match /events/{eventId} {
      allow read: if request.auth != null;
      // Only event creators/moderators can write
      allow write: if request.auth != null && 
                   (resource == null || 
                    resource.data.createdBy == request.auth.uid ||
                    resource.data.moderators.hasAny([request.auth.uid]));
    }
    
    // System collections (announcements, etc.)
    match /announcements/{announcementId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && hasRole('admin');
    }
    
    // Helper functions
    function hasRole(role) {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
  }
}
```

---

## 📈 **INDEXING STRATEGY**

### **Composite Indexes Required:**
```javascript
// User courses by schedule
Collection: users/{userId}/courses
Fields: isActive (Ascending), schedule.dayOfWeek (Ascending), schedule.startHour (Ascending)

// User events by status and date
Collection: users/{userId}/events  
Fields: participationStatus (Ascending), globalEventRef (Ascending)

// Notifications by type and status
Collection: users/{userId}/notifications
Fields: type (Ascending), status (Ascending), createdAt (Descending)

// Global events by status and date
Collection: events
Fields: status (Ascending), startDate (Ascending)

// Global events by category and date
Collection: events
Fields: category (Ascending), startDate (Ascending), featured (Descending)
```

---

## 🚀 **IMPLEMENTATION NOTES**

### **Data Migration Strategy:**
1. Create new collections alongside existing static data
2. Gradually migrate users to new system
3. Provide data import tools for existing users
4. Maintain backward compatibility during transition

### **Performance Considerations:**
- Use Firestore offline persistence for mobile apps
- Implement proper caching strategies
- Use pagination for large data sets
- Batch read/write operations where possible

### **Scalability:**
- Design for 10,000+ concurrent users
- Use subcollections to avoid document size limits
- Implement data archiving for old records
- Monitor Firestore usage and costs

---

**🎯 This schema provides the foundation for a fully personalized, scalable, and maintainable user experience in MedipolApp!**

---

*Last Updated: July 21, 2025*
*Version: 1.0*