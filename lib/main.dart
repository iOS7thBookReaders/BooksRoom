// ignore_for_file: avoid_print

import 'package:books_room/providers/book_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:books_room/screens/login_screen.dart';
import 'package:books_room/screens/root_tab.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (_) => BookProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _handleCurrentScreen(),
    );
  }

  // 로그인 상태에 따라 시작 화면 결정
  Widget _handleCurrentScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 로그인된 상태면 RootTab으로, 아니면 LoginScreen으로
        if (snapshot.hasData && snapshot.data != null) {
          print('자동로그인: ${snapshot.data!.email}');
          return const RootTab();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
