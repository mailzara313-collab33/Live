import 'package:eshop_multivendor/Helper/String.dart';

class CountryCodeModel {
  final String name;
  final String flag;
  final String countryCode;
  final String callingCode;

  const CountryCodeModel(
      this.name, this.flag, this.countryCode, this.callingCode);

  factory CountryCodeModel.fromJson(Map<String, dynamic> json) {
    return CountryCodeModel(
      json['name'] as String,
      json['flag'] as String,
      json[COUNTRY_CODE] as String,
      json['calling_code'] as String,
    );
  }
}
