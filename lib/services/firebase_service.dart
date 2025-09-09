import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Initialize Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
    // Initialize Messaging
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }

  // Auth methods
  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      await crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      await crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  // Firestore methods
  CollectionReference get users => firestore.collection('users');
  CollectionReference get products => firestore.collection('products');
  CollectionReference get conversations => firestore.collection('conversations');
  CollectionReference get leads => firestore.collection('leads');
  CollectionReference get subscriptions => firestore.collection('subscriptions');
  CollectionReference get categories => firestore.collection('categories');

  // Storage methods
  Reference get storageRef => storage.ref();
  Reference get productImagesRef => storage.ref('product_images');
  Reference get userImagesRef => storage.ref('user_images');
  Reference get documentsRef => storage.ref('documents');

  // Analytics methods
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserProperty(String name, String value) async {
    await analytics.setUserProperty(name: name, value: value);
  }

  // Messaging methods
  Future<String?> getToken() async {
    return await messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
  }
}
