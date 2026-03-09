import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for role check
import 'package:flutter_application_2/features/student/dashboard/StudentDashboardScreen.dart';
import 'package:flutter_application_2/university_mentor/layout/mentor_main_layout.dart';
import 'firebase_options.dart';
import 'package:flutter_application_2/features/student/auth/Main_Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          // 1. Wait for Firebase Auth to initialize
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final User? user = snapshot.data;

          // 2. If no user is logged in, send to Login Screen
          if (user == null) {
            return const LoginScreen();
          }

          // 3. User is logged in, now fetch their role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('user').doc(user.uid).get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                final data = roleSnapshot.data!.data() as Map<String, dynamic>;
String role = data['role'] ?? 'student';

if (role == 'mentor') {
  return const MentorMainLayout();
} else {
  return const StudentDashboardScreen();
}
              }

              // 4. Fallback: If document doesn't exist, log them out and show login
              return const LoginScreen();
            },
          );
        },
      ),
    );
  }
}