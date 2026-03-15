import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'intern_tracker_alerts',
    'Intern Tracker Alerts',
    description: 'Notifications for chats and important internship updates.',
    importance: Importance.max,
    playSound: true,
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    await _initializeLocalNotifications();
    await _requestPermissions();
    await _syncTokenForCurrentUser();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        return;
      }
      await _syncTokenForCurrentUser();
    });

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _storeToken(token);
    });

    FirebaseMessaging.onMessage.listen((message) async {
      await showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification opened: ${message.messageId}');
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initializationSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _syncTokenForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await _storeToken(token);
  }

  Future<void> _storeToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ??
        (message.data['title']?.toString() ?? 'Intern Tracker');
    final body =
        notification?.body ??
        (message.data['body']?.toString() ?? 'You have a new update.');

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    await _localNotifications.show(
      message.messageId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'intern_tracker_alerts',
          'Intern Tracker Alerts',
          channelDescription:
              'Notifications for chats and important internship updates.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }
}
