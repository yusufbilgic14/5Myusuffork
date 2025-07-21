# Firebase Standalone Backend Roadmap

## Project Overview

**Goal**: Implement standalone Firebase Authentication and backend system while maintaining Microsoft OAuth as an alternative login option.

**Current State**: 
- Hybrid Microsoft OAuth + Firebase system (Microsoft primary)
- Firebase services configured but underutilized
- User data stored in Firestore but dependent on Microsoft OAuth
- No native Firebase signup/signin functionality

**Target State**:
- **Primary**: Standalone Firebase Authentication (Email/Password, Google Sign-In)
- **Secondary**: Microsoft OAuth as alternative login method
- Complete user profile management in Firestore
- Theme, language, and notification preferences stored per user
- Course enrollment and grade tracking in Firebase
- Independent user account system

---

## Phase 1: Firebase Authentication Enhancement ✅ **FOUNDATION READY**

### Task 1.1: Enable Firebase Authentication Methods
**Priority**: Critical  
**Estimated Time**: 30 minutes  
**Status**: 🟡 **NEEDS CONFIGURATION**

**Firebase Console Setup Required:**
1. **Enable Authentication Methods**:
   - ✅ Email/Password authentication 
   - ✅ Google Sign-In provider
   - 🔲 Phone authentication (optional for later)
   - 🔲 Anonymous authentication (for guest users)

2. **Configure Google Sign-In**:
   - Add OAuth 2.0 client IDs for Android/iOS
   - Configure authorized domains
   - Download updated `google-services.json` and `GoogleService-Info.plist`

3. **Email Templates**:
   - Customize email verification template
   - Customize password reset template
   - Set sender name: "MedipolApp"

### Task 1.2: Update Firebase Auth Service
**Priority**: Critical  
**Estimated Time**: 4 hours  
**Status**: 🟡 **IN PROGRESS**

**Update**: `lib/services/firebase_auth_service.dart`

**New Methods to Implement**:
```dart
// Email/Password Authentication
Future<FirebaseAuthResult> signUpWithEmailAndPassword(String email, String password, Map<String, dynamic> userData);
Future<FirebaseAuthResult> signInWithEmailAndPassword(String email, String password);
Future<void> sendPasswordResetEmail(String email);

// Email Verification
Future<void> sendEmailVerification();
Future<void> reloadUser();
bool get isEmailVerified;

// Google Sign-In
Future<FirebaseAuthResult> signInWithGoogle();

// Profile Management
Future<void> updateUserProfile({String? displayName, String? photoURL});
Future<void> updateEmail(String newEmail, String password);
Future<void> updatePassword(String currentPassword, String newPassword);

// Account Management
Future<void> deleteAccount(String password);
Future<void> linkWithCredential(AuthCredential credential);
```

### Task 1.3: Create User Registration Flow
**Priority**: High  
**Estimated Time**: 3 hours  
**Status**: 🟡 **PENDING**

**New Components**:
- `SignUpScreen` widget
- Email validation utilities
- Password strength checker
- Terms of service agreement
- Student information collection form

**User Registration Data Collection**:
```dart
class UserRegistrationData {
  final String email;
  final String password;
  final String displayName;
  final String studentId; // Optional
  final String department; // Dropdown selection
  final String phoneNumber; // Optional
  final bool agreeToTerms;
  final UserRole role; // student, staff, guest
}
```

---

## Phase 2: Login Screen Enhancement

### Task 2.1: Add Sign-Up Functionality to Login Screen
**Priority**: Critical  
**Estimated Time**: 3 hours  
**Status**: 🟡 **PENDING**

**Update**: `lib/screens/login_screen.dart`

**UI Changes Required**:
1. **Toggle between Sign-In and Sign-Up modes**:
   ```dart
   enum AuthMode { signIn, signUp }
   AuthMode _currentMode = AuthMode.signIn;
   ```

2. **Additional Form Fields for Sign-Up**:
   - Full Name (displayName)
   - Email address 
   - Password with confirmation
   - Student ID (optional)
   - Department selection
   - Phone number (optional)

3. **Form Validation**:
   - Email format validation
   - Password strength requirements (8+ chars, numbers, special chars)
   - Password confirmation match
   - Student ID format (if provided)

4. **UI Components**:
   ```dart
   Widget _buildAuthModeToggle(); // Switch between Sign In / Sign Up
   Widget _buildSignUpForm(); // Additional fields for registration
   Widget _buildPasswordStrengthIndicator();
   Widget _buildDepartmentDropdown();
   Widget _buildTermsCheckbox();
   ```

### Task 2.2: Implement Authentication Logic
**Priority**: Critical  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Authentication Flow**:
```dart
// Sign Up Flow
Future<void> _handleFirebaseSignUp() async {
  // 1. Validate form
  // 2. Create Firebase user account
  // 3. Send email verification
  // 4. Create Firestore user document
  // 5. Set default preferences
  // 6. Navigate to email verification screen
}

// Sign In Flow  
Future<void> _handleFirebaseSignIn() async {
  // 1. Validate credentials
  // 2. Sign in with Firebase
  // 3. Check email verification status
  // 4. Load user preferences from Firestore
  // 5. Navigate to home screen
}
```

### Task 2.3: Email Verification Screen
**Priority**: High  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Create**: `lib/screens/email_verification_screen.dart`

**Features**:
- Email verification status checker
- Resend verification email button
- Auto-refresh verification status
- Skip verification option (with limitations)
- Beautiful UI with email illustration

---

## Phase 3: User Profile and Data Management

### Task 3.1: Enhanced Firestore User Data Schema
**Priority**: High  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Updated User Document Structure**:
```javascript
// /users/{uid}
{
  // Firebase Native Data
  uid: string,
  email: string,
  displayName: string,
  emailVerified: boolean,
  photoURL: string,
  phoneNumber: string,
  
  // University Information
  studentId: string, // Optional, user-provided
  employeeId: string, // For staff
  department: string, // CS, Medicine, Engineering, etc.
  enrollmentYear: number, // For students
  
  // App Preferences
  preferences: {
    theme: 'light' | 'dark' | 'system',
    language: 'tr' | 'en',
    notifications: {
      announcements: boolean,
      grades: boolean,
      calendar: boolean,
      cafeteria: boolean,
      general: boolean
    }
  },
  
  // System Data
  role: 'student' | 'staff' | 'admin' | 'guest',
  permissions: string[],
  isActive: boolean,
  accountType: 'firebase' | 'microsoft_oauth',
  
  // Timestamps
  createdAt: timestamp,
  updatedAt: timestamp,
  lastLoginAt: timestamp,
  emailVerifiedAt: timestamp
}
```

### Task 3.2: User Profile Management Screen
**Priority**: Medium  
**Estimated Time**: 4 hours  
**Status**: 🟡 **PENDING**

**Update**: `lib/screens/profile_screen.dart`

**New Features**:
- Edit profile information (name, student ID, department)
- Change password functionality
- Email change with verification
- Profile picture upload
- Account deletion option
- Data export functionality

### Task 3.3: Course and Grade Management
**Priority**: Medium  
**Estimated Time**: 3 hours  
**Status**: 🟡 **PENDING**

**User Courses Subcollection**:
```javascript
// /users/{uid}/courses/{courseId}
{
  courseCode: string, // e.g., "CS101"
  courseName: string, // e.g., "Introduction to Programming"
  instructor: string,
  credits: number,
  semester: string, // e.g., "2024-Fall"
  status: 'active' | 'completed' | 'dropped',
  
  // Grades subcollection
  grades: {
    midterm: number,
    final: number,
    assignments: number[],
    attendance: number,
    letterGrade: string, // AA, BA, BB, etc.
    gpa: number
  },
  
  createdAt: timestamp,
  updatedAt: timestamp
}
```

---

## Phase 4: Preferences and Settings Integration

### Task 4.1: Theme Preferences Storage
**Priority**: Medium  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Update**: `lib/providers/theme_provider.dart`

**Changes**:
- Load theme preference from Firestore on app start
- Save theme changes to user document
- Sync across devices when user signs in
- Handle offline theme preference caching

### Task 4.2: Language Preferences Storage  
**Priority**: Medium  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Update**: `lib/providers/language_provider.dart`

**Changes**:
- Load language preference from Firestore
- Save language selection to user document
- Default to Turkish for Turkish email domains
- Sync across devices

### Task 4.3: Notification Preferences
**Priority**: Medium  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Features**:
- Granular notification settings per category
- Firebase Cloud Messaging topic subscriptions
- In-app notification preferences
- Email notification preferences

---

## Phase 5: Dual Authentication System

### Task 5.1: Update Authentication Provider
**Priority**: High  
**Estimated Time**: 3 hours  
**Status**: 🟡 **PENDING**

**Update**: `lib/providers/authentication_provider.dart`

**New Architecture**:
```dart
class AuthenticationProvider extends ChangeNotifier {
  // Current auth method
  AuthenticationMethod _currentAuthMethod = AuthenticationMethod.none;
  
  // User objects for both methods
  AppUser? _currentUser;
  FirebaseUser? _firebaseUser;
  MicrosoftUser? _microsoftUser;
  
  // Authentication methods
  Future<bool> signInWithFirebase(String email, String password);
  Future<bool> signUpWithFirebase(String email, String password, UserRegistrationData data);
  Future<bool> signInWithMicrosoft(); // Existing
  Future<bool> signInWithGoogle();
  
  // Unified user interface
  AppUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  AuthenticationMethod get currentAuthMethod => _currentAuthMethod;
}

enum AuthenticationMethod { 
  none, 
  firebase_email, 
  firebase_google, 
  microsoft_oauth 
}
```

### Task 5.2: User Data Synchronization
**Priority**: Medium  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Features**:
- Detect if user exists in both systems
- Account linking/unlinking functionality
- Data migration between authentication methods
- Conflict resolution for duplicate accounts

---

## Phase 6: Security and Validation

### Task 6.1: Enhanced Security Rules
**Priority**: Critical  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Firestore Security Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId
        && isValidUserData(resource.data);
    }
    
    // User courses - only owner can access
    match /users/{userId}/courses/{courseId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public announcements - all authenticated users can read
    match /announcements/{announcementId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && hasAdminRole(request.auth.uid);
    }
    
    // System collections
    match /system/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only via server
    }
    
    // Validation functions
    function isValidUserData(data) {
      return data.keys().hasAll(['email', 'displayName', 'role', 'createdAt'])
        && data.email is string
        && data.email.matches('.*@.*\\..*')
        && data.displayName is string
        && data.displayName.size() > 0;
    }
    
    function hasAdminRole(uid) {
      return get(/databases/$(database)/documents/users/$(uid)).data.role == 'admin';
    }
  }
}
```

### Task 6.2: Data Validation and Sanitization
**Priority**: High  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Validation Rules**:
- Email format validation
- Password strength requirements
- Student ID format validation (if provided)
- Sanitize user input for XSS prevention
- Rate limiting for authentication attempts

---

## Phase 7: Testing and Quality Assurance

### Task 7.1: Authentication Flow Testing
**Priority**: High  
**Estimated Time**: 3 hours  
**Status**: 🟡 **PENDING**

**Test Scenarios**:
1. **Firebase Sign-Up**:
   - Valid email/password registration
   - Email verification flow
   - Duplicate email handling
   - Invalid input validation

2. **Firebase Sign-In**:
   - Valid credentials login
   - Invalid credentials handling
   - Unverified email handling
   - Password reset flow

3. **Microsoft OAuth**:
   - Existing OAuth flow still works
   - Account linking scenarios
   - Data consistency between methods

4. **Data Persistence**:
   - Theme preferences saved/loaded
   - Language preferences sync
   - Course data persistence
   - Offline data handling

### Task 7.2: Security Testing
**Priority**: Critical  
**Estimated Time**: 2 hours  
**Status**: 🟡 **PENDING**

**Security Validation**:
- Firestore security rules testing
- Authentication bypass attempts
- Data access validation
- Input sanitization verification
- Rate limiting effectiveness

---

## Implementation Timeline

### **Week 1: Foundation (Critical)**
1. ✅ Task 1.1 - Enable Firebase Auth Methods (Console)
2. 🟡 Task 1.2 - Update Firebase Auth Service 
3. 🟡 Task 2.1 - Add Sign-Up to Login Screen
4. 🟡 Task 1.3 - Create User Registration Flow

### **Week 2: Core Features (High Priority)**
5. 🟡 Task 2.2 - Implement Authentication Logic
6. 🟡 Task 2.3 - Email Verification Screen
7. 🟡 Task 3.1 - Enhanced Firestore Schema
8. 🟡 Task 5.1 - Update Authentication Provider

### **Week 3: User Experience (Medium Priority)**
9. 🟡 Task 3.2 - User Profile Management
10. 🟡 Task 4.1 - Theme Preferences Storage
11. 🟡 Task 4.2 - Language Preferences Storage
12. 🟡 Task 4.3 - Notification Preferences

### **Week 4: Advanced Features (Medium Priority)**
13. 🟡 Task 3.3 - Course and Grade Management
14. 🟡 Task 5.2 - User Data Synchronization
15. 🟡 Task 6.1 - Enhanced Security Rules
16. 🟡 Task 6.2 - Data Validation

### **Week 5: Testing and Polish (Critical)**
17. 🟡 Task 7.1 - Authentication Flow Testing
18. 🟡 Task 7.2 - Security Testing
19. 🟡 Final integration testing
20. 🟡 Performance optimization

---

## Success Metrics

### **Technical Metrics**
- ✅ Firebase Auth success rate > 99%
- ✅ Email verification delivery rate > 95%
- ✅ Data sync latency < 2 seconds
- ✅ App crash rate < 0.1%
- ✅ Security rules 100% effective

### **User Experience Metrics**
- ✅ Registration completion rate > 80%
- ✅ Email verification completion rate > 70%
- ✅ User preference sync success rate > 95%
- ✅ Cross-device consistency maintained
- ✅ Offline functionality works seamlessly

### **Feature Adoption**
- ✅ Firebase Auth adoption vs Microsoft OAuth ratio
- ✅ Profile customization usage rates
- ✅ Course management feature usage
- ✅ Notification preference configuration rates

---

## Risk Mitigation

### **High Risks**
1. **User Migration Complexity**
   - **Risk**: Existing Microsoft OAuth users confused by new options
   - **Mitigation**: Clear onboarding flow, maintain Microsoft OAuth as primary initially

2. **Data Consistency Issues**
   - **Risk**: User data conflicts between authentication methods
   - **Mitigation**: Robust data validation, conflict resolution mechanisms

3. **Email Deliverability**
   - **Risk**: Verification emails not reaching users
   - **Mitigation**: Configure SPF/DKIM records, use Firebase's reliable email service

### **Medium Risks**
1. **Performance Impact**
   - **Risk**: Additional Firestore operations slow down app
   - **Mitigation**: Implement caching, optimize queries, use offline persistence

2. **Security Vulnerabilities**
   - **Risk**: New authentication surface increases attack vectors
   - **Mitigation**: Comprehensive security rules testing, regular audits

---

## Next Steps

### **Immediate Actions Required**
1. **📋 Enable Firebase Auth Methods** in Firebase Console
2. **🔧 Begin Task 1.2** - Update Firebase Auth Service
3. **🎨 Start UI Design** for sign-up components
4. **📊 Set up Analytics** to track implementation progress

### **Dependencies**
- Firebase project billing must support authentication volume
- Email domain verification for custom email templates
- Testing devices/accounts for comprehensive flow testing

---

## Progress Tracking

**Current Status**: 🟡 **PLANNING PHASE**
- ✅ Analysis Complete
- ✅ Architecture Designed  
- ✅ Roadmap Created
- 🟡 Implementation Starting

**Next Milestone**: 🎯 **Week 1 Completion**
- Firebase Auth Service Updated
- Basic Sign-Up UI Implemented
- Email Verification Flow Working
- Initial User Registration Functional

This roadmap provides a comprehensive plan for implementing standalone Firebase authentication while maintaining Microsoft OAuth compatibility. Each task is clearly defined with priorities, time estimates, and success criteria.