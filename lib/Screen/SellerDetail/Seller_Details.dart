import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/widgets/GridViewProduct.dart';
import 'package:eshop_multivendor/widgets/ListViewProdusct.dart';
import 'package:eshop_multivendor/widgets/simmerEffect.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../Helper/String.dart';
import '../../Provider/productListProvider.dart';
import '../../Provider/sellerDetailProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';

import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/sellerProfileWidget.dart';

class SellerProfile extends StatefulWidget {
  final String? sellerID,
      sellerName,
      sellerImage,
      sellerRating,
      totalProductsOfSeller,
      storeDesc,
      sellerStoreName,
      noOfRatings;

  const SellerProfile({
    super.key,
    this.sellerID,
    this.sellerName,
    this.sellerImage,
    this.sellerRating,
    this.noOfRatings,
    required this.totalProductsOfSeller,
    this.storeDesc,
    this.sellerStoreName,
  });

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

List<String>? attributeNameList,
    attributeSubList,
    attributeIDList,
    selectedId = [];
RangeValues? currentRangeValues;
ScrollController? productsController;

class _SellerProfileState extends State<SellerProfile>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pos = 0, total = 0;
  final bool _isProgress = false;
  bool filterApply = false;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  String query = '';
  int notificationoffset = 0;
  int _selectedValue = 0;

  SpeechListenOptions options = SpeechListenOptions(
    cancelOnError: true, // New way to set cancelOnError
    partialResults: true,
    listenMode: ListenMode.dictation,
  );

  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false,
      _loagindmoredata = false;
  late AnimationController _animationController;
  Timer? _debounce;
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastStatus = '';
  String _currentLocaleId = '';
  String lastWords = '';
  final SpeechToText speech = SpeechToText();
  late StateSetter setStater;
  ChoiceChip? tagChip;
  FocusNode searchFocusNode = FocusNode();
  int totalSellerCount = 0;
  late AnimationController listViewIconController;
  var filterList;
  String minPrice = '0', maxPrice = '0';

  bool initializingFilterDialogFirstTime = true;
  ChoiceChip? choiceChip;
  String selId = '';
  String sortBy = 'p.date_added', orderBy = 'DESC';
  final List<Map<String, dynamic>> sortOptions = [
    {
      'value': 1,
      'label': 'TOP_RATED',
      'sortBy': '',
      'orderBy': 'DESC',
      'returnValue': 'option 1',
      'productArg': '1',
    },
    {
      'value': 2,
      'label': 'F_NEWEST',
      'sortBy': 'p.date_added',
      'orderBy': 'DESC',
      'returnValue': 'option 1',
      'productArg': '0',
    },
    {
      'value': 3,
      'label': 'F_OLDEST',
      'sortBy': 'p.date_added',
      'orderBy': 'ASC',
      'returnValue': 'option 2',
      'productArg': '0',
    },
    {
      'value': 4,
      'label': 'F_LOW',
      'sortBy': 'pv.special_price',
      'orderBy': 'ASC',
      'returnValue': 'option 3',
      'productArg': '0',
    },
    {
      'value': 5,
      'label': 'F_HIGH',
      'sortBy': 'pv.special_price',
      'orderBy': 'DESC',
      'returnValue': 'option 4',
      'productArg': '0',
    },
  ];

  void setStateNow() {
    setState(() {});
  }

  void setStateListViewLayOut(
      int index, bool selected, int i, StateSetter setState) {
    attributeIDList = filterList[index]['attribute_values_id'].split(',');

    if (mounted) {
      if (selected == true) {
        setState(() {
          selectedId!.add(attributeIDList![i]);
        });
      } else {
        setState(() {
          selectedId!.remove(attributeIDList![i]);
        });
      }
      //});
    }
    setState(() {});
  }

  @override
  void initState() {
    listViewIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerDetailProvider>().setOffsetvalue(0);
      notificationoffset = 0;
      context.read<SellerDetailProvider>().productList.clear();
      productsController = ScrollController(keepScrollOffset: true);
      productsController!.addListener(_productsListScrollListener);

      _controller.addListener(
        () {
          if (_controller.text.isEmpty) {
            if (mounted) {
              setState(
                () {
                  query = '';
                  notificationoffset = 0;
                  notificationisloadmore = true;
                },
              );
            }
            getProduct('0');
          } else {
            query = _controller.text;
            notificationoffset = 0;
            notificationisnodata = false;
            if (query.trim().isNotEmpty) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 500),
                () {
                  if (query.trim().isNotEmpty) {
                    notificationisloadmore = true;
                    notificationoffset = 0;
                    getProduct('0');
                  }
                },
              );
            }
          }
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      );
      getProduct('0');
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

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

  void _productsListScrollListener() {
    if (productsController!.offset >=
            productsController!.position.maxScrollExtent &&
        !productsController!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            getProduct('0');
          },
        );
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    productsController!.dispose();
    _controller.dispose();
    listViewIconController.dispose();
    searchFocusNode.dispose();

    _animationController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
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
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (BuildContext context) => super.widget),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.white,
        appBar: getAppBar(
            'SELLER_DETAILS'.translate(context: context), context, setStateNow),
        body: isNetworkAvail
            ? Column(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            circularBorderRadius10,
                          ),
                        ),
                        height: 44,
                        child: TextField(
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.normal,
                          ),
                          controller: _controller,
                          autofocus: false,
                          focusNode: searchFocusNode,
                          enabled: true,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.lightWhite),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(circularBorderRadius10),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                Radius.circular(circularBorderRadius10),
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                Radius.circular(circularBorderRadius10),
                              ),
                            ),
                            fillColor: Theme.of(context).colorScheme.lightWhite,
                            filled: true,
                            isDense: true,
                            hintText: 'searchHint'.translate(context: context),
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontSize: textFontSize12,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                            prefixIcon: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Icon(Icons.search)),
                            suffixIcon: _controller.text != ''
                                ? IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();

                                      setState(() {
                                        _controller.text = '';
                                        notificationoffset = 0;
                                        notificationisloadmore = true;
                                      });
                                      getProduct('0');
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                    ),
                                  )
                                : GestureDetector(
                                    child: Selector<ThemeNotifier, ThemeMode>(
                                        selector: (_, themeProvider) =>
                                            themeProvider.getThemeMode(),
                                        builder: (context, data, child) {
                                          return Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: (data == ThemeMode.system &&
                                                        MediaQuery.of(context)
                                                                .platformBrightness ==
                                                            Brightness.light) ||
                                                    data == ThemeMode.light
                                                ? SvgPicture.asset(
                                                    DesignConfiguration
                                                        .setSvgPath(
                                                            Assets.voiceSearch),
                                                    height: 15,
                                                    width: 15,
                                                  )
                                                : SvgPicture.asset(
                                                    DesignConfiguration
                                                        .setSvgPath(Assets
                                                            .voiceSearchWhite),
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                          );
                                        }),
                                    onTap: () {
                                      lastWords = '';
                                      if (!_hasSpeech) {
                                        initSpeechState();
                                      } else {
                                        showSpeechDialog();
                                      }
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GetSellerProfile(
                    sellerImage: widget.sellerImage!,
                    sellerStoreName: widget.sellerStoreName!,
                    sellerRating: widget.sellerRating,
                    noOfRatings: widget.noOfRatings,
                    storeDesc: widget.storeDesc,
                    totalProductsOfSeller: notificationisnodata
                        ? '0'
                        : context.read<SellerDetailProvider>().getTotalProducts,
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        _showContentOfProducts(),
                        Center(
                          child: DesignConfiguration.showCircularProgress(
                            _isProgress,
                            colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : NoInterNet(
                setStateNoInternate: setStateNoInternate,
                buttonSqueezeanimation: buttonSqueezeanimation,
                buttonController: buttonController),
        bottomNavigationBar:
            context.read<SellerDetailProvider>().productList.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .black
                              .withValues(alpha: 0.3),
                          blurRadius: 10,
                          // offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: sortAndFilterOption())
                : null);
  }

  void getAvailVarient(List<Product> tempList) {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == '2') {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == '1') {
            tempList[j].selVarient = i;

            break;
          }
        }
      }
    }
    if (notificationoffset == 0) {
      context.read<SellerDetailProvider>().productList = [];
    }
    context.read<SellerDetailProvider>().productList.addAll(tempList);
    notificationisloadmore = true;
    notificationoffset = notificationoffset + perPage;
  }

  Future getProduct(String? showTopRated) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (notificationisloadmore) {
        if (mounted) {
          setState(
            () {
              notificationisloadmore = false;
              _loagindmoredata = true;
              // notificationisgettingdata = true;
            },
          );
        }
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: notificationoffset.toString(),
          SORT: sortBy,
          ORDER: orderBy,
          TOP_RETAED: showTopRated,
          SELLER_ID: widget.sellerID
        };

        if (selId != '') {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }

        if (query.trim() != '') {
          parameter[SEARCH] = query.trim();
        }

        if (currentRangeValues != null &&
            currentRangeValues!.start.round().toString() != '0') {
          parameter[MINPRICE] = currentRangeValues!.start.round().toString();
        }

        if (currentRangeValues != null &&
            currentRangeValues!.end.round().toString() != '0') {
          parameter[MAXPRICE] = currentRangeValues!.end.round().toString();
        }

        // if (context.read<UserProvider>().userId != '') {
        // parameter[USER_ID] = context.read<UserProvider>().userId!;
        // }
        context.read<ProductListProvider>().setProductListParameter(parameter);

        Future.delayed(Duration.zero).then(
          (value) => context.read<ProductListProvider>().getProductList().then(
            (
              value,
            ) async {
              bool error = value['error'];
              String msg = value['message'];
              String? search = value['search'];
              context.read<SellerDetailProvider>().setProductTotal(
                  value['total'] ??
                      context.read<SellerDetailProvider>().totalProducts);
              notificationisgettingdata = false;
              _loagindmoredata = false;
              if (notificationoffset == 0) notificationisnodata = error;

              if (!error && search!.trim() == query.trim()) {
                if (mounted) {
                  if (initializingFilterDialogFirstTime) {
                    filterList = value['filters'];

                    minPrice = value[MINPRICE].toString();
                    maxPrice = value[MAXPRICE].toString();
                    currentRangeValues = RangeValues(
                        double.parse(minPrice), double.parse(maxPrice));
                    initializingFilterDialogFirstTime = false;
                  }

                  Future.delayed(
                    Duration.zero,
                    () => setState(
                      () {
                        List mainlist = value['data'];
                        if (mainlist.isNotEmpty) {
                          List<Product> items = [];
                          List<Product> allitems = [];

                          items.addAll(mainlist
                              .map((data) => Product.fromJson(data))
                              .toList());

                          allitems.addAll(items);

                          getAvailVarient(allitems);
                        } else {
                          notificationisloadmore = false;
                        }
                      },
                    ),
                  );
                }
              } else {
                notificationisloadmore = false;

                if (msg != 'Products Not Found !') {
                  notificationisnodata = true;
                }

                if (mounted) setState(() {});
              }
            },
          ),
        );
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

  void clearAll() {
    setState(
      () {
        query = _controller.text;
        notificationoffset = 0;
        notificationisloadmore = true;
        context.read<SellerDetailProvider>().productList.clear();
      },
    );
  }

  Widget _showContentOfProducts() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.lightWhite,
            child: notificationisnodata
                ? DesignConfiguration.getNoItem(context)
                : Stack(
                    children: [
                      context.watch<SellerDetailProvider>().getCurrentView !=
                              'GridView'
                          ? NotificationListener<
                              OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowIndicator();
                                return true;
                              },
                              child: ListView.builder(
                                controller: productsController,
                                shrinkWrap: true,
                                itemCount: context
                                    .read<SellerDetailProvider>()
                                    .productList
                                    .length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return (index ==
                                              context
                                                  .read<SellerDetailProvider>()
                                                  .productList
                                                  .length &&
                                          _isProgress)
                                      ? const SingleItemSimmer()
                                      : ListIteamListWidget(
                                          index: index,
                                          productList: context
                                              .read<SellerDetailProvider>()
                                              .productList,
                                          length: context
                                              .read<SellerDetailProvider>()
                                              .productList
                                              .length,
                                          setState: setStateNow,
                                        );
                                },
                              ),
                            )
                          //  ListViewLayOut(
                          //     update: setStateNow,
                          //   )
                          : getGridviewLayoutOfProducts(),
                      notificationisgettingdata
                          ? context
                                      .watch<SellerDetailProvider>()
                                      .getCurrentView !=
                                  'GridView'
                              ? ShimmerEffect()
                              : ShimmerEffectGrid()
                          : _loagindmoredata
                              ? Center(
                                  child: const CircularProgressIndicator(
                                    color: colors.primary,
                                  ),
                                )
                              : SizedBox(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }

  void errorListener(SpeechRecognitionError error) {}

  void statusListener(String status) {
    setStater(() {
      lastStatus = status;
    });
  }

  void startListening() {
    lastWords = '';
    speech.listen(
      onResult: resultListener,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      // partialResults: true,
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
      // cancelOnError: true,
      // listenMode: ListenMode.confirmation
    );
    setStater(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setStater(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      query = lastWords;
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then(
        (_) async {
          clearAll();

          _controller.text = lastWords;
          _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length));

          setState(() {});
          Navigator.of(context).pop();
        },
      );
    }
  }

  Widget showSpeechDialog() {
    return DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater1) {
          setStater = setStater1;
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.lightWhite,
            title: Text(
              'SEarchHint'.translate(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize16,
                fontFamily: 'ubuntu',
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: .26,
                          spreadRadius: level * 1.5,
                          color: Theme.of(context)
                              .colorScheme
                              .black
                              .withValues(alpha: .05))
                    ],
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius50)),
                  ),
                  child: IconButton(
                      icon: const Icon(
                        Icons.mic,
                        color: colors.primary,
                      ),
                      onPressed: () {
                        if (!_hasSpeech) {
                          initSpeechState();
                        } else {
                          !_hasSpeech || speech.isListening
                              ? null
                              : startListening();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    lastWords,
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: Theme.of(context)
                      .colorScheme
                      .fontColor
                      .withValues(alpha: 0.1),
                  child: Center(
                    child: speech.isListening
                        ? Text(
                            "I'm listening...".translate(context: context),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ubuntu',
                                ),
                          )
                        : Text(
                            'Not listening'.translate(context: context),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ubuntu',
                                ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(circularBorderRadius25),
          topRight: Radius.circular(circularBorderRadius25),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: Platform.isIOS
                    ? EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20)
                    : EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          top: 19.0, start: 16, end: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SORT_BY'.translate(context: context),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontSize: textFontSize18,
                              fontFamily: 'ubuntu',
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor
                                    .withValues(alpha: 0.6),
                              ))
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 0.9,
                    ),
                    RadioGroup<int>(
                      groupValue: _selectedValue,
                      onChanged: (val) {
                        setState(() => _selectedValue = val!);

                        final option =
                            sortOptions.firstWhere((o) => o['value'] == val);

                        sortBy = option['sortBy'];
                        orderBy = option['orderBy'];

                        if (mounted) {
                          notificationoffset = 0;
                          notificationisloadmore = true;
                          context
                              .read<SellerDetailProvider>()
                              .productList
                              .clear();
                        }

                        getProduct(option['productArg']);
                        Navigator.pop(context, option['returnValue']);
                      },
                      child: Column(
                        children: sortOptions.map((option) {
                          final int value = option['value'];
                          return RadioListTile<int>(
                            value: value,
                            title: Text(
                              option['label']
                                  .toString()
                                  .translate(context: context),
                              style: TextStyle(
                                color: _selectedValue == value
                                    ? Theme.of(context).colorScheme.fontColor
                                    : Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withValues(alpha: 0.6),
                                fontSize: textFontSize16,
                                fontFamily: 'ubuntu',
                              ),
                            ),
                            activeColor: Theme.of(context).colorScheme.primary,
                            controlAffinity: ListTileControlAffinity.trailing,
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget sortAndFilterOption() {
    return Container(
        color: Theme.of(context).colorScheme.white,
        height: Platform.isIOS ? 65 : 45,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  if (context
                          .read<SellerDetailProvider>()
                          .productList
                          .isNotEmpty &&
                      context.read<SellerDetailProvider>().view == 'GridView') {
                    context
                        .read<SellerDetailProvider>()
                        .changeViewTo('ListView');
                  } else if (context
                          .read<SellerDetailProvider>()
                          .productList
                          .isNotEmpty &&
                      context.read<SellerDetailProvider>().view == 'ListView') {
                    context
                        .read<SellerDetailProvider>()
                        .changeViewTo('GridView');
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SvgPicture.asset(
                      DesignConfiguration.setSvgPath(Assets.listview),
                      colorFilter: context.read<SellerDetailProvider>().view ==
                              'ListView'
                          ? ColorFilter.mode(
                              Theme.of(context).colorScheme.black,
                              BlendMode.srcIn)
                          : ColorFilter.mode(
                              Theme.of(context)
                                  .colorScheme
                                  .black
                                  .withValues(alpha: 0.5),
                              BlendMode.srcIn),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(
                      DesignConfiguration.setSvgPath(Assets.gridview),
                      colorFilter: context.read<SellerDetailProvider>().view ==
                              'GridView'
                          ? ColorFilter.mode(
                              Theme.of(context).colorScheme.black,
                              BlendMode.srcIn)
                          : ColorFilter.mode(
                              Theme.of(context)
                                  .colorScheme
                                  .black
                                  .withValues(alpha: 0.5),
                              BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: VerticalDivider(
                  color: Theme.of(context).colorScheme.gray,
                  thickness: 2,
                ),
              ),
              GestureDetector(
                onTap: sortDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                        DesignConfiguration.setSvgPath(Assets.sortby),
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.black,
                            BlendMode.srcIn)),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'SORT_BY'.translate(context: context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: textFontSize12,
                        fontFamily: 'ubuntu',
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: VerticalDivider(
                  color: Theme.of(context).colorScheme.gray,
                  thickness: 2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (filterList!.isNotEmpty) {
                    filterDialog();
                  } else {
                    setSnackbar(
                        'NO_FILTER'.translate(context: context), context);
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                        DesignConfiguration.setSvgPath(Assets.filter),
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.black,
                            BlendMode.srcIn)),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'FILTER'.translate(context: context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: textFontSize12,
                        fontFamily: 'ubuntu',
                      ),
                      textAlign: TextAlign.start,
                    ),
                    filterApply
                        ? Icon(
                            Icons.brightness_1,
                            color: colors.primary,
                            size: 5,
                          )
                        : SizedBox()
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(circularBorderRadius10),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 30.0),
                  child: AppBar(
                    title: Text(
                      'FILTER'.translate(context: context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                    centerTitle: true,
                    elevation: 5,
                    backgroundColor: Theme.of(context).colorScheme.white,
                    leading: Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(circularBorderRadius4),
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 4.0),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Theme.of(context).colorScheme.fontColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.lightWhite,
                    padding: const EdgeInsetsDirectional.only(
                        start: 7.0, end: 7.0, top: 7.0),
                    child: filterList != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding:
                                const EdgeInsetsDirectional.only(top: 10.0),
                            itemCount: filterList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    if (currentRangeValues != null)
                                      SizedBox(
                                        width: deviceWidth,
                                        child: Card(
                                          elevation: 0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "${'Price Range'.translate(context: context)} ($CUR_CURRENCY${currentRangeValues!.start.round().toString()} - $CUR_CURRENCY${currentRangeValues!.end.round().toString()})",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontFamily: 'ubuntu',
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (currentRangeValues != null)
                                      RangeSlider(
                                        values: currentRangeValues!,
                                        min: double.parse(minPrice),
                                        max: double.parse(maxPrice),
                                        onChanged: (RangeValues values) {
                                          currentRangeValues = values;
                                          setStater(() {});
                                          //setStateNow();
                                        },
                                      ),
                                  ],
                                );
                              } else {
                                index = index - 1;
                                attributeSubList = filterList[index]
                                        ['attribute_values']
                                    .split(',');

                                attributeIDList = filterList[index]
                                        ['attribute_values_id']
                                    .split(',');

                                List<Widget?> chips = [];
                                List<String> att = filterList[index]
                                        ['attribute_values']!
                                    .split(',');

                                List<String> attSType = filterList[index]
                                        ['swatche_type']
                                    .split(',');

                                List<String> attSValue = filterList[index]
                                        ['swatche_value']
                                    .split(',');

                                for (int i = 0; i < att.length; i++) {
                                  Widget itemLabel;
                                  if (attSType[i] == '1') {
                                    String clr = (attSValue[i].substring(1));

                                    String color = '0xff$clr';

                                    itemLabel = Container(
                                      width: 25,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(int.parse(color))),
                                    );
                                  } else if (attSType[i] == '2') {
                                    itemLabel = ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            circularBorderRadius10),
                                        child: Image.network(attSValue[i],
                                            width: 80,
                                            height: 80,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                DesignConfiguration.erroWidget(
                                                    80)));
                                  } else {
                                    itemLabel = Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        att[i],
                                        style: TextStyle(
                                          color: selectedId!
                                                  .contains(attributeIDList![i])
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                          fontFamily: 'ubuntu',
                                        ),
                                      ),
                                    );
                                  }

                                  choiceChip = ChoiceChip(
                                    selected: selectedId!
                                        .contains(attributeIDList![i]),
                                    label: itemLabel,
                                    labelPadding: const EdgeInsets.all(0),
                                    selectedColor: colors.primary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          attSType[i] == '1'
                                              ? circularBorderRadius100
                                              : circularBorderRadius10),
                                      side: BorderSide(
                                          color: selectedId!
                                                  .contains(attributeIDList![i])
                                              ? colors.primary
                                              : colors.secondary,
                                          width: 1.5),
                                    ),
                                    onSelected: (bool selected) {
                                      setStateListViewLayOut(
                                          index, selected, i, setStater);
                                    },
                                  );

                                  chips.add(choiceChip);
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: deviceWidth,
                                      child: Card(
                                        elevation: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            filterList[index]['name'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: 'ubuntu',
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    chips.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Wrap(
                                              children: chips.map<Widget>(
                                                (Widget? chip) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: chip,
                                                  );
                                                },
                                              ).toList(),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                );
                              }
                            },
                          )
                        : const SizedBox(),
                  ),
                ),
                Container(
                  padding: Platform.isIOS
                      ? const EdgeInsetsDirectional.symmetric(
                          horizontal: 0, vertical: 10)
                      : const EdgeInsetsDirectional.symmetric(
                          horizontal: 0,
                        ),
                  color: Theme.of(context).colorScheme.white,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 20),
                        width: deviceWidth! * 0.4,
                        child: OutlinedButton(
                          onPressed: () {
                            selectedId!.clear();
                            currentRangeValues = RangeValues(
                                double.parse(minPrice), double.parse(maxPrice));
                            setState(() {});
                            setStater(() {});
                            if (mounted) {}
                          },
                          child: Text(
                            'DISCARD'.translate(context: context),
                            style: const TextStyle(
                              fontFamily: 'ubuntu',
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SimBtn(
                        borderRadius: circularBorderRadius5,
                        size: 0.4,
                        title: 'APPLY'.translate(context: context),
                        onBtnSelected: () {
                          if (selectedId != null) {
                            selId = selectedId!.join(',');
                          }
                          if (mounted) {
                            setState(
                              () {
                                filterApply = true;
                                notificationoffset = 0;
                                context
                                    .read<SellerDetailProvider>()
                                    .productList
                                    .clear();
                                notificationisloadmore = true;
                              },
                            );
                          }
                          getProduct('0');
                          Navigator.pop(context, 'Product Filter');
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget getGridviewLayoutOfProducts() {
    return GridView.count(
      controller: productsController,
      padding: const EdgeInsetsDirectional.only(top: 10, start: 10),
      crossAxisCount: 2,
      childAspectRatio: 0.62,
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(
        context.read<SellerDetailProvider>().productList.length,
        (index) {
          return GridViewProductListWidget(
            pad: false,
            index: index,
            productList: context.read<SellerDetailProvider>().productList,
            setState: setStateNow,
          );
        },
      ),
    );
  }
}
