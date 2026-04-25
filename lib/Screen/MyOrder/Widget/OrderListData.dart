import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/OrderProvider.dart';
import '../../OrderDetail/OrderDetail.dart';

// ignore: must_be_immutable
class OrderListData extends StatelessWidget {
  OrderModel order;
  BuildContext context1;
  String searchText; //for re-doing the API call on page redirection

  OrderListData({
    super.key,
    required this.order,
    required this.searchText,
    required this.context1,
  });

  String getFilteredOrderStatus({required String status}) {
    switch (status) {
      case 'received':
        return 'Order Placed';
      case 'return_request_pending':
        return 'Return Request Pending';
      case 'return_request_approved':
        return 'Return Request Approved';
      case 'return_request_decline':
        return 'Return Request Declined';
      case 'return_pickedup':
        return 'return pickedup';
      case 'returned':
        return 'returned';
      default:
        return status
            .replaceAll('_', '')
            .replaceAll(RegExp(' +'), ' ')
            .split(' ')
            .map(
              (str) => str.isNotEmpty
                  ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
                  : '',
            )
            .join(' ');
    }
  }

  String getFormattedDate(String? date) {
    if (date == null) return '';
    try {
      return DateFormat(
        'dd MMM, yyyy',
      ).format(DateFormat('dd-MM-yyyy').parse(date));
    } catch (_) {}
    DateTime? dateTime = DateTime.tryParse(date);
    if (dateTime == null) return date;
    return DateFormat('dd MMM, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(circularBorderRadius8),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      '${'ORDER_ID_LBL'.translate(context: context)} #${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontFamily: 'ubuntu',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    getFormattedDate(order.orderDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = order.itemList![index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(circularBorderRadius4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.lightWhite,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  height: 120,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(circularBorderRadius4),
                          topLeft: Radius.circular(circularBorderRadius4),
                        ),
                        child: DesignConfiguration.getCacheNotworkImage(
                          boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                          context: context,
                          heightvalue: 110.0,
                          widthvalue: 110.0,
                          imageurlString: item.image!,
                          placeHolderSize: 110,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                item.name!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.lightBlack,
                                      fontFamily: 'ubuntu',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${'QUANTITY_LBL'.translate(context: context)}: ',
                                    ),
                                    TextSpan(
                                      text: item.qty.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const WidgetSpan(child: SizedBox(width: 8)),
                                    TextSpan(
                                      text:
                                          '${'PRICE_LBL'.translate(context: context)}: ',
                                    ),
                                    TextSpan(
                                      text: DesignConfiguration.getPriceFormat(
                                        context,
                                        double.tryParse(item.price ?? '') ?? 0,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.lightBlack,
                                      fontFamily: 'ubuntu',
                                      fontSize: 14,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional.bottomStart,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(
                                        circularBorderRadius4,
                                      ),
                                    ),
                                    child: Text(
                                      getFilteredOrderStatus(
                                        status: item.status ?? '',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: order.itemList!.length,
            ),
            const SizedBox(height: 8),
          ],
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();
          final result = await Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => OrderDetail(model: order)),
          );

          if (result == 'update') {
            context1.read<OrderProvider>().hasMoreData = true;
            context1.read<OrderProvider>().OrderOffset = 0;
            Future.delayed(Duration(seconds: 3)).then(
              (value) =>
                  context1.read<OrderProvider>().getOrder(context, searchText),
            );
          }
        },
      ),
    );
  }
}
