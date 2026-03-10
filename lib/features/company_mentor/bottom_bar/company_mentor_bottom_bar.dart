import 'package:flutter/material.dart';

import '../dashboard/CompanyMentorDashboardScreen.dart';
import '../interns_screen/CompanyMentorInternsScreen.dart';
import '../settings/CompanyMentorSettingsScreen.dart';
import '../chat/CompanyMentorChat.dart';
import '../attendance/CompanyMentorAttendanceScreen.dart';

class CompanyMentorBottomBar extends StatelessWidget {

  final int currentIndex;

  const CompanyMentorBottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 72,

      child: Stack(
        alignment: Alignment.center,

        children: [

          //////////////////////////////////////////////////////
          /// BOTTOM BAR BACKGROUND
          //////////////////////////////////////////////////////

          Container(
            height: 56,

            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [

                //////////////////////////////////////////////////////
                /// HOME
                //////////////////////////////////////////////////////

                _navItem(
                  context,
                  icon: Icons.dashboard,
                  label: "Home",
                  active: currentIndex == 0,
                  screen: const CompanyMentorDashboardScreen(),
                ),

                //////////////////////////////////////////////////////
                /// INTERNS
                //////////////////////////////////////////////////////

                _navItem(
                  context,
                  icon: Icons.people,
                  label: "Interns",
                  active: currentIndex == 1,
                  screen: const CompanyMentorInternsScreen(),
                ),

                const SizedBox(width: 60),

                //////////////////////////////////////////////////////
                /// ATTENDANCE (REPLACED REPORTS)
                //////////////////////////////////////////////////////

                _navItem(
                  context,
                  icon: Icons.fact_check,
                  label: "Attendance",
                  active: currentIndex == 2,
                  screen: const CompanyMentorAttendanceScreen(),
                ),

                //////////////////////////////////////////////////////
                /// SETTINGS
                //////////////////////////////////////////////////////

                _navItem(
                  context,
                  icon: Icons.settings,
                  label: "Settings",
                  active: currentIndex == 3,
                  screen: const CompanyMentorSettingsScreen(),
                ),
              ],
            ),
          ),

          //////////////////////////////////////////////////////
          /// FLOATING CHAT BUTTON
          //////////////////////////////////////////////////////

          Positioned(
            top: 0,

            child: GestureDetector(

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompanyMentorChat(),
                  ),
                );

              },

              child: Container(
                width: 64,
                height: 64,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,

                  border: Border.all(
                    color: Colors.blue,
                    width: 4,
                  ),
                ),

                child: const Icon(
                  Icons.chat_bubble_outline,
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

  //////////////////////////////////////////////////////
  /// NAV ITEM WIDGET
  //////////////////////////////////////////////////////

  Widget _navItem(
    BuildContext context, {

    required IconData icon,
    required String label,
    required bool active,
    required Widget screen,

  }) {

    return GestureDetector(

      onTap: () {

        if (!active) {

          Navigator.pushReplacement(
            context,

            PageRouteBuilder(
              pageBuilder: (_, __, ___) => screen,
              transitionDuration: Duration.zero,
            ),
          );

        }

      },

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: active ? Colors.blue : Colors.grey,
          ),

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