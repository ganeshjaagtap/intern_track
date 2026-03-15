import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InAppAlertService {
  InAppAlertService._();

  static final InAppAlertService instance = InAppAlertService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  final Set<String> _seenNotificationIds = <String>{};
  final Map<String, DateTime> _seenChatUpdates = <String, DateTime>{};
  final Set<String> _loadingNotificationSenders = <String>{};

  _CurrentUserProfile? _currentProfile;
  bool _isDialogVisible = false;
  bool _didPrimeChats = false;
  bool _didPrimeNotifications = false;

  void initialize() {
    _authSubscription ??=
        FirebaseAuth.instance.authStateChanges().listen(_handleAuthChanged);
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _chatSubscription?.cancel();
    await _notificationSubscription?.cancel();
    _authSubscription = null;
    _chatSubscription = null;
    _notificationSubscription = null;
  }

  Future<void> _handleAuthChanged(User? user) async {
    await _chatSubscription?.cancel();
    await _notificationSubscription?.cancel();
    _chatSubscription = null;
    _notificationSubscription = null;
    _seenNotificationIds.clear();
    _seenChatUpdates.clear();
    _loadingNotificationSenders.clear();
    _didPrimeChats = false;
    _didPrimeNotifications = false;
    _currentProfile = null;

    if (user == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .get();

    final data = userDoc.data() ?? <String, dynamic>{};
    _currentProfile = _CurrentUserProfile.fromMap(user.uid, data);

    _listenForChats(user.uid);
    _listenForNotifications();
  }

  void _listenForChats(String uid) {
    _chatSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data == null) {
          continue;
        }

        final updatedAt = _extractDateTime(
          data['lastUpdated'] ?? data['timestamp'] ?? data['createdAt'],
        );
        final docId = change.doc.id;

        if (!_didPrimeChats) {
          _seenChatUpdates[docId] = updatedAt ?? DateTime.now();
          continue;
        }

        if (change.type == DocumentChangeType.removed) {
          _seenChatUpdates.remove(docId);
          continue;
        }

        final previousUpdate = _seenChatUpdates[docId];
        _seenChatUpdates[docId] = updatedAt ?? DateTime.now();

        if (change.type == DocumentChangeType.added && previousUpdate == null) {
          continue;
        }

        if (updatedAt != null &&
            previousUpdate != null &&
            !updatedAt.isAfter(previousUpdate)) {
          continue;
        }

        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCounts'] ?? const {});
        final unreadForUser = (unreadCounts[uid] as num?)?.toInt() ?? 0;
        final lastSenderId = (data['lastSenderId'] ?? '').toString();
        if (lastSenderId.isEmpty || lastSenderId == uid || unreadForUser <= 0) {
          continue;
        }

        final title = (data['title'] ?? 'New chat message').toString().trim();
        final message =
            (data['lastMessage'] ?? 'You received a new message').toString();

        _showAlert(
          title: title.isEmpty ? 'New chat message' : title,
          body: message.isEmpty ? 'You received a new message.' : message,
        );
      }

      _didPrimeChats = true;
    });
  }

  void _listenForNotifications() {
    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data == null) {
          continue;
        }

        final docId = change.doc.id;
        if (!_didPrimeNotifications) {
          _seenNotificationIds.add(docId);
          continue;
        }

        if (change.type == DocumentChangeType.removed) {
          _seenNotificationIds.remove(docId);
          continue;
        }

        if (!_seenNotificationIds.add(docId)) {
          continue;
        }

        _handleIncomingNotification(data);
      }

      _didPrimeNotifications = true;
    });
  }

  Future<void> _handleIncomingNotification(Map<String, dynamic> data) async {
    final profile = _currentProfile;
    if (profile == null) {
      return;
    }

    final isForCurrentUser = await _isNotificationForCurrentUser(data, profile);
    if (!isForCurrentUser) {
      return;
    }

    final senderRole = (data['senderRole'] ?? '').toString().trim();
    if (senderRole.isEmpty) {
      return;
    }

    final title = (data['title'] ?? 'New notification').toString().trim();
    final body =
        (data['desc'] ?? data['message'] ?? 'You received a new update.')
            .toString()
            .trim();

    _showAlert(
      title: title.isEmpty ? 'New notification' : title,
      body: body.isEmpty ? 'You received a new update.' : body,
    );
  }

  Future<bool> _isNotificationForCurrentUser(
    Map<String, dynamic> data,
    _CurrentUserProfile profile,
  ) async {
    final recipientId = (data['recipientId'] ?? '').toString().trim();
    if (recipientId.isNotEmpty) {
      return recipientId == profile.uid;
    }

    final target = (data['target'] ?? '').toString().trim().toLowerCase();
    if (target == 'all') {
      return true;
    }

    if ((target == 'student' || target == 'students') &&
        profile.role == 'student') {
      final senderId = (data['senderId'] ?? '').toString().trim();
      if (senderId.isEmpty) {
        return true;
      }

      final senderProfile = await _loadSenderProfile(senderId);
      if (senderProfile == null) {
        return true;
      }

      final senderRole = senderProfile.role;
      if (senderRole == 'mentor') {
        return profile.companyMentorId.isNotEmpty &&
            senderProfile.mentorId == profile.companyMentorId;
      }

      if (senderRole == 'faculty') {
        return profile.facultyId.isNotEmpty &&
            senderProfile.facultyId == profile.facultyId;
      }

      return true;
    }

    if (target == profile.role) {
      return true;
    }

    return false;
  }

  Future<_CurrentUserProfile?> _loadSenderProfile(String uid) async {
    if (_loadingNotificationSenders.contains(uid)) {
      return null;
    }

    _loadingNotificationSenders.add(uid);
    try {
      final senderDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      if (!senderDoc.exists) {
        return null;
      }
      return _CurrentUserProfile.fromMap(uid, senderDoc.data() ?? {});
    } finally {
      _loadingNotificationSenders.remove(uid);
    }
  }

  void _showAlert({
    required String title,
    required String body,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    SystemSound.play(SystemSoundType.alert);

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (_isDialogVisible) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    _isDialogVisible = true;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      _isDialogVisible = false;
    });
  }

  DateTime? _extractDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class _CurrentUserProfile {
  final String uid;
  final String role;
  final String facultyId;
  final String mentorId;
  final String companyMentorId;

  const _CurrentUserProfile({
    required this.uid,
    required this.role,
    required this.facultyId,
    required this.mentorId,
    required this.companyMentorId,
  });

  factory _CurrentUserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return _CurrentUserProfile(
      uid: uid,
      role: (data['role'] ?? '').toString().trim().toLowerCase(),
      facultyId: (data['facultyId'] ?? '').toString().trim(),
      mentorId: (data['mentorId'] ?? '').toString().trim(),
      companyMentorId: (data['companyMentorId'] ?? '').toString().trim(),
    );
  }
}
