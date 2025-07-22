# Firebase Firestore Composite Indexes Setup

The app requires these composite indexes for optimal performance. You can create them manually in the Firebase Console or use the provided links from the error messages.

## Required Indexes

### 1. Events Collection Index
**Collection:** `events`
**Fields:**
- `status` (Ascending)
- `isVisible` (Ascending) 
- `startDateTime` (Ascending)

**Direct Link:** 
```
https://console.firebase.google.com/v1/r/project/medipolapp-e3b4f/firestore/indexes?create_composite=Ck9wcm9qZWN0cy9tZWRpcG9sYXBwLWUzYjRmL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9ldmVudHMvaW5kZXhlcy9fEAEaDQoJaXNWaXNpYmxlEAEaCgoGc3RhdHVzEAEaEQoNc3RhcnREYXRlVGltZRABGgwKCF9fbmFtZV9fEAE
```

### 2. Clubs Collection Index
**Collection:** `clubs`
**Fields:**
- `status` (Ascending)
- `isActive` (Ascending)
- `followerCount` (Descending)

**Direct Link:**
```
https://console.firebase.google.com/v1/r/project/medipolapp-e3b4f/firestore/indexes?create_composite=Ck5wcm9qZWN0cy9tZWRpcG9sYXBwLWUzYjRmL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9jbHVicy9pbmRleGVzL18QARoMCghpc0FjdGl2ZRABGgoKBnN0YXR1cxABGhEKDWZvbGxvd2VyQ291bnQQAhoMCghfX25hbWVfXxAC
```

## Manual Setup Instructions

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project: `medipolapp-e3b4f`

2. **Navigate to Firestore Database**
   - Click on "Firestore Database" in the left sidebar
   - Go to the "Indexes" tab

3. **Create Composite Indexes**
   
   **For Events Index:**
   - Click "Create Index"
   - Collection ID: `events`
   - Add fields:
     - `status` → Ascending
     - `isVisible` → Ascending
     - `startDateTime` → Ascending
   - Click "Create Index"
   
   **For Clubs Index:**
   - Click "Create Index" 
   - Collection ID: `clubs`
   - Add fields:
     - `status` → Ascending
     - `isActive` → Ascending
     - `followerCount` → Descending
   - Click "Create Index"

4. **Wait for Index Creation**
   - Indexes typically take 5-15 minutes to build
   - You'll see a status indicator in the console

## Temporary Fix Applied

I've already applied a temporary fix in the code that:
- Simplifies the Firestore queries to avoid composite index requirements
- Does client-side filtering instead of server-side for better immediate compatibility
- This allows the app to work right now while you set up the indexes

## After Index Setup

Once the indexes are created, you can optionally revert to the more efficient server-side queries by:
1. Restoring the original complex WHERE clauses in the queries
2. Using server-side ordering instead of client-side sorting

This will improve performance, especially with larger datasets.

## Test the Fix

After creating these indexes (or using the temporary fix), try:
1. Creating a new event
2. Creating a new club  
3. Viewing the events list
4. Viewing the clubs list

The error messages should disappear and you should see your newly created events and clubs in the app.