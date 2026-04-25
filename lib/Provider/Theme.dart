import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/String.dart';

class ThemeProvider extends ChangeNotifier {
  int activeThemeIndex = 0;
  bool isDark = false;

  getCurrentTheme(BuildContext context, List<String?> themeList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? get = prefs.getString(APP_THEME);

    activeThemeIndex = themeList.indexOf(
      get == '' || get == DEFAULT_SYSTEM
          ? 'SYSTEM_DEFAULT'.translate(context: context)
          : get == LIGHT
              ? 'LIGHT_THEME'.translate(context: context)
              : 'DARK_THEME'.translate(context: context),
    );

    notifyListeners();
  }

  void changeTheme(
    int index,
    String value,
    BuildContext context,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ThemeNotifier themeNotifier =
        Provider.of<ThemeNotifier>(context, listen: false);
    if (value == 'SYSTEM_DEFAULT'.translate(context: context)) {
      themeNotifier.setThemeMode(ThemeMode.system);
      prefs.setString(APP_THEME, DEFAULT_SYSTEM);

      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;

      isDark = brightness == Brightness.dark;
      if (isDark) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      }
    } else if (value == 'LIGHT_THEME'.translate(context: context)) {
      themeNotifier.setThemeMode(ThemeMode.light);
      prefs.setString(APP_THEME, LIGHT);

      isDark = false;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    } else if (value == 'DARK_THEME'.translate(context: context)) {
      themeNotifier.setThemeMode(ThemeMode.dark);
      prefs.setString(APP_THEME, DARK);

      isDark = true;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
    ISDARK = isDark.toString();
    activeThemeIndex = index;
    notifyListeners();
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  getThemeMode() => _themeMode;

  setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
  }
}
