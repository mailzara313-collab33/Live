// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:eshop_multivendor/widgets/desing.dart';

//single file to get main logo (vertical) from
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final ColorFilter? colorFilter;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      DesignConfiguration.setSvgPath(Assets.titleicon),
      alignment: Alignment.center,
      height: width ?? 90,
      width: height ?? 90,
      fit: BoxFit.contain,
      colorFilter: colorFilter,
    );
  }
}
