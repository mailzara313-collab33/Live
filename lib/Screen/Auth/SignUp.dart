// ignore: file_names
import 'dart:async';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/authenticationProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/widget/common_text_form_field.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/systemChromeSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/snackbar.dart';

import '../../widgets/networkAvailablity.dart';
import '../../widgets/validation.dart';

class SignUp extends StatefulWidget {
  final String mobileNumber, countryCode;
  const SignUp({
    super.key,
    required this.mobileNumber,
    required this.countryCode,
  });

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool? _showPassword = true;
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? name,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      referCode,
      friendCode;
  FocusNode? nameFocus,
      emailFocus,
      mobileFocus,
      passFocus = FocusNode(),
      referFocus = FocusNode();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  // Check if this is email registration
  bool get isEmailRegistration => widget.countryCode.isEmpty;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> getUserDetails() async {
    context.read<AuthenticationProvider>().setMobileNumber(widget.mobileNumber);
    context.read<AuthenticationProvider>().setcountrycode(widget.countryCode);

    if (mounted) setState(() {});
  }

  void setStateNow() {
    setState(() {});
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context.read<AuthenticationProvider>().getSingUPData().then((
          value,
        ) async {
          bool? error = value['error'];
          String? msg = value['message'];
          await buttonController!.reverse();
          if (!error!) {
            setSnackbar(
              'REGISTER_SUCCESS_MSG'.translate(context: context),
              context,
            );

            print("value register data: ${value["data"]}");
            var i = value['data'][0];

            id = i[ID];
            name = i[USERNAME];
            email = i[EMAIL];
            mobile = i[MOBILE];

            // Check if this is email registration
            bool isEmailRegistration =
                widget.countryCode.isEmpty || widget.mobileNumber.contains('@');

            SettingProvider settingProvider = context.read<SettingProvider>();
            settingProvider.saveUserDetail(
              id!,
              name,
              email,
              mobile,
              city,
              area,
              address,
              pincode,
              latitude,
              longitude,
              '',
              isEmailRegistration ? 'email' : PHONE_TYPE,
              i[REFERCODE],
              value[TOKEN],
              COUNTRY_CODE,
              context,
            );

            // Navigate to home screen after successful registration
            Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
          } else {
            setSnackbar(msg!, context);
          }
        }),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        if (mounted) {
          setState(() {
            isNetworkAvail = false;
          });
        }
        await buttonController!.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
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
        if (mounted) setState(() {});
      }
    });
  }

  Widget registerTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 60.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Create a new account'.translate(context: context),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold,
            fontSize: textFontSize23,
            fontFamily: 'ubuntu',
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget signUpSubTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 13.0),
      child: Text(
        'INFO_FOR_NEW_ACCOUNT'.translate(context: context),
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

  Widget setUserName() {
    return CommonTextFormField(
      controller: nameController,
      focusNode: nameFocus,
      nextFocus: emailFocus,
      hintText: 'NAMEHINT_LBL'.translate(context: context),
      icon: Icons.person,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      validator: (val) => StringValidation.validateUserName(
        val!,
        'USER_REQUIRED'.translate(context: context),
        'USER_LENGTH'.translate(context: context),
        'INVALID_USERNAME_LBL'.translate(context: context),
      ),
      onSaved: (value) {
        context.read<AuthenticationProvider>().setUserName(value);
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
      fontSize: textFontSize13,
      topPadding: 40,
      fontColor: Theme.of(context).colorScheme.fontColor,
      fillColor: Theme.of(context).colorScheme.white,
      borderRadius: circularBorderRadius10,
    );
  }

  Widget setEmail() {
    return CommonTextFormField(
      controller: emailController,
      focusNode: emailFocus,
      nextFocus: isEmailRegistration ? mobileFocus : passFocus,
      hintText: 'EMAILHINT_LBL'.translate(context: context),
      icon: Icons.mail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      readOnly: isEmailRegistration, // Readonly if email registration
      validator: (val) => StringValidation.validateEmail(
        val!,
        'EMAIL_REQUIRED'.translate(context: context),
        'VALID_EMAIL'.translate(context: context),
      ),
      onSaved: (value) {
        context.read<AuthenticationProvider>().setSingUp(value);
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
      fontSize: textFontSize13,
      topPadding: 27,
      fontColor: Theme.of(context).colorScheme.fontColor,
      fillColor: Theme.of(context).colorScheme.white,
      borderRadius: circularBorderRadius10,
    );
  }

  Widget setMobile() {
    return CommonTextFormField(
      controller: mobileController,
      focusNode: mobileFocus,
      nextFocus: passFocus,
      hintText: 'MOBILEHINT_LBL'.translate(context: context),
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      readOnly: !isEmailRegistration, // Readonly if phone registration
      validator: (val) => StringValidation.validateMob(
        val!,
        'MOB_REQUIRED'.translate(context: context),
        'VALID_MOB'.translate(context: context),
      ),
      onSaved: (value) {
        // Store mobile number in provider - will be used in registration API
        context.read<AuthenticationProvider>().setActualMobile(value);
      },
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      fontSize: textFontSize13,
      topPadding: 27,
      fontColor: Theme.of(context).colorScheme.fontColor,
      fillColor: Theme.of(context).colorScheme.white,
      borderRadius: circularBorderRadius10,
    );
  }

  Widget setRefer() {
    return CommonTextFormField(
      controller: referController,
      focusNode: referFocus,
      hintText: 'REFER'.translate(context: context),
      icon: Icons.lock,
      textInputAction: TextInputAction.done,
      onSaved: (value) {
        context.read<AuthenticationProvider>().setfriendCode(value);
      },
      onFieldSubmitted: (val) {
        referFocus!.unfocus();
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
      fontSize: textFontSize13,
      topPadding: 27,
      fontColor: Theme.of(context).colorScheme.fontColor,
      fillColor: Theme.of(context).colorScheme.white,
      borderRadius: circularBorderRadius10,
    );
  }

  Widget setPass() {
    return CommonTextFormField(
      controller: passwordController,
      focusNode: passFocus,
      nextFocus: referFocus,
      hintText: 'PASSHINT_LBL'.translate(context: context),
      icon: Icons.lock,
      obscureText: _showPassword!,
      textInputAction: TextInputAction.next,
      validator: (val) => StringValidation.validatePass(
        val!,
        'PWD_REQUIRED'.translate(context: context),
        'PASSWORD_VALIDATION'.translate(context: context),
        onlyRequired: false,
      ),
      onSaved: (value) {
        context.read<AuthenticationProvider>().setsinUpPassword(value);
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
      suffixIcon: InkWell(
        onTap: () {
          setState(() {
            _showPassword = !_showPassword!;
          });
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 10.0),
          child: Icon(
            !_showPassword! ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(
              context,
            ).colorScheme.fontColor.withValues(alpha: 0.4),
            size: 22,
          ),
        ),
      ),
      fontSize: textFontSize13,
      topPadding: 27,
      fontColor: Theme.of(context).colorScheme.fontColor,
      fillColor: Theme.of(context).colorScheme.white,
      borderRadius: circularBorderRadius10,
    );
  }

  Widget verifyBtn() {
    return Center(
      child: AppBtn(
        title: 'SAVE_LBL'.translate(context: context),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          FocusScope.of(context).unfocus();
          validateAndSubmit();
        },
      ),
    );
  }

  Widget loginTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 25.0, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'ALREADY_A_CUSTOMER'.translate(context: context),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
          ),
          InkWell(
            onTap: () {
              Routes.navigateToLoginScreen(context, isPop: false);
            },
            child: Text(
              'LOG_IN_LBL'.translate(context: context),
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
    getUserDetails();

    // Pre-fill email or mobile based on registration type
    if (isEmailRegistration) {
      // Email registration - pre-fill email
      emailController.text = widget.mobileNumber;
    } else {
      // Phone registration - pre-fill mobile
      mobileController.text = widget.mobileNumber;
    }

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

    context.read<AuthenticationProvider>().generateReferral(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 23,
                left: 23,
                right: 23,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    registerTxt(),
                    signUpSubTxt(),
                    setUserName(),
                    setEmail(),
                    setMobile(),
                    setPass(),
                    setRefer(),
                    verifyBtn(),
                  ],
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

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: const AppLogo(),
    );
  }
}
