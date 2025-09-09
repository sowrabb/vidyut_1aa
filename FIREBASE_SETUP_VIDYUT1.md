# Firebase Setup for Vidyut1 Project

## Project Details
- **Project Name**: vidyut1
- **Project ID**: vidyut1
- **Project Number**: 612881568506

## Step 1: Enable Firebase Services

### 1.1 Authentication
1. Go to [Firebase Console](https://console.firebase.google.com/project/vidyut1)
2. Navigate to **Authentication** > **Sign-in method**
3. Enable the following providers:
   - ✅ **Email/Password** (Enable)
   - ✅ **Phone** (Optional - for OTP verification)
   - ✅ **Google** (Optional - for social login)

### 1.2 Firestore Database
1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (recommend: `asia-south1` for India)

### 1.3 Storage
1. Go to **Storage**
2. Click **Get started**
3. Choose **Start in test mode** (for development)
4. Select the same location as Firestore

### 1.4 Cloud Messaging
1. Go to **Cloud Messaging**
2. No additional setup needed for basic functionality

## Step 2: Add Apps to Firebase Project

### 2.1 Android App
1. Click **Add app** and select **Android**
2. Enter package name: `com.example.vidyut`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### 2.2 iOS App
1. Click **Add app** and select **iOS**
2. Enter bundle ID: `com.example.vidyut`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 2.3 Web App
1. Click **Add app** and select **Web**
2. Register app with nickname: `vidyut-web`
3. Copy the Firebase configuration object

## Step 3: Update Configuration Files

### 3.1 Get API Keys from Firebase Console
After adding your apps, you'll get configuration objects like this:

**Web App Configuration:**
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  appId: "1:612881568506:web:XXXXXXXXXXXXXXXX",
  messagingSenderId: "612881568506",
  projectId: "vidyut1",
  authDomain: "vidyut1.firebaseapp.com",
  storageBucket: "vidyut1.appspot.com",
  measurementId: "G-XXXXXXXXXX"
};
```

**Android App Configuration:**
```json
{
  "project_info": {
    "project_number": "612881568506",
    "project_id": "vidyut1",
    "storage_bucket": "vidyut1.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:612881568506:android:XXXXXXXXXXXXXXXX",
        "android_client_info": {
          "package_name": "com.example.vidyut"
        }
      },
      "oauth_client": [
        {
          "client_id": "612881568506-XXXXXXXXXXXXXXXX.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      ]
    }
  ]
}
```

### 3.2 Update firebase_options.dart
Replace the placeholder values in `lib/firebase_options.dart` with your actual configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_WEB_API_KEY',
  appId: '1:612881568506:web:YOUR_ACTUAL_WEB_APP_ID',
  messagingSenderId: '612881568506',
  projectId: 'vidyut1',
  authDomain: 'vidyut1.firebaseapp.com',
  storageBucket: 'vidyut1.appspot.com',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);
```

## Step 4: Set Up Security Rules

### 4.1 Firestore Security Rules
Go to **Firestore Database** > **Rules** and replace with:

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

### 4.2 Storage Security Rules
Go to **Storage** > **Rules** and replace with:

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

## Step 5: Install Dependencies

Run the following command to install Firebase dependencies:

```bash
flutter pub get
```

## Step 6: Test the Setup

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Check the console for any Firebase initialization errors

3. Test authentication by navigating to the auth page

## Step 7: Initialize Firestore Collections

### 7.1 Create Initial Categories
Go to **Firestore Database** > **Start collection** and create:

**Collection: categories**
- Document ID: `Cables & Wires`
  - name: "Cables & Wires"
  - description: "Electrical cables and wires"
  - createdAt: [current timestamp]

- Document ID: `Switchgear`
  - name: "Switchgear"
  - description: "Electrical switchgear and protection devices"
  - createdAt: [current timestamp]

- Document ID: `Transformers`
  - name: "Transformers"
  - description: "Electrical transformers and power equipment"
  - createdAt: [current timestamp]

- Document ID: `Solar & Storage`
  - name: "Solar & Storage"
  - description: "Solar panels and energy storage systems"
  - createdAt: [current timestamp]

- Document ID: `Lighting`
  - name: "Lighting"
  - description: "LED lights and lighting fixtures"
  - createdAt: [current timestamp]

- Document ID: `Motors & Drives`
  - name: "Motors & Drives"
  - description: "Electric motors and drive systems"
  - createdAt: [current timestamp]

- Document ID: `Tools & Safety`
  - name: "Tools & Safety"
  - description: "Electrical tools and safety equipment"
  - createdAt: [current timestamp]

- Document ID: `Services`
  - name: "Services"
  - description: "Electrical installation and maintenance services"
  - createdAt: [current timestamp]

## Step 8: Next Steps

Once Firebase is configured:

1. **Test Authentication** - Try creating an account and signing in
2. **Create Test Products** - Add some sample products to test the system
3. **Test Messaging** - Try the real-time messaging feature
4. **Add Push Notifications** - Configure FCM for notifications
5. **Set Up Analytics** - Monitor user behavior and app performance

## Troubleshooting

- **Firebase initialization errors**: Check that your configuration files are in the correct locations
- **Authentication errors**: Verify that Email/Password is enabled in Firebase Console
- **Firestore permission errors**: Check your security rules
- **Storage upload errors**: Verify Storage is enabled and rules are correct

## Support

If you encounter any issues:
1. Check the Firebase Console for error logs
2. Verify all configuration files are properly placed
3. Ensure all required services are enabled
4. Check that your security rules are correctly configured
