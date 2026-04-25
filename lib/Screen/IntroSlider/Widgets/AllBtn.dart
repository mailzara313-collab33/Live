import 'package:eshop_multivendor/Screen/Auth/SignInUpAcc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Provider/SettingProvider.dart';

// ignore: must_be_immutable
class SliderBtn extends StatelessWidget {
  int currentPage;
  PageController pageController;
  List sliderList;
  SliderBtn(
      {super.key,
      required this.currentPage,
      required this.pageController,
      required this.sliderList});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: getList(sliderList, context, currentPage)),
        Center(
          child: CupertinoButton(
            child: Container(
              // width: 90,
              height: 50,
              alignment: FractionalOffset.center,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(circularBorderRadius50)),
              child: currentPage == 0 || currentPage == 1
                  ? Text(
                      'NEXT_LBL'.translate(context: context),
                      style: const TextStyle(
                        color: colors.whiteTemp,
                        fontFamily: 'ubuntu',
                      ),
                    )
                  : Text(
                      'GET_STARTED'.translate(context: context),
                      style: const TextStyle(
                        color: colors.whiteTemp,
                        fontFamily: 'ubuntu',
                      ),
                    ),
            ),
            onPressed: () {
              if (currentPage == 2) {
                setPrefrenceBool(ISFIRSTTIME, true);
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => const SignInUpAcc()),
                );
              } else {
                currentPage = currentPage + 1;
                pageController.animateToPage(currentPage,
                    curve: Curves.decelerate,
                    duration: const Duration(milliseconds: 300));
              }
            },
          ),
        ),
      ],
    );
  }
}

Widget skipBtn(BuildContext context, int currentPage) {
  return currentPage == 0 || currentPage == 1
      ? Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () {
                  setPrefrenceBool(ISFIRSTTIME, true);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const SignInUpAcc()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(circularBorderRadius5),
                  ),
                  child: Text(
                    'SKIP'.translate(context: context),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontFamily: 'ubuntu',
                        ),
                  ),
                ),
              ),
            ],
          ),
        )
      : Container(
          // margin: const EdgeInsetsDirectional.only(top: 50.0),
          height: 40,
        );
}

List<Widget> getList(List slideList, BuildContext context, int currentPage) {
  List<Widget> childs = [];

  for (int i = 0; i < slideList.length; i++) {
    childs.add(
      AnimatedContainer(
        // padding: EdgeInsets.symmetric(horizontal: 15),
        duration: const Duration(milliseconds: 200),
        // width: currentPage == i ? 30.0 : 10.0,
        height: 8,
        width: 8,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
          color: currentPage == i
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withValues(
                    alpha: (0.5),
                  ),
        ),
      ),
    );
  }
  return childs;
}
