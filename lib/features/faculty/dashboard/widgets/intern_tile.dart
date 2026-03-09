import 'package:flutter/material.dart';

class InternTile extends StatelessWidget {
  final String name;

  const InternTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
