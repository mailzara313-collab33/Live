import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/explore_provider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/SectionList.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/hideAppBarBottom.dart';
import 'package:eshop_multivendor/widgets/GridViewProduct.dart';
import 'package:eshop_multivendor/widgets/ListViewProdusct.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/productListProvider.dart';
import '../../Provider/sellerDetailProvider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';

import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widgte/sellerContentWidget.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _SearchState();
}

ScrollController? sellerListController;
ScrollController? productsController;

class _SearchState extends State<Explore> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pos = 0;
  final bool _isProgress = false;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  String query = '';
  int notificationoffset = 0;
  bool notificationisloadmore = true,
      notificationisgettingdata = true,
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
  late UserProvider userProvider;
  late TabController _tabController;
  late AnimationController listViewIconController;
  var filterList;
  String minPrice = '0', maxPrice = '0';
  List<String>? attributeNameList,
      attributeSubList,
      attributeIDList,
      selectedId = [];
  bool initializingFilterDialogFirstTime = true;
  int setTab = 0;
  RangeValues? currentRangeValues;
  ChoiceChip? choiceChip;
  int _selectedValue = 0;
  final List<Map<String, dynamic>> sortOptions = [
    {
      'value': 1,
      'label': 'TOP_RATED',
      'sortBy': '',
      'orderBy': 'DESC',
      'returnValue': 'option 1',
    },
    {
      'value': 2,
      'label': 'F_NEWEST',
      'sortBy': 'p.date_added',
      'orderBy': 'DESC',
      'returnValue': 'option 1',
    },
    {
      'value': 3,
      'label': 'F_OLDEST',
      'sortBy': 'p.date_added',
      'orderBy': 'ASC',
      'returnValue': 'option 2',
    },
    {
      'value': 4,
      'label': 'F_LOW',
      'sortBy': 'pv.special_price',
      'orderBy': 'ASC',
      'returnValue': 'option 3',
    },
    {
      'value': 5,
      'label': 'F_HIGH',
      'sortBy': 'pv.special_price',
      'orderBy': 'DESC',
      'returnValue': 'option 4',
    },
  ];

  String selId = '';

  SpeechListenOptions options = SpeechListenOptions(
    cancelOnError: true, // New way to set cancelOnError
    partialResults: true,
    listenMode: ListenMode.dictation,
  );

  String sortBy = 'p.date_added', orderBy = 'DESC';

  RangeValues? currentRangeValuesTest;
  List<String>? selectedIdTest;
  // bool disCardClick = false;
  bool isLoadingMore = true;
  bool filterApply = false;

  void update() {
    isLoadingMore = true;
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerDetailProvider>().doSellerListEmpty();
      context.read<SellerDetailProvider>().setOffsetvalue(0);
      notificationoffset = 0;

      context.read<ExploreProvider>().productList = [];

      _controller.addListener(
        () {
          if (_controller.text.isEmpty) {
            if (mounted) {
              setState(
                () {
                  query = '';
                  notificationoffset = 0;
                },
              );
            }
            getProduct('0');
          } else {
            _tabController.addListener(() {
              if (_tabController.indexIsChanging) {
                FocusScope.of(context).unfocus();
                _controller.text = '';
                notificationoffset = 0;
              }
            });
            if (_tabController.index == 0) {
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
            } else {
              String search = '';
              search = _controller.text;
              context.read<SellerDetailProvider>().setOffsetvalue(0);
              context.read<HomePageProvider>().setSellerLoading(true);
              if (search.trim().isNotEmpty) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (search.trim().isNotEmpty) {
                      context.read<SellerDetailProvider>().doSellerListEmpty();
                      context.read<SellerDetailProvider>().setOffsetvalue(0);
                      context.read<HomePageProvider>().setSellerLoading(true);
                      Future.delayed(Duration.zero)
                          .then(
                        (value) =>
                            context.read<SellerDetailProvider>().getSeller(
                                  '',
                                  _controller.text.trim(),
                                ),
                      )
                          .then((value) {
                        context
                            .read<HomePageProvider>()
                            .setSellerLoading(false);
                      });
                    }
                  },
                );
              }
            }
          }
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      );
      getProduct('0');
      Future.delayed(Duration.zero).then((value) => context
              .read<SellerDetailProvider>()
              .getSeller(
                '',
                _controller.text.trim(),
              )
              .then((value) {
            context.read<HomePageProvider>().setSellerLoading(false);
          }));
    });
    listViewIconController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    productsController = ScrollController(keepScrollOffset: true);
    productsController!.addListener(_productsListScrollListener);
    sellerListController = ScrollController(keepScrollOffset: true);
    sellerListController!.addListener(_sellerListController);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _tabController = TabController(
      length: 2,
      vsync: this,
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

    Future.delayed(Duration.zero).then(
      (value) {
        hideAppbarAndBottomBarOnScroll(
          productsController!,
          context,
        );
      },
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

  void _sellerListController() {
    if (sellerListController!.offset >=
            sellerListController!.position.maxScrollExtent &&
        !sellerListController!.position.outOfRange) {
      if (mounted) {
        if (context.read<SellerDetailProvider>().sellerListOffsetValue <
            context.read<SellerDetailProvider>().totalSellerCountValue) {
          Future.delayed(Duration.zero).then(
            (value) => context
                .read<SellerDetailProvider>()
                .getSeller(
                  '',
                  _controller.text.trim(),
                )
                .then((value) {
              context.read<HomePageProvider>().setSellerLoading(false);
            }),
          );
          setState(
            () {},
          );
        }
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    productsController!.dispose();
    sellerListController!.dispose();
    _tabController.dispose();
    _controller.dispose();
    listViewIconController.dispose();

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

  Future<void> setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
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
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        key: _scaffoldKey,
        body: isNetworkAvail
            ? Column(
                children: [
                  _buildSearchBar(context),
                  _buildTabBar(context),
                  _buildTabBarView()
                ],
              )
            : NoInterNet(
                setStateNoInternate: setStateNoInternate,
                buttonSqueezeanimation: buttonSqueezeanimation,
                buttonController: buttonController,
              ),
        bottomNavigationBar: setTab == 0
            ? context.read<ExploreProvider>().productList.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .black
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.gray,
                            width: 2.0,
                          ),
                        )),
                    child: sortAndFilterOption())
                : null
            : null);
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
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
            enabled: true,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.lightWhite),
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
              contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
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
              hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontSize: textFontSize12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
              prefixIcon: const Padding(
                  padding: EdgeInsets.all(15.0), child: Icon(Icons.search)),
              suffixIcon: _controller.text != ''
                  ? IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _controller.clear();

                        notificationoffset = 0;

                        notificationisloadmore = true;
                        query = '';
                        notificationoffset = 0;
                        getProduct('0');
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          lastWords = '';
                          if (!_hasSpeech) {
                            initSpeechState();
                          } else {
                            showSpeechDialog();
                          }
                        },
                        child: Selector<ThemeNotifier, ThemeMode>(
                          selector: (_, themeProvider) =>
                              themeProvider.getThemeMode(),
                          builder: (context, data, child) {
                            return (data == ThemeMode.system &&
                                        MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light) ||
                                    data == ThemeMode.light
                                ? SvgPicture.asset(
                                    DesignConfiguration.setSvgPath(
                                        Assets.voiceSearch),
                                    height: 15,
                                    width: 15,
                                  )
                                : SvgPicture.asset(
                                    DesignConfiguration.setSvgPath(
                                        Assets.voiceSearchWhite),
                                    height: 15,
                                    width: 15,
                                  );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.white,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Text(
              'ALL_PRODUCTS'.translate(context: context),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'ubuntu',
                  ),
            ),
          ),
          if (SINGLE_SELLER_SYSTEM == false)
            Tab(
              child: Text(
                'ALL_SELLERS'.translate(context: context),
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            ),
        ],
        indicatorColor: colors.primary,
        labelColor: Theme.of(context).colorScheme.fontColor,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: Theme.of(context).colorScheme.lightBlack,
        labelStyle: const TextStyle(
          fontSize: textFontSize16,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
        ),
        onTap: (value) {
          setState(
            () {
              setTab = value;
            },
          );
        },
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Stack(
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Consumer<SellerDetailProvider>(
              builder: (context, value, child) {
                if (value.getCurrentStatus ==
                    SellerDetailProviderStatus.isSuccsess) {
                  return Stack(
                    children: <Widget>[
                      ShowContentOfSellers(
                        sellerList: value.sellerList,
                      ),
                      Center(
                        child: DesignConfiguration.showCircularProgress(
                          _isProgress,
                          colors.primary,
                        ),
                      ),
                    ],
                  );
                } else if (value.getCurrentStatus ==
                    SellerDetailProviderStatus.isFailure) {
                  return Center(
                    child: Text(
                      value.geterrormessage,
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  );
                }
                return context.watch<ExploreProvider>().getCurrentView !=
                        'GridView'
                    ? ShimmerEffect()
                    : ShimmerEffectGrid();
              },
            ),
          )
        ],
      ),
    );
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
      context.read<ExploreProvider>().productList = [];
    }

    context.read<ExploreProvider>().productList.addAll(tempList);
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

        context.read<ProductListProvider>().setProductListParameter(parameter);
        Future.delayed(Duration.zero).then(
          (value) => context.read<ProductListProvider>().getProductList().then(
            (
              value,
            ) async {
              bool error = value['error'];
              String msg = value['message'];
              String? search = value['search'];
              context.read<ExploreProvider>().setProductTotal(value['total'] ??
                  context.read<ExploreProvider>().totalProducts);
              notificationisgettingdata = false;
              _loagindmoredata = false;
              if (notificationoffset == 0) notificationisnodata = error;

              if (!error && search!.trim() == query.trim()) {
                if (mounted) {
                  if (initializingFilterDialogFirstTime) {
                    filterList = value['filters'];

                    minPrice = value[MINPRICE].toString();
                    maxPrice = value[MAXPRICE].toString();
                    if (currentRangeValues == null) {
                      if (value[MINPRICE] == null || value[MAXPRICE] == null) {
                        currentRangeValues = null;
                      } else {
                        currentRangeValues = RangeValues(
                            double.tryParse(minPrice) ?? 0,
                            double.tryParse(maxPrice) ?? 0);
                      }
                    }
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
                if (msg != 'Products Not Found !') {
                  notificationisnodata = true;
                }

                notificationisloadmore = false;

                if (mounted) setState(() {});
              }
              setState(() {
                // disCardClick = false;
              });
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
        context.read<ExploreProvider>().productList.clear();
      },
    );
  }

  Widget _showContentOfProducts() {
    print('-->$notificationisgettingdata $notificationisnodata');
    return Column(
      children: <Widget>[
        // searchResult(),
        Expanded(
          child: notificationisnodata
              ? DesignConfiguration.getNoItem(context)
              : Stack(
                  children: [
                    context.watch<ExploreProvider>().getCurrentView !=
                            'GridView'
                        ? getListviewLayoutOfProducts()
                        : getGridviewLayoutOfProducts(),
                    notificationisgettingdata
                        ? context.watch<ExploreProvider>().getCurrentView !=
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
    setStater(
      () {
        lastStatus = status;
      },
    );
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
      // cancelOnError: true,
      // listenMode: ListenMode.confirmation
      listenOptions: options,
    );
    setStater(
      () {},
    );
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(
      () {
        this.level = level;
      },
    );
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setStater(
      () {
        level = 0.0;
      },
    );
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
                fontFamily: 'ubuntu',
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize16,
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
                    },
                  ),
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
                        setState(() {
                          _selectedValue = val!;

                          final option = sortOptions
                              .firstWhere((o) => o['value'] == _selectedValue);

                          sortBy = option['sortBy'];
                          orderBy = option['orderBy'];

                          if (mounted) {
                            notificationoffset = 0;
                            notificationisloadmore = true;
                            context.read<ExploreProvider>().productList.clear();
                          }

                          getProduct(
                              option['sortBy'].toString().isEmpty ? '1' : '0');
                          Navigator.pop(context, option['returnValue']);
                        });
                      },
                      child: Column(
                        children: sortOptions.map((option) {
                          return RadioListTile<int>(
                            value: option['value'],
                            title: Text(
                              option['label']
                                  .toString()
                                  .translate(context: context),
                              style: TextStyle(
                                color: _selectedValue == option['value']
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
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  if (context.read<ExploreProvider>().productList.isNotEmpty &&
                      context.read<ExploreProvider>().view == 'GridView') {
                    context.read<ExploreProvider>().changeViewTo('ListView');
                  } else if (context
                          .read<ExploreProvider>()
                          .productList
                          .isNotEmpty &&
                      context.read<ExploreProvider>().view == 'ListView') {
                    context.read<ExploreProvider>().changeViewTo('GridView');
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SvgPicture.asset(
                      DesignConfiguration.setSvgPath(Assets.listview),
                      colorFilter:
                          context.read<ExploreProvider>().view == 'ListView'
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
                      colorFilter:
                          context.read<ExploreProvider>().view == 'GridView'
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

  void setStateNow() {
    setState(() {});
  }

  Widget searchResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Container(
        color: Theme.of(context).colorScheme.white,
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20),
                child: Text(
                  'TITLE1_LBL'.translate(context: context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: textFontSize16,
                    fontFamily: 'ubuntu',
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 20),
              child: Consumer<ExploreProvider>(
                builder: (context, data, child) {
                  return Text(
                    '${notificationisnodata ? '0' : data.getTotalProducts}: ${"Items_Found".translate(context: context)}',
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filterDialog() {
    print(
        'currentRangeValue:$currentRangeValues ******$selectedId*****$currentRangeValuesTest***$selectedIdTest');

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
                    start: 7.0,
                    end: 7.0,
                    top: 7.0,
                  ),
                  child: filterList != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsetsDirectional.only(top: 10.0),
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
                                                  fontFamily: 'ubuntu',
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // if (currentRangeValues != null)
                                  RangeSlider(
                                    values: currentRangeValues!,
                                    min: double.parse(minPrice),
                                    max: double.parse(maxPrice),
                                    onChanged: (RangeValues values) {
                                      currentRangeValues = values;
                                      setState(
                                        () {
                                          setStater(() {});
                                        },
                                      );
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

                              List<String> attSType =
                                  filterList[index]['swatche_type'].split(',');

                              List<String> attSValue =
                                  filterList[index]['swatche_value'].split(',');

                              for (int i = 0; i < att.length; i++) {
                                Widget itemLabel;
                                if (attSType[i] == '1') {
                                  String clr = (attSValue[i].substring(1));

                                  String color = '0xff$clr';

                                  itemLabel = Container(
                                    width: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(
                                        int.parse(color),
                                      ),
                                    ),
                                  );
                                } else if (attSType[i] == '2') {
                                  itemLabel = ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        circularBorderRadius10),
                                    child: Image.network(
                                      attSValue[i],
                                      width: 80,
                                      height: 80,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              DesignConfiguration.erroWidget(
                                        80,
                                      ),
                                    ),
                                  );
                                } else {
                                  itemLabel = Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      att[i],
                                      style: TextStyle(
                                        fontFamily: 'ubuntu',
                                        color: selectedId!
                                                .contains(attributeIDList![i])
                                            ? Theme.of(context)
                                                .colorScheme
                                                .white
                                            : Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                      ),
                                    ),
                                  );
                                }

                                choiceChip = ChoiceChip(
                                  selected:
                                      selectedId!.contains(attributeIDList![i]),
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
                                    attributeIDList = filterList[index]
                                            ['attribute_values_id']
                                        .split(',');

                                    if (mounted) {
                                      setState(() {
                                        setStater(
                                          () {
                                            if (selected == true) {
                                              selectedId!
                                                  .add(attributeIDList![i]);
                                            } else {
                                              selectedId!
                                                  .remove(attributeIDList![i]);
                                            }
                                          },
                                        );
                                      });
                                    }
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
                                                  fontFamily: 'ubuntu',
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight:
                                                      FontWeight.normal),
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
                                                      const EdgeInsets.all(2.0),
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
                )),
                Container(
                  padding: Platform.isIOS
                      ? EdgeInsetsDirectional.symmetric(
                          horizontal: 0, vertical: 10)
                      : EdgeInsetsDirectional.symmetric(
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
                            if (mounted) {
                              setState(() {
                                setStater(
                                  () {
                                    selectedId!.clear();
                                    currentRangeValues = RangeValues(
                                        double.parse(minPrice),
                                        double.parse(maxPrice));
                                  },
                                );
                              });
                            }
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
                          print('selectedId explore*****$selectedId');
                          if (selectedId != null) {
                            selId = selectedId!.join(',');
                          }
                          if (mounted) {
                            setStater(() {
                              setState(
                                () {
                                  filterApply = true;
                                  notificationoffset = 0;
                                  notificationisloadmore = true;
                                  context
                                      .read<ExploreProvider>()
                                      .productList
                                      .clear();
                                },
                              );
                            });
                            getProduct('0');
                            Navigator.pop(context, 'Product Filter');
                          }
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

  Widget getListviewLayoutOfProducts() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: ListView.builder(
          controller: productsController,
          shrinkWrap: true,
          itemCount: context.read<ExploreProvider>().productList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.only(top: 5),
          itemBuilder: (BuildContext context, int index) {
            return (index ==
                        context.read<ExploreProvider>().productList.length &&
                    isProgress)
                ? const SizedBox()
                : ListIteamListWidget(
                    index: index,
                    productList: context.read<ExploreProvider>().productList,
                    length: context.read<ExploreProvider>().productList.length,
                    setState: setStateNow,
                  );
          }),
    );
  }

  Widget getGridviewLayoutOfProducts() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: GridView.count(
        padding: const EdgeInsetsDirectional.only(top: 10, start: 10),
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 0.62,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: productsController,
        children: List.generate(
          context.read<ExploreProvider>().productList.length,
          (index) {
            return (index ==
                        context.read<ExploreProvider>().productList.length &&
                    isProgress)
                ? const SizedBox()
                : GridViewProductListWidget(
                    pad: false,
                    index: index,
                    productList: context.read<ExploreProvider>().productList,
                    setState: setStateNow,
                  );
          },
        ),
      ),
    );
  }
}
