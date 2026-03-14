import 'package:flutter/material.dart';

class InternTile extends StatelessWidget {
  final String name;
  final String? profileImageUrl;

  const InternTile({
    super.key,
    required this.name,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = (profileImageUrl ?? '').toString();
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
