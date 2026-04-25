import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';

import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryPinCode extends StatelessWidget {
  final String deliveryMsg;
  final String deliveryDate;
  final Product? model;
  final Function pincodeCheck;
  final String codDeliveryCharges;
  final String prePaymentDeliveryCharges;
  const DeliveryPinCode({
    super.key,
    this.model,
    required this.pincodeCheck,
    required this.deliveryMsg,
    required this.deliveryDate,
    required this.codDeliveryCharges,
    required this.prePaymentDeliveryCharges,
  });

  @override
  Widget build(BuildContext context) {
    if (model!.productType != 'digital_product') {
      String pin = context.read<UserProvider>().curPincode;

      return Card(
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                pincodeCheck();
              },
              child: ListTile(
                dense: true,
                title: Text(
                  pin == ''
                      ? 'SELOC'.translate(context: context)
                      : 'DELIVERTO'.translate(context: context) + pin,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (deliveryMsg != '')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Text(deliveryMsg,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            if (deliveryDate != '') const Divider(),
            if (deliveryDate != '')
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                child: Row(
                  children: [
                    Text("${'DELIVERY_DAY_LBL'.translate(context: context)}: ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        )),
                    Text(
                      deliveryDate,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    )
                  ],
                ),
              ),
            Row(
              children: [
                if (codDeliveryCharges != '')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5.0),
                    child: Row(
                      children: [
                        Text(
                            "${'COD_CHARGE_LBL'.translate(context: context)}: ",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.lightBlack2,
                            )),
                        Text(
                            '${DesignConfiguration.getPriceFormat(context, double.parse(codDeliveryCharges))}'),
                        const SizedBox(width: 25),
                      ],
                    ),
                  ),
                if (prePaymentDeliveryCharges != '')
                  Row(
                    children: [
                      Text('${'ONLINE_PAY_LBL'.translate(context: context)}: ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack2,
                          )),
                      Text(
                          '${DesignConfiguration.getPriceFormat(context, double.parse(prePaymentDeliveryCharges))}'),
                    ],
                  ),
              ],
            )
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
