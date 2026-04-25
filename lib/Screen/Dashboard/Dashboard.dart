import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Model/message.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/Profile/MyProfile.dart';
import 'package:eshop_multivendor/Screen/ExploreSection/explore.dart';
import 'package:eshop_multivendor/Screen/PushNotification/PushNotificationService.dart';
import 'package:eshop_multivendor/cubits/personalConverstationsCubit.dart';
import 'package:eshop_multivendor/repository/NotificationRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Provider/UserProvider.dart';
import '../../widgets/systemChromeSettings.dart';
import '../SQLiteData/SqliteData.dart';
import '../../Helper/routes.dart';
import '../../widgets/desing.dart';

import '../../widgets/snackbar.dart';
import '../AllCategory/All_Category.dart';
import '../Cart/Cart.dart';
import '../Cart/Widget/clearTotalCart.dart';
import '../Notification/NotificationLIst.dart';
import '../homePage/homepageNew.dart';

class Dashboard extends StatefulWidget {
  static GlobalKey<DashboardPageState> dashboardScreenKey =
      GlobalKey<DashboardPageState>();
  const Dashboard({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

var db = DatabaseHelper();

class DashboardPageState extends State<Dashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int selBottom = 0;
  late TabController _tabController;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? linkSubscription;
  late StreamSubscription streamSubscription;

  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  void changeTabPosition(int index) {
    Future.delayed(Duration.zero, () {
      _tabController.animateTo(index);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });
    WidgetsBinding.instance.addObserver(this);
    NotificationRepository.clearChatNotifications();
    initAppLinks();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    _tabController.addListener(
      () {
        Future.delayed(const Duration(microseconds: 10)).then(
          (value) {
            setState(
              () {
                selBottom = _tabController.index;
              },
            );
          },
        );
        //show bottombar on tab change by user interaction
        if (_tabController.index != 0 ||
            _tabController.index != 2 ||
            _tabController.index != 3 &&
                !context.read<HomePageProvider>().getBars) {
          context.read<HomePageProvider>().animationController.reverse();
          context.read<HomePageProvider>().showAppAndBottomBars(true);
        }
        if (_tabController.index == 3) {
          cartTotalClear(context);
        }
      },
    );

    Future.delayed(
      Duration.zero,
      () async {
        if ((context.read<SettingProvider>().userId ?? '').isNotEmpty) {
          if (kDebugMode) {
            print('Init the push notificaiton service');
          }
          PushNotificationService.context = context;
          PushNotificationService.init();
        }
        SettingProvider settingsProvider =
            Provider.of<SettingProvider>(context, listen: false);
        context
            .read<UserProvider>()
            .setUserId(await settingsProvider.getPrefrence(ID) ?? '');

        context.read<HomePageProvider>()
          ..setAnimationController(navigationContainerAnimationController)
          ..setBottomBarOffsetToAnimateController(
              navigationContainerAnimationController)
          ..setAppBarOffsetToAnimateController(
              navigationContainerAnimationController);
      },
    );
    super.initState();
  }

  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    // Handle initial app link if app was launched from a deep link
    try {
      Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        print('Initial app link url----->${initialLink}');
        handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Error getting initial app link: $e');
    }

    // Listen for incoming deep links
    linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('app link url----->${uri}');
        handleDeepLink(uri);
      }
    });
  }

  Future<void> handleDeepLink(Uri uri) async {
    print('handleDeepLink called with uri: $uri');

    String? token = uri.queryParameters['ref'];
    String? productSlug;
    if (uri.path.contains('/products/details/')) {
      productSlug = uri.pathSegments.last;
    }
    print('Extracted productSlug: $productSlug');
    // Store the token if both token and slug are present
    if (token != null &&
        token.isNotEmpty &&
        productSlug != null &&
        productSlug.isNotEmpty) {
      await DatabaseHelper()
          .storeAppLinkToken(uri.toString(), token, productSlug);
      print('Stored app link token: $token for product: $productSlug');
    }
    // Always open the product screen if the slug is present
    if (productSlug != null && productSlug.isNotEmpty) {
      print('Fetching product details for slug: $productSlug');
      final product = await getProductDetailsFromSlug(productSlug);
      print('Fetched product: $product');
      if (product != null) {
        print('Navigating to product details page for: $productSlug');
        Routes.goToProductDetailsPage(context, product: product);
      } else {
        print('Product not found for slug: $productSlug');
      }
    } else {
      if (kDebugMode) {
        print('Received deep link: $uri');
      }
    }
  }

  Future<Product?> getProductDetailsFromSlug(String slug) async {
    try {
      final getData = await apiBaseHelper.postAPICall(getProductApi, {
        'slug': slug,
        USER_ID: context.read<UserProvider>().userId,
      });
      bool error = getData['error'];
      if (!error) {
        var data = getData['data'];

        List<Product> tempList =
            (data as List).map((data) => Product.fromJson(data)).toList();

        if (tempList.isEmpty) {
          setSnackbar(
              'NO_PRODUCTS_WITH_YOUR_LINK_FOUND'.translate(context: context),
              context);
          return null;
        }
        return tempList[0] as Product?;
      } else {
        throw Exception();
      }
    } catch (_) {}
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      NotificationRepository.getChatNotifications().then((messages) {
        for (var encodedMessage in messages) {
          final message =
              Message.fromJson(Map.from(jsonDecode(encodedMessage) ?? {}));

          if (converstationScreenStateKey.currentState?.mounted ?? false) {
            final state = converstationScreenStateKey.currentState!;

            //
            if (state.widget.personalChatHistory?.getOtherUserId() !=
                message.fromId) {
              context
                  .read<PersonalConverstationsCubit>()
                  .updateUnreadMessageCounter(userId: message.fromId!);
            } else {
              state.addMessage(message: message);
            }
          } else {
            if (message.type == 'person') {
              context
                  .read<PersonalConverstationsCubit>()
                  .updateUnreadMessageCounter(
                    userId: message.fromId!,
                  );
            } else {
              // Update group message
            }
          }
        }
        //Clear the message notifications
        NotificationRepository.clearChatNotifications();
      });
    }
  }

  void setSnackBarFunctionForCartMessage() {
    Future.delayed(const Duration(seconds: 5)).then(
      (value) {
        if (homePageSingleSellerMessage) {
          homePageSingleSellerMessage = false;
          showOverlay(
              'One of the product is out of stock, We are not able To Add In Cart'
                  .translate(context: context),
              context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selBottom == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: selBottom == 0
            ? _getAppBar()
            : AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Theme.of(context).colorScheme.white),
                toolbarHeight: 0,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.white,
              ),
        body: SafeArea(
            child: Consumer<UserProvider>(builder: (context, data, child) {
          return TabBarView(
            controller: _tabController,
            children: const [
              HomePage(),
              AllCategory(),
              Explore(),
              Cart(
                fromBottom: true,
              ),
              MyProfile(),
            ],
          );
        })),
        bottomNavigationBar: _getBottomBar(),
      ),
    );
  }

  PreferredSize _getAppBar() {
    final appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.white),
      elevation: 0,
      toolbarHeight: 60,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom:
              Radius.circular(20), // Radius for bottom left and right corners
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.white,
      title: /* _selBottom == 0
          ? */
          Theme.of(context).colorScheme.white == const Color(0xffFFFFFF)
              ? SvgPicture.asset(
                  DesignConfiguration.setSvgPath(Assets.titleicon),
                  height: 40,
                )
              : SvgPicture.asset(
                  DesignConfiguration.setSvgPath(Assets.titleiconDark),
                  height: 40,
                ),
      actions: <Widget>[
        appbarActionIcon(() {
          Routes.navigateToFavoriteScreen(context);
        }, Assets.favBlack),
        appbarActionIcon(() {
          context.read<UserProvider>().userId != ''
              ? Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const NotificationList(),
                  ),
                ).then(
                  (value) {
                    if (value != null && value) {
                      _tabController.animateTo(1);
                    }
                  },
                )
              : Routes.navigateToLoginScreen(
                  context,
                  classType: const Dashboard(),
                  isPop: true,
                );
        }, Assets.notificationBlack),
      ],
    );

    return PreferredSize(
      preferredSize: appBar.preferredSize,
      child: SlideTransition(
        position: context.watch<HomePageProvider>().animationAppBarBarOffset,
        child: SizedBox(
          height: context.watch<HomePageProvider>().getBars ? 100 : 0,
          child: appBar,
        ),
      ),
    );
  }

  Widget appbarActionIcon(Function callback, String iconname) {
    return Align(
      child: GestureDetector(
        onTap: () {
          callback();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.gray),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            color: Theme.of(context).colorScheme.white,
          ),
          margin: const EdgeInsetsDirectional.only(end: 10),
          width: Platform.isAndroid ? 37 : 30,
          height: Platform.isAndroid ? 37 : 30,
          padding: const EdgeInsets.all(7),
          child: SvgPicture.asset(
            DesignConfiguration.setSvgPath(iconname),
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget getTabItem(String enabledImage, String disabledImage,
      int selectedIndex, String name) {
    return Wrap(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: SizedBox(
                height: 25,
                child: selBottom == selectedIndex
                    ? Lottie.asset(
                        DesignConfiguration.setLottiePath(enabledImage),
                        repeat: false,
                        height: 25,
                      )
                    : SvgPicture.asset(
                        DesignConfiguration.setSvgPath(disabledImage),
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                        height: 20,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                name.translate(context: context),
                style: TextStyle(
                  color: selBottom == selectedIndex
                      ? Theme.of(context).colorScheme.fontColor
                      : Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize11,
                  fontFamily: 'ubuntu',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _getBottomBar() {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return AnimatedContainer(
      duration: Duration(
        milliseconds: context.watch<HomePageProvider>().getBars ? 500 : 500,
      ),
      padding: EdgeInsets.only(
          bottom:
              Platform.isIOS ? MediaQuery.of(context).viewPadding.bottom : 0),
      height: context.watch<HomePageProvider>().getBars
          ? kBottomNavigationBarHeight +
              (Platform.isIOS
                  ? MediaQuery.of(context).viewPadding.bottom > 8
                      ? 8
                      : MediaQuery.of(context).viewPadding.bottom
                  : 0)
          : 0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.black26,
            blurRadius: selBottom == 2 ? 0 : 5,
          )
        ],
      ),
      child: Selector<ThemeNotifier, ThemeMode>(
        selector: (_, themeProvider) => themeProvider.getThemeMode(),
        builder: (context, data, child) {
          return TabBar(
            isScrollable: false,
            controller: _tabController, indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            tabs: [
              Tab(
                child: getTabItem(
                  (data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark
                      ? Assets.darkActiveHomeName
                      : Assets.lightActiveHomeName,
                  Assets.home,
                  0,
                  'HOME_LBL',
                ),
              ),
              Tab(
                child: getTabItem(
                    (data == ThemeMode.system &&
                                currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark
                        ? Assets.darkActiveCategoryName
                        : Assets.lightActiveCategoryName,
                    Assets.category,
                    1,
                    'category'),
              ),
              Tab(
                child: getTabItem(
                  (data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark
                      ? Assets.darkActiveExplorerName
                      : Assets.lightActiveExplorerName,
                  Assets.brands,
                  2,
                  'EXPLORE',
                ),
              ),
              Tab(
                child: Selector<UserProvider, String>(
                  builder: (context, userData, child) {
                    return Stack(
                      children: [
                        getTabItem(
                          (data == ThemeMode.system &&
                                      currentBrightness == Brightness.dark) ||
                                  data == ThemeMode.dark
                              ? Assets.darkActiveCartName
                              : Assets.lightActiveCartName,
                          Assets.cart,
                          3,
                          'CART',
                        ),
                        (userData.isNotEmpty && userData != '0')
                            ? Positioned.directional(
                                end: 0,
                                textDirection: Directionality.of(context),
                                top: 0,
                                child: Container(
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.primary),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Text(
                                          userData,
                                          style: TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .white),
                                        ),
                                      ),
                                    )),
                              )
                            : const SizedBox.shrink()
                      ],
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),
              ),
              Tab(
                child: getTabItem(
                  (data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark
                      ? Assets.darkActiveProfileName
                      : Assets.lightActiveProfileName,
                  Assets.profile,
                  4,
                  'PROFILE',
                ),
              ),
            ],
            indicatorColor: Colors.transparent,
            labelColor: colors.primary,
            // isScrollable: false,
            labelStyle: const TextStyle(fontSize: textFontSize12),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }
}
