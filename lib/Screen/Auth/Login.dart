import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/SendOtp.dart';
import 'package:eshop_multivendor/Screen/Auth/widget/common_text_form_field.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/systemChromeSettings.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/authenticationProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/validation.dart';
import '../Dashboard/Dashboard.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import '../PrivacyPolicy/Privacy_Policy.dart';
import '../PushNotification/PushNotificationService.dart';

class Login extends StatefulWidget {
  final Widget? classType;
  final bool isPop;
  final bool? isRefresh;
  final bool hideBackButton;

  const Login({
    super.key,
    this.classType,
    required this.isPop,
    this.isRefresh,
    this.hideBackButton = false,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  bool acceptTnC = false;
  bool socialLoginLoading = false;
  AnimationController? buttonController;
  Animation? buttonSqueezeanimation;
  String? countryName;
  bool isShowPass = true;
  final emailOrMobileController = TextEditingController(
    text: isDemoApp ? '9879879879' : null,
  );
  FocusNode? emailOrMobileFocus, passFocus = FocusNode();
  final passwordController = TextEditingController(
    text: isDemoApp ? '12345678' : null,
  );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    buttonController!.dispose();
    emailOrMobileController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
        isDarkTheme:
            Provider.of<ThemeNotifier>(context, listen: false).getThemeMode() ==
            ThemeMode.dark,
      );
    });

    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(begin: deviceWidth! * 0.7, end: 50.0)
        .animate(
          CurvedAnimation(
            parent: buttonController!,
            curve: const Interval(0.0, 0.150),
          ),
        );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> saveAndNavigate(var getdata, String token) async {
    SettingProvider settingProvider = Provider.of<SettingProvider>(
      context,
      listen: false,
    );
    settingProvider.saveUserDetail(
      getdata[ID],
      getdata[USERNAME],
      getdata[EMAIL],
      getdata[MOBILE],
      getdata[CITY],
      getdata[AREA],
      getdata[ADDRESS],
      getdata[PINCODE],
      getdata[LATITUDE],
      getdata[LONGITUDE],
      getdata[IMAGE],
      getdata[TYPE],
      getdata[REFERCODE],
      token,
      getdata[COUNTRY_CODE],
      context,
    );
    Future.delayed(Duration.zero, () {
      PushNotificationService.context = context;
      PushNotificationService.setDeviceToken(
        clearSessionToken: true,
        settingProvider: settingProvider,
      );
    });

    offFavAdd().then((value) async {
      db.clearFav();
      context.read<FavoriteProvider>().setFavlist([]);
      List cartOffList = await db.getOffCart();
      if (singleSellerOrderSystem && cartOffList.isNotEmpty) {
        forLoginPageSingleSellerSystem = true;
        offSaveAdd().then((value) {
          clearYouCartDialog();
        });
      } else {
        offCartAdd().then((value) {
          db.clearCart();
          offSaveAdd().then((value) {
            db.clearSaveForLater();
            if (widget.isPop) {
              if (widget.isRefresh != null) {
                Navigator.pop(context, 'refresh');
              } else {
                context.read<HomePageProvider>().getFav(context);
                context.read<CartProvider>().getUserCart(
                  save: '0',
                  context: context,
                );

                Future.delayed(const Duration(seconds: 2)).whenComplete(() {
                  Navigator.of(context).pop();
                });
              }
            } else {
              Dashboard.dashboardScreenKey = GlobalKey();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      widget.classType ??
                      Dashboard(key: Dashboard.dashboardScreenKey),
                ),
                (route) => false,
              );
            }
          });
        });
      }
    });
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      // Auto-detect if input is email or mobile
      String input = emailOrMobileController.text.trim();
      bool isEmail = input.contains('@');

      if (isEmail) {
        context.read<AuthenticationProvider>().setEmail(input);
      } else {
        context.read<AuthenticationProvider>().setMobileNumber(input);
      }

      Future.delayed(Duration.zero).then(
        (value) => context
            .read<AuthenticationProvider>()
            .getLoginData(type: isEmail ? 'email' : 'phone')
            .then((value) async {
              bool error = value['error'];
              String? errorMessage = value['message'];
              await buttonController!.reverse();
              if (!error) {
                setSnackbar(errorMessage!, context);
                var getdata = value['data'][0];
                saveAndNavigate(getdata, value[TOKEN]);
              } else {
                setSnackbar(errorMessage!, context);
              }
            }),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        if (mounted) {
          setState(() {
            isNetworkAvail = false;
          });
        }
      });
    }
  }

  Future<void> clearYouCartDialog() async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(circularBorderRadius5),
                ),
              ),
              title: Text(
                'Your cart already has an items of another seller would you like to remove it ?'
                    .translate(context: context),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: textFontSize16,
                  fontFamily: 'ubuntu',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SvgPicture.asset(
                        DesignConfiguration.setSvgPath(Assets.appBarCart),
                        colorFilter: const ColorFilter.mode(
                          colors.primary,
                          BlendMode.srcIn,
                        ),
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          'CANCEL'.translate(context: context),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          Routes.pop(context);
                          db.clearSaveForLater();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (r) => false,
                          );
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Clear Cart'.translate(context: context),
                          style: const TextStyle(
                            color: colors.primary,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          if (context.read<UserProvider>().userId != '') {
                            context.read<UserProvider>().setCartCount('0');
                            context
                                .read<ProductDetailProvider>()
                                .clearCartNow(context)
                                .then((value) async {
                                  if (context
                                          .read<ProductDetailProvider>()
                                          .error ==
                                      false) {
                                    if (context
                                            .read<ProductDetailProvider>()
                                            .snackbarmessage ==
                                        'DATA_DELETED_SUCCESS'.translate(
                                          context: context,
                                        )) {
                                    } else {
                                      setSnackbar(
                                        context
                                            .read<ProductDetailProvider>()
                                            .snackbarmessage,
                                        context,
                                      );
                                    }
                                  } else {
                                    setSnackbar(
                                      context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage,
                                      context,
                                    );
                                  }
                                  Routes.pop(context);
                                  await offCartAdd();
                                  db.clearSaveForLater();
                                  Dashboard.dashboardScreenKey = GlobalKey();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (r) => false,
                                  );
                                });
                          } else {
                            Routes.pop(context);
                            db.clearSaveForLater();
                            Dashboard.dashboardScreenKey = GlobalKey();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget skipSignInBtn() {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.lightWhite,
            borderRadius: const BorderRadius.all(
              Radius.circular(circularBorderRadius10),
            ),
          ),
          child: Text(
            'SKIP_SIGNIN_LBL'.translate(context: context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
          ),
        ),
        onPressed: () {
          Dashboard.dashboardScreenKey = GlobalKey();
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        },
      ),
    );
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<void> setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then((_) async {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (BuildContext context) => super.widget),
        );
      } else {
        await buttonController!.reverse();
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();
    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]['PID']);
      }
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();
    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        addToCartCheckout(cartOffList[i]['VID'], cartOffList[i]['QTY']);
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {PRODUCT_VARIENT_ID: varId, QTY: qty};

        Response response = await post(
          manageCartApi,
          body: parameter,
          headers: headers,
        ).timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          if (getdata['message'] == 'One of the product is out of stock.') {
            homePageSingleSellerMessage = true;
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), context);
      }
    } else {
      if (mounted) isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]['VID'], saveOffList[i]['QTY']);
      }
    }
  }

  Future<void> saveForLater(String vid, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {PRODUCT_VARIENT_ID: vid, QTY: qty, SAVE_LATER: '1'};
        Response response = await post(
          manageCartApi,
          body: parameter,
          headers: headers,
        ).timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), context);
      }
    } else {
      if (mounted) {
        setState(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  Widget backBotton() {
    return InkWell(
      child: Icon(
        Icons.arrow_back_ios,
        color: Theme.of(context).colorScheme.black,
      ),
      onTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget signInTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 40.0),
      child: Text(
        'SIGNIN_LBL'.translate(context: context),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.bold,
          fontSize: textFontSize20,
          letterSpacing: 0.8,
          fontFamily: 'ubuntu',
        ),
      ),
    );
  }

  Widget signInSubTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 13.0),
      child: Text(
        'INFO_FOR_LOGIN'.translate(context: context),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.fontColor.withValues(alpha: 0.38),
          fontWeight: FontWeight.bold,
          fontFamily: 'ubuntu',
        ),
      ),
    );
  }

  Widget setEmailOrMobile() {
    return CommonTextFormField(
      controller: emailOrMobileController,
      focusNode: emailOrMobileFocus,
      nextFocus: passFocus,
      hintText: 'ENTER_EMAIL_OR_MOBILE'.translate(context: context),
      icon: Icons.person,
      prefixIconColor: Theme.of(context).colorScheme.black,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'EMAIL_OR_MOBILE_REQUIRED'.translate(context: context);
        }
        // Check if it's an email
        if (val.contains('@')) {
          // Validate as email
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
            return 'VALID_EMAIL_ADDRESS'.translate(context: context);
          }
        } else {
          // Validate as mobile number (digits only)
          if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
            return 'VALID_MOBILE_NUMBER'.translate(context: context);
          }
          if (val.length < 6 || val.length > 15) {
            return 'MOBILE_LENGTH_ERROR'.translate(context: context);
          }
        }
        return null;
      },
      onSaved: (value) {
        String input = value?.trim() ?? '';
        if (input.contains('@')) {
          context.read<AuthenticationProvider>().setEmail(input);
        } else {
          context.read<AuthenticationProvider>().setMobileNumber(input);
        }
      },
      fontSize: textFontSize14,
      topPadding: 30,
      fontColor: Theme.of(context).colorScheme.fontColor,
      fillColor: Theme.of(context).colorScheme.white,
      borderRadius: circularBorderRadius10,
    );
  }

  Widget setPass() {
    return CommonTextFormField(
      controller: passwordController,
      focusNode: passFocus,
      hintText: 'PASSHINT_LBL'.translate(context: context),
      icon: Icons.lock,
      prefixIconColor: Theme.of(context).colorScheme.black,
      obscureText: isShowPass,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
      validator: (val) => StringValidation.validatePass(
        val!,
        'PWD_REQUIRED'.translate(context: context),
        'PASSWORD_VALIDATION'.translate(context: context),
        onlyRequired: true,
      ),
      onSaved: (String? value) {
        context.read<AuthenticationProvider>().setPassword(value);
      },
      suffixIcon: InkWell(
        onTap: () {
          setState(() {
            isShowPass = !isShowPass;
          });
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 10.0),
          child: Icon(
            !isShowPass ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(
              context,
            ).colorScheme.fontColor.withValues(alpha: 0.4),
            size: 22,
          ),
        ),
      ),
      fontSize: textFontSize14,
      topPadding: 18,
      fontColor: Theme.of(context).colorScheme.fontColor,
      fillColor: Theme.of(context).colorScheme.white,
      borderRadius: circularBorderRadius10,
    );
  }

  Widget forgetPass() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () {
              // Auto-detect if current input is email or phone
              String input = emailOrMobileController.text.trim();
              bool isEmail = input.contains('@');

              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SendOtp(
                    title: 'FORGOT_PASS_TITLE'.translate(context: context),
                    from: isEmail ? 'email' : 'phone',
                    mobileNo: input.isNotEmpty ? input : null,
                  ),
                ),
              );
            },
            child: Text(
              'FORGOT_PASSWORD_LBL'.translate(context: context),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.fontColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
                fontSize: textFontSize13,
                fontFamily: 'ubuntu',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> signInUser({required String type}) async {
    try {
      final result = await context
          .read<AuthenticationProvider>()
          .socialSignInUser(type: type, context: context);
      final user = result['user'] as User;

      Map<String, dynamic> userDataTest = await context
          .read<AuthenticationProvider>()
          .loginAuth(
            mobile: user.providerData[0].phoneNumber ?? '',
            email: user.providerData[0].email ?? '',
            firebaseId: user.providerData[0].uid ?? '',
            name:
                user.providerData[0].displayName ??
                (type == APPLE_TYPE ? 'Apple User' : ''),
            type: type,
          );

      bool error = userDataTest['error'];
      String? msg = userDataTest['message'];

      setState(() {
        socialLoginLoading = false;
      });
      if (!error) {
        setSnackbar(msg!, context);

        var userdata = userDataTest['data'];
        saveAndNavigate(userdata, userDataTest[TOKEN]);
      } else {
        setSnackbar(msg!, context);
      }
    } catch (e) {
      setState(() {
        socialLoginLoading = false;
      });
      signOut(type);
      setSnackbar(e.toString(), context);
    }
  }

  Future<void> signOut(String type) async {
    _firebaseAuth.signOut();
    if (type == GOOGLE_TYPE) {
      _googleSignIn.signOut();
    } else {
      _firebaseAuth.signOut();
    }
  }

  Widget orDivider() {
    if (context.read<AppSettingsCubit>().isGoogleLoginOn() ||
        (Platform.isIOS &&
            context.read<AppSettingsCubit>().isAppleLoginAllowed())) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            Flexible(
              child: Divider(
                indent: 30,
                endIndent: 15,
                color: Theme.of(
                  context,
                ).colorScheme.fontColor.withValues(alpha: 0.6),
              ),
            ),
            Text(
              'OR_LOGIN_WITH_LBL'.translate(context: context),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.fontColor.withValues(alpha: 0.8),
              ),
            ),
            Flexible(
              child: Divider(
                indent: 15,
                endIndent: 30,
                color: Theme.of(
                  context,
                ).colorScheme.fontColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget termAndPolicyTxt() {
    if (context.read<AppSettingsCubit>().isGoogleLoginOn() ||
        (Platform.isIOS &&
            context.read<AppSettingsCubit>().isAppleLoginAllowed())) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0.0, left: 25.0, right: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: colors.primary,
                  value: acceptTnC,
                  onChanged: (newValue) {
                    setState(() => acceptTnC = newValue!);
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'CONTINUE_AGREE_LBL'.translate(context: context),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.normal,
                      ),
                      children: [
                        TextSpan(
                          text:
                              "\n${'TERMS_SERVICE_LBL'.translate(context: context)}",
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.normal,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => PrivacyPolicy(
                                    title: 'TERM'.translate(context: context),
                                  ),
                                ),
                              );
                            },
                        ),
                        TextSpan(
                          text: "  ${'AND_LBL'.translate(context: context)}  ",
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        TextSpan(
                          text: 'PRIVACY'.translate(context: context),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.normal,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => PrivacyPolicy(
                                    title: 'PRIVACY'.translate(
                                      context: context,
                                    ),
                                  ),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget socialLoginBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Center(
        child: Column(
          children: [
            if (context.read<AppSettingsCubit>().isGoogleLoginOn())
              CupertinoButton(
                padding: EdgeInsetsDirectional.zero,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.white.withValues(alpha: 0.5),
                        blurRadius: 9.0,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(circularBorderRadius50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        DesignConfiguration.setSvgPath(Assets.googleButton),
                        height: 22,
                        width: 22,
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 15),
                        child: Text(
                          'CONTINUE_WITH_GOOGLE'.translate(context: context),
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  if (acceptTnC) {
                    isNetworkAvail = await isNetworkAvailable();
                    if (isNetworkAvail) {
                      setState(() {
                        socialLoginLoading = true;
                      });
                      signInUser(type: GOOGLE_TYPE);
                    } else {
                      Future.delayed(const Duration(seconds: 2)).then((
                        _,
                      ) async {
                        await buttonController!.reverse();
                        if (mounted) {
                          setState(() {
                            isNetworkAvail = false;
                          });
                        }
                      });
                    }
                  } else {
                    setSnackbar(
                      'agreeTCFirst'.translate(context: context),
                      context,
                    );
                  }
                },
              ),
            if (Platform.isIOS &&
                context.read<AppSettingsCubit>().isAppleLoginAllowed())
              CupertinoButton(
                padding: EdgeInsetsDirectional.only(top: 15, start: 0, end: 0),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  // width: deviceWidth! * 0.7,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.white.withValues(alpha: 0.5),
                        blurRadius: 9.0,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(circularBorderRadius50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        DesignConfiguration.setSvgPath(Assets.appleLogo),
                        height: 22,
                        width: 22,
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 15),
                        child: Text(
                          'CONTINUE_WITH_APPLE'.translate(context: context),
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  if (acceptTnC) {
                    isNetworkAvail = await isNetworkAvailable();
                    if (isNetworkAvail) {
                      setState(() {
                        socialLoginLoading = true;
                      });
                      signInUser(type: APPLE_TYPE);
                    } else {
                      Future.delayed(const Duration(seconds: 2)).then((
                        _,
                      ) async {
                        await buttonController!.reverse();
                        if (mounted) {
                          setState(() {
                            isNetworkAvail = false;
                          });
                        }
                      });
                    }
                  } else {
                    setSnackbar(
                      'agreeTCFirst'.translate(context: context),
                      context,
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget setDontHaveAcc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${'DONT_HAVE_AN_ACC'.translate(context: context)} ',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) => SendOtp(
                    title: 'SEND_OTP_TITLE'.translate(context: context),
                  ),
                ),
              );
            },
            child: Text(
              'SIGN_UP_LBL'.translate(context: context),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: 'ubuntu',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginBtn() {
    return Center(
      child: Consumer<AuthenticationProvider>(
        builder: (context, value, child) {
          return AppBtn(
            title: 'SIGNIN_LBL'.translate(context: context),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              FocusScope.of(context).unfocus();
              if (passFocus != null) {
                passFocus!.unfocus();
              }
              if (emailOrMobileFocus != null) {
                emailOrMobileFocus!.unfocus();
              }
              validateAndSubmit();
            },
          );
        },
      ),
    );
  }

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10),
      child: const AppLogo(),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> _setFav(String pid) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {PRODUCT_ID: pid};
        Response response = await post(
          setFavoriteApi,
          body: parameter,
          headers: headers,
        ).timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
          setSnackbar(msg!, context);
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), context);
      }
    } else {
      if (mounted) {
        setState(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 23,
                  left: 23,
                  right: 23,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formkey,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (!widget.hideBackButton) backBotton(),
                          signInTxt(),
                          signInSubTxt(),
                          setEmailOrMobile(),
                          setPass(),
                          forgetPass(),
                          loginBtn(),
                          orDivider(),
                          socialLoginBtn(),
                          setDontHaveAcc(),
                          termAndPolicyTxt(),
                          const SizedBox(height: 40),
                        ],
                      ),
                      if (socialLoginLoading)
                        Positioned.fill(
                          child: Center(
                            child: DesignConfiguration.showCircularProgress(
                              socialLoginLoading,
                              colors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }
}
