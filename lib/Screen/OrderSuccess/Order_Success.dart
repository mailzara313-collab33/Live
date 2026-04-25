import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Dashboard/Dashboard.dart';

class OrderSuccess extends StatefulWidget {
  const OrderSuccess({super.key});

  @override
  State<StatefulWidget> createState() {
    return StateSuccess();
  }
}

class StateSuccess extends State<OrderSuccess> {
  void setStateNow() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Dashboard.dashboardScreenKey = GlobalKey();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => Dashboard(
                      key: Dashboard.dashboardScreenKey,
                    )),
            (route) => false);
      },
      child: Scaffold(
        appBar: getAppBar(
            'ORDER_PLACED'.translate(context: context), context, setStateNow,
            onTap: () {
          Dashboard.dashboardScreenKey = GlobalKey();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Dashboard(
                        key: Dashboard.dashboardScreenKey,
                      )),
              (route) => false);
        }),
        body: Center(
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: SvgPicture.asset(
                  DesignConfiguration.setSvgPath(Assets.bags),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('ORD_PLC'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: textFontSize30,
                    )),
              ),
              Text(
                'ORD_PLC_SUCC'.translate(context: context),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.fontColor),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 28.0),
                child: CupertinoButton(
                  child: Container(
                    width: deviceWidth! * 0.7,
                    height: 45,
                    alignment: FractionalOffset.center,
                    decoration: const BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    child: Text(
                      'CONTINUE_SHOPPING'.translate(context: context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: colors.whiteTemp,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  onPressed: () {
                    Dashboard.dashboardScreenKey = GlobalKey();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Dashboard(
                                  key: Dashboard.dashboardScreenKey,
                                )),
                        (route) => false);
                  },
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}
