import 'dart:io';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/repository/authRepository.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/routes.dart';

import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';
import '../../Auth/SendOtp.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final GlobalKey<FormState> _changePwdKey = GlobalKey<FormState>();

  final confirmPasswordTextController = TextEditingController();

  final newPasswordTextController = TextEditingController();

  final passwordController = TextEditingController();

  String? currentPwd, newPwd, confirmPwd;

  FocusNode confirmPwdFocus = FocusNode();
  bool onlyOneTimeTap = true;
  bool isCurrentPassShow = true;
  bool isNewPassShow = true;
  bool isConfPassShow = true;

  Future<bool> validateAndSave(
    GlobalKey<FormState> key,
    BuildContext context,
  ) async {
    final form = key.currentState!;
    form.save();
    if (form.validate()) {
      if (onlyOneTimeTap) {
        onlyOneTimeTap = false;
        await context
            .read<UserProvider>()
            .updateUserProfile(
              userID: context.read<UserProvider>().userId!,
              newPassword: newPasswordTextController.text,
              oldPassword: passwordController.text,
              username: '',
              userEmail: '',
              userMobile: '',
            )
            .then((value) {
              if (value['error'] == false) {
                setSnackbar(
                  'PASS_CHANGED_SUCCESS'.translate(context: context),
                  context,
                );
                passwordController.clear();
                newPasswordTextController.clear();
                confirmPasswordTextController.clear();
              } else {
                setSnackbar(value['message'], context);
              }
            });

        Routes.pop(context);
      }
      return true;
    }
    return false;
  }

  Widget setCurrentPasswordField(BuildContext context) {
    return PasswordField(
      controller: passwordController,
      labelText: 'CUR_PASS_LBL',
      isPasswordVisible: isCurrentPassShow,
      onToggleVisibility: () {
        setState(() => isCurrentPassShow = !isCurrentPassShow);
      },
      onSaved: (value) => currentPwd = value,
      validator: (val) => StringValidation.validatePass(
        val!,
        'PWD_REQUIRED'.translate(context: context),
        'PASSWORD_VALIDATION'.translate(context: context),
        onlyRequired: true,
      ),
    );
  }

  Widget setForgotPasswordLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          child: Text('FORGOT_PASSWORD_LBL'.translate(context: context)),
          onTap: () async {
            // Fetch latest verification status from server
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
              // If fetch fails, continue with cached values
              print('Failed to fetch verification status: $e');
            }

            // Check verification status
            bool isEmailVerified = context.read<UserProvider>().isEmailVerified;
            bool isMobileVerified = context
                .read<UserProvider>()
                .isMobileVerified;

            String? emailToPass;
            String? mobileToPass;

            // Only pass verified contact methods
            if (isEmailVerified) {
              emailToPass = context.read<UserProvider>().email;
            }
            if (isMobileVerified) {
              mobileToPass = context.read<UserProvider>().mob;
            }

            // If neither is verified, show error
            if (!isEmailVerified && !isMobileVerified) {
              setSnackbar(
                'VERIFY_EMAIL_OR_MOBILE_FIRST'.translate(context: context),
                context,
              );
              return;
            }

            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => SendOtp(
                  title: 'FORGOT_PASS_TITLE'.translate(context: context),
                  mobileNo: mobileToPass,
                  email: emailToPass,
                  from: 'changePassword',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget newPwdField(BuildContext context) {
    return PasswordField(
      controller: newPasswordTextController,
      labelText: 'NEW_PASS_LBL',
      isPasswordVisible: isNewPassShow,
      onToggleVisibility: () {
        setState(() => isNewPassShow = !isNewPassShow);
      },
      onSaved: (value) => newPwd = value,
      validator: (val) => StringValidation.validatePass(
        val!,
        'PWD_REQUIRED'.translate(context: context),
        'PASSWORD_VALIDATION'.translate(context: context),
        onlyRequired: false,
      ),
    );
  }

  Widget confirmPwdField(BuildContext context) {
    return PasswordField(
      controller: confirmPasswordTextController,
      focusNode: confirmPwdFocus,
      labelText: 'CONFIRMPASSHINT_LBL',
      isPasswordVisible: isConfPassShow,
      onToggleVisibility: () {
        setState(() => isConfPassShow = !isConfPassShow);
      },
      fontWeight: FontWeight.bold,
      validator: (value) {
        if (value!.isEmpty) {
          return 'CON_PASS_REQUIRED_MSG'.translate(context: context);
        }
        if (value != newPwd) {
          confirmPwdFocus.requestFocus();
          return 'CON_PASS_NOT_MATCH_MSG'.translate(context: context);
        }
        return null;
      },
    );
  }

  Widget saveButton(
    BuildContext context,
    String title,
    VoidCallback? onBtnSelected,
  ) {
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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _changePwdKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomBottomSheet.bottomSheetHandle(context),
                    CustomBottomSheet.bottomSheetLabel(
                      context,
                      'CHANGE_PASS_LBL',
                    ),
                    setCurrentPasswordField(context),
                    setForgotPasswordLabel(context),
                    newPwdField(context),
                    confirmPwdField(context),
                    Padding(
                      padding: Platform.isIOS
                          ? EdgeInsetsDirectional.symmetric(
                              horizontal: 0,
                              vertical: 10,
                            )
                          : EdgeInsetsDirectional.symmetric(horizontal: 0),
                      child: saveButton(
                        context,
                        'SAVE_LBL'.translate(context: context),
                        () {
                          FocusScope.of(context).unfocus();
                          validateAndSave(_changePwdKey, context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: 0 /*deviceHeight! / 3*/,
              bottom: 0 /*deviceHeight! / 3*/,
              start: 0 /*deviceWidth!/2*/,
              end: 0,
              child: Center(
                child: Selector<UserProvider, UserStatus>(
                  builder: (context, status, child) {
                    if (status == UserStatus.inProgress) {
                      return const CircularProgressIndicator();
                    }
                    return const SizedBox();
                  },
                  selector: (_, provider) => provider.userStatus,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    newPasswordTextController.dispose();
    confirmPasswordTextController.dispose();
    confirmPwdFocus.dispose();
    super.dispose();
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final FontWeight fontWeight;

  const PasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    this.onSaved,
    this.validator,
    this.focusNode,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPasswordVisible,
        obscuringCharacter: '*',
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: fontWeight,
        ),
        decoration: InputDecoration(
          errorMaxLines: 4,
          label: Text(labelText.translate(context: context)),
          fillColor: Theme.of(context).colorScheme.white,
          filled: true,
          labelStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.fontColor.withValues(alpha: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            borderSide: BorderSide(
              width: 1.0,
              color: Theme.of(
                context,
              ).colorScheme.fontColor.withValues(alpha: 0.7),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            borderSide: BorderSide(
              width: 1.0,
              color: Theme.of(
                context,
              ).colorScheme.fontColor.withValues(alpha: 0.7),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            borderSide: BorderSide(
              width: 1.0,
              color: Theme.of(
                context,
              ).colorScheme.fontColor.withValues(alpha: 0.7),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            borderSide: BorderSide(
              width: 1.0,
              color: Theme.of(
                context,
              ).colorScheme.fontColor.withValues(alpha: 0.7),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
          suffixIcon: InkWell(
            onTap: onToggleVisibility,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 10.0),
              child: Icon(
                !isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(
                  context,
                ).colorScheme.fontColor.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
        ),
        onSaved: onSaved,
        validator: validator,
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
      ),
    );
  }
}
