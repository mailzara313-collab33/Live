import 'dart:convert';
import 'dart:io';

import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/repository/paymentMethodRepository.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:provider/provider.dart';

Future<bool> addTransaction({
  required String tranId,
  required String status,
  required String msg,
  required String amount,
  required String paymentMethod,
}) async {
  try {
    var parameter = {
      // USER_ID: context.read<UserProvider>().userId,
      TXNID: tranId,
      AMOUNT: amount,
      STATUS: status,
      MSG: msg,
      ORDERID: tranId,
      PAYMENT_METHOD: paymentMethod,
      'transaction_type': 'wallet',
      'type': 'credit',
    };
    final getdata = await apiBaseHelper.postAPICall(
      addTransactionApi,
      parameter,
    );

    return getdata['error'] == false;
  } catch (_) {
    return false;
  }
}

Future<void> initiatePhonePePayment({
  required String orderId,
  required String paymentType, // 'cart' or 'wallet'
  String? amount, // Only required for wallet
  required BuildContext context,
  Function()? onSuccess,
  Function()? onFailure,
}) async {
  try {
    // Prepare request data
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId ?? '0';
    final mobile = userProvider.mob.trim().isEmpty ? userId : userProvider.mob;

    if (paymentType == 'wallet') {
      // Add 'awaiting' transaction before payment
      await addTransaction(
        tranId: orderId,
        status: 'awaiting',
        msg: 'waiting for payment',
        amount: amount ?? '',
        paymentMethod: 'PhonePe',
      );
    }

    // Fetch PhonePe details from API
    final phonePeDetails = await PaymentRepository.getPhonePeDetails(
      userId: userId,
      type: paymentType,
      mobile: mobile,
      amount: amount,
      orderId: orderId,
      transationId: orderId,
    );

    final data = phonePeDetails['data'];
    final environment = data['environment'];
    final flowId = data['flowId'];
    final merchantId = data['request']['merchantId'];
    final enableLogging = data['enableLogging'];
    final request = data['request'];

    // Initialize SDK
    bool isInitialized = await PhonePePaymentSdk.init(
      environment,
      merchantId,
      flowId,
      enableLogging,
    );

    if (!isInitialized) {
      throw Exception('PhonePe SDK initialization failed');
    }

    // Build payload
    Map<String, dynamic> payload = {
      'orderId': request['merchantOrderId'],
      'merchantId': request['merchantId'],
      'token': request['token'],
      'paymentMode': request['paymentMode'],
    };

    String payloadJson = jsonEncode(payload);
    print('PhonePe payload: $payloadJson');

    final package = Platform.isAndroid ? packageName : iosPackage;
    final response = await PhonePePaymentSdk.startTransaction(
      payloadJson,
      package,
    );

    print("PhonePe Status ----> ${response?['status']}");

    if (response != null) {
      String status = response['status'].toString().toLowerCase();
      if (status.contains('success')) {
        // Success
        if (onSuccess != null) onSuccess();
        return;
      }
    }

    // Failure fallback
    if (onFailure != null) onFailure();
  } catch (error) {
    print('PhonePe Payment Error: $error');
    if (onFailure != null) onFailure();
  }
}
