import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/chat/chat_info_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String chatTitle;
  final bool isGroup;
  final String currentUserName;
  final String chatImageUrl;
  final String infoId;
  final List<String> participantIds;
  final List<String> participantNames;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.chatTitle,
    required this.isGroup,
    required this.currentUserName,
    this.chatImageUrl = '',
    this.infoId = '',
    this.participantIds = const [],
    this.participantNames = const [],
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final Set<String> _selectedMessageIds = <String>{};
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _markChatAsRead();
    _markAllIncomingMessagesAsRead();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final msg = _controller.text.trim();
    _controller.clear();

    await _sendChatMessage(
      text: msg,
      lastMessage: msg,
    );
  }

  Future<void> _sendChatMessage({
    String text = '',
    String imageUrl = '',
    String imageBase64 = '',
    required String lastMessage,
  }) async {
    final hasText = text.trim().isNotEmpty;
    final hasImage = imageUrl.trim().isNotEmpty || imageBase64.trim().isNotEmpty;
    if (!hasText && !hasImage) {
      return;
    }

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    await chatRef.collection('messages').add({
      'senderId': currentUid,
      'senderName': widget.currentUserName,
      'text': text,
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'type': hasImage ? 'image' : 'text',
      'deliveredTo': [currentUid],
      'readBy': [currentUid],
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatRef.set({
      'chatId': widget.chatId,
      'title': widget.chatTitle,
      'type': widget.isGroup ? 'group' : 'direct',
      'participantIds': widget.participantIds,
      'participantNames': widget.participantNames,
      'lastMessage': lastMessage,
      'lastSenderId': currentUid,
      'lastSenderName': widget.currentUserName,
      'lastUpdated': FieldValue.serverTimestamp(),
      'unreadCounts.$currentUid': 0,
    }, SetOptions(merge: true));

    for (final participantId in widget.participantIds) {
      if (participantId == currentUid) {
        continue;
      }
      await chatRef.set({
        'unreadCounts.$participantId': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 960,
        maxHeight: 960,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _isUploadingImage = true;
      });

      final bytes = await pickedFile.readAsBytes();
      String imageUrl = '';
      String imageBase64 = '';

      try {
        final extension = pickedFile.path.contains('.')
            ? pickedFile.path.split('.').last.toLowerCase()
            : 'jpg';
        final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$currentUid.$extension';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child(widget.chatId)
            .child(fileName);

        final uploadTask = kIsWeb
            ? storageRef.putData(
                bytes,
                SettableMetadata(contentType: contentType),
              )
            : storageRef.putFile(
                File(pickedFile.path),
                SettableMetadata(contentType: contentType),
              );

        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (_) {
        imageBase64 = base64Encode(bytes);
        if (imageBase64.length > 800000) {
          throw Exception(
            'Image upload failed and the compressed image is too large for Firestore fallback.',
          );
        }
      }

      await _sendChatMessage(
        imageUrl: imageUrl,
        imageBase64: imageBase64,
        lastMessage: '[Photo]',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = _selectedMessageIds.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        titleSpacing: 0,
        title: isSelectionMode
            ? Text(
                '${_selectedMessageIds.length} selected',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            : InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openInfo,
                child: Row(
                  children: [
                    _ChatHeaderAvatar(
                      title: widget.chatTitle,
                      imageUrl: widget.chatImageUrl,
                      isGroup: widget.isGroup,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.chatTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        backgroundColor: const Color(0xFF16324F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete messages',
                  onPressed: _showDeleteMessageOptions,
                ),
              ]
            : [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'info') {
                      _openInfo();
                    } else if (value == 'delete') {
                      _deleteChat();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'info',
                      child: Text(widget.isGroup ? 'Group Info' : 'View Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete Chat'),
                    ),
                  ],
                ),
              ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final deletedFor = List<String>.from(data['deletedFor'] ?? const []);
                  return !deletedFor.contains(currentUid);
                }).toList();
                _syncMessageReceipts(docs);

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUid;
                    final isDeleted = data['deletedForEveryone'] == true;
                    final isSelected = _selectedMessageIds.contains(doc.id);

                    return GestureDetector(
                      onLongPress: () => _toggleMessageSelection(doc.id),
                      onTap: () {
                        if (_selectedMessageIds.isNotEmpty) {
                          _toggleMessageSelection(doc.id);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0x332563EB)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: _buildMessageBubble(
                          text: isDeleted
                              ? 'This message was deleted'
                              : (data['text'] ?? '').toString(),
                          imageUrl: isDeleted
                              ? ''
                              : (data['imageUrl'] ?? '').toString(),
                          imageBase64: isDeleted
                              ? ''
                              : (data['imageBase64'] ?? '').toString(),
                          senderName: (data['senderName'] ?? '').toString(),
                          isMe: isMe,
                          ts: data['timestamp'],
                          isDeleted: isDeleted,
                          deliveredTo: List<String>.from(data['deliveredTo'] ?? const []),
                          readBy: List<String>.from(data['readBy'] ?? const []),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required String imageUrl,
    required String imageBase64,
    required String senderName,
    required bool isMe,
    required dynamic ts,
    required bool isDeleted,
    required List<String> deliveredTo,
    required List<String> readBy,
  }) {
    final timeLabel = ts is Timestamp ? DateFormat('hh:mm a').format(ts.toDate()) : '';
    final imageBytes = imageBase64.trim().isEmpty || isDeleted
        ? null
        : _decodeBase64Image(imageBase64);
    final hasImage = imageUrl.trim().isNotEmpty || imageBytes != null;
    final receiptIcon = _buildReceiptIcon(
      isMe: isMe,
      deliveredTo: deliveredTo,
      readBy: readBy,
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: EdgeInsets.fromLTRB(
          hasImage ? 8 : 16,
          hasImage ? 8 : 12,
          hasImage ? 8 : 16,
          12,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isGroup && !isMe && senderName.isNotEmpty) ...[
              Text(
                senderName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (hasImage) ...[
              GestureDetector(
                onTap: () => _openImagePreview(
                  imageUrl: imageUrl,
                  imageBytes: imageBytes,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl.trim().isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            if (imageBytes != null) {
                              return Image.memory(
                                imageBytes,
                                width: 220,
                                height: 220,
                                fit: BoxFit.cover,
                              );
                            }
                            return Container(
                              width: 220,
                              height: 220,
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: isMe ? Colors.white70 : Colors.grey,
                                size: 42,
                              ),
                            );
                          },
                        )
                      : Image.memory(
                          imageBytes!,
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              if (text.trim().isNotEmpty) const SizedBox(height: 8),
            ],
            if (text.trim().isNotEmpty || isDeleted)
              Text(
                text,
                style: TextStyle(
                  color: isDeleted
                      ? (isMe ? Colors.white70 : const Color(0xFF64748B))
                      : (isMe ? Colors.white : Colors.black87),
                  fontSize: 15,
                  height: 1.35,
                  fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: isMe ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (receiptIcon != null) ...[
                      const SizedBox(width: 4),
                      receiptIcon,
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildReceiptIcon({
    required bool isMe,
    required List<String> deliveredTo,
    required List<String> readBy,
  }) {
    if (!isMe) {
      return null;
    }

    final otherParticipantIds = widget.participantIds
        .where((id) => id.trim().isNotEmpty && id != currentUid)
        .toSet();

    if (otherParticipantIds.isEmpty) {
      return Icon(Icons.done_rounded, size: 15, color: Colors.white70);
    }

    final deliveredSet = deliveredTo.toSet();
    final readSet = readBy.toSet();
    final deliveredAll = otherParticipantIds.every(deliveredSet.contains);
    final readAll = otherParticipantIds.every(readSet.contains);

    if (readAll) {
      return const Icon(
        Icons.done_all_rounded,
        size: 16,
        color: Color(0xFFA7F3D0),
      );
    }

    if (deliveredAll) {
      return Icon(Icons.done_all_rounded, size: 16, color: Colors.white70);
    }

    return Icon(Icons.done_rounded, size: 15, color: Colors.white70);
  }

  void _syncMessageReceipts(List<QueryDocumentSnapshot> docs) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final batch = FirebaseFirestore.instance.batch();
      var hasUpdates = false;

      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        if ((data['senderId'] ?? '') == currentUid) {
          continue;
        }

        final deliveredTo = List<String>.from(data['deliveredTo'] ?? const []);
        final readBy = List<String>.from(data['readBy'] ?? const []);
        final updates = <String, dynamic>{};

        if (!deliveredTo.contains(currentUid)) {
          updates['deliveredTo'] = FieldValue.arrayUnion([currentUid]);
        }
        if (!readBy.contains(currentUid)) {
          updates['readBy'] = FieldValue.arrayUnion([currentUid]);
        }

        if (updates.isNotEmpty) {
          batch.update(doc.reference, updates);
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    });
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE5EEF9),
            child: _isUploadingImage
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    onPressed: _pickAndSendImage,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isUploadingImage,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: widget.isGroup ? 'Message the group...' : 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFF1F4F7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isUploadingImage ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMessageIds.clear();
    });
  }

  Future<void> _showDeleteMessageOptions() async {
    if (_selectedMessageIds.isEmpty) {
      return;
    }

    final selectedIds = _selectedMessageIds.toList();
    final selectedDocs = <QueryDocumentSnapshot>[];
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    for (var i = 0; i < selectedIds.length; i += 10) {
      final chunk = selectedIds.sublist(
        i,
        i + 10 > selectedIds.length ? selectedIds.length : i + 10,
      );
      final snapshot = await messagesRef
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      selectedDocs.addAll(snapshot.docs);
    }

    final allMine = selectedDocs.every(
      (doc) => (doc.data() as Map<String, dynamic>)['senderId'] == currentUid,
    );

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Delete for me'),
                  subtitle: const Text('Remove selected messages only from your account.'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _deleteMessagesForMe(selectedIds);
                  },
                ),
                ListTile(
                  enabled: allMine,
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: allMine ? Colors.red : Colors.grey,
                  ),
                  title: Text(
                    'Delete for everyone',
                    style: TextStyle(color: allMine ? Colors.black : Colors.grey),
                  ),
                  subtitle: Text(
                    allMine
                        ? 'Replace these messages for every participant.'
                        : 'Only your own messages can be deleted for everyone.',
                  ),
                  onTap: allMine
                      ? () async {
                          Navigator.pop(context);
                          await _deleteMessagesForEveryone(selectedIds);
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteMessagesForMe(List<String> messageIds) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final messagesRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages');

      for (final messageId in messageIds) {
        batch.update(messagesRef.doc(messageId), {
          'deletedFor': FieldValue.arrayUnion([currentUid]),
        });
      }

      await batch.commit();
      _clearSelection();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete messages: $e')),
      );
    }
  }

  Future<void> _deleteMessagesForEveryone(List<String> messageIds) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final messagesRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages');

      for (final messageId in messageIds) {
        batch.update(messagesRef.doc(messageId), {
          'text': '',
          'imageUrl': '',
          'imageBase64': '',
          'deletedForEveryone': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      _clearSelection();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete messages: $e')),
      );
    }
  }

  Future<void> _openInfo() async {
    if (widget.infoId.isEmpty) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.isGroup
            ? GroupInfoScreen(
                groupId: widget.infoId,
                fallbackGroupName: widget.chatTitle,
              )
            : ChatProfileScreen(userId: widget.infoId),
      ),
    );
  }

  void _openImagePreview({
    required String imageUrl,
    required Uint8List? imageBytes,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: imageUrl.trim().isNotEmpty
                  ? Image.network(
                      imageUrl,
                      errorBuilder: (context, error, stackTrace) {
                        if (imageBytes != null) {
                          return Image.memory(imageBytes);
                        }
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 56,
                        );
                      },
                    )
                  : Image.memory(imageBytes!),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markChatAsRead() async {
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).set({
      'unreadCounts.$currentUid': 0,
    }, SetOptions(merge: true));
  }

  Future<void> _markAllIncomingMessagesAsRead() async {
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages');

      final snapshot = await messagesRef.get();
      final batch = FirebaseFirestore.instance.batch();
      var hasUpdates = false;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if ((data['senderId'] ?? '') == currentUid) {
          continue;
        }

        final deliveredTo = List<String>.from(data['deliveredTo'] ?? const []);
        final readBy = List<String>.from(data['readBy'] ?? const []);
        final updates = <String, dynamic>{};

        if (!deliveredTo.contains(currentUid)) {
          updates['deliveredTo'] = FieldValue.arrayUnion([currentUid]);
        }
        if (!readBy.contains(currentUid)) {
          updates['readBy'] = FieldValue.arrayUnion([currentUid]);
        }

        if (updates.isNotEmpty) {
          batch.update(doc.reference, updates);
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (_) {
      // Avoid breaking chat open flow if receipts update fails.
    }
  }

  Future<void> _deleteChat() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete chat?'),
        content: Text(
          widget.isGroup
              ? 'This deletes the full group conversation for everyone.'
              : 'This deletes the full conversation for both participants.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      final messagesSnapshot = await chatRef.collection('messages').get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(chatRef);
      await batch.commit();

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete chat: $e')),
      );
    }
  }
}

Uint8List? _decodeBase64Image(String value) {
  try {
    return base64Decode(value);
  } catch (_) {
    return null;
  }
}

class _ChatHeaderAvatar extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isGroup;

  const _ChatHeaderAvatar({
    required this.title,
    required this.imageUrl,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white.withOpacity(0.16),
      child: isGroup
          ? const Icon(Icons.groups_rounded, color: Colors.white, size: 18)
          : Text(
              title.isNotEmpty ? title[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
