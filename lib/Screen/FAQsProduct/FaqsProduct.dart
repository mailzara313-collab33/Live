import 'dart:async';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Faqs_Model.dart';
import '../../Model/User.dart';
import '../../Provider/CartProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';

import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/commandWidgetFaQ.dart';

class FaqsProduct extends StatefulWidget {
  final String? id;

  const FaqsProduct(this.id, {super.key});

  @override
  State<StatefulWidget> createState() {
    return StateFaqsProduct();
  }
}

class StateFaqsProduct extends State<FaqsProduct>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  List<User> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final edtFaqs = TextEditingController();
  final GlobalKey<FormState> faqsKey = GlobalKey<FormState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final TextEditingController _controller1 = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool notificationisnodata = false;
  String query = '', lastsearch = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    context.read<ProductDetailProvider>().faqsOffset = 0;
    controller = ScrollController(keepScrollOffset: true);
    controller.addListener(_scrollListener);
    _controller1.addListener(
      () {
        // Cancel previous timer
        _debounceTimer?.cancel();

        if (_controller1.text.isEmpty) {
          setState(
            () {
              query = '';
            },
          );
          // Reset and reload when search is cleared
          context.read<ProductDetailProvider>().faqsOffset = 0;
          notificationisnodata = false;
          _isLoading = true;
          isLoadingmore = true;
          getFaqs();
        } else {
          setState(() {
            query = _controller1.text;
          });

          // Debounce the search to avoid multiple API calls
          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted && lastsearch != query) {
              lastsearch = query;
              context.read<ProductDetailProvider>().faqsOffset = 0;
              notificationisnodata = false;
              isLoadingmore = true;
              _isLoading = true;
              getFaqs();
            }
          });
        }
        ScaffoldMessenger.of(context).clearSnackBars();
      },
    );

    getFaqs();
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

  @override
  void dispose() {
    buttonController!.dispose();
    edtFaqs.dispose();
    _controller1.dispose();
    _debounceTimer?.cancel();
    controller.removeListener(
      () {},
    );
    super.dispose();
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      setState(
        () {
          isLoadingmore = true;
          if (context.read<ProductDetailProvider>().faqsOffset <
              context.read<ProductDetailProvider>().faqsTotal) {
            getFaqs();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(
        'Questions and Answers'.translate(context: context),
        context,
        update,
      ),
      bottomNavigationBar: BorromBtnWidget(id: widget.id, update: update),
      body: isNetworkAvail
          ? Stack(
              children: <Widget>[
                _showForm(),
                Selector<CartProvider, bool>(
                  builder: (context, data, child) {
                    return DesignConfiguration.showCircularProgress(
                        data, colors.primary);
                  },
                  selector: (_, provider) => provider.isProgress,
                ),
              ],
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => super.widget));
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  Widget _showForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(circularBorderRadius25)),
            height: 44,
            child: TextField(
              controller: _controller1,
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
                  colorFilter:
                      const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                ),
                suffixIcon: _controller1.text != ''
                    ? IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _debounceTimer?.cancel();
                          setState(() {
                            _controller1.text = '';
                            query = '';
                            lastsearch = '';
                          });
                          // Reset and reload when search is cleared
                          context.read<ProductDetailProvider>().faqsOffset = 0;
                          notificationisnodata = false;
                          _isLoading = true;
                          isLoadingmore = true;
                          getFaqs();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: colors.primary,
                        ),
                      )
                    : const SizedBox(),
                hintText: 'Have a question? Search for answers'
                    .translate(context: context),
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
        ),
        Expanded(
          child: _faqs(),
        ),
      ],
    );
  }

  void update() {
    setState(
      () {},
    );
  }

  Widget _faqs() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: colors.primary,
            ),
          )
        : notificationisnodata
            ? Center(
                child: DesignConfiguration.getNoItem(context),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                controller: controller,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: (context.read<ProductDetailProvider>().faqsOffset <
                        context.read<ProductDetailProvider>().faqsTotal)
                    ? context
                            .read<ProductDetailProvider>()
                            .faqsProductList
                            .length +
                        1
                    : context
                        .read<ProductDetailProvider>()
                        .faqsProductList
                        .length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index ==
                          context
                              .read<ProductDetailProvider>()
                              .faqsProductList
                              .length &&
                      isLoadingmore) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: colors.primary,
                      ),
                    );
                  } else {
                    if (index <
                        context
                            .read<ProductDetailProvider>()
                            .faqsProductList
                            .length) {
                      return Padding(
                        padding: const EdgeInsets.all(7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q: ${context.read<ProductDetailProvider>().faqsProductList[index].question!}',
                              style: TextStyle(
                                fontFamily: 'ubuntu',
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.fontColor,
                                fontSize: textFontSize12,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'A: ${context.read<ProductDetailProvider>().faqsProductList[index].answer!}',
                                style: TextStyle(
                                  fontFamily: 'ubuntu',
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontSize: textFontSize11,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                context
                                    .read<ProductDetailProvider>()
                                    .faqsProductList[index]
                                    .uname!,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack2,
                                  fontSize: textFontSize11,
                                  fontFamily: 'ubuntu',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack
                                        .withValues(alpha: 0.8),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 3.0),
                                    child: Text(
                                      context
                                          .read<ProductDetailProvider>()
                                          .faqsProductList[index]
                                          .ansBy!,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack
                                            .withValues(alpha: 0.5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'ubuntu',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              );
  }

  Future<void> getFaqs() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (isLoadingmore) {
          if (mounted) {
            setState(
              () {
                isLoadingmore = false;
                if (context.read<ProductDetailProvider>().faqsOffset == 0) {
                  _isLoading = true;
                }
              },
            );
          }
          var parameter = {
            PRODUCT_ID: widget.id,
            LIMIT: perPage.toString(),
            OFFSET: context.read<ProductDetailProvider>().faqsOffset.toString(),
            SEARCH: query,
          };
          apiBaseHelper.postAPICall(getProductFaqsApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];

              _isLoading = false;
              if (context.read<ProductDetailProvider>().faqsOffset == 0) {
                notificationisnodata = error;
              }
              if (!error) {
                context.read<ProductDetailProvider>().faqsTotal =
                    int.parse(getdata['total'].toString());

                if (context.read<ProductDetailProvider>().faqsOffset <
                    context.read<ProductDetailProvider>().faqsTotal) {
                  var data = getdata['data'];

                  if (context.read<ProductDetailProvider>().faqsOffset == 0) {
                    context.read<ProductDetailProvider>().faqsProductList = [];
                  }
                  List<FaqsModel> tempList = (data as List)
                      .map((data) => FaqsModel.fromJson(data))
                      .toList();
                  context
                      .read<ProductDetailProvider>()
                      .faqsProductList
                      .addAll(tempList);
                  isLoadingmore = true;
                  context.read<ProductDetailProvider>().faqsOffset =
                      context.read<ProductDetailProvider>().faqsOffset +
                          perPage;
                } else {
                  if (msg != 'FAQs does not exist') {
                    notificationisnodata = true;
                  }
                  isLoadingmore = false;
                }
              } else {
                if (msg != 'FAQs does not exist') {
                  notificationisnodata = true;
                }
                isLoadingmore = false;
                if (mounted) setState(() {});
              }

              if (mounted) {
                setState(
                  () {
                    _isLoading = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        }
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), context);
        if (mounted) {
          setState(
            () {
              isLoadingmore = false;
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }
}
