import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/String.dart';
import '../../../widgets/ButtonDesing.dart';
import '../../Product_Detail/Widget/postFaq.dart';

// ignore: must_be_immutable
class BorromBtnWidget extends StatelessWidget {
  String? id;
  Function update;
  BorromBtnWidget({super.key, this.id, required this.update});

  @override
  Widget build(BuildContext context) {
    return context.read<UserProvider>().userId != ''
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Have doubts regarding this product?'
                      .translate(context: context),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 10, bottom: 5),
                  child: SimBtn(
                    onBtnSelected: () {
                      openPostQueBottomSheet(
                        context,
                        id,
                        update,
                      );
                    },
                    title: 'POST YOUR QUESTION'.translate(context: context),
                    height: 38.5,
                    size: deviceWidth! * 0.5,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
