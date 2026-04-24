import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'providers/expense_provider.dart';
import 'screens/splash_screen.dart';
import 'services/expense_database.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  await ExpenseDatabase.instance.init();
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..loadTransactions(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Moniqo',
        themeMode: ThemeMode.dark, 
        theme: AppTheme.dark, // Use dark as light for consistency if desired, or keep as is
        darkTheme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}

class AppTheme {
  static const Color primary = Color(0xFF64DD17); // Vibrant Green from Splash
  static const Color darkBackground = Color(0xFF061A12); // Deep Dark Green
  static const Color darkSurface = Color(0xFF0B2F1F); // Surface Green

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: primary,
          surface: darkSurface,
          onSurface: Colors.white,
          // ignore: deprecated_member_use
          background: darkBackground,
          // ignore: deprecated_member_use
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkSurface,
        dividerColor: Colors.white10,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
        ),
      );

  // Fallback for light theme to avoid crashes if triggered, but styled similarly
  static ThemeData get light => dark;
}
