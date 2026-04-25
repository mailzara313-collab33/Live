import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../Helper/Color.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';

// ignore: must_be_immutable
class NoInterNet extends StatelessWidget {
  dynamic setStateNoInternate;
  Animation<dynamic>? buttonSqueezeanimation;
  AnimationController? buttonController;
  NoInterNet(
      {super.key,
      required this.buttonController,
      required this.buttonSqueezeanimation,
      required this.setStateNoInternate});

  Widget noIntImage() {
    return SvgPicture.asset(
      DesignConfiguration.setSvgPath(Assets.noInternet),
      fit: BoxFit.contain,
    );
  }

  Widget noIntText(BuildContext context) {
    return Text(
      'NO_INTERNET'.translate(context: context),
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.normal,
            fontFamily: 'ubuntu',
          ),
    );
  }

  Widget noIntDec(BuildContext context) {
    return Container(
      padding:
          const EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
      child: Text(
        'NO_INTERNET_DISC'.translate(context: context),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.lightBlack2,
              fontWeight: FontWeight.normal,
              fontSize: textFontSize15,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 23),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              noIntImage(),
              noIntText(context),
              noIntDec(context),
              AppBtn(
                title: 'TRY_AGAIN_INT_LBL'.translate(context: context),
                btnAnim: buttonSqueezeanimation,
                btnCntrl: buttonController,
                onBtnSelected: setStateNoInternate,
              )
            ],
          ),
        ),
      ),
    );
  }
}
