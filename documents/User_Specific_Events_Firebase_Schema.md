# User-Specific Events Firebase Schema Design

## Overview
This document outlines the Firebase Firestore schema design for implementing user-specific events functionality, including likes, comments, follows, and event participation.

## Collections Structure

### 1. Events Collection (`/events`)
**Purpose**: Global events that all users can see and interact with
**Document ID**: Auto-generated
**Access**: Read by all authenticated users, Write by admins only

```typescript
interface Event {
  // Basic Event Information
  eventId: string;           // Auto-generated document ID
  title: string;             // Event title
  description: string;       // Event description
  imageUrl?: string;         // Event image URL
  
  // Event Details
  eventType: 'conference' | 'workshop' | 'social' | 'sports' | 'cultural' | 'academic' | 'career';
  category: string;          // More specific category
  location: string;          // Event location
  building?: string;         // Building name if on campus
  room?: string;            // Room number
  
  // Date & Time
  startDateTime: Timestamp;  // Event start date and time
  endDateTime: Timestamp;    // Event end date and time
  timezone: string;          // Event timezone
  
  // Capacity & Registration
  maxCapacity?: number;      // Maximum attendees (null for unlimited)
  requiresRegistration: boolean; // Whether registration is required
  registrationDeadline?: Timestamp; // Registration deadline
  
  // Organizer Information
  organizerId: string;       // ID of organizing user/admin
  organizerName: string;     // Name of organizer
  organizerType: 'university' | 'club' | 'department' | 'student_organization';
  clubId?: string;          // Reference to club if organized by club
  
  // Status & Visibility
  status: 'draft' | 'published' | 'cancelled' | 'completed';
  isVisible: boolean;        // Whether event is visible to users
  isFeatured: boolean;       // Whether event is featured
  
  // Engagement Counters (Real-time)
  likeCount: number;         // Total likes
  commentCount: number;      // Total comments
  joinCount: number;         // Total participants
  shareCount: number;        // Total shares
  
  // Metadata
  createdAt: Timestamp;      // Creation timestamp
  updatedAt: Timestamp;      // Last update timestamp
  createdBy: string;         // Creator user ID
  updatedBy: string;         // Last updater user ID
  
  // Tags & Search
  tags: string[];            // Searchable tags
  keywords: string[];        // Search keywords
}
```

### 2. User Event Interactions (`/users/{userId}/eventInteractions`)
**Purpose**: Track user-specific interactions with events
**Document ID**: eventId
**Access**: Read/Write by document owner only

```typescript
interface UserEventInteraction {
  eventId: string;           // Reference to event
  userId: string;            // User ID (from document path)
  
  // Interaction Types
  hasLiked: boolean;         // Whether user liked the event
  hasJoined: boolean;        // Whether user joined the event
  hasShared: boolean;        // Whether user shared the event
  isFavorited: boolean;      // Whether user favorited the event
  
  // Participation Details
  joinedAt?: Timestamp;      // When user joined
  leftAt?: Timestamp;        // When user left (if applicable)
  joinStatus: 'not_joined' | 'joined' | 'waitlisted' | 'cancelled';
  
  // Notification Preferences
  notifyBeforeEvent: boolean; // Notify before event starts
  notifyDayBefore: boolean;  // Notify 1 day before
  notifyHourBefore: boolean; // Notify 1 hour before
  
  // Interaction History
  likedAt?: Timestamp;       // When user liked
  unlikedAt?: Timestamp;     // When user unliked (for analytics)
  
  // Metadata
  createdAt: Timestamp;      // First interaction timestamp
  updatedAt: Timestamp;      // Last interaction timestamp
}
```

### 3. Event Comments (`/events/{eventId}/comments`)
**Purpose**: Comments on events
**Document ID**: Auto-generated
**Access**: Read by all authenticated users, Write by authenticated users

```typescript
interface EventComment {
  commentId: string;         // Auto-generated document ID
  eventId: string;           // Parent event ID
  
  // Comment Content
  content: string;           // Comment text content
  contentType: 'text' | 'text_with_media';
  mediaUrls?: string[];      // Optional media attachments
  
  // Author Information
  authorId: string;          // Comment author user ID
  authorName: string;        // Author display name
  authorAvatar?: string;     // Author profile picture URL
  
  // Reply System
  parentCommentId?: string;  // Parent comment ID (for replies)
  replyLevel: number;        // 0 = top-level, 1 = reply, 2 = reply to reply, etc.
  replyCount: number;        // Number of replies to this comment
  
  // Engagement
  likeCount: number;         // Number of likes on comment
  
  // Status & Moderation
  status: 'active' | 'hidden' | 'deleted' | 'flagged';
  isEdited: boolean;         // Whether comment was edited
  editedAt?: Timestamp;      // Last edit timestamp
  
  // Metadata
  createdAt: Timestamp;      // Creation timestamp
  updatedAt: Timestamp;      // Last update timestamp
}
```

### 4. Comment Likes (`/events/{eventId}/comments/{commentId}/likes`)
**Purpose**: Track who liked each comment
**Document ID**: userId
**Access**: Read by all authenticated users, Write by document owner only

```typescript
interface CommentLike {
  commentId: string;         // Parent comment ID
  userId: string;            // User who liked (document ID)
  userName: string;          // User display name
  likedAt: Timestamp;        // When the like occurred
}
```

### 5. User Followed Clubs (`/users/{userId}/followedClubs`)
**Purpose**: Track which clubs/organizations a user follows
**Document ID**: clubId
**Access**: Read/Write by document owner only

```typescript
interface UserFollowedClub {
  clubId: string;            // Club/organization ID (document ID)
  clubName: string;          // Club display name
  clubType: 'student_club' | 'department' | 'university_organization';
  clubAvatar?: string;       // Club logo/avatar URL
  
  // Follow Details
  followedAt: Timestamp;     // When user followed
  notificationsEnabled: boolean; // Receive notifications from this club
  
  // Engagement
  eventCount: number;        // Number of events from this club
  lastEventDate?: Timestamp; // Date of last event from this club
  
  // Metadata
  createdAt: Timestamp;      // Creation timestamp
  updatedAt: Timestamp;      // Last update timestamp
}
```

### 6. Clubs/Organizations (`/clubs`)
**Purpose**: Information about clubs and organizations
**Document ID**: Auto-generated
**Access**: Read by all authenticated users, Write by club admins

```typescript
interface Club {
  clubId: string;            // Auto-generated document ID
  name: string;              // Club name
  displayName: string;       // Display name
  description: string;       // Club description
  
  // Visual Identity
  logoUrl?: string;          // Club logo
  bannerUrl?: string;        // Club banner image
  colors: {                  // Club theme colors
    primary: string;         // Primary color hex
    secondary: string;       // Secondary color hex
  };
  
  // Contact Information
  email?: string;            // Contact email
  website?: string;          // Club website
  socialMedia: {             // Social media links
    instagram?: string;
    twitter?: string;
    facebook?: string;
    linkedin?: string;
  };
  
  // Club Details
  category: string;          // Club category
  department?: string;       // Associated department
  faculty?: string;          // Associated faculty
  establishedYear?: number;  // Year established
  
  // Membership
  memberCount: number;       // Number of members
  followerCount: number;     // Number of followers
  isActive: boolean;         // Whether club is active
  
  // Management
  adminIds: string[];        // Club admin user IDs
  moderatorIds: string[];    // Club moderator user IDs
  
  // Status
  status: 'active' | 'inactive' | 'suspended';
  verificationStatus: 'verified' | 'pending' | 'unverified';
  
  // Metadata
  createdAt: Timestamp;      // Creation timestamp
  updatedAt: Timestamp;      // Last update timestamp
  createdBy: string;         // Creator user ID
}
```

### 7. User My Events (`/users/{userId}/myEvents`)
**Purpose**: User's personal event calendar (joined events)
**Document ID**: eventId
**Access**: Read/Write by document owner only

```typescript
interface UserMyEvent {
  eventId: string;           // Reference to main event (document ID)
  userId: string;            // User ID (from document path)
  
  // Event Reference Data (denormalized for performance)
  eventTitle: string;        // Event title
  eventStartDate: Timestamp; // Event start date
  eventEndDate: Timestamp;   // Event end date
  eventLocation: string;     // Event location
  organizerName: string;     // Event organizer
  
  // User Participation
  joinedAt: Timestamp;       // When user joined
  joinMethod: 'direct' | 'invitation' | 'import'; // How user joined
  participationStatus: 'confirmed' | 'maybe' | 'cancelled';
  
  // Personal Notes & Reminders
  personalNotes?: string;    // User's personal notes about event
  customReminders: {         // Custom reminder settings
    enabled: boolean;
    beforeMinutes: number[]; // Reminder times in minutes before event
  };
  
  // Calendar Integration
  addedToCalendar: boolean;  // Whether added to device calendar
  calendarEventId?: string;  // Device calendar event ID
  
  // Metadata
  createdAt: Timestamp;      // Creation timestamp
  updatedAt: Timestamp;      // Last update timestamp
}
```

## Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events - Read by all authenticated users, Write by admins only
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'moderator');
      
      // Event comments - Read by all, Write by authenticated users
      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && 
                        (request.auth.uid == resource.data.authorId || request.operation == 'create');
        allow delete: if request.auth != null && 
                         (request.auth.uid == resource.data.authorId ||
                          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
        
        // Comment likes
        match /likes/{userId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    
    // User-specific collections - Only owner can access
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /eventInteractions/{eventId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /followedClubs/{clubId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /myEvents/{eventId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Clubs - Read by all authenticated, Write by club admins
    match /clubs/{clubId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
                       request.auth.uid in resource.data.adminIds);
    }
  }
}
```

## Indexing Strategy

### Composite Indexes Required

1. **Events Collection**:
   - `status` + `isVisible` + `startDateTime`
   - `organizerType` + `startDateTime`
   - `eventType` + `startDateTime`
   - `tags` (array) + `startDateTime`

2. **Event Comments**:
   - `eventId` + `parentCommentId` + `createdAt`
   - `authorId` + `createdAt`

3. **User Event Interactions**:
   - `hasJoined` + `joinedAt`
   - `hasLiked` + `likedAt`

4. **User My Events**:
   - `eventStartDate` + `participationStatus`

## Real-time Features Implementation

### 1. Event Engagement Counters
- Use Firestore transactions to update counters atomically
- Implement Cloud Functions for counter consistency
- Use batched writes for bulk operations

### 2. Real-time Comment System
- Stream comments using Firestore real-time listeners
- Implement optimistic UI updates
- Handle offline scenarios with local caching

### 3. Live Event Updates
- Stream event participation counts
- Real-time like/unlike animations
- Live comment notifications

## Data Consistency Strategies

### 1. Denormalization
- Store essential event data in `userMyEvents` for fast loading
- Cache user display names in comments for performance
- Replicate club information in `followedClubs`

### 2. Counter Management
- Use Cloud Functions to maintain accurate counters
- Implement eventual consistency patterns
- Handle race conditions with transactions

### 3. Cache Invalidation
- Clear relevant caches when data changes
- Use timestamp-based cache validation
- Implement smart refresh strategies

## Performance Considerations

### 1. Pagination
- Implement cursor-based pagination for large lists
- Use `startAfter()` for efficient data loading
- Limit query results (25-50 items per page)

### 2. Offline Support
- Cache recent events locally
- Store user interactions for offline processing
- Sync when connection is restored

### 3. Optimizations
- Use shallow queries where possible
- Implement lazy loading for non-critical data
- Batch multiple operations together

This schema design enables a fully user-specific events system with social features while maintaining performance and data consistency.