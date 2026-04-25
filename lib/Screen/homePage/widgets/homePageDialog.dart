import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Helper/String.dart';
import '../../../widgets/desing.dart';

class HomePageDialog {
  static Future<void> showUnderMaintenanceDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    circularBorderRadius5,
                  ),
                ),
              ),
              title: Text(
                'APP_MAINTENANCE'.translate(context: context),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
                  Container(
                    child: Lottie.asset(
                      DesignConfiguration.setLottiePath(
                          Assets.appMaintenanceName),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    MAINTENANCE_MESSAGE != ''
                        ? '$MAINTENANCE_MESSAGE'
                        : 'MAINTENANCE_DEFAULT_MESSAGE'
                            .translate(context: context),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.normal,
                      fontSize: textFontSize12,
                      fontFamily: 'ubuntu',
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Future<void> showAppUpdateDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(circularBorderRadius5),
              ),
            ),
            title: Text('UPDATE_APP'.translate(context: context)),
            content: Text(
              'UPDATE_AVAIL'.translate(context: context),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'NO'.translate(context: context),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  'YES'.translate(context: context),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop(false);

                  String url = '';
                  if (Platform.isAndroid) {
                    url = context.read<AppSettingsCubit>().getandroidLink()!;
                  } else if (Platform.isIOS) {
                    url = context.read<AppSettingsCubit>().getiosLink()!;
                  }

                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }
}
