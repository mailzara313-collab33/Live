import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';

import 'package:eshop_multivendor/Screen/Payment/Widget/PaymentRadio.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/myWalletProvider.dart';
import 'package:eshop_multivendor/Provider/paymentProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Provider/userWalletProvider.dart';
import 'package:eshop_multivendor/Screen/Payment/Widget/paymentMethod.dart';
import 'package:eshop_multivendor/Screen/WebView/PaypalWebviewActivity.dart';
import 'package:eshop_multivendor/Screen/WebView/instamojo_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';

import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';
import '../../WebView/midtransWebView.dart';

class MyWalletDialog {
  static TextEditingController? accNumberController = TextEditingController();
  static TextEditingController? ifscCodeController = TextEditingController();
  static TextEditingController? accNameController = TextEditingController();

  static Future<void> showWithdrawAmountDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController? amountTextController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // Removes the blur/dim background
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(circularBorderRadius5),
            ),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                  child: Text(
                    'Send Withrawal Request'.translate(context: context),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ),
                Divider(color: Theme.of(context).colorScheme.lightBlack),
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) => StringValidation.validateField(
                            val!,
                            'FIELD_REQUIRED'.translate(context: context),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: 'Withdrwal Amount'.translate(
                              context: context,
                            ),
                            hintStyle: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.lightBlack,
                                  fontWeight: FontWeight.normal,
                                ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                          controller: amountTextController,
                        ),
                      ),
                      bankDetailsData(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCEL'.translate(context: context),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'error': true,
                  'status': false,
                  'message': '',
                });
              },
            ),
            TextButton(
              child: Text(
                'SEND'.translate(context: context),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
              ),
              onPressed: () async {
                final form = formKey.currentState!;
                if (form.validate()) {
                  form.save();
                  Routes.pop(context);

                  await context
                      .read<UserTransactionProvider>()
                      .sendAmountWithdrawRequest(
                        userID: context.read<UserProvider>().userId!,
                        withdrawalAmount: amountTextController.text.toString(),
                        bankDetails:
                            '${accNumberController!.text.toString()}\n${ifscCodeController!.text.toString()}\n${accNameController!.text.toString()}',
                      )
                      .then((result) async {
                        setSnackbar(result['message'], context);
                        if (result['newBalance'] != '') {
                          accNameController!.clear();
                          ifscCodeController!.clear();
                          accNumberController!.clear();
                          amountTextController.clear();
                          context.read<UserProvider>().setBalance(
                            (result['newBalance']).toString(),
                          );
                        }
                      });
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Widget bankDetailsData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: Text(
            'BANK_DETAILS_LBL'.translate(context: context),
            textAlign: TextAlign.end,
            style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
          child: TextFormField(
            cursorColor: Theme.of(context).colorScheme.fontColor,
            style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => StringValidation.validateField(
              val!,
              'FIELD_REQUIRED'.translate(context: context),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: 'ACCNO'.translate(context: context),
              hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
              ),
            ),
            controller: accNumberController,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
          child: TextFormField(
            cursorColor: Theme.of(context).colorScheme.fontColor,
            style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => StringValidation.validateField(
              val!,
              'FIELD_REQUIRED'.translate(context: context),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: 'IFSC_CODE_LBL'.translate(context: context),
              hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
              ),
            ),
            controller: ifscCodeController,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
          child: TextFormField(
            cursorColor: Theme.of(context).colorScheme.fontColor,
            style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => StringValidation.validateField(
              val!,
              'FIELD_REQUIRED'.translate(context: context),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: 'NAME_LBL'.translate(context: context),
              hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
              ),
            ),
            controller: accNameController,
          ),
        ),
      ],
    );
  }

  // static showFilterDialog(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ButtonBarTheme(
  //         data: const ButtonBarThemeData(
  //           alignment: MainAxisAlignment.center,
  //         ),
  //         child: AlertDialog(
  //           elevation: 2.0,
  //           shape: const RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(
  //               Radius.circular(circularBorderRadius5),
  //             ),
  //           ),
  //           contentPadding: const EdgeInsets.all(0.0),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsetsDirectional.only(
  //                       top: 19.0, bottom: 16.0),
  //                   child: Text(
  //                      'FILTER_BY'),
  //                     style: Theme.of(context).textTheme.titleLarge!.copyWith(
  //                           color: Theme.of(context).colorScheme.fontColor,
  //                           fontFamily: 'ubuntu',
  //                         ),
  //                   ),
  //                 ),
  //                 Divider(color: Theme.of(context).colorScheme.lightBlack),
  //                 Flexible(
  //                   child: SingleChildScrollView(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         MyWalletDialog.getFilterDialogValues(
  //                            'Transaction History'),
  //                           1,
  //                           context,
  //                         ),
  //                         Divider(
  //                             color: Theme.of(context).colorScheme.lightBlack),
  //                         MyWalletDialog.getFilterDialogValues(
  //                            'Wallet History'),
  //                           2,
  //                           context,
  //                         ),
  //                         Divider(
  //                             color: Theme.of(context).colorScheme.lightBlack),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  static Widget getFilterDialogValues(
    String title,
    int index,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.maxFinite,
      child: TextButton(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.lightBlack,
            fontFamily: 'ubuntu',
          ),
        ),
        onPressed: () async {
          Routes.pop(context);
          if (index == 1) {
            // context
            //     .read<MyWalletProvider>()
            //     .setCurrentSelectedFilterIsTransaction = true;
          } else {
            // context
            //     .read<MyWalletProvider>()
            //     .setCurrentSelectedFilterIsTransaction = false;
            await context
                .read<MyWalletProvider>()
                .fetchUserWalletAmountWithdrawalRequestTransactions(
                  walletTransactionIsLoadingMore: false,
                  context: context,
                );
          }
        },
      ),
    );
  }

  static Future<void> showAddMoneyDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return const AddMoneyDialog();
      },
    ).then((value) {
      try {
        setSnackbar(value['message'], context);
      } catch (_) {}
      if (value != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          updateTransaction(context);
        });
      }
    });
  }
}

Future<void> updateTransaction(BuildContext context) async {
  await context.read<MyWalletProvider>().getUserWalletTransactions(
    context: context,
    walletTransactionIsLoadingMore: false,
  );
}

class AddMoneyDialog extends StatefulWidget {
  const AddMoneyDialog({super.key});

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController? messageTextController = TextEditingController();

  final TextEditingController? amountTextController = TextEditingController();

  bool payWarn = false;
  ValueNotifier<bool> isButtonLoading = ValueNotifier(false);
  SystemProvider? systemProvider;
  late Razorpay _razorpay;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      systemProvider = Provider.of<SystemProvider>(context, listen: false);
    });

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(circularBorderRadius5)),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
              child: Text(
                'ADD_MONEY'.translate(context: context),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontFamily: 'ubuntu',
                ),
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.lightBlack),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) => StringValidation.validateField(
                        val!,
                        'FIELD_REQUIRED'.translate(context: context),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'AMOUNT'.translate(context: context),
                        hintStyle: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.lightBlack,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                      controller: amountTextController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'MSG'.translate(context: context),
                        hintStyle: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.lightBlack,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                      controller: messageTextController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 5),
                    child: Text(
                      'SELECT_PAYMENT'.translate(context: context),
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(fontFamily: 'ubuntu'),
                    ),
                  ),
                  const Divider(),
                  payWarn
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'payWarning'.translate(context: context),
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Colors.red,
                                  fontFamily: 'ubuntu',
                                ),
                          ),
                        )
                      : const SizedBox(),
                  context.read<SystemProvider>().isPaypalEnable == null
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: getPaymentMethodList(context),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),

      actions: <Widget>[
        TextButton(
          child: Text(
            'CANCEL'.translate(context: context),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.lightBlack,
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
          ),
          onPressed: () {
            Routes.pop(context);
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isButtonLoading,
          builder: (context, value, _) {
            return TextButton(
              child: value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color?>(
                          colors.primary,
                        ),
                      ),
                    )
                  : Text(
                      'ADD'.translate(context: context),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                    ),
              onPressed: () async {
                if (isButtonLoading.value) {
                  return;
                }
                final form = formKey.currentState!;
                if (form.validate() && amountTextController!.text != '0') {
                  form.save();
                  if (systemProvider!.selectedPaymentMethodName == null) {
                    setState(() {
                      payWarn = true;
                    });
                  } else {
                    isButtonLoading.value = true;
                    if (systemProvider!.selectedPaymentMethodName!.trim() ==
                        'STRIPE_LBL'.translate(context: context).trim()) {
                      var response = await doPaymentWithStripe(
                        price: amountTextController!.text,
                        currencyCode: context
                            .read<SystemProvider>()
                            .stripeCurrencyCode!,
                        paymentFor: 'wallet',
                        context: context,
                      );
                      Navigator.pop(context, response);
                      //await updateUserWalletAmount();
                    } else if (systemProvider!.selectedPaymentMethodName!
                            .trim() ==
                        'RAZORPAY_LBL'.translate(context: context).trim()) {
                      var response = await doPaymentWithRazorpay(
                        price: int.parse(amountTextController!.text),
                      );
                      // await updateUserWalletAmount();
                      Navigator.pop(context, response);
                    } else if (systemProvider!.selectedPaymentMethodName!
                            .trim() ==
                        'PAYSTACK_LBL'.translate(context: context).trim()) {
                      var response = await doPaymentWithPayStack(
                        price: double.parse(amountTextController!.text),
                      );
                      Navigator.pop(context, response);
                      // await updateUserWalletAmount();
                    } else if (systemProvider!.selectedPaymentMethodName ==
                        'PAYTM_LBL'.translate(context: context)) {
                      var response = await doPaymentWithPaytm(
                        price: double.parse(amountTextController!.text),
                      );
                      Navigator.pop(context, response);
                      // await updateUserWalletAmount();
                    } else if (systemProvider!.selectedPaymentMethodName ==
                        'PAYPAL_LBL'.translate(context: context)) {
                      var response = await doPaymentWithPaypal(
                        price: amountTextController!.text,
                      );
                      Navigator.pop(context, response);
                      //await updateUserWalletAmount();
                    } else if (systemProvider!.selectedPaymentMethodName ==
                        'FLUTTERWAVE_LBL'.translate(context: context)) {
                      var response = await doPaymentWithFlutterWave(
                        price: amountTextController!.text,
                      );
                      Navigator.pop(context, response);
                      // await updateUserWalletAmount();
                    } else if (systemProvider!.selectedPaymentMethodName ==
                        'MidTrans'.translate(context: context)) {
                      await doPaymentWithMidTrash(
                        price: amountTextController!.text,
                      );
                    } else if (systemProvider!.selectedPaymentMethodName ==
                        'My Fatoorah'.translate(context: context)) {
                      var response = await doMyFatoorah(
                        price: amountTextController!.text,
                      );

                      Navigator.pop(context, response);
                    } else if (systemProvider!.selectedPaymentMethodName ==
                        'instamojo_lbl'.translate(context: context)) {
                      var response = await doPaymentWithInstamojo(
                        price: amountTextController!.text,
                      );
                      Navigator.pop(context, response);
                      // await updateUserWalletAmount();
                    } else if (systemProvider!.selectedPaymentMethodName ==
                        'PHONEPE_LBL'.translate(context: context)) {
                      var response = await payWithPhonePeWallet(
                        double.parse(amountTextController!.text.toString()),
                      );
                      Navigator.pop(context, response);
                    }
                    isButtonLoading.value = false;
                  }
                  //updateTransaction();
                }
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  List<Widget> getPaymentMethodList(BuildContext context) {
    return context
        .read<SystemProvider>()
        .paymentMethodList
        .asMap()
        .map((index, element) => MapEntry(index, paymentItem(index, context)))
        .values
        .toList();
  }

  Widget paymentItem(int index, BuildContext context) {
    systemProvider ??= Provider.of<SystemProvider>(context, listen: false);
    if (index == 0 && systemProvider!.isPaypalEnable! ||
        index == 1 && systemProvider!.isRazorpayEnable! ||
        index == 2 && systemProvider!.isPayStackEnable! ||
        index == 3 && systemProvider!.isFlutterWaveEnable! ||
        index == 4 && systemProvider!.isStripeEnable! ||
        index == 5 && systemProvider!.isPaytmEnable! ||
        index == 6 && systemProvider!.isMidtrashEnable! ||
        index == 7 && systemProvider!.isMyFatoorahEnable! ||
        index == 8 && systemProvider!.isInstamojoEnable! ||
        index == 9 && systemProvider!.isPhonepeEnable!) {
      return InkWell(
        onTap: () {
          systemProvider!.selectedPaymentMethodIndex = index;
          systemProvider!.selectedPaymentMethodName = systemProvider!
              .paymentMethodList[systemProvider!.selectedPaymentMethodIndex];
          for (var element in systemProvider!.payModel) {
            element.isSelected = false;
          }
          systemProvider!.payModel[index].isSelected = true;
          setState(() {});
        },
        child: RadioItem(systemProvider!.payModel[index]),
      );
    } else {
      return const SizedBox();
    }
  }

  Future<Map<String, dynamic>> payWithPhonePeWallet(double price) async {
    String orderID =
        '${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}';

    Map<String, dynamic> result = {
      'error': true,
      'message': 'PHONEPE_PAYMENT_FAILED'.translate(context: context),
      'status': false,
    };

    await initiatePhonePePayment(
      context: context,
      orderId: orderID,
      paymentType: 'wallet',
      amount: price.toString(),
      onSuccess: () {
        setSnackbar(
          'PHONEPE_PAYMENT_SUCCESS'.translate(context: context),
          context,
        );
        result = {
          'error': false,
          'message': 'PHONEPE_PAYMENT_SUCCESS',
          'status': true,
        };
      },
      onFailure: () {
        setSnackbar(
          'PHONEPE_PAYMENT_FAILED'.translate(context: context),
          context,
        );
        result = {
          'error': true,
          'message': 'PHONEPE_PAYMENT_FAILED',
          'status': false,
        };
      },
    );

    return result;
  }

  // Future<bool> addTransaction({
  //   required String tranId,
  //   required String status,
  //   required String msg,
  //   required String amount,
  //   required String paymentMethod,
  // }) async {
  //   try {
  //     var parameter = {
  //       // USER_ID: context.read<UserProvider>().userId,
  //       TXNID: tranId,
  //       AMOUNT: amount,
  //       STATUS: status,
  //       MSG: msg,
  //       ORDERID: tranId,
  //       PAYMENT_METHOD: paymentMethod,
  //       'transaction_type': 'wallet',
  //       'type': 'credit',
  //     };
  //     final getdata = await apiBaseHelper.postAPICall(
  //       addTransactionApi,
  //       parameter,
  //     );

  //     return getdata['error'] == false;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  // Future<Map<String, dynamic>> doPaymentWithPhonePe({
  //   required double price,
  // }) async {
  //   try {
  //     // Generate a unique order ID for the wallet transaction
  //     String orderID =
  //         '${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}';

  //     // Before starting PhonePe transaction, add 'awaiting' transaction
  //     await addTransaction(
  //       tranId: orderID,
  //       status: 'awaiting',
  //       msg: 'waiting for payment',
  //       amount: price.toString(),
  //       paymentMethod: 'PhonePe',
  //     );

  //     // Get PhonePe details from backend for wallet
  //     final phonePeDetails = await PaymentRepository.getPhonePeDetails(
  //       userId: context.read<UserProvider>().userId ?? '0',
  //       type: 'wallet',
  //       mobile: context.read<UserProvider>().mob.trim().isEmpty
  //           ? context.read<UserProvider>().userId ?? '0'
  //           : context.read<UserProvider>().mob,
  //       amount: price.toString(),
  //       orderId: orderID,
  //       transationId: orderID,
  //     );

  //     final data = phonePeDetails['data'];
  //     final environment = data['environment'];
  //     final flowId = data['flowId'];
  //     final merchantId = data['request']['merchantId'];
  //     final enableLogging = data['enableLogging'];

  //     // Initialize PhonePe SDK with backend values
  //     bool isInitialized = await PhonePePaymentSdk.init(
  //       environment,
  //       merchantId,
  //       flowId,
  //       enableLogging,
  //     );

  //     if (!isInitialized) {
  //       return {
  //         'error': true,
  //         'message': 'PHONEPE_PAYMENT_FAILED'.translate(context: context),
  //         'status': false,
  //       };
  //     }

  //     // Build payload from backend response
  //     final request = data['request'];

  //     Map<String, dynamic> payload = {
  //       'orderId': request['merchantOrderId'],
  //       'merchantId': request['merchantId'],
  //       'token': request['token'],
  //       'paymentMode': request['paymentMode'],
  //     };
  //     String payloadJson = jsonEncode(payload);
  //     print('PhonePe payload: $payloadJson');

  //     final package = Platform.isAndroid ? packageName : iosPackage;
  //     final response = await PhonePePaymentSdk.startTransaction(
  //       payloadJson,
  //       package,
  //     );
  //     print("PhonePe Status ---->  ${response?['status']}");
  //     if (response != null) {
  //       String status = response['status'].toString();
  //       if (status == 'SUCCESS' ||
  //           status == 'PAYMENT_SUCCESS' ||
  //           status.toLowerCase().contains('success') ||
  //           status.toLowerCase().contains('payment_success')) {
  //         return {
  //           'error': false,
  //           'message': 'PHONEPE_PAYMENT_SUCCESS'.translate(context: context),
  //           'status': true,
  //         };
  //       } else {
  //         // On failure, return error
  //         return {
  //           'error': true,
  //           'message': 'PHONEPE_PAYMENT_FAILED'.translate(context: context),
  //           'status': false,
  //         };
  //       }
  //     } else {
  //       return {
  //         'error': true,
  //         'message': 'PHONEPE_PAYMENT_FAILED'.translate(context: context),
  //         'status': false,
  //       };
  //     }
  //   } catch (error) {
  //     print('PhonePe Payment Error: $error');
  //     return {
  //       'error': true,
  //       'message': 'PHONEPE_PAYMENT_FAILED'.translate(context: context),
  //       'status': false,
  //     };
  //   }
  // }

  Future<Map<String, dynamic>> doPaymentWithPaytm({
    required double price,
  }) async {
    context.read<MyWalletProvider>().isLoading = true;
    try {
      String orderID = DateTime.now().millisecondsSinceEpoch.toString();

      String paytmCallBackURL =
          context.read<SystemProvider>().isPaytmOnTestMode ?? true
          ? 'https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderID'
          : 'https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderID';

      var response = await context.read<PaymentProvider>().payWithPaytm(
        userID: context.read<UserProvider>().userId!,
        orderID: orderID,
        paymentAmount: price.toString(),
        paytmCallBackURL: paytmCallBackURL,
        paytmMerchantID: context.read<SystemProvider>().paytmMerchantID!,
        isTestingModeEnable:
            context.read<SystemProvider>().isPaytmOnTestMode ?? true,
      );

      return response;
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithStripe({
    required String price,
    required String currencyCode,
    required String paymentFor,
    required BuildContext context,
  }) async {
    try {
      var response = await context.read<PaymentProvider>().payWithStripe(
        paymentAmount: price.toString(),
        currencyCode: currencyCode,
        paymentFor: paymentFor,
        context: context,
      );

      return response;
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doMyFatoorah({required String price}) async {
    try {
      String tranId = '';
      String orderID =
          'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      String amount = price;
      String successUrl =
          '${systemProvider!.myfatoorahSuccessUrl!}?txn_id=$tranId&order_id=$orderID&amount=$price';
      String errorUrl =
          '${systemProvider!.myfatoorahErrorUrl!}?txn_id=$tranId&order_id=$orderID&amount=$price';
      String token = systemProvider!.myfatoorahToken!;
      try {
        var response = await MyFatoorah.startPayment(
          context: context,
          successChild: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 200,
              height: 200,
              child: Icon(Icons.done, size: 100, color: Colors.green),
            ),
          ),
          request: systemProvider!.myfatoorahPaymentMode == 'test'
              ? MyfatoorahRequest.test(
                  userDefinedField: orderID,
                  currencyIso: () {
                    if (systemProvider!.myfatoorahCosuntry == 'Kuwait') {
                      return Country.Kuwait;
                    } else if (systemProvider!.myfatoorahCosuntry == 'UAE') {
                      return Country.UAE;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Egypt') {
                      return Country.Egypt;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Jordan') {
                      return Country.Jordan;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Oman') {
                      return Country.Oman;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (systemProvider!.myfatoorahLanguage == 'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                )
              : MyfatoorahRequest.live(
                  userDefinedField: orderID,
                  currencyIso: () {
                    if (systemProvider!.myfatoorahCosuntry == 'Kuwait') {
                      return Country.Kuwait;
                    } else if (systemProvider!.myfatoorahCosuntry == 'UAE') {
                      return Country.UAE;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Egypt') {
                      return Country.Egypt;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Jordan') {
                      return Country.Jordan;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Oman') {
                      return Country.Oman;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (systemProvider!.myfatoorahLanguage == 'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                ),
        );
        if (response.status.toString() == 'PaymentStatus.Success') {
          //updateUserWalletAmount();
          return {
            'error': false,
            'message': 'Transaction Successful',
            'status': true,
          };
        }
        if (response.status.toString() == 'PaymentStatus.Error') {
          return {'error': true, 'message': e.toString(), 'status': false};
        }
        if (response.status.toString() == 'PaymentStatus.None') {
          return {'error': true, 'message': e.toString(), 'status': false};
        }
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), context);
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithMidTrash({
    required String price,
  }) async {
    try {
      String orderID =
          'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      //
      try {
        var parameter = {
          AMOUNT: price,
          // USER_ID: context.read<UserProvider>().userId,
          ORDER_ID: orderID,
        };
        apiBaseHelper
            .postAPICall(createMidtransTransactionApi, parameter)
            .then(
              (getdata) {
                bool error = getdata['error'];
                String? msg = getdata['message'];
                if (!error) {
                  var data = getdata['data'];
                  // String token = data['token'];
                  String redirectUrl = data['redirect_url'];
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) => MidTrashWebview(
                        url: redirectUrl,
                        from: 'order',
                        orderId: orderID,
                      ),
                    ),
                  ).then((value) async {
                    String msg = await context
                        .read<PaymentProvider>()
                        .midtransWebhook(orderID);
                    if (msg ==
                        'Order id is not matched with transaction order id.') {
                      msg = 'Transaction Failed...!';
                    }
                    String currentBalance = await context
                        .read<PaymentProvider>()
                        .getUserCurrentBalance(context);
                    if (currentBalance != '') {
                      Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).setBalance(currentBalance);
                    }
                    setSnackbar(msg, context);
                    Navigator.pop(context, value);
                  });
                } else {
                  setSnackbar(msg!, context);
                }
              },
              onError: (error) {
                setSnackbar(error.toString(), context);
              },
            );
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), context);
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithPaypal({
    required String price,
  }) async {
    try {
      String orderID =
          'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';

      var paypalLink = await context
          .read<PaymentProvider>()
          .getPaypalGatewayLink(
            userID: context.read<UserProvider>().userId.toString(),
            orderID: orderID,
            paymentAmount: price,
          );

      if (paypalLink != '') {
        var response = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) =>
                WebViewClass(url: paypalLink, from: 'wallet'),
          ),
        );

        if (response == 'true') {
          return {'error': true, 'message': '', 'status': false};
        }
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithInstamojo({
    required String price,
  }) async {
    try {
      var link = await context.read<PaymentProvider>().getInstamojoGatewayLink(
        userID: context.read<UserProvider>().userId.toString(),
        paymentAmount: price,
        unioqueOrderId:
            'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}',
      );

      if (link != '') {
        var response = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) =>
                InstamojoWebview(url: link, from: 'wallet'),
          ),
        );
        if (response == 'true') {
          return {'error': true, 'message': '', 'status': false};
        }
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithFlutterWave({
    required String price,
  }) async {
    try {
      var flutterWaveLink = await context
          .read<PaymentProvider>()
          .getFlutterWaveGatewayLink(
            userID: context.read<UserProvider>().userId.toString(),
            paymentAmount: price,
            unioqueOrderId:
                'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}',
          );

      if (flutterWaveLink != '') {
        var response = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) =>
                WebViewClass(url: flutterWaveLink, from: 'wallet'),
          ),
        );
        if (response == 'true') {
          return {'error': true, 'message': '', 'status': false};
        }
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<Map<String, dynamic>> doPaymentWithPayStack({
    required double price,
  }) async {
    try {
      String payStackID = context.read<SystemProvider>().payStackKeyID!;
      String? userEmail = context.read<UserProvider>().email;

      var response = await context.read<PaymentProvider>().payWithPayStack(
        paymentAmount: (price * 100).toInt(),
        userEmail: userEmail,
        reference: _getReference(),
        // Platform.isIOS ? 'iOS' : 'Android',
        payStackID: payStackID,
        context: context,
      );

      return response;
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithRazorpay({
    required int price,
  }) async {
    try {
      String orderID =
          'wallet-refill-user-${context.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      SettingProvider settingsProvider = Provider.of<SettingProvider>(
        context,
        listen: false,
      );
      String userContactNumber = settingsProvider.mobile;
      String userEmail = settingsProvider.email;
      String razorpayID = context.read<SystemProvider>().razorpayId!;

      double payableAmount = price * 100;
      var razorpayOptions = {
        KEY: razorpayID,
        AMOUNT: payableAmount.toString(),
        NAME: settingsProvider.userName,
        'notes': {'order_id': orderID},
        'prefill': {CONTACT: userContactNumber, EMAIL: userEmail},
      };

      _razorpay.open(razorpayOptions);

      return {'error': true, 'message': '', 'status': false};
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setSnackbar('Transaction Successful'.translate(context: context), context);
    Navigator.pop(context, response);
    // await updateUserWalletAmount();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setSnackbar('somethingMSg'.translate(context: context), context);
    Navigator.pop(context, response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}
}
