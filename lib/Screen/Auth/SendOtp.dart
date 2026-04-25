import 'dart:async';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/Auth/countryCodePickerScreen.dart';
import 'package:eshop_multivendor/Screen/PrivacyPolicy/Privacy_Policy.dart';
import 'package:eshop_multivendor/Screen/Auth/Verify_Otp.dart';
import 'package:eshop_multivendor/cubits/loadCountryCodeCubit.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/systemChromeSettings.dart';
import 'package:eshop_multivendor/widgets/validation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Provider/authenticationProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';

enum OtpType { phone, email }

// ignore: must_be_immutable
class SendOtp extends StatefulWidget {
  String? title;
  String? mobileNo;
  String? email;
  String? from;

  SendOtp({super.key, this.title, this.mobileNo, this.from, this.email});

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, countrycode, email;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool acceptTnC = false;
  int? numberLength;
  final GlobalKey<FormState> verifyPhoneNumberFormKey = GlobalKey<FormState>();

  // OTP type selection
  OtpType selectedOtpType = OtpType.phone;

  bool get isEmailMode => selectedOtpType == OtpType.email;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
      // ignore: empty_catches
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      // Email mode - use backend OTP system
      if (isEmailMode) {
        // Store email in provider
        context.read<AuthenticationProvider>().setSingUp(emailController.text);

        Future.delayed(Duration.zero).then(
          (value) => context
              .read<AuthenticationProvider>()
              .getVerifyUserByEmail(
                emailController.text,
                isForgotPassword:
                    widget.title ==
                    'FORGOT_PASS_TITLE'.translate(context: context),
              )
              .then((value) async {
                bool? error = value['error'];
                String? msg = value['message'];
                await buttonController!.reverse();

                if (widget.title ==
                    'SEND_OTP_TITLE'.translate(context: context)) {
                  if (!error!) {
                    setSnackbar(msg!, context);
                    Future.delayed(const Duration(seconds: 1)).then((_) {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => VerifyOtp(
                            mobileNumber: emailController.text,
                            countryCode: '', // Empty for email
                            title: 'SEND_OTP_TITLE'.translate(context: context),
                          ),
                        ),
                      );
                    });
                  } else {
                    setSnackbar(msg!, context);
                  }
                }
                if (widget.title ==
                    'FORGOT_PASS_TITLE'.translate(context: context)) {
                  if (!error!) {
                    setSnackbar(msg!, context);
                    Future.delayed(const Duration(seconds: 1)).then((_) {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => VerifyOtp(
                            mobileNumber: emailController.text,
                            countryCode: '', // Empty for email
                            title: 'FORGOT_PASS_TITLE'.translate(
                              context: context,
                            ),
                          ),
                        ),
                      );
                    });
                  } else {
                    setSnackbar(msg!.translate(context: context), context);
                  }
                }
              }),
        );
        return;
      }

      // Phone mode - existing OTP flow
      final String countryCallingCode = context
          .read<CountryCodeCubit>()
          .getSelectedCountryCode();

      countrycode = countryCallingCode;
      Future.delayed(Duration.zero).then(
        (value) => context
            .read<AuthenticationProvider>()
            .getVerifyUser(
              mobileController.text,
              countryCode: countrycode!,
              isForgotPassword:
                  widget.title ==
                  'FORGOT_PASS_TITLE'.translate(context: context),
            )
            .then((value) async {
              bool? error = value['error'];
              String? msg = value['message'];
              await buttonController!.reverse();

              if (widget.title ==
                  'SEND_OTP_TITLE'.translate(context: context)) {
                if (!error!) {
                  setSnackbar(msg!, context);
                  Future.delayed(const Duration(seconds: 1)).then((_) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                          mobileNumber: mobileController.text,
                          countryCode: countrycode,
                          title: 'SEND_OTP_TITLE'.translate(context: context),
                        ),
                      ),
                    );
                  });
                } else {
                  setSnackbar(msg!, context);
                }
              }
              if (widget.title ==
                  'FORGOT_PASS_TITLE'.translate(context: context)) {
                if (!error!) {
                  setSnackbar(msg!, context);
                  Future.delayed(const Duration(seconds: 1)).then((_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                          mobileNumber: mobileController.text,
                          countryCode: countrycode,
                          title: 'FORGOT_PASS_TITLE'.translate(
                            context: context,
                          ),
                        ),
                      ),
                    );
                  });
                } else {
                  setSnackbar(msg!.translate(context: context), context);
                }
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

    if (isEmailMode) {
      if (emailController.text.toString().trim().isEmpty) {
        setSnackbar('ENTER_EMAIL_ADDRESS'.translate(context: context), context);
        return false;
      } else if (form.validate()) {
        return true;
      }
      return false;
    } else {
      if (mobileController.text.toString().trim().isEmpty) {
        setSnackbar('MOB_REQUIRED'.translate(context: context), context);
        return false;
      } else if (form.validate()) {
        return true;
      }
      return false;
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    emailController.dispose();
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
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Widget verifyCodeTxt() {
    return Padding(
      padding: const EdgeInsets.only(top: 13.0),
      child: Text(
        'SEND_VERIFY_CODE_LBL'.translate(context: context),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.fontColor.withValues(alpha: 0.4),
          fontWeight: FontWeight.bold,
          fontFamily: 'ubuntu',
        ),
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 3,
      ),
    );
  }

  Widget otpTypeToggle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedOtpType = OtpType.phone;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedOtpType == OtpType.phone
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedOtpType == OtpType.phone
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.lightWhite,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_android,
                      color: selectedOtpType == OtpType.phone
                          ? Theme.of(context).colorScheme.white
                          : Theme.of(context).colorScheme.fontColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PHONE'.translate(context: context),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: selectedOtpType == OtpType.phone
                            ? Theme.of(context).colorScheme.white
                            : Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedOtpType = OtpType.email;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedOtpType == OtpType.email
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedOtpType == OtpType.email
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.lightWhite,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: selectedOtpType == OtpType.email
                          ? Theme.of(context).colorScheme.white
                          : Theme.of(context).colorScheme.fontColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'EMAILHINT_LBL'.translate(context: context),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: selectedOtpType == OtpType.email
                            ? Theme.of(context).colorScheme.white
                            : Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget setCodeWithMono() {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
            titleMedium:
                Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                ) ??
                TextStyle(color: Theme.of(context).colorScheme.fontColor),
          ),
        ),
        child: TextFormField(
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal,
          ),
          controller: mobileController,
          readOnly:
              widget.title == 'FORGOT_PASS_TITLE'.translate(context: context)
              ? false
              : (widget.mobileNo == null ? false : true),
          autofocus: widget.mobileNo == null ? true : false,
          enabled: true,
          decoration: InputDecoration(
            counterStyle: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
            ),
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal,
            ),
            hintText: 'MOBILEHINT_LBL'.translate(context: context),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(circularBorderRadius7),
            ),
            fillColor: Theme.of(context).colorScheme.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ((numberLength! < minimumMobileNumberDigit)
                    ? Theme.of(context).colorScheme.lightWhite
                    : (numberLength! > maximumMobileNumberDigit)
                    ? colors.red
                    : Theme.of(context).colorScheme.onSurface),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, bottom: 2),
              child: BlocBuilder<CountryCodeCubit, CountryCodeState>(
                builder:
                    (final BuildContext context, final CountryCodeState state) {
                      var code = '--';
                      var codeflag = '--';

                      if (state is CountryCodeFetchSuccess) {
                        code = state.selectedCountry!.callingCode;
                        codeflag = state.selectedCountry!.flag;
                      }

                      return InkWell(
                        onTap: () {
                          if (allowOnlySingleCountry) {
                            return;
                          }
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => CountryCodePickerScreen(),
                            ),
                          ).then(
                            (_) => context
                                .read<CountryCodeCubit>()
                                .fillTemporaryList(),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Builder(
                              builder: (BuildContext context) {
                                if (state is CountryCodeFetchSuccess) {
                                  return Center(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 25,
                                          child: Image.asset(codeflag),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          code,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.fontColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                if (state is CountryCodeFetchFail) {
                                  return setSnackbar(state.error, context);
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      );
                    },
              ),
            ),
          ),
          onChanged: (number) {
            setState(() {
              numberLength = number.length;
            });
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: Theme.of(context).colorScheme.fontColor,
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }

  Widget setEmailField() {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: TextFormField(
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: emailController,
        readOnly: false,
        autofocus: widget.mobileNo == null ? true : false,
        keyboardType: TextInputType.emailAddress,
        validator: (val) => StringValidation.validateEmail(
          val!,
          'EMAIL_REQUIRED'.translate(context: context),
          'VALID_EMAIL'.translate(context: context),
        ),
        decoration: InputDecoration(
          counterStyle: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
          ),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal,
          ),
          hintText: 'EMAIL_ADDRESS_LBL'.translate(context: context),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(circularBorderRadius7),
          ),
          fillColor: Theme.of(context).colorScheme.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: Theme.of(context).colorScheme.fontColor,
          ),
        ),
        cursorColor: Theme.of(context).colorScheme.fontColor,
      ),
    );
  }

  Widget verifyBtn() {
    return Center(
      child: AppBtn(
        title: widget.title == 'SEND_OTP_TITLE'.translate(context: context)
            ? 'SEND_OTP'.translate(context: context)
            : 'CONTINUE'.translate(context: context),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          FocusScope.of(context).unfocus();
          if (widget.title == 'FORGOT_PASS_TITLE'.translate(context: context) ||
              acceptTnC) {
            validateAndSubmit();
          } else {
            setSnackbar('agreeTCFirst'.translate(context: context), context);
          }
        },
      ),
    );
  }

  Widget termAndPolicyTxt() {
    if (widget.title != 'FORGOT_PASS_TITLE'.translate(context: context)) {
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
      return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CountryCodeCubit>().loadAllCountryCode(context);
    });
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
        isDarkTheme:
            Provider.of<ThemeNotifier>(context, listen: false).getThemeMode() ==
            ThemeMode.dark,
      );
    });
    // Handle email parameter if provided separately
    if (widget.email != null && widget.email!.isNotEmpty) {
      setState(() {
        emailController.text = widget.email!;
        selectedOtpType = OtpType.email;
      });
    }
    // Handle mobileNo parameter (could be email or phone)
    else if (widget.mobileNo != null) {
      setState(() {
        // Check if the input is an email or mobile number
        if (widget.mobileNo!.contains('@')) {
          // It's an email
          emailController.text = widget.mobileNo!;
          selectedOtpType = OtpType.email;
        } else {
          // It's a mobile number
          mobileController.text = widget.mobileNo!;
          mobile = widget.mobileNo!;
        }
      });
    }
    numberLength = mobileController.text.length;
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

  Widget setDontHaveAcc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 15),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              'ALREADY_HAVE_AN_ACCOUNT'.translate(context: context),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'ubuntu',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (widget.from != 'changePassword')
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  " ${'SIGNIN_LBL'.translate(context: context)}",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 23,
                    left: 23,
                    right: 23,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            backBotton(),
                            signUpTxt(),
                            verifyCodeTxt(),
                            otpTypeToggle(),
                            isEmailMode ? setEmailField() : setCodeWithMono(),
                            verifyBtn(),
                            SizedBox(height: 20),
                            if (widget.title ==
                                'SEND_OTP_TITLE'.translate(context: context))
                              setDontHaveAcc(),
                          ],
                        ),
                        termAndPolicyTxt(),
                      ],
                    ),
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

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: const AppLogo(),
    );
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

  Widget signUpTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 40.0),
      child: Text(
        widget.title == 'SEND_OTP_TITLE'.translate(context: context)
            ? 'SIGN_UP_LBL'.translate(context: context)
            : 'FORGOT_PASSWORDTITILE'.translate(context: context),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.bold,
          fontSize: textFontSize23,
          fontFamily: 'ubuntu',
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
