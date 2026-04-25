import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';

import '../../widgets/snackbar.dart';

class ReferEarn extends StatefulWidget {
  const ReferEarn({super.key});

  @override
  State<ReferEarn> createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: getSimpleAppBar('REFEREARN'.translate(context: context), context),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  DesignConfiguration.setSvgPath(Assets.refer),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    'REFEREARN'.translate(context: context),
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'REFER_TEXT'.translate(context: context),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    'YOUR_CODE'.translate(context: context),
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontFamily: 'ubuntu',
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        style: BorderStyle.solid,
                        color: colors.secondary,
                      ),
                      borderRadius:
                          BorderRadius.circular(circularBorderRadius4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        context.read<UserProvider>().referCode,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontFamily: 'ubuntu',
                            ),
                      ),
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.lightWhite,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius4),
                      ),
                    ),
                    child: Text(
                      'TAP_TO_COPY'.translate(context: context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontFamily: 'ubuntu',
                          ),
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: context.read<UserProvider>().referCode));
                    setSnackbar(
                      'Refercode Copied to clipboard'
                          .translate(context: context),
                      context,
                    );
                  },
                ),
                SimBtn(
                  borderRadius: circularBorderRadius5,
                  size: 0.8,
                  title: 'SHARE_APP'.translate(context: context),
                  onBtnSelected: () {
                    var str =
                        "$appName\nRefer Code:${context.read<UserProvider>().referCode}\n${'APPFIND'.translate(context: context)}${context.read<AppSettingsCubit>().getandroidLink()!}\n\n${'IOSLBL'.translate(context: context)}\n${context.read<AppSettingsCubit>().getiosLink()!}";
                    SharePlus.instance.share(ShareParams(
                        text: str,
                        sharePositionOrigin: Rect.fromLTWH(
                            0,
                            0,
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height / 2)));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
