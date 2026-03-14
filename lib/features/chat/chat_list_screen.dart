import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/chat/chat_detail_screen.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static String getDirectChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access chats.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF16324F),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const _EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Profile not found',
              message: 'Your Firestore user document is missing.',
            );
          }

          final userData = snapshot.data!.data() ?? <String, dynamic>{};
          final role = (userData['role'] ?? '').toString().trim().toLowerCase();
          final currentUserName = _displayName(userData, fallback: 'User');

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _HeaderCard(
                title: 'Your inbox',
                subtitle: _roleSubtitle(role),
              ),
              const SizedBox(height: 20),
              if (role == 'student')
                _StudentChats(
                  currentUid: currentUser.uid,
                  currentUserName: currentUserName,
                  currentUserData: userData,
                )
              else if (role == 'faculty')
                _FacultyChats(
                  currentUid: currentUser.uid,
                  currentUserName: currentUserName,
                  currentUserData: userData,
                )
              else if (role == 'mentor')
                _MentorChats(
                  currentUid: currentUser.uid,
                  currentUserName: currentUserName,
                  currentUserData: userData,
                )
              else
                const _EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat not configured',
                  message: 'This role does not have a chat inbox yet.',
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentChats extends StatelessWidget {
  final String currentUid;
  final String currentUserName;
  final Map<String, dynamic> currentUserData;

  const _StudentChats({
    required this.currentUid,
    required this.currentUserName,
    required this.currentUserData,
  });

  @override
  Widget build(BuildContext context) {
    final facultyId = (currentUserData['facultyId'] ?? '').toString().trim();
    final mentorId = (currentUserData['companyMentorId'] ?? '').toString().trim();
    final groupId = (currentUserData['assignedGroupId'] ?? '').toString().trim();

    if (groupId.isEmpty) {
      return const _EmptyState(
        icon: Icons.groups_outlined,
        title: 'No group assigned',
        message: 'Assign the student to a group before opening channel chats.',
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
      builder: (context, groupSnapshot) {
        if (groupSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupData = groupSnapshot.data?.data() ?? <String, dynamic>{};
        final groupName = (groupData['groupName'] ??
                currentUserData['assignedGroupName'] ??
                'Project Group')
            .toString()
            .trim();
        final studentIds = List<String>.from(groupData['studentIds'] ?? [currentUid]);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('user')
              .where('role', isEqualTo: 'faculty')
              .where('facultyId', isEqualTo: facultyId)
              .limit(1)
              .snapshots(),
          builder: (context, facultySnapshot) {
            final facultyDoc = facultySnapshot.data?.docs.isNotEmpty == true
                ? facultySnapshot.data!.docs.first
                : null;
            final facultyUid = facultyDoc?.id ?? '';

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('role', isEqualTo: 'mentor')
                  .where('mentorId', isEqualTo: mentorId)
                  .limit(1)
                  .snapshots(),
              builder: (context, mentorSnapshot) {
                final mentorDoc = mentorSnapshot.data?.docs.isNotEmpty == true
                    ? mentorSnapshot.data!.docs.first
                    : null;
                final mentorUid = mentorDoc?.id ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Group Channels'),
                    const SizedBox(height: 12),
                    _GroupChatTile(
                      currentUid: currentUid,
                      chatId: groupId,
                      infoId: groupId,
                      title: 'Project Group',
                      subtitle: groupName,
                      currentUserName: currentUserName,
                      emptyMessage: 'No project group found.',
                      participantIds: studentIds,
                      accentColor: const Color(0xFF7C3AED),
                    ),
                    const SizedBox(height: 12),
                    _GroupChatTile(
                      currentUid: currentUid,
                      chatId: _academicChatId(facultyId, groupId),
                      infoId: groupId,
                      title: 'Academic Channel',
                      subtitle: groupName,
                      currentUserName: currentUserName,
                      emptyMessage: 'No faculty mentor assigned yet.',
                      participantIds: [
                        ...studentIds,
                        if (facultyUid.isNotEmpty) facultyUid,
                      ],
                      accentColor: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    _GroupChatTile(
                      currentUid: currentUid,
                      chatId: _industryChatId(mentorId, groupId),
                      infoId: groupId,
                      title: 'Industry Channel',
                      subtitle: groupName,
                      currentUserName: currentUserName,
                      emptyMessage: 'No company mentor assigned yet.',
                      participantIds: [
                        ...studentIds,
                        if (mentorUid.isNotEmpty) mentorUid,
                      ],
                      accentColor: const Color(0xFF0F766E),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FacultyChats extends StatelessWidget {
  final String currentUid;
  final String currentUserName;
  final Map<String, dynamic> currentUserData;

  const _FacultyChats({
    required this.currentUid,
    required this.currentUserName,
    required this.currentUserData,
  });

  @override
  Widget build(BuildContext context) {
    final facultyId = (currentUserData['facultyId'] ?? '').toString().trim();

    if (facultyId.isEmpty) {
      return const _EmptyState(
        icon: Icons.badge_outlined,
        title: 'Faculty ID missing',
        message: 'Add your faculty ID in profile settings to load assigned chats.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .where('facultyId', isEqualTo: facultyId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final studentDocs = snapshot.data?.docs ?? [];
        final channels = _buildAcademicChannels(
          facultyId: facultyId,
          facultyUid: currentUid,
          studentDocs: studentDocs,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeopleSection(
              title: 'Students',
              emptyMessage: 'No students are linked to your faculty ID yet.',
              children: studentDocs
                  .map(
                    (studentDoc) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DirectChatTile(
                        currentUid: currentUid,
                        currentUserName: currentUserName,
                        otherUid: studentDoc.id,
                        title: _displayName(studentDoc.data(), fallback: 'Student'),
                        subtitle: 'Individual student chat',
                        imageUrl: (studentDoc.data()['profileImageUrl'] ?? '').toString(),
                        icon: Icons.person_rounded,
                        accentColor: const Color(0xFF2563EB),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            _PeopleSection(
              title: 'Academic Channels',
              emptyMessage: 'No academic channels are linked to your assigned groups yet.',
              children: channels
                  .map(
                    (channel) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GroupChatTile(
                        currentUid: currentUid,
                        chatId: channel.chatId,
                        infoId: channel.groupId,
                        title: 'Academic Channel',
                        subtitle: channel.groupName,
                        currentUserName: currentUserName,
                        emptyMessage: 'No channel available.',
                        participantIds: channel.participantIds,
                        accentColor: const Color(0xFF2563EB),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _MentorChats extends StatelessWidget {
  final String currentUid;
  final String currentUserName;
  final Map<String, dynamic> currentUserData;

  const _MentorChats({
    required this.currentUid,
    required this.currentUserName,
    required this.currentUserData,
  });

  @override
  Widget build(BuildContext context) {
    final mentorId = (currentUserData['mentorId'] ?? '').toString().trim();

    if (mentorId.isEmpty) {
      return const _EmptyState(
        icon: Icons.badge_outlined,
        title: 'Mentor ID missing',
        message: 'Add your mentor ID in profile settings to load assigned chats.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .where('companyMentorId', isEqualTo: mentorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final studentDocs = snapshot.data?.docs ?? [];
        final channels = _buildIndustryChannels(
          mentorId: mentorId,
          mentorUid: currentUid,
          studentDocs: studentDocs,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeopleSection(
              title: 'Students',
              emptyMessage: 'No students are linked to your mentor ID yet.',
              children: studentDocs
                  .map(
                    (studentDoc) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DirectChatTile(
                        currentUid: currentUid,
                        currentUserName: currentUserName,
                        otherUid: studentDoc.id,
                        title: _displayName(studentDoc.data(), fallback: 'Student'),
                        subtitle: 'Individual student chat',
                        imageUrl: (studentDoc.data()['profileImageUrl'] ?? '').toString(),
                        icon: Icons.person_rounded,
                        accentColor: const Color(0xFF0F766E),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            _PeopleSection(
              title: 'Industry Channels',
              emptyMessage: 'No industry channels are linked to your assigned groups yet.',
              children: channels
                  .map(
                    (channel) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GroupChatTile(
                        currentUid: currentUid,
                        chatId: channel.chatId,
                        infoId: channel.groupId,
                        title: 'Industry Channel',
                        subtitle: channel.groupName,
                        currentUserName: currentUserName,
                        emptyMessage: 'No channel available.',
                        participantIds: channel.participantIds,
                        accentColor: const Color(0xFF0F766E),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _UserLookupTile extends StatelessWidget {
  final String role;
  final String lookupField;
  final String lookupValue;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData icon;
  final Color accentColor;
  final String currentUid;
  final String currentUserName;

  const _UserLookupTile({
    required this.role,
    required this.lookupField,
    required this.lookupValue,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.icon,
    required this.accentColor,
    required this.currentUid,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    if (lookupValue.isEmpty) {
      return _DisabledChatCard(
        title: emptyTitle,
        subtitle: emptySubtitle,
        icon: icon,
        accentColor: accentColor,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: role)
          .where(lookupField, isEqualTo: lookupValue)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingChatCard();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _DisabledChatCard(
            title: emptyTitle,
            subtitle: emptySubtitle,
            icon: icon,
            accentColor: accentColor,
          );
        }

        final otherDoc = snapshot.data!.docs.first;
        final otherData = otherDoc.data();

        return _DirectChatTile(
          currentUid: currentUid,
          currentUserName: currentUserName,
          otherUid: otherDoc.id,
          title: _displayName(otherData, fallback: emptyTitle),
          subtitle: emptyTitle,
          imageUrl: (otherData['profileImageUrl'] ?? '').toString(),
          icon: icon,
          accentColor: accentColor,
        );
      },
    );
  }
}

class _DirectChatTile extends StatelessWidget {
  final String currentUid;
  final String currentUserName;
  final String otherUid;
  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData icon;
  final Color accentColor;

  const _DirectChatTile({
    required this.currentUid,
    required this.currentUserName,
    required this.otherUid,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final chatId = ChatListScreen.getDirectChatId(currentUid, otherUid);

    return _ChatPreviewTile(
      currentUid: currentUid,
      chatId: chatId,
      title: title,
      fallbackSubtitle: subtitle,
      imageUrl: imageUrl,
      icon: icon,
      accentColor: accentColor,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              chatTitle: title,
              isGroup: false,
              currentUserName: currentUserName,
              chatImageUrl: imageUrl,
              infoId: otherUid,
              participantIds: [currentUid, otherUid],
              participantNames: [currentUserName, title],
            ),
          ),
        );
      },
    );
  }
}

class _GroupChatTile extends StatelessWidget {
  final String currentUid;
  final String chatId;
  final String infoId;
  final String title;
  final String subtitle;
  final String currentUserName;
  final String emptyMessage;
  final List<String> participantIds;
  final Color accentColor;

  const _GroupChatTile({
    required this.currentUid,
    required this.chatId,
    required this.infoId,
    required this.title,
    required this.subtitle,
    required this.currentUserName,
    required this.emptyMessage,
    this.participantIds = const [],
    this.accentColor = const Color(0xFF7C3AED),
  });

  @override
  Widget build(BuildContext context) {
    if (chatId.isEmpty) {
      return _DisabledChatCard(
        title: title,
        subtitle: emptyMessage,
        icon: Icons.groups_rounded,
        accentColor: accentColor,
      );
    }

    return _ChatPreviewTile(
      currentUid: currentUid,
      chatId: chatId,
      title: title,
      fallbackSubtitle: subtitle,
      imageUrl: '',
      icon: Icons.groups_rounded,
      accentColor: accentColor,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              chatTitle: title,
              isGroup: true,
              currentUserName: currentUserName,
              chatImageUrl: '',
              infoId: infoId,
              participantIds: participantIds,
            ),
          ),
        );
      },
    );
  }
}

class _ChatPreviewTile extends StatelessWidget {
  final String currentUid;
  final String chatId;
  final String title;
  final String fallbackSubtitle;
  final String imageUrl;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _ChatPreviewTile({
    required this.currentUid,
    required this.chatId,
    required this.title,
    required this.fallbackSubtitle,
    required this.imageUrl,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('chats').doc(chatId).snapshots(),
      builder: (context, snapshot) {
        final chatData = snapshot.data?.data();
        final lastMessage = (chatData?['lastMessage'] ?? '').toString().trim();
        final lastUpdated = chatData?['lastUpdated'];
        final unreadMap = Map<String, dynamic>.from(chatData?['unreadCounts'] ?? const {});
        final unreadCount = currentUid.isEmpty
            ? 0
            : ((unreadMap[currentUid] as num?)?.toInt() ?? 0);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F0F172A),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _ChatAvatar(
                    title: title,
                    imageUrl: imageUrl,
                    icon: icon,
                    accentColor: accentColor,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lastMessage.isEmpty ? fallbackSubtitle : lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: lastMessage.isEmpty
                                ? const Color(0xFF64748B)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(lastUpdated),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (unreadCount > 0)
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 26,
                            minHeight: 26,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: accentColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  final String title;
  final String imageUrl;
  final IconData icon;
  final Color accentColor;

  const _ChatAvatar({
    required this.title,
    required this.imageUrl,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(radius: 26, backgroundImage: NetworkImage(imageUrl));
    }

    return CircleAvatar(
      radius: 26,
      backgroundColor: accentColor.withOpacity(0.12),
      child: title.isNotEmpty
          ? Text(
              title[0].toUpperCase(),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            )
          : Icon(icon, color: accentColor),
    );
  }
}

class _PeopleSection extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<Widget> children;

  const _PeopleSection({
    required this.title,
    required this.emptyMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        const SizedBox(height: 12),
        if (children.isEmpty)
          _EmptySectionCard(message: emptyMessage)
        else
          ...children,
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF16324F), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Realtime Firestore chat',
            style: TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 12,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFE0F2FE),
              fontSize: 13.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
  }
}

class _LoadingChatCard extends StatelessWidget {
  const _LoadingChatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DisabledChatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _DisabledChatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: accentColor.withOpacity(0.12),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  final String message;

  const _EmptySectionCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFDBEAFE),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSummary {
  final String id;
  final String name;

  const _GroupSummary({required this.id, required this.name});
}

class _ChannelSummary {
  final String chatId;
  final String groupId;
  final String groupName;
  final List<String> participantIds;

  const _ChannelSummary({
    required this.chatId,
    required this.groupId,
    required this.groupName,
    required this.participantIds,
  });
}

List<_GroupSummary> _extractGroups(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
  final groups = <String, _GroupSummary>{};

  for (final doc in docs) {
    final data = doc.data();
    final id = (data['assignedGroupId'] ?? '').toString().trim();
    if (id.isEmpty) {
      continue;
    }

    final name = (data['assignedGroupName'] ?? '').toString().trim();
    groups[id] = _GroupSummary(
      id: id,
      name: name.isEmpty ? 'Group $id' : name,
    );
  }

  return groups.values.toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

String _displayName(Map<String, dynamic> data, {required String fallback}) {
  final fullName = (data['fullName'] ?? data['name'] ?? '').toString().trim();
  return fullName.isEmpty ? fallback : fullName;
}

String _academicChatId(String facultyId, String groupId) {
  return 'academic_${facultyId}_$groupId';
}

String _industryChatId(String mentorId, String groupId) {
  return 'industry_${mentorId}_$groupId';
}

List<_ChannelSummary> _buildAcademicChannels({
  required String facultyId,
  required String facultyUid,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> studentDocs,
}) {
  final channels = <String, _ChannelSummary>{};

  for (final studentDoc in studentDocs) {
    final data = studentDoc.data();
    final groupId = (data['assignedGroupId'] ?? '').toString().trim();
    if (groupId.isEmpty) {
      continue;
    }

    final groupName = (data['assignedGroupName'] ?? '').toString().trim();
    final chatId = _academicChatId(facultyId, groupId);
    final existing = channels[chatId];
    final participantIds = <String>{
      ...?existing?.participantIds,
      studentDoc.id,
      facultyUid,
    }..removeWhere((id) => id.trim().isEmpty);

    channels[chatId] = _ChannelSummary(
      chatId: chatId,
      groupId: groupId,
      groupName: groupName.isEmpty ? 'Group $groupId' : groupName,
      participantIds: participantIds.toList(),
    );
  }

  return channels.values.toList()
    ..sort((a, b) => a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()));
}

List<_ChannelSummary> _buildIndustryChannels({
  required String mentorId,
  required String mentorUid,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> studentDocs,
}) {
  final channels = <String, _ChannelSummary>{};

  for (final studentDoc in studentDocs) {
    final data = studentDoc.data();
    final groupId = (data['assignedGroupId'] ?? '').toString().trim();
    if (groupId.isEmpty) {
      continue;
    }

    final groupName = (data['assignedGroupName'] ?? '').toString().trim();
    final chatId = _industryChatId(mentorId, groupId);
    final existing = channels[chatId];
    final participantIds = <String>{
      ...?existing?.participantIds,
      studentDoc.id,
      mentorUid,
    }..removeWhere((id) => id.trim().isEmpty);

    channels[chatId] = _ChannelSummary(
      chatId: chatId,
      groupId: groupId,
      groupName: groupName.isEmpty ? 'Group $groupId' : groupName,
      participantIds: participantIds.toList(),
    );
  }

  return channels.values.toList()
    ..sort((a, b) => a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()));
}

String _formatTime(dynamic value) {
  if (value is! Timestamp) {
    return '';
  }

  final date = value.toDate();
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;

  return isToday ? DateFormat('hh:mm a').format(date) : DateFormat('dd MMM').format(date);
}

String _roleSubtitle(String role) {
  switch (role) {
    case 'student':
      return 'Message your faculty mentor, company mentor, and assigned group.';
    case 'faculty':
      return 'Track student conversations and reach shared company mentors quickly.';
    case 'mentor':
      return 'Stay in touch with assigned students and their active groups.';
    default:
      return 'Role-based chat access powered by Firestore streams.';
  }
}
