import 'package:eshop_multivendor/repository/hiveRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {
  LanguageLoader(this.languageCode);
  final dynamic languageCode;
}

class LanguageLoadFail extends LanguageState {}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void loadCurrentLanguage() {
    final language = HiveRepository.getSelectedLanguageCode;
    print("language---->${language}");
    if (language != "") {
      print("language1111---->${language}");
      emit(LanguageLoader(language));
    } else {
      emit(LanguageLoadFail());
    }
  }

  Future<void> changeLanguage({
    required final String selectedLanguageCode,
    required final String selectedLanguageName,
    required final String selectedSubLanguageName,
  }) async {
    HiveRepository.setSelectedLanguageCode = selectedLanguageCode;
    HiveRepository.setSelectedLanguageName = selectedLanguageName;
    HiveRepository.setSelectedSubLanguageName = selectedSubLanguageName;

    // await HiveRepository.putValuesOf(boxName: HiveRepository.languageBox, key: HiveRepository.currentLanguageCodeKey, value: selectedLanguageCode);
    //await HiveRepository.putValuesOf(boxName: HiveRepository.languageBox, key: HiveRepository.currentLanguageNameKey, value: selectedLanguageName);
    // await Hive.box(languageBox).put(currentLanguageCodeKey, selectedLanguageCode);
    // await Hive.box(languageBox).put(currentLanguageNameKey, selectedLanguageName);
    emit(LanguageLoader(selectedLanguageCode));
  }
}
