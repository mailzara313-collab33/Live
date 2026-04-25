import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Helper/Constant.dart';
import '../../../widgets/desing.dart';

Widget slider(List slideList, PageController pageController,
    BuildContext context, Function(int) onPageChanged) {
  return Expanded(
    child: PageView.builder(
      itemCount: slideList.length,
      scrollDirection: Axis.horizontal,
      controller: pageController,
      onPageChanged: onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                getImages(index, context, slideList),
                getTitle(index, slideList, context),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget getTitle(int index, List slideList, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        margin:
            const EdgeInsetsDirectional.only(top: 20.0, start: 15.0, end: 15.0),
        child: Text(
          slideList[index].title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontFamily: 'ubuntu',
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      Container(
        padding:
            const EdgeInsetsDirectional.only(top: 15.0, start: 70.0, end: 70.0),
        child: Text(
          slideList[index].description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
                fontSize: textFontSize14,
                fontFamily: 'ubuntu',
              ),
        ),
      )
    ],
  );
}

Widget getImages(int index, BuildContext context, List slideList) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.5,
    child: Theme.of(context).colorScheme.white == const Color(0xffFFFFFF)
        ? SvgPicture.asset(
            DesignConfiguration.setSvgPath(
              slideList[index].imageUrl,
            ),
          )
        : SvgPicture.asset(
            DesignConfiguration.setSvgPath(
              '${slideList[index].imageUrl}_dark',
            ),
          ),
  );
}

List<T?> map<T>(List list, Function handler) {
  List<T?> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}
