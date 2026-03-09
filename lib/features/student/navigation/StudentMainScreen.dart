import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/chat/screens/chat_selection_screen.dart';

import '../dashboard/StudentDashboardScreen.dart';
import '../attendance/AttendanceScreen.dart';
import '../reports/ReportScreen.dart';
import '../profile/SettingsScreen.dart';

class StudentMainScreen extends StatefulWidget {
const StudentMainScreen({super.key});

@override
State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
int currentIndex = 0;

final List<Widget> screens = const [
StudentDashboardScreen(),
AttendanceScreen(),
ReportScreen(),
SettingsScreen(),
];

void changeTab(int index) {
setState(() {
currentIndex = index;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
resizeToAvoidBottomInset: false,


  body: IndexedStack(
    index: currentIndex,
    children: screens,
  ),

  bottomNavigationBar: _CustomBottomNav(
    currentIndex: currentIndex,
    onTabSelected: changeTab,
  ),
);


}
}

////////////////////////////////////////////////////////////
/// CUSTOM BOTTOM NAV
////////////////////////////////////////////////////////////
class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const _CustomBottomNav({
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
          /// FIX: Added Positioned to strictly bind the width to the edges of the screen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _navItem(
                      icon: Icons.home,
                      label: "Home",
                      active: currentIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),
                  ),
                  Expanded(
                    child: _navItem(
                      icon: Icons.check_circle_outline,
                      label: "Attendance",
                      active: currentIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  
                  const SizedBox(width: 60), // Spacer for the center button
                  
                  Expanded(
                    child: _navItem(
                      icon: Icons.description,
                      label: "Report",
                      active: currentIndex == 2,
                      onTap: () => onTabSelected(2),
                    ),
                  ),
                  Expanded(
                    child: _navItem(
                      icon: Icons.settings,
                      label: "Settings",
                      active: currentIndex == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// FLOATING CHAT BUTTON (Remains at the top center of the Stack)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatSelectionScreen()));
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.blue, width: 4),
                ),
                child: const Icon(
                  Icons.chat_sharp,
                  color: Colors.blue,
                  size: 30,
                ),
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
      behavior: HitTestBehavior.opaque, // Ensures the whole area is clickable
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.blue : Colors.grey,
            ),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
