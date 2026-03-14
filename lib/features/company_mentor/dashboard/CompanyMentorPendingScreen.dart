import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CompanyMentorPendingScreen extends StatefulWidget {
  const CompanyMentorPendingScreen({super.key});

  @override
  State<CompanyMentorPendingScreen> createState() => _CompanyMentorPendingScreenState();
}

class _CompanyMentorPendingScreenState extends State<CompanyMentorPendingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentMentorUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _rejectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rejectionController.dispose();
    super.dispose();
  }

  // --- SHOW REJECTION DIALOG ---
  void _showRejectionDialog(String docId) {
    _rejectionController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.report_problem_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Reject Task"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Provide a clear reason for the intern to resubmit.", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: _rejectionController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "e.g., Code logic is correct but please follow the naming conventions...",
                hintStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              if (_rejectionController.text.trim().length > 3) {
                _updateTaskStatus(docId, 'todo', "Task sent back to Intern", reason: _rejectionController.text.trim());
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide a valid reason.")));
              }
            },
            child: const Text("Reject Task", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UPDATED STATUS UPDATE LOGIC ---
  Future<void> _updateTaskStatus(String docId, String newStatus, String message, {String? reason}) async {
    try {
      Map<String, dynamic> updateData = {
        'status': newStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
      };

      if (reason != null) {
        updateData['rejectionReason'] = reason;
      } else {
        // When verifying, clear the old rejection reason so it doesn't show up again
        updateData['rejectionReason'] = FieldValue.delete();
      }

      await FirebaseFirestore.instance.collection('tasks').doc(docId).update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: newStatus == 'verified' ? Colors.green.shade600 : Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF5F9ED6),
              elevation: 0,
              centerTitle: true,
              title: const Text("Approvals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: "Pending Review"),
                    Tab(text: "Verified"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList(statusFilter: 'completed', isReviewable: true),
            _buildTaskList(statusFilter: 'verified', isReviewable: false),
          ],
        ),
      ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  Widget _buildTaskList({required String statusFilter, required bool isReviewable}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('assignedByMentorId', isEqualTo: currentMentorUid)
          .where('status', isEqualTo: statusFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5F9ED6)));
        }

        final tasks = snapshot.data?.docs ?? [];
        if (tasks.isEmpty) return _buildEmptyState(isReviewable);

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskDoc = tasks[index];
              final task = taskDoc.data() as Map<String, dynamic>;
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: _buildTaskCard(task, taskDoc.id, isReviewable)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, String docId, bool isReviewable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAnimatedAvatar(task['studentName'] ?? "?", isReviewable),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task['title'] ?? "Task Title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF2D3243))),
                          Text("Intern: ${task['studentName'] ?? 'Unknown'}", style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (!isReviewable) const Icon(Icons.verified_user_rounded, color: Colors.green, size: 28),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(height: 1, color: Color(0xFFF1F4F8)),
                const SizedBox(height: 15),
                Text(task['description'] ?? "No description provided.", style: const TextStyle(fontSize: 14, color: Color(0xFF5A637A), height: 1.5)),
                
                // Show rejection reason history if it exists
                if (task['rejectionReason'] != null && isReviewable) ...[
                   const SizedBox(height: 15),
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Row(
                           children: [
                             Icon(Icons.history, size: 14, color: Colors.red),
                             SizedBox(width: 6),
                             Text("Previous Feedback:", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                           ],
                         ),
                         const SizedBox(height: 4),
                         Text("${task['rejectionReason']}", style: TextStyle(color: Colors.red.shade900, fontSize: 13)),
                       ],
                     ),
                   )
                ]
              ],
            ),
          ),
          if (isReviewable)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectionDialog(docId),
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                      label: const Text("Reject", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateTaskStatus(docId, 'verified', "Task Verified Successfully"),
                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                      label: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAvatar(String name, bool isPending) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPending ? [Colors.orange.shade300, Colors.orange.shade600] : [const Color(0xFF5F9ED6), const Color(0xFF4A89C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: (isPending ? Colors.orange : Colors.blue).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
    );
  }

  Widget _buildEmptyState(bool isReviewable) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
            child: Icon(isReviewable ? Icons.assignment_turned_in_rounded : Icons.verified_rounded, size: 70, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          Text(isReviewable ? "All caught up!" : "No verified tasks yet", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3243))),
          const SizedBox(height: 8),
          Text(isReviewable ? "No tasks are waiting for your review." : "Verified tasks will appear here.", style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: const Color(0xFF5F9ED6), child: _tabBar);
  }
  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}