import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatProfileScreen extends StatelessWidget {
  final String userId;

  const ChatProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Contact Info'),
        backgroundColor: const Color(0xFF16324F),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('user').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found.'));
          }

          final data = snapshot.data!.data() ?? <String, dynamic>{};
          final name = _displayName(data, fallback: 'User');
          final role = _roleLabel((data['role'] ?? '').toString());
          final imageUrl = (data['profileImageUrl'] ?? '').toString();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16324F),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                role,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                children: [
                  _InfoRow(label: 'Email', value: (data['email'] ?? '').toString()),
                  _InfoRow(label: 'Faculty ID', value: (data['facultyId'] ?? '').toString()),
                  _InfoRow(label: 'Mentor ID', value: (data['mentorId'] ?? '').toString()),
                  _InfoRow(
                    label: 'Enrollment No',
                    value: (data['enrollmentNo'] ?? '').toString(),
                  ),
                  _InfoRow(label: 'Department', value: (data['dept'] ?? '').toString()),
                  _InfoRow(
                    label: 'Company',
                    value: (data['company_name'] ?? data['company'] ?? '').toString(),
                  ),
                  _InfoRow(
                    label: 'Assigned Group',
                    value: (data['assignedGroupName'] ?? '').toString(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class GroupInfoScreen extends StatelessWidget {
  final String groupId;
  final String fallbackGroupName;

  const GroupInfoScreen({
    super.key,
    required this.groupId,
    required this.fallbackGroupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Group Info'),
        backgroundColor: const Color(0xFF16324F),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? <String, dynamic>{};
          final groupName = (data['groupName'] ?? fallbackGroupName).toString();
          final memberIds = List<String>.from(data['studentIds'] ?? const []);
          final leaderId = (data['leaderId'] ?? '').toString();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: const Icon(
                    Icons.groups_rounded,
                    size: 34,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                groupName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${memberIds.length} members',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                children: [
                  _InfoRow(label: 'Group ID', value: groupId),
                  _InfoRow(label: 'Leader ID', value: leaderId),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (memberIds.isEmpty)
                const _EmptyInfoCard(message: 'No members found for this group.')
              else
                ...memberIds.map(
                  (memberId) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MemberTile(
                      memberId: memberId,
                      isLeader: memberId == leaderId,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String memberId;
  final bool isLeader;

  const _MemberTile({
    required this.memberId,
    required this.isLeader,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('user').doc(memberId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final name = _displayName(data, fallback: 'Student');
        final imageUrl = (data['profileImageUrl'] ?? '').toString();
        final enrollmentNo = (data['enrollmentNo'] ?? '').toString();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isLeader)
                          const Icon(Icons.star_rounded, color: Colors.amber),
                      ],
                    ),
                    if (enrollmentNo.isNotEmpty)
                      Text(
                        enrollmentNo,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final visibleChildren = children.whereType<Widget>().toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: visibleChildren),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInfoCard extends StatelessWidget {
  final String message;

  const _EmptyInfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }
}

String _displayName(Map<String, dynamic> data, {required String fallback}) {
  final fullName = (data['fullName'] ?? data['name'] ?? '').toString().trim();
  return fullName.isEmpty ? fallback : fullName;
}

String _roleLabel(String role) {
  switch (role.trim().toLowerCase()) {
    case 'student':
      return 'Student';
    case 'faculty':
      return 'Faculty Mentor';
    case 'mentor':
      return 'Company Mentor';
    default:
      return role.isEmpty ? 'User' : role;
  }
}
