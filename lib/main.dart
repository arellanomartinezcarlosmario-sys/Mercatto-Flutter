import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MercattoApp());

class MercattoApp extends StatelessWidget {
  const MercattoApp({super.key});
  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE53935);
    return MaterialApp(
      title: 'Mercatto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: red, primary: red),
        scaffoldBackgroundColor: const Color(0xFFF7F7F8),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        cardTheme: CardThemeData(color: Colors.white, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
      home: const HomeScreen(),
    );
  }
}
