import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeService extends GetxService {
  final _box = GetStorage();
  final _key = 'themeColor';
  
  final Rx<Color> primaryColor = const Color(0xFF2196F3).obs; // Default blue
  
  // Available theme colors
  static const Map<String, Color> themeColors = {
    'Blue': Color(0xFF2196F3),
    'Purple': Color(0xFF9C27B0),
    'Green': Color(0xFF4CAF50),
    'Pink': Color(0xFFE91E63),
    'Teal': Color(0xFF009688),
    'Orange': Color(0xFFFF9800),
    'Indigo': Color(0xFF3F51B5),
  };
  
  Future<ThemeService> init() async {
    await GetStorage.init();
    _loadTheme();
    return this;
  }
  
  void _loadTheme() {
    final savedColor = _box.read<int>(_key);
    if (savedColor != null) {
      primaryColor.value = Color(savedColor);
    }
  }
  
  void setThemeColor(Color color) {
    primaryColor.value = color;
    _box.write(_key, color.value);
  }
  
  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: _createMaterialColor(primaryColor.value),
      primaryColor: primaryColor.value,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor.value,
        secondary: primaryColor.value,
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor.value,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: primaryColor.value,
        secondary: primaryColor.value,
        surface: const Color(0xFF424242),
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white, 
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
  
  String getColorName(Color color) {
    for (var entry in themeColors.entries) {
      if (entry.value.value == color.value) {
        return entry.key;
      }
    }
    return 'Custom';
  }
}
