import 'dart:async';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Model/Order_Model.dart';
import 'package:eshop_multivendor/Provider/Order/OrderProvider.dart';
import 'package:eshop_multivendor/Screen/MyOrder/Widget/OrderListData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';

import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class MyOrder extends StatefulWidget {
  static GlobalKey<StateMyOrder> globalKeyMyOrder = GlobalKey<StateMyOrder>();

  MyOrder({Key? key}) : super(key: globalKeyMyOrder);

  @override
  State<StatefulWidget> createState() {
    return StateMyOrder();
  }
}

class StateMyOrder extends State<MyOrder> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ScrollController scrollController = ScrollController();
  String _searchText = '', _lastsearch = '';

  void setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().hasMoreData = true;
      context.read<OrderProvider>().OrderOffset = 0;
      context.read<OrderProvider>().getOrder(context, _searchText);
      _controller.addListener(
        () {
          if (_controller.text.isEmpty) {
            if (mounted) {
              setState(
                () {
                  _searchText = '';
                },
              );
            }
          } else {
            if (mounted) {
              setState(
                () {
                  _searchText = _controller.text;
                },
              );
            }
          }

          if (_lastsearch != _searchText &&
              ((_searchText.isNotEmpty) || (_searchText == ''))) {
            _lastsearch = _searchText;

            context.read<OrderProvider>().hasMoreData = true;

            context.read<OrderProvider>().OrderOffset = 0;
            print('came here 1');
            Future.delayed(Duration.zero).then(
              (value) =>
                  context.read<OrderProvider>().getOrder(context, _searchText),
            );
          }
        },
      );
    });
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    networkChecking();
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

  void networkChecking() async {
    isNetworkAvail = await isNetworkAvailable();
    setState(() {});
  }

  void _scrollListener() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        print('came here 2');
        Future.delayed(Duration.zero).then(
          (value) => context.read<OrderProvider>().getOrder(
                context,
                _searchText,
              ),
        );
      }
    });
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          print('came here 3');
          Future.delayed(Duration.zero).then(
            (value) => context.read<OrderProvider>().getOrder(
                  context,
                  _searchText,
                ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      appBar:
          getSimpleAppBar('MY_ORDERS_LBL'.translate(context: context), context),
      body: isNetworkAvail
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        fillColor: Theme.of(context).colorScheme.white,
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          maxHeight: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        prefixIcon: SvgPicture.asset(
                          DesignConfiguration.setSvgPath(Assets.search),
                          colorFilter: const ColorFilter.mode(
                              colors.primary, BlendMode.srcIn),
                        ),
                        hintText:
                            'FIND_ORDER_ITEMS_LBL'.translate(context: context),
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor
                              .withValues(alpha: 0.3),
                          fontWeight: FontWeight.normal,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Consumer<OrderProvider>(
                      builder: (context, value, child) {
                        if (value.getCurrentStatus == OrderStatus.isSuccsess) {
                          return value.OrderList.isEmpty
                              ? Center(
                                  child: Text(
                                    'noItem'.translate(context: context),
                                    style: const TextStyle(
                                      fontFamily: 'ubuntu',
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  child: RefreshIndicator(
                                    color: colors.primary,
                                    key: _refreshIndicatorKey,
                                    onRefresh: _refresh,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                            controller: scrollController,
                                            padding: const EdgeInsetsDirectional
                                                .only(top: 5.0),
                                            itemCount: value.OrderList.length,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              OrderItem? orderItem;
                                              try {
                                                if (value.OrderList[index]
                                                    .itemList!.isNotEmpty) {
                                                  orderItem = value
                                                      .OrderList[index]
                                                      .itemList![0];
                                                }
                                              } on Exception catch (_) {}

                                              return orderItem == null
                                                  ? const SizedBox()
                                                  : OrderListData(
                                                      context1: context,
                                                      order: value
                                                          .OrderList[index],
                                                      searchText: _searchText);
                                            },
                                          ),
                                        ),
                                        if (value.isGettingdata &&
                                            !value.hasMoreData)
                                          Center(
                                              child:
                                                  const CircularProgressIndicator())
                                      ],
                                    ),
                                  ),
                                );
                        } else if (value.getCurrentStatus ==
                            OrderStatus.isFailure) {
                          return Center(
                            child: Text(
                              value.errorMessage,
                              style: const TextStyle(
                                fontFamily: 'ubuntu',
                              ),
                            ),
                          );
                        }

                        return ShimmerEffect();
                      },
                    ),
                  ),
                ],
              ),
            )
          : NoInterNet(
              buttonController: buttonController,
              buttonSqueezeanimation: buttonSqueezeanimation,
              setStateNoInternate: setStateNoInternate,
            ),
    );
  }

  Future _refresh() async {
    if (mounted) {
      context.read<OrderProvider>().hasMoreData = true;
      context.read<OrderProvider>().OrderOffset = 0;
      Future.delayed(Duration.zero).then((value) =>
          context.read<OrderProvider>().getOrder(context, _searchText));
    }
  }

  void refreshFromReview() {
    if (mounted) {
      context.read<OrderProvider>().hasMoreData = true;
      context.read<OrderProvider>().OrderOffset = 0;
      Future.delayed(Duration.zero).then((value) =>
          context.read<OrderProvider>().getOrder(context, _searchText));
    }
  }
}
