import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/productDetailProvider.dart';
import 'package:eshop_multivendor/main.dart';
import 'package:eshop_multivendor/repository/pushnotificationRepositry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SessionManager {
  static bool _isLoggingOut = false;

  static Future<void> forceLogout(BuildContext context) async {
    if (_isLoggingOut) return; // Prevent multiple calls
    _isLoggingOut = true;

    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      context.read<ProductDetailProvider>().setcompareList([]);
      final fcmId = globalSettingsProvider?.fcmId;
      print("fcmId $fcmId");

      try {
        await NotificationRepository.updateFcmID(parameter: {
          FCM_ID: fcmId,
          'device_type': '-',
          'is_logout': '1',
        });
      } catch (e) {
        print("Logout error while updating FCM: $e");
      }

      final settingProvider =
          Provider.of<SettingProvider>(context, listen: false);
      final loginType = context.read<UserProvider>().loginType;

      if (loginType != PHONE_TYPE) {
        if (loginType == GOOGLE_TYPE) {
          await googleSignIn.signOut();
        } else {
          await firebaseAuth.signOut();
        }
      }

      settingProvider.clearUserSession(context);
      context.read<FavoriteProvider>().setFavlist([]);

      // Navigate back to login screen
      Routes.navigateToLoginScreen(context, isPop: false);
    } finally {
      _isLoggingOut = false; // reset once finished
    }
  }
}
