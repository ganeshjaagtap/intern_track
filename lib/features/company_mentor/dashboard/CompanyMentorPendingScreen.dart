import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Add this to pubspec

class CompanyMentorPendingScreen extends StatefulWidget {
  const CompanyMentorPendingScreen({super.key});

  @override
  State<CompanyMentorPendingScreen> createState() => _CompanyMentorPendingScreenState();
}

class _CompanyMentorPendingScreenState extends State<CompanyMentorPendingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentMentorUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateTaskStatus(String docId, String newStatus, String message) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(docId).update({
        'status': newStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
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
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF5F9ED6),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text("Approvals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                background: Container(color: const Color(0xFF5F9ED6)),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.pending_actions, size: 18), SizedBox(width: 8), Text("Pending")])),
                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.verified, size: 18), SizedBox(width: 8), Text("Verified")])),
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

        if (tasks.isEmpty) {
          return _buildEmptyState(isReviewable, statusFilter);
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskDoc = tasks[index];
              final task = taskDoc.data() as Map<String, dynamic>;
              final String docId = taskDoc.id;

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildTaskCard(task, docId, isReviewable),
                  ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
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
                            const SizedBox(height: 4),
                            Text("Intern: ${task['studentName'] ?? 'Unknown'}", style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (!isReviewable) const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xFFF1F4F8)),
                  const SizedBox(height: 10),
                  Text(task['description'] ?? "No description provided.", style: const TextStyle(fontSize: 14, color: Color(0xFF5A637A), height: 1.5)),
                  if (!isReviewable) ...[
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          "Verified on: ${task['reviewedAt'] != null ? DateFormat('MMM dd, yyyy').format((task['reviewedAt'] as Timestamp).toDate()) : 'Recently'}",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            if (isReviewable)
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade50),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _updateTaskStatus(docId, 'todo', "Task Rejected"),
                        icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                        label: const Text("Reject", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateTaskStatus(docId, 'verified', "Task Approved"),
                        icon: const Icon(Icons.check, size: 18, color: Colors.white),
                        label: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAvatar(String name, bool isPending) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPending 
            ? [Colors.orange.shade300, Colors.orange.shade600] 
            : [const Color(0xFF5F9ED6), const Color(0xFF4A89C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: (isPending ? Colors.orange : Colors.blue).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
    );
  }

  Widget _buildEmptyState(bool isReviewable, String statusFilter) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
                  child: Icon(isReviewable ? Icons.auto_awesome : Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
                ),
                const SizedBox(height: 25),
                Text(
                  isReviewable ? "All caught up!" : "No verified tasks",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3243)),
                ),
                const SizedBox(height: 10),
                Text(
                  "No tasks found for ${statusFilter == 'completed' ? 'review' : 'approval'}.",
                  style: TextStyle(color: Colors.blueGrey.shade300),
                ),
              ],
            ),
          ),
        );
      },
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
    return Container(
      color: const Color(0xFF5F9ED6),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}