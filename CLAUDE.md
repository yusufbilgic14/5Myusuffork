# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MedipolApp is a comprehensive Flutter university campus application for Medipol University that provides students and staff with campus services including Microsoft OAuth authentication, academic calendar, cafeteria menus, campus mapping with Google Maps, QR access codes, course grades, and announcements. The app uses a hybrid authentication system (Microsoft MSAL + Firebase) with Firebase as the backend for real-time data synchronization.

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run code generation for JSON models
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code for issues
flutter analyze

# Run the app on connected device
flutter run

# Build for different platforms
flutter build apk
flutter build ios
flutter build web
flutter build windows

# Generate app icons
flutter pub run flutter_launcher_icons

# Clean build artifacts
flutter clean
```

### Testing and Quality
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Format code
dart format .

# Check for outdated dependencies
flutter pub outdated
```

## Architecture Overview

### Technology Stack
- **Framework**: Flutter 3.8.0+ with Dart
- **State Management**: Provider pattern
- **Authentication**: Microsoft MSAL (primary) + Firebase Auth (secondary)
- **Backend**: Firebase (Firestore, Storage, Analytics, Crashlytics, FCM)
- **Localization**: flutter_localizations with Turkish/English support
- **Maps**: Google Maps Flutter with custom dark theme styling

### Project Structure
```
lib/
├── constants/          # App-wide constants and enums
├── firebase_options.dart
├── main.dart          # App entry point with MaterialApp setup
├── l10n/             # Localization files (TR/EN .arb files)
├── models/           # Data models with JSON serialization (@JsonSerializable)
├── providers/        # State management (AuthenticationProvider, ThemeProvider, LanguageProvider)
├── screens/          # 17 UI screens for different app features
├── services/         # Business logic and API services
├── themes/           # Light/Dark theme definitions
└── widgets/          # Reusable UI components
    ├── common/       # Shared widgets (AppDrawer, BottomNavigation, etc.)
    └── universal_map_widget.dart
```

### Authentication Flow
1. **Microsoft OAuth via MSAL**: Primary authentication using Azure AD
2. **Firebase Custom Token**: Secondary authentication for Firebase services
3. **Token Storage**: Flutter Secure Storage for token persistence
4. **User Data Sync**: Microsoft Graph API data synced to Firestore

### Key Dependencies
- **Authentication**: `msal_auth`, `firebase_auth`, `flutter_secure_storage`
- **Firebase Services**: `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging`
- **UI Components**: `google_maps_flutter`, `qr_flutter`, `table_calendar`, `camera`
- **State Management**: `provider`, `shared_preferences`
- **Development**: `flutter_lints`, `build_runner`, `json_serializable`

## Critical Issues & Refactoring Priorities

### High Priority Code Duplication
1. **Drawer Implementation**: 6 screens have ~900 lines of duplicated `_buildSideDrawer()` code
   - Files: `home_screen.dart`, `calendar_screen.dart`, `profile_screen.dart`, `feedback_screen.dart`, `qr_access_screen.dart`, `course_grades_screen.dart`
   - Solution: Implement centralized `AppDrawerWidget` from `lib/widgets/common/`

2. **Bottom Navigation**: Mixed usage between custom implementations and `BottomNavigationWidget`
   - Inconsistent files: `home_screen.dart`, `campus_map_screen.dart`, `feedback_screen.dart`
   - Solution: Standardize usage of `BottomNavigationWidget`

3. **Campus Map Screen**: Contains multiple syntax errors and incomplete GoogleMap widget implementation

### Development Guidelines

#### Code Quality Standards (from .cursor/rules/)
- Use Turkish comments for code explanation, English for code itself
- Declare types for all variables and functions
- Use const constructors for immutable widgets
- Prefer composition over inheritance
- Use descriptive variable names with auxiliary verbs (isLoading, hasError)
- Write functions with single purpose (<20 instructions)
- Follow SOLID principles

#### Model Conventions
- Use `@JsonSerializable(fieldRename: FieldRename.snake)` for API models
- Include `createdAt`, `updatedAt`, `isDeleted` fields in database models
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after model changes

#### Navigation Patterns
- Use `Navigator.pushNamed()` with route names from constants
- Pass data through constructor parameters or route arguments
- Implement proper back navigation handling

## Configuration Files

### Required Setup Files
- `assets/msal_config.json` - Microsoft OAuth configuration
- `android/app/google-services.json` - Firebase Android configuration
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS configuration
- `assets/map_styles/dark_map_style.json` - Custom Google Maps dark theme

### Environment Setup
1. **Firebase Project**: Configure Authentication, Firestore, Storage, Analytics
2. **Google Maps API**: Enable Maps SDK for Android/iOS with API key
3. **Microsoft Azure AD**: Register OAuth app for MSAL authentication
4. **Platform Configuration**: Add Firebase configuration files to respective platforms

## Common Development Patterns

### State Management with Provider
```dart
// Access providers in widgets
final authProvider = Provider.of<AuthenticationProvider>(context);
final themeProvider = Provider.of<ThemeProvider>(context);

// Listen to changes
Consumer<AuthenticationProvider>(
  builder: (context, auth, child) => // Widget tree
)
```

### Firebase Service Usage
```dart
// Firestore operations through FirestoreService
final firestoreService = FirestoreService();
await firestoreService.createUser(userData);
final announcements = await firestoreService.getAnnouncements();
```

### Localization Implementation
```dart
// Access localized strings
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcomeMessage)
```

### Theme Integration
```dart
// Use theme colors instead of hardcoded values
color: Theme.of(context).primaryColor
textStyle: Theme.of(context).textTheme.titleLarge
```

## Common Issues to Watch For

1. **Print Statements**: Replace `print()` with proper logging framework
2. **Hardcoded Colors**: Use theme system instead of `Color(0xFF...)` values  
3. **Unused Imports**: Regular cleanup to maintain code quality
4. **Deprecated APIs**: Update `withOpacity()` to `withValues()` for Flutter 3.x
5. **Missing Error Handling**: Wrap Firebase operations in try-catch blocks
6. **BuildContext Across Async**: Guard async operations with `mounted` check

## Documentation References
- `GOOGLE_MAPS_SETUP.md` - Google Maps API configuration guide
- `REFACTORIZATION_ANALYSIS.md` - Detailed code quality analysis and improvement roadmap
- `documents/Backend_Roadmap_Tasks.md` - Firebase integration roadmap
- `documents/Firestore_Database_Schema.md` - Database design documentation