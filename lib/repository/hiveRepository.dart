import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:hive/hive.dart';

class HiveRepository {
  static String languageBoxKey = "language";

  ///--------------------------------- languageBoxKey Keys
  ///
  static String currentLanguageCodeKey = 'currentLanguageCode';
  static String currentLanguageNameKey = 'currentLanguageName';
  static String currentSubLanguageNameKey = 'currentSubLanguageName';

  ///--------------------------------- languageBox methods

  static String get getSelectedLanguageCode =>
      Hive.box(languageBoxKey).get(currentLanguageCodeKey) ??
      defaultLanguageCode;

  static set setSelectedLanguageCode(languageCode) =>
      Hive.box(languageBoxKey).put(currentLanguageCodeKey, languageCode);

  static String get getSelectedLanguageName =>
      Hive.box(languageBoxKey).get(currentLanguageNameKey) ??
      defaultLanguageName;

  static set setSelectedLanguageName(languageName) =>
      Hive.box(languageBoxKey).put(currentLanguageNameKey, languageName);

  static String get getSelectedSubLanguageName =>
      Hive.box(languageBoxKey).get(currentLanguageNameKey) ??
      defaultLanguageName;

  static set setSelectedSubLanguageName(subLanguageName) =>
      Hive.box(languageBoxKey).put(currentSubLanguageNameKey, subLanguageName);

  static Future<void> init() async {
    await Hive.openBox(languageBoxKey);
  }
}
