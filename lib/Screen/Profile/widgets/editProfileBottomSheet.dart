import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Auth/countryCodePickerScreen.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/cubits/loadCountryCodeCubit.dart';
import 'package:eshop_multivendor/repository/authRepository.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';

import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key});

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  FocusNode? passFocus = FocusNode();

  final GlobalKey<FormState> _changeUserDetailsKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  // Track original email to detect changes
  String? originalEmail;
  String? originalMobile;
  // Track if new email/mobile has been verified
  bool isNewEmailVerified = false;
  bool isNewMobileVerified = false;
  // Track if OTP is being sent to prevent multiple clicks
  bool isSendingMobileOtp = false;
  bool isSendingEmailOtp = false;

  // Debounce mechanism - track last OTP send time
  DateTime? _lastMobileOtpSentTime;

  // Firebase Phone Auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;
  bool isSMSGatewayOn = false;

  Widget getUserImage(String profileImage, VoidCallback? onBtnSelected) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (mounted) {
              if (context.read<UserProvider>().userId != '') {
                onBtnSelected!();
              }
            }
          },
          child: Container(
            margin: const EdgeInsetsDirectional.only(end: 20),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1.0,
                color: Theme.of(context).colorScheme.white,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(circularBorderRadius100),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return userProvider.profilePic != ''
                      ? DesignConfiguration.getCacheNotworkImage(
                          boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                          context: context,
                          heightvalue: 64.0,
                          widthvalue: 64.0,
                          placeHolderSize: 64.0,
                          imageurlString: userProvider.profilePic,
                        )
                      : DesignConfiguration.imagePlaceHolder(62, context);
                },
              ),
            ),
          ),
        ),
        if (context.read<UserProvider>().userId != '')
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: 20,
            bottom: 5,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.all(
                  Radius.circular(circularBorderRadius20),
                ),
                border: Border.all(color: colors.primary),
              ),
              child: InkWell(
                child: const Icon(
                  Icons.edit,
                  color: colors.whiteTemp,
                  size: 10,
                ),
                onTap: () {
                  if (mounted) {
                    onBtnSelected!();
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget setNameField({required String userName}) => CustomTextField(
    controller: nameController,
    labelText: 'NAME_LBL',
    validator: (val) => StringValidation.validateUserName(
      val!,
      'USER_REQUIRED'.translate(context: context),
      'USER_LENGTH'.translate(context: context),
      'INVALID_USERNAME_LBL'.translate(context: context),
    ),
  );

  Widget setEmailField({required String email}) {
    // Check if the current email is verified or if login type is Google
    bool isEmailVerified = context.read<UserProvider>().isEmailVerified;
    bool isGoogleLogin = context.read<UserProvider>().loginType == GOOGLE_TYPE;

    bool emailChanged =
        emailController.text.isNotEmpty &&
        emailController.text.trim() != originalEmail?.trim();

    // Show verify button when:
    // 1. Email has changed (new email) and not yet verified, OR
    // 2. Email hasn't changed but original email is not verified
    bool showVerifyButton =
        !isGoogleLogin &&
        ((emailChanged && !isNewEmailVerified) ||
            (!emailChanged && !isEmailVerified));

    // Show verified icon when:
    // 1. Email hasn't changed and original is verified, OR
    // 2. Email has changed and new email is verified, OR
    // 3. Google login (always verified)
    bool showVerifiedIcon =
        isGoogleLogin ||
        (!emailChanged && isEmailVerified) ||
        (emailChanged && isNewEmailVerified);

    return CustomTextField(
      controller: emailController,
      labelText: 'EMAILHINT_LBL',
      readOnly:
          isEmailVerified ||
          isGoogleLogin, // Read-only if verified or Google login
      validator: (val) => StringValidation.validateEmail(
        val!,
        'EMAIL_REQUIRED'.translate(context: context),
        'VALID_EMAIL'.translate(context: context),
      ),
      suffixIcon: showVerifyButton
          ? InkWell(
              onTap: () => _sendEmailVerificationOtp(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'VERIFY'.translate(context: context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : showVerifiedIcon
          ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.verified, color: Colors.green),
            )
          : null,
    );
  }

  Widget setMobileField() {
    // Check if the current mobile is verified
    bool isMobileVerified = context.read<UserProvider>().isMobileVerified;
    bool isGoogleLogin = context.read<UserProvider>().loginType == GOOGLE_TYPE;

    // Check if there's actually a mobile number
    bool hasMobileNumber =
        originalMobile != null && originalMobile!.trim().isNotEmpty;

    bool mobileChanged =
        mobileController.text.isNotEmpty &&
        mobileController.text.trim() != originalMobile?.trim();

    // Show verify button when:
    // 1. Mobile has changed (new mobile) and not yet verified, OR
    // 2. Mobile hasn't changed but original mobile is not verified (and has a mobile number)
    bool showVerifyButton =
        (mobileChanged && !isNewMobileVerified) ||
        (!mobileChanged && hasMobileNumber && !isMobileVerified) &&
            (!isGoogleLogin);

    // Show verified icon when:
    // 1. Mobile hasn't changed and original is verified AND has a mobile number, OR
    // 2. Mobile has changed and new mobile is verified
    bool showVerifiedIcon =
        (!mobileChanged && hasMobileNumber && isMobileVerified) ||
        (mobileChanged && isNewMobileVerified) && (!isGoogleLogin);

    bool isReadOnly = hasMobileNumber && isMobileVerified;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            controller: mobileController,
            readOnly: isReadOnly,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              label: Text(
                'MOBILEHINT_LBL'.translate(context: context),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BlocBuilder<CountryCodeCubit, CountryCodeState>(
                  builder: (context, state) {
                    String code = '';
                    String codeflag = '';

                    if (state is CountryCodeFetchSuccess) {
                      if (state.selectedCountry != null) {
                        code = state.selectedCountry!.callingCode;
                        codeflag = state.selectedCountry!.flag;
                      }
                    }

                    return InkWell(
                      onTap: isReadOnly
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const CountryCodePickerScreen(),
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
                          if (codeflag.isNotEmpty)
                            SizedBox(
                              width: 20,
                              height: 25,
                              child: Image.asset(codeflag),
                            ),
                          if (codeflag.isNotEmpty) const SizedBox(width: 5),
                          Text(
                            code.isEmpty ? 'Select' : code,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.fontColor,
                              fontSize: 16,
                            ),
                          ),
                          if (!isReadOnly)
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).colorScheme.fontColor,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              suffixIcon: showVerifyButton
                  ? InkWell(
                      onTap: () => _sendMobileVerificationOtp(),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'VERIFY'.translate(context: context),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : showVerifiedIcon
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.verified, color: Colors.green),
                    )
                  : null,
              fillColor: Theme.of(context).colorScheme.primary,
              border: InputBorder.none,
            ),
            validator: (val) => StringValidation.validateMob(
              val!,
              'MOB_REQUIRED'.translate(context: context),
              'VALID_MOB'.translate(context: context),
              check: false,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      ),
    );
  }

  Widget saveButton({required String title, VoidCallback? onBtnSelected}) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 8.0,
            ),
            child: InkWell(
              onTap: onBtnSelected,
              child: Container(
                height: 45.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.grad1Color, colors.grad2Color],
                    stops: [0, 1],
                  ),
                  borderRadius: BorderRadius.circular(circularBorderRadius10),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: textFontSize16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _imgFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'],
    );
    if (result != null) {
      var image = File(result.files.single.path!);
      if (mounted) {
        Map result = await context
            .read<UserProvider>()
            .updateUserProfilePicture(image: image, context: context);

        if (!result['error']) {
          String? imageURL;
          var data = result['data'];

          for (var i in data) {
            imageURL = i[IMAGE];
          }

          await Provider.of<SettingProvider>(
            context,
            listen: false,
          ).setPrefrence(IMAGE, imageURL!);
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setProfilePic(imageURL);
          setSnackbar(
            'PROFILE_UPDATE_MSG'.translate(context: context),
            context,
          );
          Routes.pop(context);
        } else {
          setSnackbar(result['message'], context);
        }
      }
    } else {
      // User canceled the picker
    }
  }

  Future<bool> validateAndSave(
    GlobalKey<FormState> key,
    BuildContext context,
  ) async {
    final form = key.currentState!;
    form.save();
    if (form.validate()) {
      bool isGoogleLogin =
          context.read<UserProvider>().loginType == GOOGLE_TYPE;

      bool emailChanged = emailController.text.trim() != originalEmail;

      // If login type is Google, prevent email changes
      if (isGoogleLogin && emailChanged) {
        setSnackbar(
          'CANNOT_CHANGE_GOOGLE_EMAIL'.translate(context: context),
          context,
        );
        return false;
      }

      // // If email is already verified, prevent changes
      // if (isEmailVerified && emailChanged) {
      //   setSnackbar(
      //     'CANNOT_CHANGE_VERIFIED_EMAIL'.translate(context: context),
      //     context,
      //   );
      //   return false;
      // }

      // // If mobile is already verified and not using Google login, prevent changes
      // if (isMobileVerified && mobileChanged && !isGoogleLogin) {
      //   setSnackbar(
      //     'CANNOT_CHANGE_VERIFIED_MOBILE'.translate(context: context),
      //     context,
      //   );
      //   return false;
      // }

      // Get selected country code
      String selectedCountryCode = context
          .read<CountryCodeCubit>()
          .getSelectedCountryCode();

      await context
          .read<UserProvider>()
          .updateUserProfile(
            userID: context.read<UserProvider>().userId!,
            newPassword: '',
            oldPassword: '',
            username: nameController.text,
            userEmail: emailController.text,
            userMobile: mobileController.text,
            countryCode: selectedCountryCode,
          )
          .then((value) {
            if (value['error'] == false) {
              var settingProvider = Provider.of<SettingProvider>(
                context,
                listen: false,
              );
              var userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );

              settingProvider.setPrefrence(USERNAME, nameController.text);
              userProvider.setName(nameController.text);

              // Update email and mobile in local storage
              settingProvider.setPrefrence(EMAIL, emailController.text);
              userProvider.setEmail(emailController.text);

              settingProvider.setPrefrence(MOBILE, mobileController.text);
              userProvider.setMobile(mobileController.text);

              // Save country code to local storage
              if (selectedCountryCode.isNotEmpty) {
                settingProvider.setPrefrence(
                  'countryCode',
                  selectedCountryCode,
                );
                userProvider.setCountrycode(selectedCountryCode);
              }

              // Update verification status if new email/mobile was verified
              if (isNewEmailVerified) {
                userProvider.setEmailVerified(true);
              }
              if (isNewMobileVerified) {
                userProvider.setMobileVerified(true);
              }

              setSnackbar(
                'USER_UPDATE_MSG'.translate(context: context),
                context,
              );
            } else {
              setSnackbar(value['message'], context);
            }
          });

      Routes.pop(context);

      return true;
    }
    return false;
  }

  Future<void> _sendEmailVerificationOtp() async {
    // Prevent multiple clicks
    if (isSendingEmailOtp) return;

    // Validate email format first
    String email = emailController.text.trim();
    String? emailError = StringValidation.validateEmail(
      email,
      'EMAIL_REQUIRED'.translate(context: context),
      'VALID_EMAIL'.translate(context: context),
    );

    if (emailError != null) {
      setSnackbar(emailError, context);
      return;
    }

    setState(() {
      isSendingEmailOtp = true;
    });

    try {
      // Send OTP to new email
      var response = await AuthRepository.sendProfileEmailVerificationOtp(
        email: email,
      );

      if (response['error'] == false) {
        // Show OTP verification dialog
        await _showOtpVerificationDialog(email);
      } else {
        setSnackbar(response['message'] ?? 'Failed to send OTP', context);
      }
    } catch (e) {
      setSnackbar(e.toString(), context);
    } finally {
      if (mounted) {
        setState(() {
          isSendingEmailOtp = false;
        });
      }
    }
  }

  Future<void> _showOtpVerificationDialog(String email) async {
    String otpCode = '';
    String? errorMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('VERIFY_EMAIL'.translate(context: context)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${'ENTER_OTP_SENT_TO'.translate(context: context)} $email',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontSize: textFontSize16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ENTER_OTP'.translate(context: context),
                      hintStyle: Theme.of(context).textTheme.titleSmall!
                          .copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.fontColor.withValues(alpha: 0.5),
                            fontWeight: FontWeight.normal,
                          ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.lightWhite,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      counterStyle: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      errorText: errorMessage,
                      errorStyle: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                        borderRadius: BorderRadius.circular(
                          circularBorderRadius10,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.lightWhite,
                        ),
                        borderRadius: BorderRadius.circular(
                          circularBorderRadius10,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      otpCode = value;
                      // Clear error when user types
                      if (errorMessage != null) {
                        setDialogState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('CANCEL'.translate(context: context)),
                ),
                TextButton(
                  onPressed: () async {
                    if (otpCode.length == 6) {
                      Navigator.pop(dialogContext);
                      await _verifyProfileEmailOtp(email, otpCode);
                    } else {
                      // Dismiss keyboard first
                      FocusScope.of(dialogContext).unfocus();
                      // Show error in dialog
                      setDialogState(() {
                        errorMessage = 'ENTER_VALID_OTP'.translate(
                          context: context,
                        );
                      });
                    }
                  },
                  child: Text('VERIFY'.translate(context: context)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _verifyProfileEmailOtp(String email, String otp) async {
    try {
      var response = await AuthRepository.verifyProfileEmail(
        email: email,
        otp: otp,
      );

      if (response['error'] == false) {
        setState(() {
          isNewEmailVerified = true;
        });
        setSnackbar(
          'EMAIL_VERIFIED_SUCCESS'.translate(context: context),
          context,
        );

        // Update local provider with new email
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        var settingProvider = Provider.of<SettingProvider>(
          context,
          listen: false,
        );

        userProvider.setEmail(email);
        settingProvider.setPrefrence(EMAIL, email);
      } else {
        setSnackbar(response['message'] ?? 'Invalid OTP', context);
      }
    } catch (e) {
      setSnackbar(e.toString(), context);
    }
  }

  Future<void> _sendMobileVerificationOtp() async {
    // Prevent multiple clicks
    if (isSendingMobileOtp) return;

    // Debounce: Check if enough time has passed since last OTP send (60 seconds)
    if (_lastMobileOtpSentTime != null) {
      final timeSinceLastSend = DateTime.now().difference(
        _lastMobileOtpSentTime!,
      );
      if (timeSinceLastSend.inSeconds < 60) {
        final remainingSeconds = 60 - timeSinceLastSend.inSeconds;
        setSnackbar(
          'Please wait $remainingSeconds seconds before resending OTP'
              .translate(context: context),
          context,
        );
        return;
      }
    }

    // Set flag immediately to prevent race condition
    setState(() {
      isSendingMobileOtp = true;
    });

    // Validate mobile format first
    String mobile = mobileController.text.trim();
    String? mobileError = StringValidation.validateMob(
      mobile,
      'MOB_REQUIRED'.translate(context: context),
      'VALID_MOB'.translate(context: context),
      check: false,
    );

    if (mobileError != null) {
      setSnackbar(mobileError, context);
      setState(() {
        isSendingMobileOtp = false;
      });
      return;
    }

    try {
      String countryCode = context
          .read<CountryCodeCubit>()
          .getSelectedCountryCode();

      if (countryCode.isEmpty) {
        setSnackbar(
          'Please select a country code'.translate(context: context),
          context,
        );
        if (mounted) {
          setState(() {
            isSendingMobileOtp = false;
          });
        }
        return;
      }

      isSMSGatewayOn = context.read<AppSettingsCubit>().isSMSGatewayActive();

      if (isSMSGatewayOn) {
        // Remove '+' from country code for SMS gateway (API expects numbers only)
        String smsCountryCode = countryCode.replaceAll('+', '');

        await AuthRepository.resendOtp(
          mobileNumber: mobile,
          country_code: smsCountryCode,
        );

        // Update timestamp after successful OTP send
        _lastMobileOtpSentTime = DateTime.now();

        // Reset loading flag and show OTP dialog
        if (mounted) {
          setState(() {
            isSendingMobileOtp = false;
          });
          _showMobileOtpVerificationDialog(mobile);
        }
      } else {
        // Use Firebase Phone Authentication
        if (!countryCode.startsWith('+')) {
          countryCode = '+$countryCode';
        }

        String cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '');
        String cleanCountryCode = countryCode.replaceAll('+', '');
        String phoneNumber = '+$cleanCountryCode$cleanMobile';

        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (mounted) {
              setState(() {
                isSendingMobileOtp = false;
              });
            }

            try {
              await _firebaseAuth.signInWithCredential(credential);

              if (mounted) {
                await _verifyProfileMobileWithBackend(mobile);
              }
            } catch (e) {
              if (mounted) {
                setSnackbar(e.toString(), context);
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              setState(() {
                isSendingMobileOtp = false;
              });
              setSnackbar(
                e.message ?? 'VERIFICATION_FAILED'.translate(context: context),
                context,
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _lastMobileOtpSentTime = DateTime.now(); // Update timestamp

            if (mounted) {
              setState(() {
                isSendingMobileOtp = false;
              });

              _showMobileOtpVerificationDialog(mobile);
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
          forceResendingToken: _resendToken,
        );
      }
    } catch (e) {
      setSnackbar(e.toString(), context);
      if (mounted) {
        setState(() {
          isSendingMobileOtp = false;
        });
      }
    }
  }

  Future<void> _showMobileOtpVerificationDialog(String mobile) async {
    String otpCode = '';
    String? errorMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'VERIFY_MOBILE'.translate(context: context),
                style: Theme.of(this.context).textTheme.titleMedium!.copyWith(
                  fontFamily: 'ubuntu',
                  color: Theme.of(context).colorScheme.fontColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${'ENTER_OTP_SENT_TO'.translate(context: context)} $mobile',
                    style: Theme.of(this.context).textTheme.bodyMedium!
                        .copyWith(
                          fontFamily: 'ubuntu',
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontSize: textFontSize16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ENTER_OTP'.translate(context: context),
                      hintStyle: Theme.of(context).textTheme.titleSmall!
                          .copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.fontColor.withValues(alpha: 0.5),
                            fontWeight: FontWeight.normal,
                          ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.lightWhite,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      counterStyle: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      errorText: errorMessage,
                      errorStyle: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                        borderRadius: BorderRadius.circular(
                          circularBorderRadius10,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.lightWhite,
                        ),
                        borderRadius: BorderRadius.circular(
                          circularBorderRadius10,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      otpCode = value;
                      // Clear error when user types
                      if (errorMessage != null) {
                        setDialogState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  // Resend OTP button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _sendMobileVerificationOtp();
                      },
                      child: Text(
                        'RESEND_OTP'.translate(context: context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('CANCEL'.translate(context: context)),
                ),
                TextButton(
                  onPressed: () async {
                    if (otpCode.length == 6) {
                      Navigator.pop(dialogContext);
                      await _verifyProfileMobileOtp(mobile, otpCode);
                    } else {
                      // Dismiss keyboard first
                      FocusScope.of(dialogContext).unfocus();
                      // Show error in dialog
                      setDialogState(() {
                        errorMessage = 'ENTER_VALID_OTP'.translate(
                          context: context,
                        );
                      });
                    }
                  },
                  child: Text('VERIFY'.translate(context: context)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _verifyProfileMobileOtp(String mobile, String otp) async {
    if (isSMSGatewayOn) {
      try {
        await AuthRepository.verifyOtp(mobileNumber: mobile, otp: otp);
        await _verifyProfileMobileWithBackend(mobile);
      } catch (e) {
        setSnackbar(e.toString(), context);
      }
    } else {
      try {
        if (_verificationId == null) {
          setSnackbar(
            'VERIFICATION_ERROR'.translate(context: context),
            context,
          );
          return;
        }

        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );

        await _firebaseAuth.signInWithCredential(credential);

        await _verifyProfileMobileWithBackend(mobile);
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        if (e.code == 'invalid-verification-code') {
          errorMessage = 'INVALID_OTP'.translate(context: context);
        } else {
          errorMessage =
              e.message ?? 'VERIFICATION_FAILED'.translate(context: context);
        }

        setSnackbar(errorMessage, context);
      } catch (e) {
        setSnackbar(e.toString(), context);
      }
    }
  }

  Future<void> _verifyProfileMobileWithBackend(String mobile) async {
    try {
      var response = await AuthRepository.verifyProfileMobile(mobile: mobile);

      if (response['error'] == false) {
        setState(() {
          isNewMobileVerified = true;
        });
        setSnackbar(
          'MOBILE_VERIFIED_SUCCESS'.translate(context: context),
          context,
        );

        // Update local provider with new mobile
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        var settingProvider = Provider.of<SettingProvider>(
          context,
          listen: false,
        );

        // Get the selected country code from CountryCodeCubit
        String selectedCountryCode = context
            .read<CountryCodeCubit>()
            .getSelectedCountryCode();

        userProvider.setMobile(mobile);
        settingProvider.setPrefrence(MOBILE, mobile);
        userProvider.setMobileVerified(true);

        // Save the selected country code to user profile
        if (selectedCountryCode.isNotEmpty) {
          userProvider.setCountrycode(selectedCountryCode);
          settingProvider.setPrefrence('countryCode', selectedCountryCode);
        }
      } else {
        setSnackbar(
          response['message'] ??
              'BACKEND_VERIFICATION_FAILED'.translate(context: context),
          context,
        );
      }
    } catch (e) {
      setSnackbar(e.toString(), context);
    }
  }

  @override
  void initState() {
    // Load country codes (same as SendOtp screen)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CountryCodeCubit>().loadAllCountryCode(context);
      // After loading country codes, restore user's saved country code
      _restoreSavedCountryCode();
    });

    Future.delayed(Duration.zero).then((value) async {
      nameController.text = context.read<UserProvider>().curUserName;
      emailController.text = context.read<UserProvider>().email;
      mobileController.text = context.read<UserProvider>().mob;
      // Save original email and mobile for comparison
      originalEmail = context.read<UserProvider>().email;
      originalMobile = context.read<UserProvider>().mob;

      // Fetch verification status
      await _fetchVerificationStatus();
    });

    // Add listeners to update UI when email/mobile changes
    emailController.addListener(() {
      if (mounted) setState(() {});
    });

    mobileController.addListener(() {
      if (mounted) setState(() {});
    });

    super.initState();
  }

  Future<void> _fetchVerificationStatus() async {
    try {
      var response = await AuthRepository.getVerificationStatus();
      if (response['error'] == false && mounted) {
        var data = response['data'];
        context.read<UserProvider>().setEmailVerified(
          data['email_verified'] == 1,
        );
        context.read<UserProvider>().setMobileVerified(
          data['mobile_verified'] == 1,
        );
      }
    } catch (e) {
      setSnackbar(e.toString(), context);
    }
  }

  // Restore user's saved country code
  void _restoreSavedCountryCode() {
    try {
      final userProvider = context.read<UserProvider>();
      final savedCountryCode = userProvider.countryCode;

      if (savedCountryCode.isNotEmpty) {
        final countryCodeCubit = context.read<CountryCodeCubit>();
        final state = countryCodeCubit.state;

        if (state is CountryCodeFetchSuccess && state.countryList != null) {
          // Find the country with matching calling code
          try {
            final country = state.countryList!.firstWhere(
              (c) =>
                  c.callingCode == savedCountryCode ||
                  c.callingCode == '+$savedCountryCode',
            );
            countryCodeCubit.selectCountryCode(country);
          } catch (e) {
            // Country not found, use default
            print('Country code not found: $savedCountryCode');
          }
        }
      }
    } catch (e) {
      print('Error restoring country code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _changeUserDetailsKey,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomBottomSheet.bottomSheetHandle(context),
                            CustomBottomSheet.bottomSheetLabel(
                              context,
                              'EDIT_PROFILE_LBL',
                            ),
                            Selector<UserProvider, String>(
                              selector: (_, provider) => provider.profilePic,
                              builder: (context, profileImage, child) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: getUserImage(
                                    profileImage,
                                    _imgFromGallery,
                                  ),
                                );
                              },
                            ),
                            Selector<UserProvider, String>(
                              selector: (_, provider) => provider.curUserName,
                              builder: (context, userName, child) {
                                return setNameField(userName: userName);
                              },
                            ),
                            Selector<UserProvider, String>(
                              selector: (_, provider) => provider.email,
                              builder: (context, userEmail, child) {
                                return setEmailField(email: userEmail);
                              },
                            ),
                            Selector<UserProvider, String>(
                              selector: (_, provider) => provider.mob,
                              builder: (context, userMob, child) {
                                return setMobileField();
                              },
                            ),
                            Padding(
                              padding: Platform.isIOS
                                  ? EdgeInsetsDirectional.symmetric(
                                      horizontal: 0,
                                      vertical: 10,
                                    )
                                  : EdgeInsetsDirectional.symmetric(
                                      horizontal: 0,
                                    ),
                              child: saveButton(
                                title: 'SAVE_LBL'.translate(context: context),
                                onBtnSelected: () {
                                  if (context.read<UserProvider>().userStatus !=
                                      UserStatus.inProgress) {
                                    validateAndSave(
                                      _changeUserDetailsKey,
                                      context,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        if (userProvider.userStatus == UserStatus.inProgress)
                          SizedBox(
                            height:
                                constraints.maxHeight *
                                0.5, // Adjust the percentage as needed
                            child: Center(
                              child: DesignConfiguration.showCircularProgress(
                                true,
                                colors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool readOnly;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              label: Text(
                labelText.translate(context: context),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              suffixIcon: suffixIcon,
              fillColor: Theme.of(context).colorScheme.primary,
              border: InputBorder.none,
            ),
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      ),
    );
  }
}
