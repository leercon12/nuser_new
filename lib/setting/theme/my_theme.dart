import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode');
    if (savedThemeMode != null) {
      themeMode = _themeModeFromString(savedThemeMode);
      notifyListeners();
    }
  }

  setThemeMode(ThemeMode newThemeMode) {
    themeMode = newThemeMode;
    saveThemeModePrefs(themeMode.toString().replaceAll("ThemeMode.", ""));
    notifyListeners();
  }

  saveThemeModePrefs(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("themeMode", value);
  }

  // Helper function to convert string to ThemeMode
  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}

class MyThemes {
  static final lightTheme = ThemeData().copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: kGreenFontColor,
      background: Color(0xffF3F3F3),
    ),
    primaryColor: Colors.grey[900],
    tabBarTheme: TabBarTheme(dividerColor: Colors.transparent),
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, scrolledUnderElevation: 0),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    cardColor: Colors.white,
    scaffoldBackgroundColor: const Color(0xffF3F3F3),

    // backgroundColor: Colors.white,
  );

  static final darkTheme = ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        background: Color(0xff101012),
        primary: kGreenFontColor,
      ),
      tabBarTheme: TabBarTheme(dividerColor: Colors.transparent),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: const Color(0xff262627),
      cardColor: Colors.grey[900],
      scaffoldBackgroundColor: const Color(0xff101012),
      appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xff101012), scrolledUnderElevation: 0)

      //backgroundColor: Colors.grey[900],
      );
}

/* ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(background: Colors.grey.shade400),
  primaryColor: Colors.grey.shade300,
  backgroundColor: Colors.white,
);

ThemeData dartMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.light(background: Colors.grey.shade900),
  primaryColor: Colors.grey.shade800,
  backgroundColor: Colors.grey[900],
); */

// light mode

const kLightBackground = Color(0xFFFFFFFF);
const kLightFontColor = Color(0xFF000000);
var kLightFontColorWith60 = const Color(0xFF000000).withOpacity(0.6);

const kLightGreenAssetBackground = Color(0xFFDCFFE9);

// dark mode

const kDarkBackground = Color(0xFF212121);
const kDarkBackground2 = Color(0xFF191919);
const kDarkFontColor = Color(0xFFFFFFFF);
var kDarkFontColorWith60 = const Color(0xFFFFFFFF).withOpacity(0.6);

var kDarkAssetBackground = const Color(0xFFFFFFFF).withOpacity(0.6);

// all mode

const kGreenFontColor = Color(0xFF18AF18);
const kGreenBackgroundColor = Color(0xFF01C448);
const kGreenAssetColor = Color(0xFF01C448);

const kRedColor = Color(0xFFFF3D3D);
const kLightRedColor = Color(0xFF8D2929);
const setRed = Color(0xFF3755);

const kOrangeAssetColor = Color(0xFFFA6C1F);
const kOrangeBssetColor = Color(0xFFF3BF37);

const kBlueBssetColor = Color(0xFF00A3FF);
const kBlueAssetColor = Color(0xFF003b6f);
const secondaryColor = Color(0xFF2A2D3E);
const kCyanA = Color.fromARGB(255, 7, 237, 233);
const kPinkA = Color.fromARGB(255, 255, 0, 119);
const dialogColor = Color(0xFF202127);
const btnColor = Color(0xFF1A1A1F);

const noState = Color(0xFF2C2C34);
const noText = Color(0xFF9A98A5);

const msgBackColor = Color(0xFF18171C);

const kColorA = Color(0xFF5F8592);
const kColorB = Color(0xFF75925F);
const kColorC = Color(0xFF6C5F92);
const kColorD = Color(0xFF925F5F);

const btnNull = Color(0xFF2A292E);

const setWhite = Color(0xFFFFFFFF);
const setBlack = Color(0xFF000000);
