import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/core/notifications/push_notification_service.dart';
import 'package:flutter_application_2/core/utils/mentor_emails.dart';
import 'package:flutter_application_2/features/HOD/layout/hod_main_layout.dart';
import 'package:flutter_application_2/features/company_mentor/dashboard/CompanyMentorDashboardScreen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/faculty_dashboard_screen.dart';
import 'package:flutter_application_2/features/principal/dashboard/principal_dashboard_screen.dart';
import 'package:flutter_application_2/features/student/auth/Main_Login.dart';
import 'package:flutter_application_2/features/student/navigation/StudentMainScreen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intern Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('user').doc(user.uid).get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                final data = roleSnapshot.data!.data() as Map<String, dynamic>;
                final role =
                    (data['role'] ?? 'student').toString().trim().toLowerCase();
                final email = (user.email ?? '').trim().toLowerCase();

                if (mentorEmails.contains(email) || role == 'hod') {
                  return const HodMainLayout();
                }
                if (role == 'mentor') {
                  return const CompanyMentorDashboardScreen();
                }
                if (role == 'faculty') {
                  return const FacultyDashboardScreen();
                }
                if (role == 'principal') {
                  return const PrincipalDashboardScreen();
                }
                if (role == 'student') {
                  return const StudentMainScreen();
                }

                return const LoginScreen();
              }

              return const LoginScreen();
            },
          );
        },
      ),
    );
  }
}
