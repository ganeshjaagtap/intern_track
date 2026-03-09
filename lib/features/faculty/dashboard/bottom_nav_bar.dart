import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/chat/screens/chat_selection_screen.dart';

class FacultyBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const FacultyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.dashboard,
                  label: "Home",
                  active: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
                _navItem(
                  icon: Icons.group,
                  label: "Groups",
                  active: currentIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
                const SizedBox(width: 60),
                _navItem(
                  icon: Icons.calendar_month_outlined,
                  label: "Calendar",
                  active: currentIndex == 2,
                  onTap: () => onTabSelected(2),
                ),
                _navItem(
                  icon: Icons.person_outline,
                  label: "Profile",
                  active: currentIndex == 3,
                  onTap: () => onTabSelected(3),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatSelectionScreen(),
                  ),
                );
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.blue, width: 4),
                ),
                child: const Icon(Icons.chat, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}