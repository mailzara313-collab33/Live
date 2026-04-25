import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Constant.dart';

import '../../FAQsProduct/FaqsProduct.dart';

class AllQuesBtn extends StatelessWidget {
  final String? id;
  const AllQuesBtn({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => FaqsProduct(id),
            ),
          );
        },
        child: Row(
          children: [
            Text(
              'See all answered questions'.translate(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w400,
                fontFamily: 'Ubuntu',
                fontStyle: FontStyle.normal,
                fontSize: textFontSize14,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.navigate_next,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}
