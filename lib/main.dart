import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/expense_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/expense_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        title: 'Daily Expense Tracker',
        themeMode: ThemeMode.system,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const DashboardScreen(),
      ),
    );
  }
}

class AppTheme {
  static const Color primary = Color(0xFFE91E63);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8FB),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 1,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primary,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 1,
        ),
      );
}
