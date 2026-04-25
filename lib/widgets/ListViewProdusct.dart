import 'dart:async';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:eshop_multivendor/widgets/customfevoritebuttonforCards.dart';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Provider/CartProvider.dart';
import '../Provider/UserProvider.dart';
import 'desing.dart';
import 'customAddCartSection.dart';
import 'networkAvailablity.dart';
import 'snackbar.dart';
import '../Screen/Dashboard/Dashboard.dart';
import '../Screen/Product_Detail/productDetail.dart';
import 'package:collection/src/iterable_extensions.dart';

// ignore: must_be_immutable
class ListIteamListWidget extends StatefulWidget {
  List<Product>? productList;
  final int? index;
  int? length;
  Function setState;
  ListIteamListWidget({
    super.key,
    this.productList,
    required this.index,
    required this.setState,
    this.length,
  });

  @override
  State<ListIteamListWidget> createState() => _ListIteamListWidgetState();
}

class _ListIteamListWidgetState extends State<ListIteamListWidget> {
  final TextEditingController controllerText = TextEditingController();

  @override
  void dispose() {
    controllerText.dispose();

    super.dispose();
  }

  Future<void> removeFromCart(int index) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        if (mounted) {
          isProgress = true;
          widget.setState();
        }

        int qty;

        qty =
            (int.parse(controllerText.text) -
            int.parse(widget.productList![index].qtyStepSize!));

        if (qty < widget.productList![index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: widget.productList![index].prVarientList![0].id,
          // USER_ID: context.read<UserProvider>().userId,
          QTY: qty.toString(),
        };

        apiBaseHelper
            .postAPICall(manageCartApi, parameter)
            .then(
              (getdata) {
                bool error = getdata['error'];
                String? msg = getdata['message'];
                if (!error) {
                  var data = getdata['data'];

                  String? qty = data['total_quantity'];

                  context.read<UserProvider>().setCartCount(data['cart_count']);
                  widget.productList![index].prVarientList![0].cartCount = qty
                      .toString();

                  var cart = getdata['cart'];
                  if (cart is List) {
                    List<SectionModel> cartList = cart
                        .map((cart) => SectionModel.fromCart(cart))
                        .toList();
                    context.read<CartProvider>().setCartlist(cartList);
                  }
                } else {
                  setSnackbar(msg!, context);
                }

                if (mounted) {
                  isProgress = false;
                  widget.setState();
                }
              },
              onError: (error) {
                setSnackbar(error.toString(), context);
                isProgress = false;
                widget.setState();
              },
            );
      } else {
        isProgress = true;
        widget.setState();

        int qty;

        qty =
            (int.parse(controllerText.text) -
            int.parse(widget.productList![index].qtyStepSize!));

        if (qty < widget.productList![index].minOrderQuntity!) {
          qty = 0;
          db.removeCart(
            widget.productList![index].prVarientList![0].id!,
            widget.productList![index].id!,
            context,
          );
          context.read<CartProvider>().removeCartItem(
            widget.productList![index].prVarientList![0].id!,
          );
        } else {
          context.read<CartProvider>().updateCartItem(
            widget.productList![index].id!,
            qty.toString(),
            0,
            widget.productList![index].prVarientList![0].id!,
          );
          db.updateCart(
            widget.productList![index].id!,
            widget.productList![index].prVarientList![0].id!,
            qty.toString(),
          );
        }
        isProgress = false;
        widget.setState();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  Future<void> addToCart(int index, String qty, int from) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        if (mounted) {
          isProgress = true;
          widget.setState();
        }

        if (int.parse(qty) < widget.productList![index].minOrderQuntity!) {
          qty = widget.productList![index].minOrderQuntity.toString();

          setSnackbar("${'MIN_MSG'.translate(context: context)}$qty", context);
        }

        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_VARIENT_ID: widget.productList![index].prVarientList![0].id,
          QTY: qty,
        };

        apiBaseHelper
            .postAPICall(manageCartApi, parameter)
            .then(
              (getdata) {
                bool error = getdata['error'];
                String? msg = getdata['message'];
                if (!error) {
                  var data = getdata['data'];
                  String? qty = data['total_quantity'];
                  context.read<UserProvider>().setCartCount(data['cart_count']);
                  widget.productList![index].prVarientList![0].cartCount = qty
                      .toString();

                  var cart = getdata['cart'];
                  if (cart is List) {
                    List<SectionModel> cartList = cart
                        .map((cart) => SectionModel.fromCart(cart))
                        .toList();
                    context.read<CartProvider>().setCartlist(cartList);
                  }
                } else {
                  setSnackbar(msg!, context);
                }
                if (mounted) {
                  isProgress = false;
                  widget.setState();
                }
              },
              onError: (error) {
                setSnackbar(error.toString(), context);
                if (mounted) {
                  isProgress = false;
                  widget.setState();
                }
              },
            );
      } else {
        isProgress = true;
        widget.setState();

        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' ||
              CurrentSellerID == widget.productList![index].seller_id) {
            CurrentSellerID = widget.productList![index].seller_id!;
            if (from == 1) {
              List<Product>? prList = [];
              prList.add(widget.productList![index]);
              context.read<CartProvider>().addCartItem(
                SectionModel(
                  qty: qty,
                  productList: prList,
                  varientId: widget.productList![index].prVarientList![0].id!,
                  id: widget.productList![index].id,
                  sellerId: widget.productList![index].seller_id,
                ),
              );
              db.insertCart(
                widget.productList![index].id!,
                widget.productList![index].prVarientList![0].id!,
                qty,
                context,
              );
              setSnackbar(
                'PRODUCT_ADDED_TO_CART_LBL'.translate(context: context),
                context,
              );
            } else {
              if (int.parse(qty) >
                  int.parse(widget.productList![index].itemsCounter!.last)) {
                setSnackbar(
                  "${'MAXQTY'.translate(context: context)} ${widget.productList![index].itemsCounter!.last}",
                  context,
                );
              } else {
                context.read<CartProvider>().updateCartItem(
                  widget.productList![index].id!,
                  qty,
                  0,
                  widget.productList![index].prVarientList![0].id!,
                );
                db.updateCart(
                  widget.productList![index].id!,
                  widget.productList![index].prVarientList![0].id!,
                  qty,
                );
                setSnackbar(
                  'Cart Update Successfully'.translate(context: context),
                  context,
                );
              }
            }
          } else {
            setSnackbar(
              'only Single Seller Product Allow'.translate(context: context),
              context,
            );
          }
        } else {
          if (from == 1) {
            List<Product>? prList = [];
            prList.add(widget.productList![index]);
            context.read<CartProvider>().addCartItem(
              SectionModel(
                qty: qty,
                productList: prList,
                varientId: widget.productList![index].prVarientList![0].id!,
                id: widget.productList![index].id,
                sellerId: widget.productList![index].seller_id,
              ),
            );
            db.insertCart(
              widget.productList![index].id!,
              widget.productList![index].prVarientList![0].id!,
              qty,
              context,
            );
            setSnackbar(
              'PRODUCT_ADDED_TO_CART_LBL'.translate(context: context),
              context,
            );
          } else {
            if (int.parse(qty) >
                int.parse(widget.productList![index].itemsCounter!.last)) {
              setSnackbar(
                "${'MAXQTY'.translate(context: context)} ${widget.productList![index].itemsCounter!.last}",
                context,
              );
            } else {
              context.read<CartProvider>().updateCartItem(
                widget.productList![index].id!,
                qty,
                0,
                widget.productList![index].prVarientList![0].id!,
              );
              db.updateCart(
                widget.productList![index].id!,
                widget.productList![index].prVarientList![0].id!,
                qty,
              );
              setSnackbar(
                'Cart Update Successfully'.translate(context: context),
                context,
              );
            }
          }
        }
        isProgress = false;
        widget.setState();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index! < widget.productList!.length) {
      Product model = widget.productList![widget.index!];

      totalProduct = model.total;

      // if (controllerText.length < widget.index! + 1) {
      //   controllerText.add(TextEditingController());
      // }

      double price = double.parse(model.prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![0].price!);
      }

      double off = 0;
      if (model.prVarientList![0].disPrice! != '0') {
        off =
            (double.parse(model.prVarientList![0].price!) -
                    double.parse(model.prVarientList![0].disPrice!))
                .toDouble();
        off = off * 100 / double.parse(model.prVarientList![0].price!);
      }
      return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 5.0,
          end: 2.0,
          top: 5.0,
        ),
        child: Consumer<CartProvider>(
          builder: (context, data, _) {
            final tempId = data.cartList.firstWhereOrNull(
              (cp) =>
                  cp.id == model.id &&
                  cp.varientId == model.prVarientList![0].id!,
            );

            if (tempId != null) {
              controllerText.text = tempId.qty!;
            } else {
              controllerText.text = '0';
            }
            return Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(circularBorderRadius10),
                child: Stack(
                  children: <Widget>[
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Hero(
                            tag:
                                '$heroTagUniqueString${widget.index}${model.id}',
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(circularBorderRadius4),
                                bottomLeft: Radius.circular(
                                  circularBorderRadius4,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  DesignConfiguration.getCacheNotworkImage(
                                    boxFit: extendImg
                                        ? BoxFit.cover
                                        : BoxFit.contain,
                                    context: context,
                                    heightvalue: 110.0,
                                    widthvalue: 110.0,
                                    imageurlString: model.image!,
                                    placeHolderSize: 110,
                                  ),
                                  Positioned.fill(
                                    child:
                                        model.prVarientList![0].availability ==
                                            '0'
                                        ? Container(
                                            height: 55,
                                            color: colors.white70,
                                            padding: const EdgeInsets.all(2),
                                            child: Center(
                                              child: Text(
                                                'OUT_OF_STOCK_LBL'.translate(
                                                  context: context,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const VerticalDivider(
                            width: 0.2,
                            color: Colors.grey,
                            thickness: 0.2,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: 10.0,
                                start: 5.0,
                                end: 35,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.productList![widget.index!].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.fontColor,
                                          fontFamily: 'ubuntu',
                                          // fontWeight: FontWeight.w400,
                                          // fontStyle: FontStyle.normal,
                                          fontSize: textFontSize12,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          DesignConfiguration.getPriceFormat(
                                            context,
                                            price,
                                          )!,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontSize: textFontSize14,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          double.parse(
                                                        widget
                                                            .productList![widget
                                                                .index!]
                                                            .prVarientList![0]
                                                            .disPrice!,
                                                      ) !=
                                                      0 &&
                                                  widget
                                                          .productList![widget
                                                              .index!]
                                                          .prVarientList![0]
                                                          .disPrice! !=
                                                      widget
                                                          .productList![widget
                                                              .index!]
                                                          .prVarientList![0]
                                                          .price!
                                              ? '${DesignConfiguration.getPriceFormat(context, double.parse(widget.productList![widget.index!].prVarientList![0].price!))}'
                                              : '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.lightBlack,
                                                fontFamily: 'ubuntu',
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    colors.darkColor3,
                                                decorationStyle:
                                                    TextDecorationStyle.solid,
                                                decorationThickness: 2,
                                                letterSpacing: 0,
                                                fontSize: textFontSize10,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        off != 0
                                            ? Text(
                                                '${off.toStringAsFixed(2)}%',
                                                style: TextStyle(
                                                  color: colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: textFontSize9,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  widget
                                              .productList![widget.index!]
                                              .noOfRating! !=
                                          '0'
                                      ? SizedBox(
                                          width: 80,
                                          child: RatingCartForProduct(
                                            noOfRating: widget
                                                .productList![widget.index!]
                                                .noOfRating!,
                                            totalRating: widget
                                                .productList![widget.index!]
                                                .rating!,
                                          ),
                                        )
                                      : const SizedBox(height: 30),
                                  const SizedBox(height: 8),
                                  CommonAddCartSection(
                                    controller: controllerText,
                                    model: model,
                                    onAddToCart: () {
                                      addToCart(
                                        widget.index!,
                                        (int.parse(controllerText.text) +
                                                int.parse(model.qtyStepSize!))
                                            .toString(),
                                        1,
                                      );
                                    },
                                    onRemoveFromCart: () {
                                      removeFromCart(widget.index!);
                                    },
                                    onUpdateCart: () {
                                      addToCart(
                                        widget.index!,
                                        (int.parse(controllerText.text) +
                                                int.parse(model.qtyStepSize!))
                                            .toString(),
                                        2,
                                      );
                                    },
                                    itemsCounter: model.itemsCounter!,
                                    onQuantitySelected: (String value) {
                                      addToCart(widget.index!, value, 2);
                                    },
                                    isProgress: isProgress,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CustomFevoriteButtonForCart(model: model),
                    ),
                  ],
                ),
                onTap: () {
                  Product model = widget.productList![widget.index!];
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProductDetail(
                        model: model,
                        index: widget.index,
                        secPos: 0,
                        list: true,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
