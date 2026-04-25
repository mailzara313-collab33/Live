// ignore_for_file: prefer_final_locals
import 'package:country_pickers/utils/utils.dart';
import 'package:eshop_multivendor/Model/countryCodeModel.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/repository/countryCodeRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CountryCodeState {}

class CountryCodeInitial extends CountryCodeState {}

class CountryCodeLoadingInProgress extends CountryCodeState {}

class CountryCodeFetchSuccess extends CountryCodeState {
  CountryCodeFetchSuccess({
    this.selectedCountry,
    this.countryList,
    this.temporaryCountryList,
  });

  final CountryCodeModel? selectedCountry;
  final List<CountryCodeModel>? countryList;
  final List<CountryCodeModel>? temporaryCountryList;
}

class CountryCodeFetchFail extends CountryCodeState {
  CountryCodeFetchFail(this.error);

  final dynamic error;
}

class CountryCodeCubit extends Cubit<CountryCodeState> {
  CountryCodeCubit() : super(CountryCodeInitial());

  CountryCodeRepository countryCodeRepository = CountryCodeRepository();

  Future<void> loadAllCountryCode(final BuildContext context) async {
    String? numericCountryCode = context.read<UserProvider>().countryCode;

    if (numericCountryCode == 'null') {
      numericCountryCode =
          context.read<AppSettingsCubit>().getDefaultCountryCode();
    }

    print(
        "userCountryCode---->${context.read<UserProvider>().countryCode} --->defaultCountryCode--->${context.read<AppSettingsCubit>().getDefaultCountryCode()} ");

    if (numericCountryCode == null) {
      emit(CountryCodeFetchFail(Exception("Country code not available")));
      return;
    }

    String? isoCountryCode;
    try {
      isoCountryCode =
          CountryPickerUtils.getCountryByPhoneCode(numericCountryCode).isoCode;
    } catch (e) {
      print("Error getting ISO code, using default country code.");
      isoCountryCode = context.read<AppSettingsCubit>().getDefaultCountryCode();
    }

    if (isoCountryCode == null) {
      emit(CountryCodeFetchFail(Exception("Failed to get ISO country code.")));
      return;
    }

    try {
      emit(CountryCodeLoadingInProgress());

      CountryCodeModel? country;
      try {
        country = await countryCodeRepository.getCountryByCountryCode(
            context, isoCountryCode);
      } catch (e) {
        print("Country not found, falling back to default country.");
        country = null;
      }

      if (country == null) {
        emit(CountryCodeFetchFail(
            Exception("Country not found: $isoCountryCode")));
        return;
      }

      final countriesList = await countryCodeRepository.getCountries(context);
      emit(
        CountryCodeFetchSuccess(
          selectedCountry: country,
          countryList: countriesList,
          temporaryCountryList: countriesList,
        ),
      );
    } catch (e) {
      emit(CountryCodeFetchFail(e));
    }
  }

  void selectCountryCode(final CountryCodeModel country) {
    if (state is CountryCodeFetchSuccess) {
      emit(
        CountryCodeFetchSuccess(
          selectedCountry: country,
          countryList: (state as CountryCodeFetchSuccess).countryList,
          temporaryCountryList:
              (state as CountryCodeFetchSuccess).temporaryCountryList,
        ),
      );
    }
  }

  Future<CountryCodeModel?> getCountryDetailsFromCountryLocale(
      BuildContext context,
      {required String countryLocale}) async {
    final CountryCodeModel country = await countryCodeRepository
        .getCountryByCountryCode(context, countryLocale);
    return country;
  }

  void filterCountryCodeList(final String content) {
    if (state is CountryCodeFetchSuccess) {
      final List<CountryCodeModel>? mainList =
          (state as CountryCodeFetchSuccess).countryList;
      List<CountryCodeModel>? tempList = [];

      final CountryCodeModel? selectedCountry =
          (state as CountryCodeFetchSuccess).selectedCountry;

      for (int i = 0; i < mainList!.length; i++) {
        final CountryCodeModel country = mainList[i];

        if (country.name.toLowerCase().contains(content.toLowerCase()) ||
            country.callingCode.toLowerCase().contains(content.toLowerCase())) {
          if (!tempList.contains(country)) {
            tempList.add(country);
          }
        }
      }

      emit(
        CountryCodeFetchSuccess(
          temporaryCountryList: tempList,
          countryList: mainList,
          selectedCountry: selectedCountry,
        ),
      );
    }
  }

  void fillTemporaryList() {
    if (state is CountryCodeFetchSuccess) {
      final List<CountryCodeModel>? mainList =
          (state as CountryCodeFetchSuccess).countryList;
      final CountryCodeModel? selectedCountry =
          (state as CountryCodeFetchSuccess).selectedCountry;
      emit(
        CountryCodeFetchSuccess(
          temporaryCountryList: mainList,
          countryList: mainList,
          selectedCountry: selectedCountry,
        ),
      );
    }
  }

  String getSelectedCountryCode() =>
      (state as CountryCodeFetchSuccess).selectedCountry!.callingCode;
}
