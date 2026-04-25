import 'package:flutter/material.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Order_Model.dart';

Widget getPlaced(String? pDate, BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(
        Icons.circle,
        color: pDate == '' ? Colors.grey : colors.primary,
        size: 15,
      ),
      Container(
        margin: const EdgeInsetsDirectional.only(start: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ORDER_PLACED'.translate(context: context),
              style: const TextStyle(fontSize: textFontSize8),
            ),
            Text(
              pDate ?? '',
              style: const TextStyle(fontSize: textFontSize8),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget getProcessed(String? prDate, String? cDate, BuildContext context) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: prDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: prDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ORDER_PROCESSED'.translate(context: context),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    prDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                ],
              ),
            ),
          ],
        )
      : prDate == null
          ? const SizedBox()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER_PROCESSED'.translate(context: context),
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                      Text(
                        prDate,
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                    ],
                  ),
                ),
              ],
            );
}

Widget getShipped(
  String? sDate,
  String? cDate,
  BuildContext context,
) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: sDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: sDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER_SHIPPED'.translate(context: context),
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    sDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                ],
              ),
            ),
          ],
        )
      : sDate == null
          ? const SizedBox()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER_SHIPPED'.translate(context: context),
                        style: const TextStyle(fontSize: textFontSize8),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        sDate,
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                    ],
                  ),
                ),
              ],
            );
}

Widget getDelivered(
  String? dDate,
  String? cDate,
  BuildContext context,
) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: dDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: dDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER_DELIVERED'.translate(context: context),
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

Widget getCanceled(String? cDate, BuildContext context) {
  return cDate != null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.cancel_rounded,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER_CANCLED'.translate(context: context),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    cDate,
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

Widget getPickupAccept(
  OrderItem item,
  String? returnPickupDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURNED)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.no_crash_outlined,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RETURN_PICKUP'.translate(context: context),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    returnPickupDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

Widget getReturned(
  OrderItem item,
  String? rDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURNED)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER_RETURNED'.translate(context: context),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    rDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

Widget getReturneRequestPending(
  OrderItem item,
  String? repDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURN_REQ_PENDING)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.pending,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RETURN_REQUEST_PENDING_LBL'.translate(context: context),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    repDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

Widget getReturneRequestApproved(
  OrderItem item,
  String? reapDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURN_REQ_APPROVED)
      ? Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.approval,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RETURN_REQUEST_APPROVED_LBL'
                            .translate(context: context),
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                      Text(
                        reapDate ?? ' ',
                        style: const TextStyle(fontSize: textFontSize8),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.returnRequestRemark != '')
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: colors.green.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(circularBorderRadius8)),
                      child: Text(
                        '${'Remark'.translate(context: context)} : ${item.returnRequestRemark}',
                        style: TextStyle(color: colors.green, fontSize: 12),
                      ),
                    ),
                  ))
          ],
        )
      : const SizedBox();
}

Widget getReturneRequestDecline(
  OrderItem item,
  String? redDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURN_REQ_DECLINE)
      ? Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.cancel_rounded,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RETURN_REQUEST_DECLINE_LBL'
                            .translate(context: context),
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                      Text(
                        redDate ?? ' ',
                        style: const TextStyle(fontSize: textFontSize8),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.returnRequestRemark != '')
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(circularBorderRadius8)),
                      child: Text(
                        '${'Remark'.translate(context: context)} : ${item.returnRequestRemark}',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ))
          ],
        )
      : const SizedBox();
}
