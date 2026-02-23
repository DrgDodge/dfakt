import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'providers/app_provider.dart';
import 'services/sync_service.dart';
import 'screens/home_screen.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => SyncService()),
      ],
      child: const MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatefulWidget {
  const MaterialAppWithTheme({super.key});

  @override
  State<MaterialAppWithTheme> createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
   @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleLaunch);
      HomeWidget.widgetClicked.listen(_handleLaunch);
    }
  }

  void _handleLaunch(Uri? uri) {
    if (uri == null) return;
    if (uri.host == 'categories') {
       Provider.of<AppProvider>(context, listen: false).requestJumpToCategories();
    } else if (uri.host == 'task') {
       final catId = int.tryParse(uri.queryParameters['categoryId'] ?? '');
       final remId = int.tryParse(uri.queryParameters['reminderId'] ?? '');
       if (catId != null && remId != null) {
          Provider.of<AppProvider>(context, listen: false).requestJumpToReminder(catId, remId);
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'DFakt',
        theme: _buildTheme(),
        home: const HomeScreen(),
      );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF80CBC4), // Pastel Turquoise
        secondary: Color(0xFF4DB6AC),
        surface: Color(0xFF1E1E1E),
        onPrimary: Colors.black,
        onSurface: Color(0xFFEEEEEE),
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFEEEEEE),
        displayColor: const Color(0xFFEEEEEE),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.bungee(
          fontSize: 24, 
          color: const Color(0xFF80CBC4) 
        ),
        iconTheme: const IconThemeData(color: Color(0xFF80CBC4)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E), // Slightly lighter than background
        selectedItemColor: Color(0xFF80CBC4),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF80CBC4),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFFEEEEEE),
        iconColor: Color(0xFFB0BEC5),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        textColor: Color(0xFF80CBC4),
        iconColor: Color(0xFF80CBC4),
        collapsedTextColor: Color(0xFFEEEEEE),
        collapsedIconColor: Color(0xFFB0BEC5),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.outfit(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
      )
    );
  }
}