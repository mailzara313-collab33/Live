import 'dart:async';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/editProfileBottomSheet.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/myProfileDialog.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/changePasswordBottomSheet.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/UserProvider.dart';
import '../../widgets/desing.dart';

import 'widgets/languageBottomSheet.dart';
import 'widgets/themeBottomSheet.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<StatefulWidget> createState() => StateProfile();
}

class StateProfile extends State<MyProfile> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final InAppReview _inAppReview = InAppReview.instance;

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  void setStateNow() {
    setState(() {});
  }

  Widget _getDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'MY_ORDERS_LBL'.translate(context: context),
                Assets.proMyorder,
              ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'MANAGE_ADD_LBL'.translate(context: context),
                Assets.proAddress,
              ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'MYWALLET'.translate(context: context),
                Assets.proWh,
              ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'YOUR_PROM_CO'.translate(context: context),
                Assets.promo,
              ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'MYTRANSACTION'.translate(context: context),
                Assets.proTh,
              ),
        _getDrawerItem(
          'CHANGE_THEME_LBL'.translate(context: context),
          Assets.proTheme,
        ),
        _getDrawerItem(
          'CHANGE_LANGUAGE_LBL'.translate(context: context),
          Assets.proLanguage,
        ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : context.read<UserProvider>().loginType == PHONE_TYPE ||
                  context.read<UserProvider>().loginType == EMAIL_TYPE
            ? _getDrawerItem(
                'CHANGE_PASS_LBL'.translate(context: context),
                Assets.proPass,
              )
            : const SizedBox(),
        context.read<UserProvider>().userId == '' || !refer
            ? const SizedBox()
            : _getDrawerItem(
                'REFEREARN'.translate(context: context),
                Assets.proReferral,
              ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'CUSTOMER_SUPPORT'.translate(context: context),
                Assets.proCustomersupport,
              ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'CHAT'.translate(context: context),
                Assets.proChat,
              ),
        _getDrawerItem(
          'ABOUT_LBL'.translate(context: context),
          Assets.proAboutus,
        ),
        _getDrawerItem(
          'CONTACT_LBL'.translate(context: context),
          Assets.proContactUs,
        ),
        _getDrawerItem('FAQS'.translate(context: context), Assets.proFaq),
        _getDrawerItem('PRIVACY'.translate(context: context), Assets.proPp),
        _getDrawerItem('TERM'.translate(context: context), Assets.proTc),
        _getDrawerItem(
          'SHIPPING_POLICY_LBL'.translate(context: context),
          Assets.proShippingPolicy,
        ),
        _getDrawerItem(
          'RETURN_POLICY_LBL'.translate(context: context),
          Assets.proReturnPolicy,
        ),
        _getDrawerItem('RATE_US'.translate(context: context), Assets.proRateus),
        _getDrawerItem(
          'Share App'.translate(context: context),
          Assets.proShare,
        ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'DeleteAcoountNow'.translate(context: context),
                Assets.deleteUser,
              ),
        context.read<UserProvider>().userId == ''
            ? const SizedBox()
            : _getDrawerItem(
                'LOGOUT'.translate(context: context),
                Assets.proLogout,
              ),
      ],
    );
  }

  Widget _getDrawerItem(String title, String img) {
    return Card(
      elevation: 0.1,
      child: ListTile(
        trailing: const Icon(Icons.navigate_next, color: colors.primary),
        leading: SvgPicture.asset(
          DesignConfiguration.setSvgPath(img),
          height: 25,
          width: 25,
          colorFilter: const ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.lightBlack,
            fontSize: textFontSize15,
          ),
        ),
        onTap: () {
          if (title == 'MY_ORDERS_LBL'.translate(context: context)) {
            Routes.navigateToMyOrderScreen(context);
          } else if (title == 'MYTRANSACTION'.translate(context: context)) {
            Routes.navigateToUserTransactionsScreen(context);
          } else if (title == 'MYWALLET'.translate(context: context)) {
            Routes.navigateToMyWalletScreen(context);
          } else if (title == 'YOUR_PROM_CO'.translate(context: context)) {
            Routes.navigateToPromoCodeScreen(context, 'Profile', setStateNow);
          } else if (title == 'MANAGE_ADD_LBL'.translate(context: context)) {
            Routes.navigateToManageAddressScreen(context, true);
          } else if (title == 'REFEREARN'.translate(context: context)) {
            Routes.navigateToReferEarnScreen(context);
          } else if (title == 'CONTACT_LBL'.translate(context: context)) {
            Routes.navigateToPrivacyPolicyScreen(
              context: context,
              title: 'CONTACT_LBL',
            );
          } else if (title == 'CUSTOMER_SUPPORT'.translate(context: context)) {
            Routes.navigateToCustomerSupportScreen(context);
          } else if (title == 'TERM'.translate(context: context)) {
            Routes.navigateToPrivacyPolicyScreen(
              context: context,
              title: 'TERM',
            );
          } else if (title == 'PRIVACY'.translate(context: context)) {
            Routes.navigateToPrivacyPolicyScreen(
              context: context,
              title: 'PRIVACY',
            );
          } else if (title == 'RATE_US'.translate(context: context)) {
            _openStoreListing();
          } else if (title == 'Share App'.translate(context: context)) {
            shareApp(context);
          } else if (title == 'ABOUT_LBL'.translate(context: context)) {
            Routes.navigateToPrivacyPolicyScreen(
              context: context,
              title: 'ABOUT_LBL',
            );
          } else if (title ==
              'SHIPPING_POLICY_LBL'.translate(context: context)) {
            Routes.navigateToPrivacyPolicyScreen(
              context: context,
              title: 'SHIPPING_POLICY_LBL',
            );
          } else if (title == 'RETURN_POLICY_LBL'.translate(context: context)) {
            Routes.navigateToPrivacyPolicyScreen(
              context: context,
              title: 'RETURN_POLICY_LBL',
            );
          } else if (title == 'FAQS'.translate(context: context)) {
            Routes.navigateToFaqsListScreen(context);
          } else if (title == 'CHAT'.translate(context: context)) {
            if (SINGLE_SELLER_SYSTEM == false) {
              Routes.navigateToConverstationListScreen(context);
            } else {
              Routes.navigateToConverstationScreen(
                context: context,
                personalChatHistory: PersonalChatHistory(
                  id: SINGLE_SELLER_SYSTEM_SELLER_ID,
                  opponentUserId: SINGLE_SELLER_SYSTEM_SELLER_ID,
                  unreadMsg: '0',
                  opponentUsername: '',
                  image: '',
                ),
                isGroup: false,
              );
            }
          } else if (title == 'CHANGE_THEME_LBL'.translate(context: context)) {
            CustomBottomSheet.showBottomSheet(
              child: ThemeBottomSheet(),
              context: context,
              enableDrag: true,
            ).then((value) {
              setState(() {});
              Future.delayed(const Duration(seconds: 3)).then((_) {
                if (mounted) {
                  setState(() {});
                }
              });
            });
          } else if (title == 'LOGOUT'.translate(context: context)) {
            MyProfileDialog.showLogoutDialog(context);
          } else if (title == 'CHANGE_PASS_LBL'.translate(context: context)) {
            CustomBottomSheet.showBottomSheet(
              child: const ChangePasswordBottomSheet(),
              context: context,
              enableDrag: true,
            );
          } else if (title ==
              'CHANGE_LANGUAGE_LBL'.translate(context: context)) {
            CustomBottomSheet.showBottomSheet(
              child: LanguageBottomSheet(),
              context: context,
              enableDrag: true,
            );
          } else if (title == 'DeleteAcoountNow'.translate(context: context)) {
            MyProfileDialog.showDeleteWarningAccountDialog(context);
          }
        },
      ),
    );
  }

  bool _isSharing = false;

  void shareApp(BuildContext context) async {
    if (_isSharing) return; // prevent multiple clicks
    _isSharing = true;

    try {
      var str =
          "$appName\n\n${'APPFIND'.translate(context: context)}${context.read<AppSettingsCubit>().getandroidLink()!}\n\n${'IOSLBL'.translate(context: context)}\n${context.read<AppSettingsCubit>().getiosLink()!}";

      await SharePlus.instance.share(
        ShareParams(
          text: str,
          sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height / 2,
          ),
        ),
      );
    } finally {
      _isSharing = false; // allow sharing again after closing
    }
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
    appStoreId: context.read<AppSettingsCubit>().getAppStoreId()!,
    microsoftStoreId: 'microsoftStoreId',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Consumer<UserProvider>(
        builder: (context, data, child) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: 10.0,
                      top: 10,
                    ),
                    child: Container(
                      padding: const EdgeInsetsDirectional.only(start: 10.0),
                      child: Row(
                        children: [
                          Selector<UserProvider, String>(
                            selector: (_, provider) => provider.profilePic,
                            builder: (context, profileImage, child) {
                              return getUserImage(
                                profileImage,
                                context,
                                () => openEditBottomSheet(context),
                              );
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Selector<UserProvider, String>(
                                selector: (_, provider) => provider.curUserName,
                                builder: (context, userName, child) {
                                  return Text(
                                    userName == ''
                                        ? 'GUEST'.translate(context: context)
                                        : userName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.fontColor,
                                        ),
                                  );
                                },
                              ),
                              Selector<UserProvider, String>(
                                selector: (_, provider) => provider.mob,
                                builder: (context, userMobile, child) {
                                  return userMobile != ''
                                      ? Text(
                                          userMobile,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.fontColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        )
                                      : Container(height: 0);
                                },
                              ),
                              Selector<UserProvider, String>(
                                selector: (_, provider) => provider.email,
                                builder: (context, userEmail, child) {
                                  return userEmail != ''
                                      ? Text(
                                          userEmail,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.fontColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        )
                                      : Container(height: 0);
                                },
                              ),
                              Consumer<UserProvider>(
                                builder: (context, userProvider, _) {
                                  return userProvider.curUserName == ''
                                      ? Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                top: 7,
                                              ),
                                          child: InkWell(
                                            child: Text(
                                              'LOGIN_REGISTER_LBL'.translate(
                                                context: context,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    color: colors.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                            ),
                                            onTap: () {
                                              Routes.navigateToLoginScreen(
                                                context,
                                                classType: const MyProfile(),
                                                isPop: true,
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  _getDrawer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getUserImage(
    String profileImage,
    BuildContext context,
    VoidCallback? onBtnSelected,
  ) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (context.read<UserProvider>().userId != '') {
              onBtnSelected!();
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
                color: Theme.of(context).colorScheme.black,
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
                  onBtnSelected!();
                },
              ),
            ),
          ),
      ],
    );
  }

  void openChangeUserDetailsBottomSheet(BuildContext context) {
    CustomBottomSheet.showBottomSheet(
      child: const EditProfileBottomSheet(),
      context: context,
      enableDrag: true,
    );
  }

  void openEditBottomSheet(BuildContext context) {
    return openChangeUserDetailsBottomSheet(context);
  }
}
