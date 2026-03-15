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
    extends State<PrincipalNotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedType = 'alert';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter title and description')),
      );
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String senderName = 'Principal';

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .get();
        final userData = userDoc.data() ?? <String, dynamic>{};
        senderName =
            (userData['fullName'] ?? userData['name'] ?? 'Principal').toString();
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'type': _selectedType,
        'senderName': senderName,
        'senderRole': 'Principal',
        'senderId': currentUser?.uid ?? '',
        'target': 'all',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descController.clear();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification published')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Publish failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.black),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF64A9F6),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF64A9F6),
            tabs: [
              Tab(text: 'Alerts'),
              Tab(text: 'Notices'),
              Tab(text: 'Publish'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFilteredList('alert', Icons.notifications),
            _buildFilteredList('notice', Icons.campaign),
            _buildPublishTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(String type, IconData icon) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No items yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Icon(icon, color: Colors.black87),
                title: Text((data['title'] ?? '').toString()),
                subtitle: Text((data['desc'] ?? '').toString()),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPublishTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Type',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          DropdownButton<String>(
            value: _selectedType,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'alert', child: Text('Alert')),
              DropdownMenuItem(value: 'notice', child: Text('Notice')),
            ],
            onChanged: (val) => setState(() => _selectedType = val ?? 'alert'),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _handlePublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Publish Notification'),
            ),
          ),
        ],
      ),
    );
  }
}
