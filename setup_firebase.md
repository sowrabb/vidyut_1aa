# Firebase Setup Instructions for Vidyut

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `vidyut-electrical-marketplace`
4. Enable Google Analytics (recommended)
5. Choose or create a Google Analytics account

## 2. Add Flutter App to Firebase Project

### For Android:
1. Click "Add app" and select Android
2. Enter package name: `com.example.vidyut` (or your custom package name)
3. Download `google-services.json` and place it in `android/app/`
4. Add the following to `android/build.gradle`:
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```
5. Add to `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### For iOS:
1. Click "Add app" and select iOS
2. Enter bundle ID: `com.example.vidyut` (or your custom bundle ID)
3. Download `GoogleService-Info.plist` and place it in `ios/Runner/`
4. Add to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLName</key>
       <string>REVERSED_CLIENT_ID</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>YOUR_REVERSED_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

### For Web:
1. Click "Add app" and select Web
2. Register app with nickname: `vidyut-web`
3. Copy the Firebase configuration object

## 3. Enable Firebase Services

### Authentication:
1. Go to Authentication > Sign-in method
2. Enable Email/Password
3. Enable Phone (optional)
4. Enable Google (optional)

### Firestore Database:
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users

### Storage:
1. Go to Storage
2. Click "Get started"
3. Choose "Start in test mode" (for development)
4. Select the same location as Firestore

### Cloud Messaging:
1. Go to Cloud Messaging
2. No additional setup needed for basic functionality

### Analytics:
1. Go to Analytics
2. No additional setup needed if enabled during project creation

## 4. Update Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
// Get these values from your Firebase project settings
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

## 5. Set Up Firestore Security Rules

Go to Firestore Database > Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are readable by all authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.sellerId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Conversations are readable by participants
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.buyerId || 
         request.auth.uid == resource.data.sellerId);
    }
    
    // Messages are readable by conversation participants
    match /conversations/{conversationId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.buyerId ||
         request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.sellerId);
    }
    
    // Leads are readable by all authenticated users
    match /leads/{leadId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Categories are readable by all
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 6. Set Up Storage Security Rules

Go to Storage > Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Product images are readable by all authenticated users
    match /product_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // User images are readable by all authenticated users
    match /user_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Documents are readable by all authenticated users
    match /documents/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 7. Install Dependencies

Run the following command to install the new Firebase dependencies:

```bash
flutter pub get
```

## 8. Test the Setup

1. Run your Flutter app
2. Check the console for any Firebase initialization errors
3. Test authentication by trying to sign up/sign in
4. Test Firestore by creating a test product

## 9. Next Steps

After completing this setup, you can:
1. Implement user authentication flows
2. Create product management features
3. Set up real-time messaging
4. Add push notifications
5. Implement analytics tracking

## Troubleshooting

- If you get Firebase initialization errors, check that your configuration files are in the correct locations
- Make sure your package name/bundle ID matches what you entered in Firebase
- Check that all required services are enabled in the Firebase console
- Verify that your security rules are properly configured
