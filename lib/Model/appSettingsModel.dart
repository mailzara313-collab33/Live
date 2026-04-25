import 'package:eshop_multivendor/Helper/String.dart';

class AppSettingsModel {
  bool isAppleLoginAllowed;
  bool isGoogleLoginAllowed;
  bool isSMSGatewayActive;
  bool isCityWiseDeliveribility;
  String? iosLink;
  String? appStoreId;
  String? androidLink;
  String? defaultCountryCode;
  String? userCountryCode;

  AppSettingsModel(
      {required this.isAppleLoginAllowed,
      required this.isGoogleLoginAllowed,
      required this.isSMSGatewayActive,
      required this.isCityWiseDeliveribility,
      required this.androidLink,
      required this.iosLink,
      required this.appStoreId,
      required this.defaultCountryCode,
      required this.userCountryCode});

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    final data = map['systemSetting']['system_settings'][0];
    final shippingData = map['systemSetting']['shipping_method'][0];
    final fullResponseData = map['systemSetting'];
    return AppSettingsModel(
      isAppleLoginAllowed: data[APPLE_LOGIN] == '1',
      isGoogleLoginAllowed: data[GOOGLE_LOGIN] == '1',
      isSMSGatewayActive: fullResponseData['authentication_settings'] != null &&
              fullResponseData['authentication_settings'].isNotEmpty
          ? fullResponseData['authentication_settings'][0]
                      ['authentication_method']
                  .toString()
                  .toLowerCase() ==
              'sms'
          : false,
      isCityWiseDeliveribility:
          shippingData['city_wise_deliverability'].toString() == '1',
      iosLink: data['ios_app_store_link'] ?? '',
      appStoreId: data['app_store_id'] ?? '',
      androidLink: data['android_app_store_link'] ?? '',
      defaultCountryCode: data['default_country_code'] ?? 'IN',
      userCountryCode: (map['systemSetting']['user_data'][0] != null &&
              map['systemSetting']['user_data'].isNotEmpty &&
              map['systemSetting']['user_data'][0][COUNTRY_CODE] != null)
          ? map['systemSetting']['user_data'][0][COUNTRY_CODE]
          : '',
    );
  }

  AppSettingsModel copyWith({
    bool? isAppleLoginAllowed,
    bool? isGoogleLoginAllowed,
    bool? isSMSGatewayActive,
    bool? isCityWiseDeliveribility,
    String? iosLink,
    String? appStoreId,
    String? androidLink,
    String? defaultCountryCode,
    String? userCountryCode,
  }) {
    return AppSettingsModel(
      isAppleLoginAllowed: isAppleLoginAllowed ?? this.isAppleLoginAllowed,
      isGoogleLoginAllowed: isGoogleLoginAllowed ?? this.isGoogleLoginAllowed,
      isSMSGatewayActive: isSMSGatewayActive ?? this.isSMSGatewayActive,
      isCityWiseDeliveribility:
          isCityWiseDeliveribility ?? this.isCityWiseDeliveribility,
      iosLink: iosLink ?? this.iosLink,
      appStoreId: appStoreId ?? this.appStoreId,
      androidLink: androidLink ?? this.androidLink,
      defaultCountryCode: defaultCountryCode ?? this.defaultCountryCode,
      userCountryCode: userCountryCode ?? this.userCountryCode,
    );
  }
}
