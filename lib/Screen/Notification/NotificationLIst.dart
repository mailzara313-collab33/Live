import 'dart:async';
import 'package:eshop_multivendor/Model/Notification_Model.dart';
import 'package:eshop_multivendor/Provider/NotificationProvider.dart';
import 'package:eshop_multivendor/Screen/Notification/Widget/NotiListData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../../widgets/appBar.dart';

import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<StatefulWidget> createState() => StateNoti();
}

class StateNoti extends State<NotificationList> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isLoadingMore = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) => context
        .read<NotificationProvider>()
        .getNotification(isLoadingMore: false, context: context));
    controller.addListener(_scrollListener);
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
    super.initState();
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

  void setStateNow() {
    setState(() {});
  }

  Future<void> setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then((_) async {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        Future.delayed(Duration.zero).then((value) => context
            .read<NotificationProvider>()
            .getNotification(isLoadingMore: false, context: context));
      } else {
        await buttonController!.reverse();
        if (mounted) setState(() {});
      }
    });
  }

  Future _refresh() async {
    if (mounted) {
      return Future.delayed(Duration.zero).then((value) => context
          .read<NotificationProvider>()
          .getNotification(isLoadingMore: true, context: context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          'NOTIFICATION'.translate(context: context), context, setStateNow),
      key: _scaffoldKey,
      body: isNetworkAvail
          ? Consumer<NotificationProvider>(
              builder: (context, value, child) {
                if (value.getCurrentStatus == NotificationStatus.isSuccsess) {
                  return Column(
                    children: [
                      Expanded(
                        child: showContent(value.notificationList),
                      ),
                      if (isLoadingMore)
                        Center(
                          child: CircularProgressIndicator(),
                        )
                    ],
                  );
                } else if (value.getCurrentStatus ==
                    NotificationStatus.isFailure) {
                  return Center(
                    child: Text(
                      value.errorMessage,
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  );
                }
                return const ShimmerEffect();
              },
            )
          : NoInterNet(
              buttonController: buttonController,
              buttonSqueezeanimation: buttonSqueezeanimation,
              setStateNoInternate: setStateNoInternate,
            ),
    );
  }

  Widget showContent(List<NotificationModel>? notificationList) {
    return notificationList!.isEmpty
        ? Padding(
            padding: const EdgeInsetsDirectional.only(top: kToolbarHeight),
            child: Center(
              child: Text(
                'noNoti'.translate(context: context),
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            ),
          )
        : RefreshIndicator(
            color: colors.primary,
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
            child: ListView.builder(
              shrinkWrap: true,
              controller: controller,
              itemCount: notificationList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return NotiListData(
                  index: index,
                  notiList: notificationList,
                );
              },
            ),
          );
  }

  Future<void> _scrollListener() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.offset >= controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        if (context.read<NotificationProvider>().hasMoreData) {
          setState(
            () {
              isLoadingMore = true;
            },
          );
          context
              .read<NotificationProvider>()
              .getNotification(isLoadingMore: false, context: context)
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
    });
  }
}
