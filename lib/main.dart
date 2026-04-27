import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'providers/expense_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    // Keep the native splash screen until our custom animation is ready to take over
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    
    await Firebase.initializeApp();
    
    runApp(const ExpenseApp());
  } catch (e) {
    debugPrint('Initialization error: $e');
    runApp(const ExpenseApp());
  }
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Moniqo',
        themeMode: ThemeMode.dark, 
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}

class AppTheme {
  static const Color primary = Color(0xFF64DD17); // Vibrant Green
  static const Color darkBackground = Color(0xFF061A12); // Deep Dark Green
  static const Color darkSurface = Color(0xFF0B2F1F); // Surface Green (Cards)

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: primary,
          onPrimary: Colors.black,
          secondary: primary,
          surface: darkSurface,
          onSurface: Colors.white,
          error: Colors.redAccent,
          onSurfaceVariant: Colors.white70,
        ),
        scaffoldBackgroundColor: darkBackground,
        canvasColor: darkBackground,
        cardColor: darkSurface,
        dividerColor: Colors.white10,
        
        // Universal AppBar (Dashboard style)
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white, 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Universal Card style (Dashboard style)
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Colors.white10, width: 1),
          ),
        ),

        // Universal Input style (Login/Signup style)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),

        // Universal Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
        ),
        
        // Elevated Button style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        iconTheme: const IconThemeData(color: primary),
      );

  static ThemeData get light => dark;
}
