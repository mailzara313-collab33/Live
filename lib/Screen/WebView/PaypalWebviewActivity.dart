import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/widgets/networkAvailablity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../widgets/desing.dart';

import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewClass extends StatefulWidget {
  final String? url, from, msg, amt, orderId;

  const WebViewClass({
    super.key,
    this.url,
    this.from,
    this.msg,
    this.amt,
    this.orderId,
  });

  @override
  State<StatefulWidget> createState() {
    return StateWebViewClass();
  }
}

class StateWebViewClass extends State<WebViewClass> {
  String message = '';
  bool isloading = true;
  bool transactionSuccessful =
      false; // Track if transaction completed successfully
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? currentBackPressTime;
  late UserProvider userProvider;
  late final WebViewController _controller;

  @override
  void initState() {
    webViewInitiliased();
    super.initState();
  }

  void webViewInitiliased() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(
              () {
                isloading = false;
              },
            );
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
                Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(PAYPAL_RESPONSE_URL) ||
                request.url.startsWith(FLUTTERWAVE_RES_URL)) {
              if (mounted) {
                setState(() {
                  isloading = true;
                });
              }
              String responseurl = request.url;
              if (responseurl.contains('Failed') ||
                  responseurl.contains('failed')) {
                if (mounted) {
                  setState(() {
                    isloading = false;
                    message = 'Transaction Failed';
                  });
                }
                Timer(const Duration(seconds: 1), () {
                  Routes.pop(context);
                });
              } else if (responseurl.contains('Completed') ||
                  responseurl.contains('completed') ||
                  responseurl.toLowerCase().contains('success') ||
                  responseurl.toLowerCase().contains('successful')) {
                if (mounted) {
                  setState(() {
                    message = 'Transaction Successfull';
                  });
                }
                List<String> testdata = responseurl.split('&');
                bool transactionProcessed = false;

                for (String data in testdata) {
                  if (data.contains('=') &&
                      (data.split('=')[0].toLowerCase() == 'tx' ||
                          data.split('=')[0].toLowerCase() ==
                              'transaction_id')) {
                    // Validate transaction ID is not null or empty
                    List<String> parts = data.split('=');
                    if (parts.length > 1 && parts[1].isNotEmpty) {
                      String txid = parts[1];
                      userProvider.setCartCount('0');
                      transactionProcessed = true;

                      if (widget.from == 'order') {
                        if (request.url.startsWith(PAYPAL_RESPONSE_URL)) {
                          Routes.navigateToOrderSuccessScreen(context);
                        } else {
                          addTransaction(
                            txid,
                            widget.orderId!,
                            SUCCESS,
                            'Order placed successfully',
                            true,
                          );
                        }
                      } else if (widget.from == 'wallet') {
                        if (request.url.startsWith(FLUTTERWAVE_RES_URL)) {
                          setSnackbar('Transaction Successful', context);
                          if (mounted) {
                            setState(
                              () {
                                isloading = false;
                              },
                            );
                          }
                          Timer(
                            const Duration(seconds: 1),
                            () {
                              transactionSuccessful = true;
                              Navigator.pop(context, 'true');
                            },
                          );
                        } else {
                          transactionSuccessful = true;
                          Navigator.pop(context, 'true');
                        }
                      }
                      break;
                    }
                  }
                }

                // If no valid transaction ID found but response indicates success
                if (!transactionProcessed && widget.from == 'order') {
                  userProvider.setCartCount('0');
                  if (request.url.startsWith(PAYPAL_RESPONSE_URL)) {
                    Routes.navigateToOrderSuccessScreen(context);
                  } else {
                    // Use a fallback transaction ID for successful transactions without proper ID
                    String fallbackTxid =
                        'success_${DateTime.now().millisecondsSinceEpoch}';
                    addTransaction(
                      fallbackTxid,
                      widget.orderId!,
                      SUCCESS,
                      'Order placed successfully',
                      true,
                    );
                  }
                }
              }

              // Only delete order if transaction explicitly failed, not if it was successful
              if (request.url.startsWith(PAYPAL_RESPONSE_URL) &&
                      widget.orderId != null &&
                      !responseurl.toLowerCase().contains('success') ||
                  !responseurl.toLowerCase().contains('successful') &&
                      !responseurl.contains('Completed') &&
                      !responseurl.contains('completed') &&
                      (responseurl.contains('Canceled-Reversal') ||
                          responseurl.contains('Denied') ||
                          responseurl.contains('Failed'))) {
                deleteOrder();
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          setSnackbar(message.message, context);
        },
      )
      ..loadRequest(Uri.parse(widget.url!));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: DesignConfiguration.shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(circularBorderRadius4),
                onTap: () {
                  DateTime now = DateTime.now();
                  if (currentBackPressTime == null ||
                      now.difference(currentBackPressTime!) >
                          const Duration(seconds: 2)) {
                    currentBackPressTime = now;
                    setSnackbar(
                      "${"Don't press back while doing payment!".translate(
                        context: context,
                      )}\n ${'EXIT_WR'.translate(context: context)}",
                      context,
                    );
                  }
                  if (widget.from == 'order' &&
                      widget.orderId != null &&
                      !transactionSuccessful) {
                    deleteOrder();
                  }
                  Routes.pop(context);
                },
                child: const Center(
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          );
        }),
        title: Text(
          appName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontFamily: 'ubuntu',
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime = now;
            setSnackbar(
                "${"Don't press back while doing payment!".translate(
                  context: context,
                )}\n ${'EXIT_WR'.translate(
                  context: context,
                )}",
                context);
          } else {
            if (widget.from == 'order' &&
                widget.orderId != null &&
                !transactionSuccessful) {
              deleteOrder();
            }

            if (didPop) {
              return;
            }
            Navigator.pop(context, 'true');
          }
        },
        child: Stack(
          children: <Widget>[
            isNetworkAvail
                ? WebViewWidget(controller: _controller)
                : const SizedBox(),
            isloading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox(),
            message.trim().isEmpty
                ? const SizedBox()
                : Center(
                    child: Container(
                      color: colors.primary,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.white,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteOrder() async {
    try {
      var parameter = {
        ORDER_ID: widget.orderId,
      };

      await post(deleteOrderApi, body: parameter, headers: headers).timeout(
        const Duration(
          seconds: timeOut,
        ),
      );
      if (mounted) {
        setState(
          () {
            isloading = false;
          },
        );
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar('somethingMSg'.translate(context: context), context);

      setState(
        () {
          isloading = false;
        },
      );
    }
  }

  Future<void> addTransaction(String tranId, String orderID, String status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        ORDER_ID: orderID,
        TYPE: context.read<CartProvider>().payMethod,
        TXNID: tranId,
        AMOUNT: context.read<CartProvider>().totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };

      Response response =
          await post(addTransactionApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      DateTime now = DateTime.now();
      currentBackPressTime = now;
      var getdata = json.decode(response.body);

      bool error = getdata['error'];
      String? msg1 = getdata['message'];
      if (!error) {
        if (redirect) {
          userProvider.setCartCount('0');

          context.read<CartProvider>().totalPrice = 0;
          context.read<CartProvider>().oriPrice = 0;
          context.read<CartProvider>().taxPer = 0;
          context.read<CartProvider>().deliveryCharge = 0;
          context.read<CartProvider>().addressList.clear();
          context.read<CartProvider>().setCartlist([]);
          context.read<CartProvider>().setProgress(false);
          context.read<CartProvider>().promoAmt = 0;
          context.read<CartProvider>().remWalBal = 0;
          context.read<CartProvider>().usedBalance = 0;
          context.read<CartProvider>().payMethod = null;
          context.read<CartProvider>().isPromoValid = false;
          context.read<CartProvider>().isUseWallet = false;
          context.read<CartProvider>().isPayLayShow = true;
          context.read<CartProvider>().selectedMethod = null;
          context.read<CartProvider>().deliverable = false;
          context.read<CartProvider>().codDeliverChargesOfShipRocket = 0.0;
          context.read<CartProvider>().prePaidDeliverChargesOfShipRocket = 0.0;
          context.read<CartProvider>().isLocalDelCharge = null;
          context.read<CartProvider>().isShippingDeliveryChargeApplied = false;
          context.read<CartProvider>().shipRocketDeliverableDate = '';
          context.read<CartProvider>().isAddressChange = null;
          context.read<CartProvider>().noteController.clear();
          context.read<CartProvider>().promoC.clear();
          context.read<CartProvider>().promocode = null;

          // Return success to Cart.dart instead of navigating directly
          transactionSuccessful = true; // Mark transaction as successful
          Navigator.pop(context, 'true');
        }
      } else {
        setSnackbar(msg1!, context);
      }
    } on TimeoutException catch (_) {
      setSnackbar('somethingMSg'.translate(context: context), context);
    }
  }
}
