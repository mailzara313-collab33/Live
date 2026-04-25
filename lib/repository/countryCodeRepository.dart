import 'dart:convert';
import 'package:eshop_multivendor/Model/countryCodeModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CountryCodeRepository {
  Future<List<CountryCodeModel>> getCountries(BuildContext context) async {
    final String rawData =
        await rootBundle.loadString('assets/countryCodes/countryCodes.json');
    final parsed = json.decode(rawData.toString()).cast<Map<String, dynamic>>();
    return parsed
        .map<CountryCodeModel>((json) => CountryCodeModel.fromJson(json))
        .toList();
  }

  Future<CountryCodeModel> getCountryByCountryCode(
      BuildContext context, String countryCode) async {
    final list = await getCountries(context);

    return list.firstWhere(
      (element) => element.countryCode == countryCode,
      orElse: () {
        print("Warning: No country found for code -> $countryCode");
        throw Exception("Country code not found: $countryCode");
      },
    );
  }

  // Future<CountryCodeModel> getCountryByCountryCode(
  //     BuildContext context, String countryCode) async {
  //   final list = await getCountries(context);
  //   return list.firstWhere((element) => element.callingCode == countryCode);
  // }
}
