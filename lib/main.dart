import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFE0E0E0),
              foregroundColor: Colors.black,
              elevation: 4,
              shadowColor: Color(0x55000000),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFFE0E0E0),
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.grey,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF181A20),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF22232A),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Color(0x99000000),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF22232A),
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.grey,
            ),
          ),
          themeMode: mode,
          home: SplashScreen(),
        );
      },
    );
  }
}

class HomeScreenWithThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            title: const Text(
              'PotaKu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(themeNotifier.value == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                tooltip: themeNotifier.value == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  themeNotifier.value = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
            ],
          ),
        ),
      ),
      body: const HomeScreen(),
    );
  }
}