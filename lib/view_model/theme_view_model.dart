import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeApp extends ChangeNotifier {
  ThemeData currentTheme = lightTheme;
  String currentThemeName = '';

  Future<void> changeTheme() async {
    if (currentThemeName == 'Light') {
      currentTheme = darkTheme;
      currentThemeName = 'Dark';
    } else {
      currentTheme = lightTheme;
      currentThemeName = 'Light';
    }
    notifyListeners();
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xFF5865F2),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF5865F2),
      onPrimary: Colors.white,
      secondary: const Color(0xFF747F8D),
      onSecondary: Colors.white,
      surface: const Color(0xFFF2F3F5),
      onSurface: const Color(0xFF2E3338),
      error: const Color(0xFFED4245),
      onError: Colors.white,
      surfaceContainerHighest: const Color(0xFFE3E5E8),
      onSurfaceVariant: const Color(0xFF4F5660),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF2F3F5),
      foregroundColor: const Color(0xFF060607),
      elevation: 0.5,
      titleTextStyle: const TextStyle(
        color: Color(0xFF060607),
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF4F5660)),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side:
            const BorderSide(color: Color(0xFFE3E5E8), width: 1), // Borda sutil
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    ),
    listTileTheme: ListTileThemeData(
      tileColor:
          Colors.transparent, // ListTile transparente para usar cor do pai
      selectedTileColor: const Color(0xFFE0E1E5), // Cor de seleção sutil
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFFE3E5E8), // Divisores cinza claro
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF5865F2),
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE3E5E8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Color(0xFF5865F2), width: 1),
      ),
      labelStyle: const TextStyle(color: Color(0xFF4F5660)),
      hintStyle: const TextStyle(color: Color(0xFF747F8D)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF060607),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5865F2), // Botão primário azul Discord
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFFF2F3F5),
      selectedItemColor: const Color(0xFF060607),
      unselectedItemColor: const Color(0xFF4F5660),
      elevation: 0.5,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: const Color(0xFFF2F3F5),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    primaryColor: const Color(0xFF5865F2),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF5865F2),
      onPrimary: Colors.grey[900]!,
      secondary: const Color(0xFF747F8D),
      onSecondary: Colors.grey[900]!,
      surface: const Color(0xFFF2F3F5),
      onSurface: const Color(0xFF2E3338),
      error: const Color(0xFFED4245),
      onError: Colors.white,
      surfaceContainerHighest: const Color(0xFFE3E5E8),
      onSurfaceVariant: const Color(0xFF4F5660),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF2F3F5),
      foregroundColor: const Color(0xFF060607),
      elevation: 0.5,
      titleTextStyle: const TextStyle(
        color: CupertinoColors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF4F5660)),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFFE3E5E8), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: const Color(0xFFE0E1E5),
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFFE3E5E8),
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF5865F2),
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE3E5E8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Color(0xFF5865F2), width: 1),
      ),
      labelStyle: const TextStyle(color: Color(0xFF4F5660)),
      hintStyle: const TextStyle(color: Color(0xFF747F8D)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF060607),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5865F2), // Botão primário azul Discord
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFFF2F3F5),
      selectedItemColor: const Color(0xFF060607),
      unselectedItemColor: const Color(0xFF4F5660),
      elevation: 0.5,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: const Color(0xFFF2F3F5),
    ),
  );
}
