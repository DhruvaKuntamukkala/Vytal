import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/reminders_page.dart';
import 'screens/profile_page.dart';
import 'screens/medicine_info_page.dart';
import 'screens/calendar_page.dart';
import 'screens/home_page.dart';
import 'screens/splash_screen.dart';
import 'screens/dietplan_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const VytalApp(),
    ),
  );
}

class VytalApp extends StatelessWidget {
  const VytalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Vytal',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: themeNotifier.isDarkMode
                ? Brightness.dark
                : Brightness.light,
            scaffoldBackgroundColor: themeNotifier.isDarkMode
                ? Colors.black
                : Colors.white,
            fontFamily: 'Poppins',
            appBarTheme: AppBarTheme(
              backgroundColor: themeNotifier.isDarkMode
                  ? Colors.tealAccent
                  : Colors.teal,
              foregroundColor: themeNotifier.isDarkMode
                  ? Colors.black
                  : Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: themeNotifier.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[200],
              border: const OutlineInputBorder(),
            ),
          ),
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => StrokeSplashScreen(),
            '/login': (_) =>
                const LoginPage(), // Light/dark toggle skipped here
            '/signup': (_) =>
                const SignUpPage(), // Light/dark toggle skipped here
            '/reminders': (_) => const RemindersPage(),
            '/medicine_info': (_) => const MedicineInfoPage(),
            '/calendar': (_) => const CalendarPage(),
            '/dietplan': (_) => const DietPlanPage(),
            '/home': (_) => const HomePage(name: '', email: ''),
            '/profile': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map?;
              final name = args?['name'] ?? 'Unknown';
              final email = args?['email'] ?? 'unknown@example.com';
              return ProfilePage(name: name, email: email);
            },
          },
        );
      },
    );
  }
}
