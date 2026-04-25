import 'dart:async';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Provider/CartProvider.dart';
import '../../Provider/promoCodeProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';

import '../../widgets/simmerEffect.dart';
import '../../widgets/snackbar.dart';

class PromoCode extends StatefulWidget {
  final String from;
  final Function? updateParent;

  const PromoCode({super.key, required this.from, this.updateParent});

  @override
  State<StatefulWidget> createState() => StatePromoCode();
}

class StatePromoCode extends State<PromoCode> with TickerProviderStateMixin {
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ScrollController controller = ScrollController();
  final GlobalKey expansionTileKey = GlobalKey();

  bool isLoadingMore = false;
  bool PromoCodeApplyInProccess = false;
  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) =>
        context.read<PromoCodeProvider>().getPromoCodes(isLoadingMore: false));

    controller.addListener(_scrollListener);
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    super.initState();
  }

  void setStateNow() {
    setState(() {});
  }

  void callShowOverlayMethod() {
    _showOverlay(context);
  }

  Future<void> _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange &&
        !isLoadingMore) {
      if (mounted) {
        if (context.read<PromoCodeProvider>().hasMoreData) {
          setState(
            () {
              isLoadingMore = true;
            },
          );
          await context
              .read<PromoCodeProvider>()
              .getPromoCodes(isLoadingMore: false)
              .then(
            (value) {
              setState(
                () {
                  isLoadingMore = false;
                },
              );
            },
          );
        }
      }
    }
  }

  Future<void> _refresh() {
    return context.read<PromoCodeProvider>().getPromoCodes(isLoadingMore: true);
  }

  void _showOverlay(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).colorScheme.black26,
            ),
            Lottie.asset(
              DesignConfiguration.setLottiePath(Assets.celebrateName),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.white,
                    ),
                    borderRadius: BorderRadius.circular(circularBorderRadius20),
                    color: Theme.of(context).colorScheme.white),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Container(
                        child: Lottie.asset(
                            DesignConfiguration.setLottiePath(
                                Assets.promocodeName),
                            height: 150,
                            width: 150),
                      ),
                      Text(
                        '${context.read<CartProvider>().promocode} applied',
                        style: TextStyle(
                          fontSize: textFontSize16,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${'You saved'.translate(context: context)} ${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().promoAmt)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: textFontSize18,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'with this coupon code'.translate(context: context),
                        style: TextStyle(
                          fontSize: textFontSize12,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'woohoo! Thanks'.translate(context: context),
                            style: const TextStyle(
                              fontSize: textFontSize12,
                              color: colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(overlayEntry);

    await Future.delayed(const Duration(seconds: 4));
    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:
          getSimpleAppBar('YOUR_PROM_CO'.translate(context: context), context),
      body: Consumer<PromoCodeProvider>(
        builder: (context, value, child) {
          if (value.getCurrentStatus == PromoCodeStatus.isFailure) {
            return Center(
              child: Text(value.errorMessage),
            );
          } else if (value.getCurrentStatus == PromoCodeStatus.isSuccsess) {
            return value.promoCodeList.isEmpty
                ? Center(
                    child: Text(
                      'NO_PROMCO'.translate(context: context),
                    ),
                  )
                : RefreshIndicator(
                    color: colors.primary,
                    key: _refreshIndicatorKey,
                    onRefresh: _refresh,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        controller: controller,
                        itemCount: value.promoCodeList.length,
                        itemBuilder: (context, index) {
                          return (index == value.promoCodeList.length &&
                                  isLoadingMore)
                              ? const SingleItemSimmer()
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      ExpansionPanelList.radio(
                                        children: [
                                          ExpansionPanelRadio(
                                            body: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                                vertical: 5.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        size: 10,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${"MIN_ORDER_VALUE".translate(context: context)} ${DesignConfiguration.getPriceFormat(context, double.parse(value.promoCodeList[index].minOrderAmt!))}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                textFontSize12,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        size: 10,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${"MAX_DISCOUNT".translate(context: context)}  ${DesignConfiguration.getPriceFormat(context, double.parse(value.promoCodeList[index].maxDiscountAmt!))}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                textFontSize12,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        size: 10,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${"OFFER_VALID_FROM".translate(context: context)} ${value.promoCodeList[index].startDate} to ${value.promoCodeList[index].endDate}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                textFontSize12,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        size: 10,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: value
                                                                    .promoCodeList[
                                                                        index]
                                                                    .repeatUsage ==
                                                                'Allowed'
                                                            ? Text(
                                                                "${"MAX_APPLICABLE".translate(context: context)}  ${value.promoCodeList[index].noOfRepeatUsage} times",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      textFontSize12,
                                                                ),
                                                              )
                                                            : Text(
                                                                'OFFER_VALID_ONCE'
                                                                    .translate(
                                                                        context:
                                                                            context),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      textFontSize12,
                                                                ),
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        size: 10,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: value
                                                                    .promoCodeList[
                                                                        index]
                                                                    .isInstantCashback ==
                                                                '0'
                                                            ? Text(
                                                                'You will get Instant Cashback'
                                                                    .translate(
                                                                        context:
                                                                            context),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        textFontSize12))
                                                            : Text(
                                                                'You will get Cashback In Wallet'
                                                                    .translate(
                                                                        context:
                                                                            context),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      textFontSize12,
                                                                ),
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            headerBuilder:
                                                (context, isExpanded) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          height: 50,
                                                          width: 50,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              circularBorderRadius7,
                                                            ),
                                                            child:
                                                                Image.network(
                                                              value
                                                                  .promoCodeList[
                                                                      index]
                                                                  .image!,
                                                              height: 50,
                                                              width: 50,
                                                              fit: BoxFit.fill,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  DesignConfiguration
                                                                      .erroWidget(
                                                                80,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  value.promoCodeList[index]
                                                                          .promoCode ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                  value.promoCodeList[index]
                                                                          .message ??
                                                                      '',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        textFontSize12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            value: index,
                                            canTapOnHeader: true,
                                          ),
                                        ],
                                        elevation: 0.0,
                                        animationDuration:
                                            const Duration(milliseconds: 700),
                                        expansionCallback:
                                            (int item, bool status) {
                                          setState(
                                            () {
                                              value.promoCodeList[index]
                                                  .isExpanded = !status;
                                            },
                                          );
                                        },
                                      ),
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        color:
                                            Theme.of(context).colorScheme.white,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          child: widget.from == 'Profile'
                                              ? InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text: value
                                                            .promoCodeList[
                                                                index]
                                                            .promoCode!,
                                                      ),
                                                    );
                                                    setSnackbar(
                                                        'Promo Code Copied to clipboard'
                                                            .translate(
                                                                context:
                                                                    context),
                                                        context);
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: SvgPicture.asset(
                                                          DesignConfiguration
                                                              .setSvgPath(Assets
                                                                  .promoLight),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .lightWhite,
                                                                  BlendMode
                                                                      .srcIn),
                                                          height: 35,
                                                        ),
                                                      ),
                                                      Text(
                                                        value
                                                                .promoCodeList[
                                                                    index]
                                                                .promoCode ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5),
                                                                child: InkWell(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    DesignConfiguration
                                                                        .setSvgPath(
                                                                            Assets.promoLight),
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.4,
                                                                    colorFilter:
                                                                        ColorFilter
                                                                            .mode(
                                                                      Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .lightWhite,
                                                                      BlendMode
                                                                          .srcIn,
                                                                    ),
                                                                    height: 35,
                                                                  ),
                                                                  onTap: () {
                                                                    Clipboard
                                                                        .setData(
                                                                      ClipboardData(
                                                                        text: value
                                                                            .promoCodeList[index]
                                                                            .promoCode!,
                                                                      ),
                                                                    );
                                                                    setSnackbar(
                                                                        'Promo Code Copied to clipboard'.translate(
                                                                            context:
                                                                                context),
                                                                        context);
                                                                  },
                                                                ),
                                                              ),
                                                              Text(
                                                                value
                                                                        .promoCodeList[
                                                                            index]
                                                                        .promoCode ??
                                                                    '',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SimBtn(
                                                      borderRadius:
                                                          circularBorderRadius5,
                                                      title: 'APPLY'.translate(
                                                          context: context),
                                                      size: 0.4,
                                                      onBtnSelected: () {
                                                        if (PromoCodeApplyInProccess) {
                                                          return;
                                                        }
                                                        PromoCodeApplyInProccess =
                                                            true;
                                                        context
                                                            .read<
                                                                PromoCodeProvider>()
                                                            .validatePromo(
                                                              value
                                                                  .promoCodeList[
                                                                      index]
                                                                  .promoCode!,
                                                              context,
                                                              setStateNow,
                                                              widget
                                                                  .updateParent,
                                                              callShowOverlayMethod,
                                                            )
                                                            .then(
                                                          (value) {
                                                            PromoCodeApplyInProccess =
                                                                false;
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  );
          }
          return const ShimmerEffect();
        },
      ),
    );
  }
}
