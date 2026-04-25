import 'package:flutter/cupertino.dart';
import '../../../Helper/String.dart';
import '../../../Model/Order_Model.dart';

import 'ProductItemdata.dart';

// ignore: must_be_immutable
class GetSingleProduct extends StatelessWidget {
  OrderModel model;
  String activeStatus;
  String id;
  Function updateNow;
  GetSingleProduct({
    super.key,
    required this.id,
    required this.activeStatus,
    required this.model,
    required this.updateNow,
  });

  @override
  Widget build(BuildContext context) {
    var count = 0;
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: model.itemList!.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        var orderItem = model.itemList![i];
        if (activeStatus != '') {
          if (orderItem.status == activeStatus) {
            return ProductItemWidget(
              orderItem: orderItem,
              model: model,
              id: id,
              updateNow: updateNow,
            );
          }
        } else {
          return ProductItemWidget(
            orderItem: orderItem,
            model: model,
            id: id,
            updateNow: updateNow,
          );
        }
        count++;
        if (count == model.itemList!.length) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Text(
                'noItem'.translate(context: context),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
