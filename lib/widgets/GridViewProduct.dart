import 'dart:async';
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
import '../Screen/ProductList&SectionView/ProductList.dart';
import 'package:collection/src/iterable_extensions.dart';

// ignore: must_be_immutable
class GridViewProductListWidget extends StatefulWidget {
  List<Product>? productList;
  final int? index;
  bool pad;

  Function setState;

  GridViewProductListWidget({
    super.key,
    this.productList,
    required this.index,
    required this.pad,
    required this.setState,
  });

  @override
  State<GridViewProductListWidget> createState() =>
      _GridViewProductListWidgetState();
}

class _GridViewProductListWidgetState extends State<GridViewProductListWidget> {
  final TextEditingController controllerText = TextEditingController();

  @override
  void dispose() {
    controllerText.dispose();

    super.dispose();
  }

  // ========== CART HELPER METHODS ==========

  /// Set progress state safely
  void _setProgressState(bool value) {
    if (mounted) {
      isProgress = value;
      widget.setState();
    }
  }

  /// Update cart data from API response
  void _updateCartFromResponse(Map data, int index) {
    String? qty = data['total_quantity'];
    context.read<UserProvider>().setCartCount(data['cart_count']);
    widget.productList![index].prVarientList![0].cartCount = qty.toString();
  }

  /// Calculate quantity after removing step size
  int _calculateRemovedQty(int index) {
    int qty =
        (int.parse(controllerText.text) -
        int.parse(widget.productList![index].qtyStepSize!));

    if (qty < widget.productList![index].minOrderQuntity!) {
      qty = 0;
    }
    return qty;
  }

  // ========== CART OPERATIONS ==========

  Future<void> removeFromCart(int index) async {
    isNetworkAvail = await isNetworkAvailable();
    if (!isNetworkAvail) {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
      return;
    }

    _setProgressState(true);
    int qty = _calculateRemovedQty(index);

    if (context.read<UserProvider>().userId != '') {
      // Logged in user - API call
      var parameter = {
        PRODUCT_VARIENT_ID: widget.productList![index].prVarientList![0].id,
        QTY: qty.toString(),
      };

      apiBaseHelper
          .postAPICall(manageCartApi, parameter)
          .then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                _updateCartFromResponse(getdata['data'], index);

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
              _setProgressState(false);
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
              _setProgressState(false);
            },
          );
    } else {
      // Guest user - local database
      if (qty == 0) {
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
      _setProgressState(false);
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

  // ========== HELPER METHODS ==========

  /// Calculate the display price (uses discount price if available, otherwise regular price)
  double _getDisplayPrice(Product product) {
    double price = double.parse(product.prVarientList![0].disPrice!);
    if (price == 0) {
      price = double.parse(product.prVarientList![0].price!);
    }
    return price;
  }

  /// Calculate discount percentage
  double _getDiscountPercentage(Product product) {
    if (product.prVarientList![0].disPrice! == '0') return 0;

    double originalPrice = double.parse(product.prVarientList![0].price!);
    double discountPrice = double.parse(product.prVarientList![0].disPrice!);

    if (discountPrice == 0) return 0;

    double off = (originalPrice - discountPrice) / originalPrice * 100;
    return off;
  }

  /// Check if product has a discount
  bool _hasDiscount(Product product) {
    return double.parse(product.prVarientList![0].disPrice!) != 0 &&
        product.prVarientList![0].disPrice! != product.prVarientList![0].price!;
  }

  // ========== WIDGET BUILDER METHODS ==========

  /// Build the product image section with overlays (out of stock, rating, favorite)
  Widget _buildImageSection(Product product, double width) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Product image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(circularBorderRadius5),
            topRight: Radius.circular(circularBorderRadius5),
          ),
          child: Hero(
            tag: '$heroTagUniqueString${widget.index}${product.id}',
            child: DesignConfiguration.getCacheNotworkImage(
              boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
              context: context,
              heightvalue: double.maxFinite,
              widthvalue: double.maxFinite,
              placeHolderSize: width,
              imageurlString: product.image!,
            ),
          ),
        ),
        // Out of stock overlay - covers entire image
        if (product.prVarientList![0].availability == '0')
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.white70,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(circularBorderRadius5),
                  topRight: Radius.circular(circularBorderRadius5),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'OUT_OF_STOCK_LBL'.translate(context: context),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                  fontSize: textFontSize16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        const Divider(height: 1),
        // Rating badge
        if (product.noOfRating! != '0')
          Positioned(
            bottom: 0,
            right: 0,
            child: RatingCartForProduct(
              noOfRating: product.noOfRating!,
              totalRating: product.rating!,
            ),
          ),
        // Favorite button
        Positioned(
          top: 0,
          right: 0,
          child: CustomFevoriteButtonForCart(model: product),
        ),
      ],
    );
  }

  /// Build product information section (name and pricing)
  Widget _buildProductInfo(Product product) {
    double displayPrice = _getDisplayPrice(product);
    double discountPercentage = _getDiscountPercentage(product);
    bool hasDiscount = _hasDiscount(product);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          product.name!,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
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
        // Pricing section
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Display price
            Text(
              '${DesignConfiguration.getPriceFormat(context, displayPrice)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: textFontSize14,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontFamily: 'ubuntu',
              ),
            ),
            const SizedBox(width: 5),
            // Original price (with strikethrough)
            if (hasDiscount)
              Text(
                '${DesignConfiguration.getPriceFormat(context, double.parse(product.prVarientList![0].price!))}',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).colorScheme.lightBlack,
                  fontFamily: 'ubuntu',
                  decoration: TextDecoration.lineThrough,
                  decorationColor: colors.darkColor3,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationThickness: 2,
                  letterSpacing: 0,
                  fontSize: textFontSize9,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                ),
              ),
            // Discount percentage
            if (discountPercentage != 0)
              Text(
                '  ${discountPercentage.toStringAsFixed(2)}%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontFamily: 'ubuntu',
                  color: colors.green,
                  letterSpacing: 0,
                  fontSize: textFontSize9,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ========== BUILD METHOD ==========

  @override
  Widget build(BuildContext context) {
    if (widget.index! < widget.productList!.length) {
      Product productmodel = widget.productList![widget.index!];

      print('cartBtn list***$cartBtnList******${0}');
      totalProduct = productmodel.total;

      double width = deviceWidth! * 0.5;

      return Consumer<CartProvider>(
        builder: (context, data, _) {
          final tempId = data.cartList.firstWhereOrNull(
            (cp) =>
                cp.id == productmodel.id &&
                cp.varientId == productmodel.prVarientList![0].id!,
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
              margin: EdgeInsetsDirectional.only(
                bottom: 10,
                end: 10,
                start: widget.pad ? 10 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Product image section
                  Expanded(child: _buildImageSection(productmodel, width)),
                  // Product info section (name and pricing)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 5.0,
                      top: 8,
                      end: 5,
                      bottom: 5,
                    ),
                    child: _buildProductInfo(productmodel),
                  ),
                  // Cart button section
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      bottom: 8.0,
                    ),
                    child: CommonAddCartSection(
                      controller: controllerText,
                      model: productmodel,
                      onAddToCart: () {
                        addToCart(
                          widget.index!,
                          (int.parse(controllerText.text) +
                                  int.parse(productmodel.qtyStepSize!))
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
                                  int.parse(productmodel.qtyStepSize!))
                              .toString(),
                          2,
                        );
                      },
                      itemsCounter: productmodel.itemsCounter!,
                      onQuantitySelected: (String value) {
                        addToCart(widget.index!, value, 2);
                      },
                      isProgress: isProgress,
                    ),
                  ),
                ],
              ),
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
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
