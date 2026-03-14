import 'package:flutter/material.dart';

class PrincipalNotificationsScreen extends StatefulWidget {
  const PrincipalNotificationsScreen({super.key});

  @override
  State<PrincipalNotificationsScreen> createState() =>
      _PrincipalNotificationsScreenState();
}

class _PrincipalNotificationsScreenState
    extends State<PrincipalNotificationsScreen> {
  // 📝 LOCAL STATE: This stores your notifications temporarily
  final List<Map<String, String>> _allNotifications = [
    {"title": "Welcome", "desc": "System is ready.", "type": "Alert"},
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedType = "Alert";

  // Function to add the new notification to the list
  void _handlePublish() {
    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
      setState(() {
        _allNotifications.add({
          "title": _titleController.text,
          "desc": _descController.text,
          "type": _selectedType,
        });
      });

      // Clear fields and switch to the relevant tab
      _titleController.clear();
      _descController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Published to $_selectedType")));
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
            "Notifications",
            style: TextStyle(color: Colors.black),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF64A9F6),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF64A9F6),
            tabs: [
              Tab(text: "Alerts"),
              Tab(text: "Notices"),
              Tab(text: "Publish"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Alerts Tab: Filters local list for 'Alert'
            _buildFilteredList("Alert", Icons.notifications),
            // Notices Tab: Filters local list for 'Notice'
            _buildFilteredList("Notice", Icons.campaign),
            // Publish Tab
            _buildPublishTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(String type, IconData icon) {
    final filtered = _allNotifications.where((n) => n["type"] == type).toList();

    return filtered.isEmpty
        ? const Center(child: Text("No items yet"))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Icon(icon, color: Colors.black87),
                  title: Text(filtered[index]["title"]!),
                  subtitle: Text(filtered[index]["desc"]!),
                ),
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
            "Notification Type",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          DropdownButton<String>(
            value: _selectedType,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "Alert", child: Text("Alert")),
              DropdownMenuItem(value: "Notice", child: Text("Notice")),
            ],
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Description",
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
              child: const Text("Publish Notification"),
            ),
          ),
        ],
      ),
    );
  }
}
