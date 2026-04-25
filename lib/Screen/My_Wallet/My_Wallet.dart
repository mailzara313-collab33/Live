import 'dart:async';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/myWalletProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Screen/My_Wallet/Widgets/myWalletDialog.dart';
import 'package:eshop_multivendor/Screen/My_Wallet/Widgets/walletTransactionItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Transaction_Model.dart';
import '../../Model/getWithdrawelRequest/withdrawTransactiponsModel.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';

import '../../widgets/simmerEffect.dart';
import 'Widgets/withdrawRequestItem.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  State<StatefulWidget> createState() {
    return StateWallet();
  }
}

//GlobalKey<StateWallet>? walletPageState;

class StateWallet extends State<MyWallet> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ScrollController controller = ScrollController();
  late TabController _tabController;
  int? pastindex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // walletPageState = GlobalKey<StateWallet>();
    Future.delayed(
      Duration.zero,
      () {
        context.read<SystemProvider>().paymentMethodList = [
          'PAYPAL_LBL'.translate(context: context),
          'RAZORPAY_LBL'.translate(context: context),
          'PAYSTACK_LBL'.translate(context: context),
          'FLUTTERWAVE_LBL'.translate(context: context),
          'STRIPE_LBL'.translate(context: context),
          'PAYTM_LBL'.translate(context: context),
          'MidTrans'.translate(context: context),
          'My Fatoorah'.translate(context: context),
          'instamojo_lbl'.translate(context: context),
          'PHONEPE_LBL'.translate(context: context)
        ];

        context.read<SystemProvider>().fetchAvailablePaymentMethodsAndAssignIDs(
            settingType: PAYMENT_METHOD);
      },
    );

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
    getWalletHistory();
  }

  void getWalletHistory() {
    if (_tabController.index == 0) {
      Future.delayed(Duration.zero).then(
        (value) async {
          context.read<MyWalletProvider>().getUserWalletTransactions(
                context: context,
                walletTransactionIsLoadingMore: false,
              );
        },
      );
    } else if (_tabController.index == 1) {
      context
          .read<MyWalletProvider>()
          .fetchUserWalletAmountWithdrawalRequestTransactions(
              walletTransactionIsLoadingMore: false, context: context);
    }
  }

  Widget getFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularBorderRadius5),
            color: Theme.of(context).colorScheme.white),
        child: InkWell(
          child: TabBar(
              onTap: (index) async {
                {
                  if (index != pastindex) {
                    pastindex = index;
                    getWalletHistory();
                  }
                }
              },
              indicatorSize: TabBarIndicatorSize.tab,
              padding: EdgeInsets.all(8),
              labelPadding: EdgeInsets.zero,
              unselectedLabelStyle:
                  Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.black,
                        fontWeight: FontWeight.normal,
                      ),
              labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.white,
                    fontWeight: FontWeight.bold,
                  ),
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              controller: _tabController,
              indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(circularBorderRadius5)),
              tabs: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Transaction History'.translate(context: context),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Wallet History'.translate(context: context),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(circularBorderRadius4),
                onTap: () => Navigator.of(context).pop(),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
              ),
            );
          },
        ),
        title: Text(
          'MYWALLET'.translate(context: context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal,
            fontFamily: 'ubuntu',
          ),
        ),
      ),
      body: Consumer<MyWalletProvider>(
        builder: (context, value, child) {
          if (value.getCurrentStatus == MyWalletStatus.isFailure) {
            return Center(
              child: Text(
                value.errorMessage,
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            );
          } else if (value.getCurrentStatus == MyWalletStatus.isSuccsess) {
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: getFilters(),
                ),
                Expanded(
                    flex: 10,
                    child: showContent(value.walletTransactionList,
                        value.walletWithdrawalRequestList)),
              ],
            );
          }
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: getFilters(),
              ),
              Expanded(flex: 10, child: const ShimmerEffect()),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController to free resources
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    getWalletHistory();
    return;
  }

  Future<void> updateTransaction() async {
    await context.read<MyWalletProvider>().getUserWalletTransactions(
        context: context, walletTransactionIsLoadingMore: false);
  }

  Future<void> _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange &&
        !context.read<MyWalletProvider>().walletTransactionIsLoadingMore) {
      if (mounted) {
        if (context.read<MyWalletProvider>().walletTransactionHasMoreData) {
          context
              .read<MyWalletProvider>()
              .changeWalletTransactionIsLoadingMoreTo(true);

          await context
              .read<MyWalletProvider>()
              .getUserWalletTransactions(
                  context: context, walletTransactionIsLoadingMore: true)
              .then(
            (value) {
              context
                  .read<MyWalletProvider>()
                  .changeWalletTransactionIsLoadingMoreTo(false);
            },
          );
        }
      }
    }
  }

  Widget showContent(List<TransactionModel> walletTransactionList,
      List<WithdrawTransaction> withdrawList) {
    return RefreshIndicator(
      color: colors.primary,
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                        Text(
                          ' ${'CURBAL_LBL'.translate(context: context)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ubuntu',
                              ),
                        ),
                      ],
                    ),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return Text(
                          ' ${DesignConfiguration.getPriceFormat(
                            context,
                            double.parse(userProvider.curBalance),
                          )!}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                fontFamily: 'ubuntu',
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SimBtn(
                            borderRadius: circularBorderRadius5,
                            size: 0.8,
                            title: 'ADD_MONEY'.translate(context: context),
                            onBtnSelected: () async {
                              MyWalletDialog.showAddMoneyDialog(context);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SimBtn(
                            borderRadius: circularBorderRadius5,
                            size: 0.8,
                            title: 'Withdraw'.translate(context: context),
                            onBtnSelected: () {
                              MyWalletDialog.showWithdrawAmountDialog(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Text(
              _tabController.index == 0
                  ? 'WALLET_TRANSACTION_HISTORY'.translate(context: context)
                  : 'Wallet History'.translate(context: context),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'ubuntu',
              ),
            ),
          ),
          _tabController.index == 0
              ? walletTransactionList.isEmpty
                  ? DesignConfiguration.getNoItem(context)
                  : Expanded(
                      child: ListView.builder(
                        controller: controller,
                        shrinkWrap: true,
                        itemCount: walletTransactionList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return (index == walletTransactionList.length &&
                                  context
                                      .watch<MyWalletProvider>()
                                      .walletTransactionIsLoadingMore)
                              ? const Center(child: CircularProgressIndicator())
                              : WalletTransactionItem(
                                  transactionData: walletTransactionList[index],
                                );
                        },
                      ),
                    )
              : withdrawList.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        controller: controller,
                        shrinkWrap: true,
                        itemCount: withdrawList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return (index == withdrawList.length &&
                                  context
                                      .watch<MyWalletProvider>()
                                      .walletTransactionIsLoadingMore)
                              ? const Center(child: CircularProgressIndicator())
                              : WithdrawRequestItem(
                                  withdrawItem: withdrawList[index],
                                );
                        },
                      ),
                    )
                  : DesignConfiguration.getNoItem(context),
        ],
      ),
    );
  }
}
