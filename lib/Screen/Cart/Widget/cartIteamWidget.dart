import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Product_Detail/productDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../widgets/desing.dart';

// ignore: must_be_immutable
class CartIteam extends StatefulWidget {
  List<SectionModel> cartList;
  int index;
  Function setState;
  Function(bool) checkDeliverable;

  CartIteam({
    super.key,
    required this.cartList,
    required this.index,
    required this.setState,
    required this.checkDeliverable,
  });

  @override
  State<CartIteam> createState() => _CartIteamState();
}

class _CartIteamState extends State<CartIteam> {
  @override
  Widget build(BuildContext context) {
    List<SectionModel> cartList = widget.cartList;
    int index = widget.index;
    int selectedPos = 0;
    for (
      int i = 0;
      i < cartList[index].productList![0].prVarientList!.length;
      i++
    ) {
      if (cartList[index].varientId ==
          cartList[index].productList![0].prVarientList![i].id) {
        selectedPos = i;
      }
    }
    // print(
    //     "cartList[index].productList![0].tax! ${cartList[index].productList![0].tax!}");
    // List<String> parts = cartList[index].productList![0].tax!.split(',');
    // double total_tax =
    //     parts.map((e) => double.parse(e)).fold(0.0, (a, b) => a + b);
    // print("total_tax $total_tax");
    cartList[index].perItemTaxPercentage = double.parse(
      cartList[index].productList![0].totalTax!.toString(),
    );

    double price = double.parse(
      cartList[index].productList![0].prVarientList![selectedPos].disPrice!,
    );
    if (price == 0) {
      //Discount price is 0
      price = double.parse(
        cartList[index].productList![0].prVarientList![selectedPos].price!,
      );
    }

    cartList[index].perItemPrice = price.toString();
    cartList[index].perItemTotal = (price * double.parse(cartList[index].qty!))
        .toString();

    //----- Tax calculation
    cartList[index].perItemTaxPriceOnItemsTotal =
        cartList[index].perItemTaxPercentage != 0
        ? ((double.parse(cartList[index].perItemTotal!) *
                  cartList[index].perItemTaxPercentage!) /
              100)
        : 0;

    cartList[index].perItemTaxPriceOnItemAmount =
        cartList[index].perItemTaxPercentage != 0
        ? ((double.parse(cartList[index].perItemPrice!) *
                  cartList[index].perItemTaxPercentage!) /
              100)
        : 0;
    //----- Tax calculation

    context.read<CartProvider>().controller[index].text = cartList[index].qty!;

    List att = [], val = [];
    if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
        '') {
      att = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    String? id, varId;
    bool? available = false;
    String deliveryMsg = '';
    if (context.read<CartProvider>().deliverableList.isNotEmpty) {
      id = cartList[index].id;
      varId = cartList[index].productList![0].prVarientList![selectedPos].id;

      for (
        int i = 0;
        i < context.read<CartProvider>().deliverableList.length;
        i++
      ) {
        if (id == context.read<CartProvider>().deliverableList[i].prodId &&
            varId == context.read<CartProvider>().deliverableList[i].varId) {
          available = context.read<CartProvider>().deliverableList[i].isDel;

          if (context.read<CartProvider>().deliverableList[i].msg != null) {
            deliveryMsg = context.read<CartProvider>().deliverableList[i].msg!;
          }
          break;
        }
      }
    }

    return GestureDetector(
      onTap: () {
        print("selectedPos----$selectedPos");
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetail(
              index: index,
              model: cartList[index].productList![0],
              selectedVarientIndex: selectedPos,
              list: false,
              fromCart: true,
              secPos: selectedPos,
            ),
          ),
        );
      },
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Hero(
                    tag:
                        '$heroTagUniqueString$heroTagUniqueString$index${cartList[index].productList![0].id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        circularBorderRadius7,
                      ),
                      child: DesignConfiguration.getCacheNotworkImage(
                        boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                        context: context,
                        heightvalue: 100.0,
                        widthvalue: 100.0,
                        imageurlString:
                            cartList[index].productList![0].type ==
                                    'variable_product' &&
                                cartList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .images!
                                    .isNotEmpty
                            ? cartList[index]
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .images![0]
                            : cartList[index].productList![0].image!,
                        placeHolderSize: null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    top: 5.0,
                                  ),
                                  child: Text(
                                    cartList[index].productList![0].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontFamily: 'ubuntu',
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.lightBlack,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 8.0,
                                    end: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.fontColor,
                                  ),
                                ),
                                onTap: () {
                                  if (context.read<CartProvider>().isProgress ==
                                      false) {
                                    context.read<CartProvider>().deleteFromCart(
                                      cartList: cartList,
                                      context: context,
                                      index: index,
                                      promoCode: context
                                          .read<CartProvider>()
                                          .promoC
                                          .text,
                                      move: false,
                                      selPos: selectedPos,
                                      update: widget.setState,
                                      from: 3,
                                    );
                                    widget.checkDeliverable(false);
                                  }
                                },
                              ),
                            ],
                          ),
                          cartList[index]
                                          .productList![0]
                                          .prVarientList![selectedPos]
                                          .attr_name !=
                                      '' &&
                                  cartList[index]
                                      .productList![0]
                                      .prVarientList![selectedPos]
                                      .attr_name!
                                      .isNotEmpty
                              ? ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: att.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            att[index].trim() + ':',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                  fontFamily: 'ubuntu',
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.lightBlack,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                start: 5.0,
                                              ),
                                          child: Text(
                                            val[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                  fontFamily: 'ubuntu',
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.lightBlack,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : const SizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Wrap(
                                  // mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      '${DesignConfiguration.getPriceFormat(context, price)!} ',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'ubuntu',
                                      ),
                                    ),
                                    Text(
                                      double.parse(
                                                    cartList[index]
                                                        .productList![0]
                                                        .prVarientList![selectedPos]
                                                        .disPrice!,
                                                  ) !=
                                                  0 &&
                                              cartList[index]
                                                      .productList![0]
                                                      .prVarientList![selectedPos]
                                                      .disPrice! !=
                                                  cartList[index]
                                                      .productList![0]
                                                      .prVarientList![selectedPos]
                                                      .price!
                                          ? DesignConfiguration.getPriceFormat(
                                              context,
                                              double.parse(
                                                cartList[index]
                                                    .productList![0]
                                                    .prVarientList![selectedPos]
                                                    .price!,
                                              ),
                                            )!
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                            fontFamily: 'ubuntu',
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor: colors.darkColor3,
                                            decorationStyle:
                                                TextDecorationStyle.solid,
                                            decorationThickness: 2,
                                            letterSpacing: 0.7,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              cartList[index].productList![0].availability ==
                                          '1' ||
                                      cartList[index]
                                              .productList![0]
                                              .stockType ==
                                          ''
                                  ? Row(
                                      children: <Widget>[
                                        cartList[index].productList![0].type ==
                                                'digital_product'
                                            ? const SizedBox()
                                            : Row(
                                                children: <Widget>[
                                                  InkWell(
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              circularBorderRadius50,
                                                            ),
                                                      ),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                          5.0,
                                                        ),
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (context
                                                              .read<
                                                                CartProvider
                                                              >()
                                                              .isProgress ==
                                                          false) {
                                                        context
                                                            .read<
                                                              CartProvider
                                                            >()
                                                            .removeFromCartCheckout(
                                                              cartList:
                                                                  cartList,
                                                              context: context,
                                                              index: index,
                                                              promoCode: context
                                                                  .read<
                                                                    CartProvider
                                                                  >()
                                                                  .promoC
                                                                  .text,
                                                              remove: false,
                                                              update: widget
                                                                  .setState,
                                                            );
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: Stack(
                                                      children: [
                                                        TextField(
                                                          textAlign:
                                                              TextAlign.center,
                                                          readOnly: true,
                                                          style: TextStyle(
                                                            fontSize:
                                                                textFontSize12,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .fontColor,
                                                          ),
                                                          controller: context
                                                              .read<
                                                                CartProvider
                                                              >()
                                                              .controller[index],
                                                          decoration:
                                                              const InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                        ),
                                                        PopupMenuButton<String>(
                                                          tooltip: '',
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            size: 1,
                                                          ),
                                                          onSelected: (String value) {
                                                            context
                                                                .read<
                                                                  CartProvider
                                                                >()
                                                                .addToCartCheckout(
                                                                  context:
                                                                      context,
                                                                  cartList:
                                                                      cartList,
                                                                  index: index,
                                                                  qty: value,
                                                                  update: widget
                                                                      .setState,
                                                                );
                                                          },
                                                          itemBuilder: (BuildContext context) {
                                                            return cartList[index]
                                                                .productList![0]
                                                                .itemsCounter!
                                                                .map<
                                                                  PopupMenuItem<
                                                                    String
                                                                  >
                                                                >((
                                                                  String value,
                                                                ) {
                                                                  return PopupMenuItem(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                      value,
                                                                      style: TextStyle(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).colorScheme.fontColor,
                                                                        fontFamily:
                                                                            'ubuntu',
                                                                      ),
                                                                    ),
                                                                  );
                                                                })
                                                                .toList();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  InkWell(
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              circularBorderRadius50,
                                                            ),
                                                      ),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                          5.0,
                                                        ),
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (context
                                                              .read<
                                                                CartProvider
                                                              >()
                                                              .isProgress ==
                                                          false) {
                                                        context.read<CartProvider>().addToCartCheckout(
                                                          context: context,
                                                          cartList: cartList,
                                                          index: index,
                                                          qty:
                                                              (int.parse(
                                                                        cartList[index]
                                                                            .qty!,
                                                                      ) +
                                                                      int.parse(
                                                                        cartList[index]
                                                                            .productList![0]
                                                                            .qtyStepSize!,
                                                                      ))
                                                                  .toString(),
                                                          update:
                                                              widget.setState,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NET_AMOUNT'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2,
                    ),
                  ),
                  Text(
                    ' ${DesignConfiguration.getPriceFormat(context, (double.parse(cartList[index].singleItemNetAmount!)))!} x ${cartList[index].qty}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  Text(
                    ' ${DesignConfiguration.getPriceFormat(context, ((double.parse(cartList[index].singleItemNetAmount!)) * double.parse(cartList[index].qty!)))!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TAXPER'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  Text(
                    '${cartList[index].perItemTaxPercentage}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  Text(
                    ' ${DesignConfiguration.getPriceFormat(context, ((double.parse(cartList[index].singleItemTaxAmount!)) * double.parse(cartList[index].qty!)))}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL_LBL'.translate(context: context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.lightBlack2,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  Text(
                    DesignConfiguration.getPriceFormat(
                      context,
                      (((double.parse(cartList[index].singleItemNetAmount!)) *
                              double.parse(cartList[index].qty!)) +
                          (((double.parse(
                                cartList[index].singleItemTaxAmount!,
                              )) *
                              double.parse(cartList[index].qty!)))),
                    )!,
                    style: TextStyle(
                      fontFamily: 'ubuntu',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  ),
                ],
              ),
              if (cartList[index].productList![0].productType !=
                  'digital_product')
                !available! &&
                        context.read<CartProvider>().deliverableList.isNotEmpty
                    ? Text(
                        deliveryMsg != ''
                            ? deliveryMsg
                            : 'NOT_DEL'.translate(context: context),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                          color: colors.red,
                          fontFamily: 'ubuntu',
                        ),
                      )
                    : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
