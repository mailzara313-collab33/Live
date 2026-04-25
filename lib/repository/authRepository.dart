import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class AuthRepository {
  //
  //This method is used to fetch System policies {e.g. Privacy Policy, T&C etc..}
  static Future<Map<String, dynamic>> fetchLoginData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail = await ApiBaseHelper().postAPICall(
        getUserLoginApi,
        parameter,
      );

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> loginWithEmail({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail = await ApiBaseHelper().postAPICall(
        loginWithEmailApi,
        parameter,
      );

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchSocialLoginData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail = await ApiBaseHelper().postAPICall(
        signUpUserApi,
        parameter,
      );

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //validate referl code
  static Future<Map<String, dynamic>> validateReferal({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper().postAPICall(
        validateReferalApi,
        parameter,
      );

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchverificationData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail = await ApiBaseHelper().postAPICall(
        getVerifyUserApi,
        parameter,
      );

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(getVerifyOtpApi, {
        MOBILE: mobileNumber.replaceAll(' ', ''),
        OTP: otp,
      });
      if (response['error'] == true) {
        throw ApiException(response['message']);
      }
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<void> resendOtp({
    required String mobileNumber,
    required String country_code,
  }) async {
    try {
      final response = await ApiBaseHelper().postAPICall(
        getResendOtpApi,
        <String, dynamic>{
          'country_code': country_code,
          'mobile': mobileNumber.replaceAll(' ', ''),
        },
      );

      if (response['error'] == true) {
        throw ApiException(response['message']);
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
    String type = 'registration',
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(
        sendEmailOtpApi,
        <String, dynamic>{'email': email, 'type': type},
      );
      return response;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(
        verifyEmailOtpApi,
        <String, dynamic>{'email': email, 'otp': otp},
      );
      return response;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> registerUserWithEmail({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(
        registerUserWithEmailApi,
        parameter,
      );
      return response;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> sendProfileEmailVerificationOtp({
    required String email,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(
        sendProfileEmailVerificationOtpApi,
        <String, dynamic>{'email': email},
      );
      return response;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> verifyProfileEmail({
    required String email,
    required String otp,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(
        verifyProfileEmailApi,
        <String, dynamic>{'email': email, 'otp': otp},
      );
      return response;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> verifyProfileMobile({
    required String mobile,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(
        verifyProfileMobileApi,
        <String, dynamic>{'mobile': mobile},
      );
      return response;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      var response = await ApiBaseHelper().postAPICall(
        getVerificationStatusApi,
        <String, dynamic>{},
      );
      return response;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchSingUpData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail = await ApiBaseHelper().postAPICall(
        getUserSignUpApi,
        parameter,
      );

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchFetchReset({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail = await ApiBaseHelper().postAPICall(
        getResetPassApi,
        parameter,
      );

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> resetPasswordWithEmail({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      var parameter = {'email': email, 'otp': otp, 'new_password': newPassword};

      var result = await ApiBaseHelper().postAPICall(
        resetPasswordWithEmailApi,
        parameter,
      );

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
