import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Constant.dart';

class BrandName extends StatelessWidget {
  final String? brandName;
  const BrandName({super.key, this.brandName});

  @override
  Widget build(BuildContext context) {
    return brandName != '' && brandName != null
        ? Container(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
            color: Theme.of(context).colorScheme.white,
            child: ListTile(
              dense: true,
              title: Row(
                children: [
                  Text(
                    'Brand Name : '.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Ubuntu',
                      fontStyle: FontStyle.normal,
                      fontSize: textFontSize16,
                    ),
                  ),
                  Text(
                    brandName!,
                    style: const TextStyle(
                      color: Color(0xffa0a1a0),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Ubuntu',
                      fontStyle: FontStyle.normal,
                      fontSize: textFontSize16,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}
