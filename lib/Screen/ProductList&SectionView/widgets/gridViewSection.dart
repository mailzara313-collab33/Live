import 'dart:async';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/widgets/customfevoritebuttonforCards.dart';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/customAddCartSection.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Product_Detail/productDetail.dart';
import '../SectionList.dart';
import 'package:collection/src/iterable_extensions.dart';

// ignore: must_be_immutable
class GridViewWidget extends StatefulWidget {
  final int? index;
  SectionModel? section_model;
  final int from;
  Function setState;

  GridViewWidget({
    super.key,
    this.index,
    this.section_model,
    required this.from,
    required this.setState,
  });

  @override
  State<GridViewWidget> createState() => _GridViewWidgetState();
}

class _GridViewWidgetState extends State<GridViewWidget> {
  final TextEditingController controllerText = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controllerText.dispose();

    super.dispose();
  }

  Future<void> removeFav(int index) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        widget.section_model!.productList![index].isFavLoading = true;
        widget.setState();

        var parameter = {
          PRODUCT_ID: widget.section_model!.productList![index].id,
        };
        ApiBaseHelper()
            .postAPICall(removeFavApi, parameter)
            .then(
              (getdata) {
                bool error = getdata['error'];
                String? msg = getdata['message'];
                if (!error) {
                  widget.section_model!.productList![index].isFav = '0';

                  context.read<FavoriteProvider>().removeFavItem(
                    widget
                        .section_model!
                        .productList![index]
                        .prVarientList![0]
                        .id!,
                  );
                  setSnackbar(msg!, context);
                } else {
                  setSnackbar(msg!, context);
                }

                widget.section_model!.productList![index].isFavLoading = false;
                widget.setState();
              },
              onError: (error) {
                setSnackbar(error.toString(), context);
              },
            );
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), context);
      }
    } else {
      isNetworkAvail = false;
      widget.setState();
    }
  }

  // Future<void> _setFav(int index) async {
  //   isNetworkAvail = await isNetworkAvailable();
  //   if (isNetworkAvail) {
  //     try {
  //       if (mounted) {
  //         widget.section_model!.productList![index].isFavLoading = true;
  //         widget.setState();
  //       }

  //       var parameter = {
  //         PRODUCT_ID: widget.section_model!.productList![index].id
  //       };

  //       ApiBaseHelper().postAPICall(setFavoriteApi, parameter).then(
  //         (getdata) {
  //           bool error = getdata['error'];
  //           String? msg = getdata['message'];
  //           if (!error) {
  //             widget.section_model!.productList![index].isFav = '1';
  //             context
  //                 .read<FavoriteProvider>()
  //                 .addFavItem(widget.section_model!.productList![index]);
  //             setSnackbar(msg!, context);
  //           } else {
  //             setSnackbar(msg!, context);
  //           }

  //           if (mounted) {
  //             widget.section_model!.productList![index].isFavLoading = false;
  //             widget.setState();
  //           }
  //         },
  //         onError: (error) {
  //           setSnackbar(error.toString(), context);
  //         },
  //       );
  //     } on TimeoutException catch (_) {
  //       setSnackbar('somethingMSg'.translate(context: context), context);
  //     }
  //   } else {
  //     if (mounted) {
  //       isNetworkAvail = false;
  //       widget.setState();
  //     }
  //   }
  // }

  Future<void> removeFromCart(int index) async {
    Product model;
    if (widget.from == 1) {
      model = widget.section_model!.productList![index];
    } else {
      model = widget.section_model!.productList![index];
    }
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        try {
          if (mounted) {
            isProgress = true;
            widget.setState();
          }

          int qty;

          qty =
              (int.parse(controllerText.text) - int.parse(model.qtyStepSize!));

          if (qty < model.minOrderQuntity!) {
            qty = 0;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![0].id,
            QTY: qty.toString(),
          };
          ApiBaseHelper()
              .postAPICall(manageCartApi, parameter)
              .then(
                (getdata) {
                  bool error = getdata['error'];
                  String? msg = getdata['message'];
                  if (!error) {
                    var data = getdata['data'];

                    String? qty = data['total_quantity'];

                    userProvider.setCartCount(data['cart_count']);
                    model.prVarientList![0].cartCount = qty.toString();

                    var cart = getdata['cart'];
                    if (cart is List) {
                      List<SectionModel> cartList = (cart)
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
                },
              );
        } on TimeoutException catch (_) {
          setSnackbar('somethingMSg'.translate(context: context), context);
          if (mounted) {
            isProgress = false;
            widget.setState();
          }
        }
      } else {
        isProgress = true;
        widget.setState();

        int qty;

        qty = (int.parse(controllerText.text) - int.parse(model.qtyStepSize!));

        if (qty < model.minOrderQuntity!) {
          qty = 0;
          context.read<CartProvider>().removeCartItem(
            model.prVarientList![0].id!,
          );
          db.removeCart(model.prVarientList![0].id!, model.id!, context);
        } else {
          context.read<CartProvider>().updateCartItem(
            model.id!,
            qty.toString(),
            0,
            model.prVarientList![0].id!,
          );
          db.updateCart(model.id!, model.prVarientList![0].id!, qty.toString());
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
    Product model;
    if (widget.from == 1) {
      model = widget.section_model!.productList![index];
    } else {
      model = widget.section_model!.productList![index];
    }
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        try {
          if (mounted) {
            isProgress = true;
            widget.setState();
          }

          if (int.parse(qty) < model.minOrderQuntity!) {
            qty = model.minOrderQuntity.toString();

            setSnackbar(
              "${'MIN_MSG'.translate(context: context)}$qty",
              context,
            );
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![0].id,
            QTY: qty,
          };

          ApiBaseHelper()
              .postAPICall(manageCartApi, parameter)
              .then(
                (getdata) {
                  bool error = getdata['error'];
                  String? msg = getdata['message'];
                  if (!error) {
                    var data = getdata['data'];

                    String? qty = data['total_quantity'];

                    userProvider.setCartCount(data['cart_count']);
                    model.prVarientList![0].cartCount = qty.toString();

                    var cart = getdata['cart'];
                    if (cart is List) {
                      List<SectionModel> cartList = (cart)
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
                },
              );
        } on TimeoutException catch (_) {
          setSnackbar('somethingMSg'.translate(context: context), context);
          if (mounted) {
            isProgress = false;
            widget.setState();
          }
        }
      } else {
        isProgress = true;
        widget.setState();

        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' || CurrentSellerID == model.seller_id) {
            CurrentSellerID = model.seller_id!;
            if (from == 1) {
              List<Product>? prList = [];
              prList.add(model);
              context.read<CartProvider>().addCartItem(
                SectionModel(
                  qty: qty,
                  productList: prList,
                  varientId: model.prVarientList![0].id!,
                  id: model.id,
                  sellerId: model.seller_id,
                ),
              );
              db.insertCart(
                model.id!,
                model.prVarientList![0].id!,
                qty,
                context,
              );
              setSnackbar(
                'PRODUCT_ADDED_TO_CART_LBL'.translate(context: context),
                context,
              );
            } else {
              if (int.parse(qty) > int.parse(model.itemsCounter!.last)) {
                setSnackbar(
                  "${'MAXQTY'.translate(context: context)} ${int.parse(model.itemsCounter!.last)}",
                  context,
                );
              } else {
                context.read<CartProvider>().updateCartItem(
                  model.id!,
                  qty,
                  0,
                  model.prVarientList![0].id!,
                );
                db.updateCart(model.id!, model.prVarientList![0].id!, qty);
                setSnackbar(
                  'Cart Update Successfully'.translate(context: context),
                  context,
                );
              }
            }
          }
        } else {
          if (from == 1) {
            List<Product>? prList = [];
            prList.add(model);
            context.read<CartProvider>().addCartItem(
              SectionModel(
                qty: qty,
                productList: prList,
                varientId: model.prVarientList![0].id!,
                id: model.id,
                sellerId: model.seller_id,
              ),
            );
            db.insertCart(model.id!, model.prVarientList![0].id!, qty, context);
            setSnackbar(
              'PRODUCT_ADDED_TO_CART_LBL'.translate(context: context),
              context,
            );
          } else {
            if (int.parse(qty) > int.parse(model.itemsCounter!.last)) {
              setSnackbar(
                "${'MAXQTY'.translate(context: context)} ${int.parse(model.itemsCounter!.last)}",
                context,
              );
            } else {
              context.read<CartProvider>().updateCartItem(
                model.id!,
                qty,
                0,
                model.prVarientList![0].id!,
              );
              db.updateCart(model.id!, model.prVarientList![0].id!, qty);
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
    if (widget.index! < widget.section_model!.productList!.length) {
      Product model = widget.section_model!.productList![widget.index!];

      double width = deviceWidth! * 0.5 - 20;
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

      return Consumer<CartProvider>(
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

          return InkWell(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.gray,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              elevation: 0.2,
              margin: EdgeInsetsDirectional.only(bottom: 10, end: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: cartBtnList ? 4 : 6,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(circularBorderRadius5),
                            topRight: Radius.circular(circularBorderRadius5),
                          ),
                          child: Hero(
                            tag:
                                '$heroTagUniqueString${widget.index}${model.id}',
                            child: DesignConfiguration.getCacheNotworkImage(
                              boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                              context: context,
                              heightvalue: double.maxFinite,
                              widthvalue: double.maxFinite,
                              placeHolderSize: width,
                              imageurlString: model.image!,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: model.prVarientList![0].availability == '0'
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
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ubuntu',
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        const Divider(height: 1),
                        if (widget
                                .section_model!
                                .productList![widget.index!]
                                .noOfRating! !=
                            '0')
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: RatingCartForProduct(
                              noOfRating: widget
                                  .section_model!
                                  .productList![widget.index!]
                                  .noOfRating!,
                              totalRating: widget
                                  .section_model!
                                  .productList![widget.index!]
                                  .rating!,
                            ),
                          ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CustomFevoriteButtonForCart(model: model),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 5.0,
                        top: 8,
                        end: 5,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget
                                .section_model!
                                .productList![widget.index!]
                                .name!,
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.fontColor,
                                  fontSize: textFontSize12,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'ubuntu',
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                DesignConfiguration.getPriceFormat(
                                  context,
                                  price,
                                )!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: textFontSize14,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                double.parse(
                                              widget
                                                  .section_model!
                                                  .productList![widget.index!]
                                                  .prVarientList![0]
                                                  .disPrice!,
                                            ) !=
                                            0 &&
                                        double.parse(
                                              widget
                                                  .section_model!
                                                  .productList![widget.index!]
                                                  .prVarientList![0]
                                                  .disPrice!,
                                            ) !=
                                            double.parse(
                                              widget
                                                  .section_model!
                                                  .productList![widget.index!]
                                                  .prVarientList![0]
                                                  .price!,
                                            )
                                    ? '${DesignConfiguration.getPriceFormat(context, double.parse(widget.section_model!.productList![widget.index!].prVarientList![0].price!))}'
                                    : '',
                                style: Theme.of(context).textTheme.labelSmall!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.lightBlack,
                                      fontFamily: 'ubuntu',
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: colors.darkColor3,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationThickness: 2,
                                      letterSpacing: 0,
                                      fontSize: textFontSize9,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                              ),
                              off != 0
                                  ? Text(
                                      '  ${off.toStringAsFixed(2)}%',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                            fontFamily: 'ubuntu',
                                            color: colors.green,
                                            letterSpacing: 0,
                                            fontSize: textFontSize9,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                          ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
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
            onTap: () {
              Product model = widget.section_model!.productList![widget.index!];
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
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
