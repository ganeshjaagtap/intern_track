import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrincipalNotificationsScreen extends StatefulWidget {
  const PrincipalNotificationsScreen({super.key});

  @override
  State<PrincipalNotificationsScreen> createState() =>
      _PrincipalNotificationsScreenState();
}

class _PrincipalNotificationsScreenState
    extends State<PrincipalNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedType = 'alert';
  String? _principalId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _principalId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title and description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_principalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Principal not logged in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      var senderName = 'Principal';
      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(_principalId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() ?? <String, dynamic>{};
        senderName =
            (userData['fullName'] ?? userData['name'] ?? senderName).toString();
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'type': _selectedType,
        'senderName': senderName,
        'senderRole': 'Principal',
        'senderId': _principalId,
        'target': 'all',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descController.clear();
      _tabController.animateTo(_selectedType == 'alert' ? 0 : 1);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification published for students, faculty, and HOD.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Publish failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openDetails(Map<String, dynamic> data, String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrincipalNotificationDetailsScreen(
          data: data,
          docId: docId,
        ),
      ),
    );
  }

  Widget _buildFilteredList(String type, IconData icon) {
    if (_principalId == null) {
      return const Center(child: Text('Please log in.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: type)
          .where('senderId', isEqualTo: _principalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Unable to load notifications right now.',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              "You haven't published any ${type}s yet.",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        docs.sort((a, b) {
          final t1 = a.data()['createdAt'] as Timestamp?;
          final t2 = b.data()['createdAt'] as Timestamp?;
          if (t1 == null || t2 == null) {
            return 0;
          }
          return t2.compareTo(t1);
        });

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF5F9ED6).withOpacity(0.2),
                  child: Icon(icon, color: const Color(0xFF5F9ED6)),
                ),
                title: Text(
                  (data['title'] ?? '').toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (data['desc'] ?? '').toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openDetails(data, doc.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPublishTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Notification Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: const [
              DropdownMenuItem(value: 'alert', child: Text('Urgent Alert')),
              DropdownMenuItem(value: 'notice', child: Text('General Notice')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value ?? 'alert';
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'E.g., College internship review meeting',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Type your message here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.public, color: Color(0xFF5F9ED6), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This notification will be visible to students, faculty, and HOD.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text(
              'Publish Now',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF5F9ED6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _handlePublish,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notifications'),
        backgroundColor: const Color(0xFF5F9ED6),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'My Alerts'),
            Tab(text: 'My Notices'),
            Tab(text: 'Publish'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFilteredList('alert', Icons.notifications_active),
          _buildFilteredList('notice', Icons.campaign),
          _buildPublishTab(),
        ],
      ),
    );
  }
}

class PrincipalNotificationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const PrincipalNotificationDetailsScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<PrincipalNotificationDetailsScreen> createState() =>
      _PrincipalNotificationDetailsScreenState();
}

class _PrincipalNotificationDetailsScreenState
    extends State<PrincipalNotificationDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  String _selectedType = 'alert';
  bool _isEditing = false;
  bool _isProcessing = false;
  late final String? _currentPrincipalId;

  @override
  void initState() {
    super.initState();
    _currentPrincipalId = FirebaseAuth.instance.currentUser?.uid;
    _titleController = TextEditingController(
      text: (widget.data['title'] ?? '').toString(),
    );
    _descController = TextEditingController(
      text: (widget.data['desc'] ?? '').toString(),
    );
    _selectedType = (widget.data['type'] ?? 'alert').toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _updateNotification() async {
    if (!_canManageNotification()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can edit only your own notifications.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.docId)
          .update({
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'type': _selectedType,
        'target': 'all',
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditing = false;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification() async {
    if (!_canManageNotification()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can delete only your own notifications.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.docId)
          .delete();

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _canManageNotification();
    final ts = widget.data['createdAt'] as Timestamp?;
    var publishedTime = 'Pending/Just now';

    if (ts != null) {
      final dt = ts.toDate();
      publishedTime =
          '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: Text(_isEditing ? 'Edit Notification' : 'Notification Details'),
        actions: [
          if (!_isEditing && canManage)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (canManage)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNotification,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Published by: ${(widget.data['senderName'] ?? widget.data['sender'] ?? 'Unknown').toString()}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Designation: ${(widget.data['senderRole'] ?? 'Principal').toString()}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Audience: Students, Faculty, HOD',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Published on: $publishedTime',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_isEditing) ...[
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Notification Type',
                ),
                items: const [
                  DropdownMenuItem(value: 'alert', child: Text('Alert')),
                  DropdownMenuItem(value: 'notice', child: Text('Notice')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value ?? 'alert';
                  });
                },
              ),
              const SizedBox(height: 20),
            ],
            _isEditing
                ? TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    _titleController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 20),
            _isEditing
                ? TextField(
                    controller: _descController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Text(
                      _descController.text,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
            const SizedBox(height: 40),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _isProcessing ? null : _updateNotification,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canManageNotification() {
    return _currentPrincipalId != null &&
        widget.data['senderId']?.toString() == _currentPrincipalId;
  }
}
