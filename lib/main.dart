import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/app/theme/app_theme.dart';
import 'package:social_chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:social_chat_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:social_chat_app/features/home/presentation/screens/home_screen.dart';
import 'package:social_chat_app/features/test/presentation/screens/test_connection_screen.dart'; // ADD THIS

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const TestConnectionScreen(), // CHANGE TO TEST SCREEN
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/test': (context) => const TestConnectionScreen(), // ADD THIS
      },
    );
  }
}