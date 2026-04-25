import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/repository/Order/OrderRepository.dart';
import 'package:eshop_multivendor/widgets/networkAvailablity.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/UpdateOrderProvider.dart';
import '../../../widgets/desing.dart';

import '../../../widgets/snackbar.dart';
import 'SingleProduct.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class GetOrderDetails extends StatelessWidget {
  OrderModel model;
  ScrollController controller;
  Future<List<Directory>?>? externalStorageDirectories;
  Function updateNow;

  GetOrderDetails({
    super.key,
    this.externalStorageDirectories,
    required this.controller,
    required this.updateNow,
    required this.model,
  });

  Widget priceDetails(BuildContext context, OrderModel model) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                'PRICE_DETAIL'.translate(context: context),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${'PRICE_LBL'.translate(context: context)} : (${'INCLUDE_LBL'.translate(context: context)} ${DesignConfiguration.getPriceFormat(context, double.parse(model.taxAmount!))!} ${'IN_TAXES_LBL'.translate(context: context)})",
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2,
                          ),
                    ),
                  ),
                  Text(
                    ' ${DesignConfiguration.getPriceFormat(context, double.parse(model.subTotal!))!}',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${'DELIVERY_CHARGE'.translate(context: context)} :',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2)),
                  Text(
                      '+${DesignConfiguration.getPriceFormat(context, double.parse(model.delCharge!))!}',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${'PROMO_CODE_DIS_LBL'.translate(context: context)} :',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2)),
                  Text(
                      '-${DesignConfiguration.getPriceFormat(context, double.parse(model.promoDis!))!}',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'WALLET_BAL'.translate(context: context)} :',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  ),
                  Text(
                    '-${DesignConfiguration.getPriceFormat(context, double.parse(model.walBal!))!}',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 15.0, end: 15.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'PAYABLE'.translate(context: context)} :',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                        ),
                  ),
                  Text(
                    DesignConfiguration.getPriceFormat(
                        context, double.parse(model.payable!))!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 15.0,
                end: 15.0,
                top: 5.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${'TOTAL_PRICE'.translate(context: context)} :',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontWeight: FontWeight.bold)),
                  Text(
                    DesignConfiguration.getPriceFormat(
                      context,
                      double.parse(model.total!),
                    )!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontWeight: FontWeight.bold,
                        ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _imgFromGallery(BuildContext context) async {
    var result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null) {
      context.read<UpdateOrdProvider>().files =
          result.paths.map((path) => File(path!)).toList();
      updateNow();
    } else {
      // User canceled the picker
    }
  }

  Widget bankProof(OrderModel model) {
    String status = model.attachList![0].bankTranStatus!;
    Color clr;
    if (status == '0') {
      status = 'Pending';
      clr = Colors.cyan;
    } else if (status == '1') {
      status = 'Rejected';
      clr = Colors.red;
    } else {
      status = 'Accepted';
      clr = Colors.green;
    }

    return Card(
      elevation: 0,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: model.attachList!.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Text(
                        '${'Attachment'.translate(context: context)} ${i + 1}',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      onTap: () {
                        _launchURL(
                          model.attachList![i].attachment!,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: clr,
              borderRadius: BorderRadius.circular(circularBorderRadius5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(status),
            ),
          )
        ],
      ),
    );
  }

  void _launchURL(String url) async => await canLaunchUrlString(url)
      ? await launchUrlString(url)
      : throw 'Could not launch $url';

  Widget shippingDetails(BuildContext context, OrderModel model) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                'SHIPPING_DETAIL'.translate(context: context),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                model.userAddressName ?? '' ',',
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                model.address!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.lightBlack2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                model.mobile!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.lightBlack2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Widget dwnInvoice(OrderModel model, Function update, BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        child: ListTile(
          dense: true,
          trailing: const Icon(
            Icons.navigate_next,
            color: colors.primary,
          ),
          leading: const Icon(
            Icons.receipt,
            color: colors.primary,
          ),
          title: Text(
            'DWNLD_INVOICE'.translate(context: context),
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.lightBlack),
          ),
        ),
        onTap: () async {
          context
              .read<UpdateOrdProvider>()
              .changeStatus(UpdateOrdStatus.inProgress);
          updateNow();

          String invoiceHtml = await OrderRepository.getInvoiceHtml(
              orderId: model.id.toString());
          if (invoiceHtml.trim().isNotEmpty) {
            bool hasPermission = await checkPermission();

            String target = Platform.isAndroid && hasPermission
                ? (await ExternalPath.getExternalStoragePublicDirectory(
                    ExternalPath.DIRECTORY_DOWNLOAD,
                  ))
                : (await getApplicationDocumentsDirectory()).path;

            var targetFileName = 'Invoice_${model.id!}';
            var generatedPdfFile, filePath;
            try {
              generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
                  invoiceHtml, target, targetFileName);
              filePath = generatedPdfFile.path;
            } catch (e) {
              context
                  .read<UpdateOrdProvider>()
                  .changeStatus(UpdateOrdStatus.initial);
              updateNow();
              setSnackbar('somethingMSg'.translate(context: context), context);
              return;
            }
            context
                .read<UpdateOrdProvider>()
                .changeStatus(UpdateOrdStatus.isSuccsess);
            updateNow();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${'INVOICE_PATH'.translate(context: context)} $targetFileName",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.black),
                ),
                action: SnackBarAction(
                  label: 'VIEW'.translate(context: context),
                  textColor: Theme.of(context).colorScheme.fontColor,
                  onPressed: () async {
                    await OpenFile.open(filePath);
                  },
                ),
                backgroundColor: Theme.of(context).colorScheme.white,
                elevation: 1.0,
              ),
            );
          } else {
            context
                .read<UpdateOrdProvider>()
                .changeStatus(UpdateOrdStatus.initial);
            updateNow();
            setSnackbar('somethingMSg'.translate(context: context), context);
          }
        },
      ),
    );
  }

  Widget bankTransfer(OrderModel model, BuildContext context, String id) {
    return model.payMethod.toString().toLowerCase() ==
            'Bank Transfer'.toLowerCase()
        ? Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BANKRECEIPT'.translate(context: context),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack),
                      ),
                      SizedBox(
                        height: 30,
                        child: IconButton(
                          icon: const Icon(
                            Icons.add_photo_alternate,
                            color: colors.primary,
                            size: 20.0,
                          ),
                          onPressed: () {
                            _imgFromGallery(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  model.attachList!.isNotEmpty
                      ? bankProof(model)
                      : const SizedBox(),
                  Consumer<UpdateOrdProvider>(builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0, top: 5),
                      height: value.files.isNotEmpty ? 180 : 0,
                      child: value.files.isNotEmpty
                          ? Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: value.files.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, i) {
                                      return InkWell(
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional.topEnd,
                                          children: [
                                            Image.file(
                                              value.files[i],
                                              width: 180,
                                              height: 180,
                                            ),
                                            Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .black26,
                                              child: const Icon(
                                                Icons.clear,
                                                size: 15,
                                              ),
                                            )
                                          ],
                                        ),
                                        onTap: () {
                                          value.files.removeAt(i);
                                          updateNow();
                                        },
                                      );
                                    },
                                  ),
                                ),
                                InkWell(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightWhite,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(
                                          circularBorderRadius4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'SUBMIT_LBL'.translate(context: context),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor),
                                    ),
                                  ),
                                  onTap: () {
                                    if (value.getCurrentStatus !=
                                        UpdateOrdStatus.inProgress) {
                                      Future.delayed(Duration.zero).then(
                                        (value) => context
                                            .read<UpdateOrdProvider>()
                                            .sendBankProof(id, context),
                                      );
                                    }
                                  },
                                ),
                              ],
                            )
                          : SizedBox(),
                    );
                  })
                ],
              ),
            ),
          )
        : const SizedBox();
  }

  Widget showNote(OrderModel model, BuildContext context) {
    return model.note! != ''
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${'NOTE'.translate(context: context)}:",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                    Text(model.note!,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget getOrderNoAndOTPDetails(OrderModel model, BuildContext context) {
    return Card(
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${"ORDER_ID_LBL".translate(context: context)} - ${model.id}",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                Text(
                  DateTime.tryParse(model.dateTime ?? '') == null
                      ? '${model.dateTime}'
                      : DateFormat('dd-MM-yyyy hh:mm a')
                          .format(DateTime.parse(model.dateTime!)),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )
              ],
            ),
            model.otp != null && model.otp!.isNotEmpty && model.otp != '0'
                ? Text(
                    "${"OTP".translate(context: context)} - ${model.otp}",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  )
                : const SizedBox(),
            Text(
              'Email - ${model.email}',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.lightBlack2),
            ),
          ],
        ),
      ),
    );
  }

  reOrderDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext cxt) {
        return AlertDialog(
          title: Text(
            'RE_ORDER'.translate(context: cxt),
            style: TextStyle(color: Theme.of(cxt).colorScheme.fontColor),
          ),
          content: Text(
            'RE_ORDER_WARNNING'.translate(context: cxt),
            style: TextStyle(
              color: Theme.of(cxt).colorScheme.fontColor,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'YES'.translate(context: cxt),
                style: const TextStyle(color: colors.primary),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              child: Text(
                'NO'.translate(context: cxt),
                style: const TextStyle(color: colors.primary),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      },
    ).then((value) {
      return value;
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, StateSetter setState) {
      return Stack(
        children: [
          SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  getOrderNoAndOTPDetails(model, context),
                  model.delDate != null && model.delDate!.isNotEmpty
                      ? Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "${'PREFER_DATE_TIME'.translate(context: context)}: ${model.delDate!} - ${model.delTime!}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  showNote(model, context),
                  bankTransfer(model, context, model.id!),
                  GetSingleProduct(
                    model: model,
                    activeStatus: '',
                    id: model.id!,
                    updateNow: updateNow,
                  ),
                  dwnInvoice(model, updateNow, context),
                  //reorder button
                  Card(
                    elevation: 0,
                    child: InkWell(
                        child: ListTile(
                          dense: true,
                          trailing: const Icon(
                            Icons.navigate_next,
                            color: colors.primary,
                          ),
                          leading: const Icon(
                            Icons.shopping_cart,
                            color: colors.primary,
                          ),
                          title: Text(
                            'RE_ORDER'.translate(context: context),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack),
                          ),
                        ),
                        onTap: () async {
                          bool? didReOrder = await reOrderDialog(context);
                          if (didReOrder != null && didReOrder) {
                            setState(
                              () {
                                loading = true;
                              },
                            );
                            bool showSuccessMessage = false;
                            bool navigateToCartScreen = false;
                            try {
                              isNetworkAvail = await isNetworkAvailable();
                              if (isNetworkAvail) {
                                if (context.read<UserProvider>().userId != '') {
                                  try {
                                    if (context.mounted) {
                                      setState(
                                        () {
                                          context
                                              .read<CartProvider>()
                                              .setProgress(true);
                                        },
                                      );
                                    }
                                    for (int i = 0;
                                        i < model.itemList!.length;
                                        i++) {
                                      final thisItem = model.itemList![i];
                                      var parameter = {
                                        //   USER_ID:
                                        //       context.read<UserProvider>().userId,
                                        PRODUCT_VARIENT_ID: thisItem.varientId,
                                        QTY: thisItem.qty,
                                      };

                                      await ApiBaseHelper()
                                          .postAPICall(manageCartApi, parameter)
                                          .then(
                                        (getdata) {
                                          bool error = getdata['error'];
                                          String? msg = getdata['message'];

                                          if (msg ==
                                              'Only single seller items are allow in cart. You can remove privious item(s) and add this item.'
                                                  .translate(
                                                      context: context)) {}
                                          if (!error) {
                                            var data = getdata['data'];
                                            context
                                                .read<UserProvider>()
                                                .setCartCount(
                                                    data['cart_count']);
                                            var cart = getdata['cart'];
                                            if (cart is List) {
                                              List<SectionModel> cartList = [];
                                              cartList = cart
                                                  .map((cart) =>
                                                      SectionModel.fromCart(
                                                          cart))
                                                  .toList();
                                              context
                                                  .read<CartProvider>()
                                                  .setCartlist(cartList);
                                            }

                                            context
                                                .read<CartProvider>()
                                                .totalPrice = 0;
                                            context
                                                .read<CartProvider>()
                                                .taxPer = 0;
                                            context
                                                .read<CartProvider>()
                                                .deliveryCharge = 0;
                                            context
                                                .read<CartProvider>()
                                                .addressList
                                                .clear();
                                            context
                                                .read<CartProvider>()
                                                .promoAmt = 0;
                                            context
                                                .read<CartProvider>()
                                                .remWalBal = 0;
                                            context
                                                .read<CartProvider>()
                                                .usedBalance = 0;
                                            context
                                                .read<CartProvider>()
                                                .payMethod = null;
                                            context
                                                .read<CartProvider>()
                                                .isPromoValid = false;
                                            context
                                                .read<CartProvider>()
                                                .isPromoLen = false;
                                            context
                                                .read<CartProvider>()
                                                .isUseWallet = false;
                                            context
                                                .read<CartProvider>()
                                                .isPayLayShow = true;
                                            context
                                                .read<CartProvider>()
                                                .selectedMethod = null;
                                            context
                                                .read<CartProvider>()
                                                .selectedTime = null;
                                            context
                                                .read<CartProvider>()
                                                .selectedDate = null;
                                            context
                                                .read<CartProvider>()
                                                .selAddress = '';
                                            context
                                                .read<CartProvider>()
                                                .selTime = '';
                                            context
                                                .read<CartProvider>()
                                                .selDate = '';
                                            context
                                                .read<CartProvider>()
                                                .promocode = '';

                                            navigateToCartScreen = true;
                                          } else {
                                            if (msg !=
                                                'Only single seller items are allow in cart.You can remove privious item(s) and add this item.'
                                                    .translate(
                                                        context: context)) {
                                              setSnackbar(msg!, context);
                                            }
                                          }
                                          if (context.mounted) {
                                            setState(
                                              () {
                                                context
                                                    .read<CartProvider>()
                                                    .setProgress(false);
                                              },
                                            );
                                          }

                                          if (msg == 'Cart Updated !') {
                                            showSuccessMessage = true;
                                          }
                                        },
                                        onError: (error) {
                                          setSnackbar(
                                              error.toString(), context);
                                        },
                                      );
                                    }
                                  } on TimeoutException catch (_) {
                                    setSnackbar(
                                        'somethingMSg'
                                            .translate(context: context),
                                        context);
                                    if (context.mounted) {
                                      setState(
                                        () {
                                          context
                                              .read<CartProvider>()
                                              .setProgress(false);
                                        },
                                      );
                                    }
                                  }
                                }
                              }
                            } catch (_) {}
                            setState(
                              () {
                                loading = false;
                              },
                            );
                            if (navigateToCartScreen) {
                              Routes.navigateToCartScreen(context, false);
                            }
                            if (showSuccessMessage) {
                              setSnackbar(
                                  'RE_ORDER_SUCCESSFULLY'
                                      .translate(context: context),
                                  context);
                            }
                          }
                        }),
                  ),
                  model.itemList![0].productType != 'digital_product'
                      ? shippingDetails(
                          context,
                          model,
                        )
                      : const SizedBox(),
                  priceDetails(
                    context,
                    model,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
          //reorder processing
          if (loading)
            Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      );
    });
  }
}
