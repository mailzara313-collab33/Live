import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';

class SpeciExtraBtnDetails extends StatelessWidget {
  final Product? model;
  const SpeciExtraBtnDetails({super.key, this.model});

  Widget getImageWithHeading(
      String image, String heading, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            child: SvgPicture.asset(
              DesignConfiguration.setSvgPath(image),
              height: 32.0,
              width: 32.0,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Theme.of(context)
                      .colorScheme
                      .fontColor
                      .withValues(alpha: 0.7),
                  BlendMode.srcIn),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * (0.22),
            child: Text(
              heading,
              style: const TextStyle(
                fontSize: textFontSize12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? cod = model!.codAllowed;
    if (cod == '1') {
      cod = 'COD'.translate(context: context);
    } else {
      cod = 'COD Not Allowed'.translate(context: context);
    }

    String? cancellable = model!.isCancelable;
    if (cancellable == '1') {
      cancellable =
          '${"Cancellable Till".translate(context: context)} ${model!.cancleTill!}';
    } else {
      cancellable = 'No Cancellable'.translate(context: context);
    }

    String? returnable = model!.isReturnable;
    if (returnable == '1') {
      returnable =
          '${RETURN_DAYS!} ${"Days Returnable".translate(context: context)}';
    } else {
      returnable = 'No Returnable'.translate(context: context);
    }

    String? guarantee = model!.gurantee;
    String? warranty = model!.warranty;

    return Container(
      color: Theme.of(context).colorScheme.white,
      width: deviceWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          children: [
            model!.codAllowed == '1'
                ? Expanded(
                    child: getImageWithHeading(
                      Assets.cod,
                      cod,
                      context,
                    ),
                  )
                : Container(
                    width: 0,
                  ),
            Expanded(
              child: getImageWithHeading(
                model!.isCancelable == '1'
                    ? Assets.cancelable
                    : Assets.notcancelable,
                cancellable,
                context,
              ),
            ),
            Expanded(
              child: getImageWithHeading(
                model!.isReturnable == '1'
                    ? Assets.returnable
                    : Assets.notreturnable,
                returnable,
                context,
              ),
            ),
            guarantee != '' && guarantee!.isNotEmpty
                ? Expanded(
                    child: getImageWithHeading(
                      Assets.guarantee,
                      '$guarantee Guarantee',
                      context,
                    ),
                  )
                : Container(
                    width: 0,
                  ),
            warranty != '' && warranty!.isNotEmpty
                ? Expanded(
                    child: getImageWithHeading(
                      Assets.warranty,
                      '$warranty Warranty',
                      context,
                    ),
                  )
                : Container(
                    width: 0,
                  )
          ],
        ),
      ),
    );
  }
}
