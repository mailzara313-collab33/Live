import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:eshop_multivendor/widgets/networkAvailablity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Model/Section_Model.dart';
import '../../widgets/desing.dart';
import '../../widgets/GridViewProduct.dart';
import '../ProductList&SectionView/ProductList.dart';
import '../SubCategory/SubCategory.dart';

class AllCategory extends StatefulWidget {
  const AllCategory({super.key});

  @override
  State<AllCategory> createState() => _AllCategoryState();
}

class _AllCategoryState extends State<AllCategory>
    with TickerProviderStateMixin {
  late AnimationController buttonController;
  late Animation buttonSqueezeanimation;

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    buttonSqueezeanimation = Tween(begin: deviceWidth! * 0.7, end: 50.0)
        .animate(
          CurvedAnimation(
            parent: buttonController,
            curve: const Interval(0.0, 0.150),
          ),
        );
  }

  Future<void> setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then((_) async {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (BuildContext context) => super.widget),
        );
      } else {
        await buttonController.reverse();
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  // Fetch products for a category
  Future<void> fetchCategoryProducts(String? categoryId) async {
    if (categoryId == null) return;

    try {
      context.read<CategoryProvider>().setLoadingProducts(true);

      Map<String, String> parameter = {CATID: categoryId};

      final response = await ApiBaseHelper().postAPICall(
        getProductApi,
        parameter,
      );

      if (response['error'] == false) {
        final data = response['data'];

        final List<Product> productList = [];

        //  FIX: Direct flat product list handling
        if (data != null && data is List) {
          for (var productData in data) {
            try {
              final product = Product.fromJson(productData);
              productList.add(product);
            } catch (e) {}
          }
        }

        if (mounted) {
          context.read<CategoryProvider>().setProductList(productList);
        }
      } else {
        if (mounted) {
          context.read<CategoryProvider>().clearProductList();
        }
      }
    } catch (e) {
      if (mounted) {
        context.read<CategoryProvider>().clearProductList();
      }
    } finally {
      if (mounted) {
        context.read<CategoryProvider>().setLoadingProducts(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isNetworkAvail
          ? NoInterNet(
              buttonController: buttonController,
              buttonSqueezeanimation: buttonSqueezeanimation,
              setStateNoInternate: setStateNoInternate,
            )
          : Consumer<HomePageProvider>(
              builder: (context, homePageProvider, _) {
                if (homePageProvider.catLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (homePageProvider.catList.isEmpty) {
                  return Center(
                    child: Text(
                      'CAT_IS_NOT_AVAILABLE_LBL'.translate(context: context),
                    ),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Theme.of(context).colorScheme.lightWhite,
                        child: NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsetsDirectional.only(
                              top: 10.0,
                            ),
                            itemCount: context
                                .read<HomePageProvider>()
                                .catList
                                .length,
                            itemBuilder: (context, index) {
                              return Selector<CategoryProvider, int>(
                                builder: (context, data, child) {
                                  if (index == 0 &&
                                      (context
                                          .read<HomePageProvider>()
                                          .popularList
                                          .isNotEmpty)) {
                                    return GestureDetector(
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: data == index
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.white
                                              : Colors.transparent,
                                          border: data == index
                                              ? const Border(
                                                  left: BorderSide(
                                                    width: 5.0,
                                                    color: colors.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      circularBorderRadius25,
                                                    ),
                                                child: SvgPicture.asset(
                                                  DesignConfiguration.setSvgPath(
                                                    data == index
                                                        ? Assets.popularSel
                                                        : Assets.popular,
                                                  ),
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                        colors.primary,
                                                        BlendMode.srcIn,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${context.read<HomePageProvider>().catList[index].name!}\n',
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontFamily: 'ubuntu',
                                                    color: data == index
                                                        ? colors.primary
                                                        : Theme.of(context)
                                                              .colorScheme
                                                              .fontColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        context
                                            .read<CategoryProvider>()
                                            .setCurSelected(index);
                                        context
                                            .read<CategoryProvider>()
                                            .setSubList(
                                              context
                                                  .read<HomePageProvider>()
                                                  .popularList,
                                            );
                                      },
                                    );
                                  } else {
                                    return GestureDetector(
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          //shape: BoxShape.circle,
                                          color: data == index
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.white
                                              : Colors.transparent,
                                          border: data == index
                                              ? const Border(
                                                  left: BorderSide(
                                                    width: 5.0,
                                                    color: colors.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        circularBorderRadius25,
                                                      ),
                                                  child:
                                                      DesignConfiguration.getCacheNotworkImage(
                                                        boxFit: BoxFit.fill,
                                                        context: context,
                                                        heightvalue: null,
                                                        widthvalue: null,
                                                        imageurlString: context
                                                            .read<
                                                              HomePageProvider
                                                            >()
                                                            .catList[index]
                                                            .image!,
                                                        placeHolderSize: null,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${context.read<HomePageProvider>().catList[index].name!}\n',
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontFamily: 'ubuntu',
                                                    color: data == index
                                                        ? colors.primary
                                                        : Theme.of(context)
                                                              .colorScheme
                                                              .fontColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        context
                                            .read<CategoryProvider>()
                                            .setCurSelected(index);
                                        if (context
                                                    .read<HomePageProvider>()
                                                    .catList[index]
                                                    .subList ==
                                                null ||
                                            context
                                                .read<HomePageProvider>()
                                                .catList[index]
                                                .subList!
                                                .isEmpty) {
                                          context
                                              .read<CategoryProvider>()
                                              .setSubList([]);
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => ProductList(
                                                name: context
                                                    .read<HomePageProvider>()
                                                    .catList[index]
                                                    .name,
                                                id: context
                                                    .read<HomePageProvider>()
                                                    .catList[index]
                                                    .id,
                                                tag: false,
                                                fromSeller: false,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Has subcategories
                                          final category = context
                                              .read<HomePageProvider>()
                                              .catList[index];

                                          context
                                              .read<CategoryProvider>()
                                              .setSubList(category.subList);

                                          // Fetch products for this category
                                          fetchCategoryProducts(category.id);
                                        }
                                      },
                                    );
                                  }
                                },
                                selector: (_, cat) => cat.curCat,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: context.read<HomePageProvider>().catList.isNotEmpty
                          ? Column(
                              children: [
                                Selector<CategoryProvider, int>(
                                  builder: (context, data, child) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${context.read<HomePageProvider>().catList[data].name!} ',
                                                style: const TextStyle(
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                              const Expanded(
                                                child: Divider(thickness: 2),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              '${'All'.translate(context: context)} ${context.read<HomePageProvider>().catList[data].name!} ',
                                              style: TextStyle(
                                                fontFamily: 'ubuntu',
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: textFontSize16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  selector: (_, cat) => cat.curCat,
                                ),
                                Expanded(
                                  child: Consumer<CategoryProvider>(
                                    builder: (context, categoryProvider, child) {
                                      final currentCatIndex =
                                          categoryProvider.curCat;
                                      final subList =
                                          categoryProvider.subList ?? [];
                                      final productList =
                                          categoryProvider.productList ?? [];
                                      final isLoadingProducts =
                                          categoryProvider.isLoadingProducts;

                                      // Check if current category has subcategories (exclude Popular)
                                      final hasSubcategories =
                                          subList.isNotEmpty &&
                                          currentCatIndex !=
                                              0; // Exclude Popular category

                                      // Check if products are available
                                      final hasProducts =
                                          productList.isNotEmpty &&
                                          currentCatIndex != 0;

                                      // Show both subcategories and products when both exist
                                      final showBoth =
                                          hasSubcategories && hasProducts;

                                      // Data to display: subcategories when no products, otherwise show both sections
                                      final data = showBoth
                                          ? productList
                                          : subList;

                                      return (data.isNotEmpty ||
                                              isLoadingProducts)
                                          ? NotificationListener<
                                              OverscrollIndicatorNotification
                                            >(
                                              onNotification: (overscroll) {
                                                overscroll.disallowIndicator();
                                                return true;
                                              },
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Show loading indicator while fetching products
                                                    if (isLoadingProducts)
                                                      const Padding(
                                                        padding: EdgeInsets.all(
                                                          20.0,
                                                        ),
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      ),
                                                    // Horizontal subcategories section (only when both subcategories and products exist)
                                                    if (showBoth) ...[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12.0,
                                                            ),
                                                        child: Text(
                                                          'SUBCATEGORY'
                                                              .translate(
                                                                context:
                                                                    context,
                                                              ),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'ubuntu',
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .fontColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                textFontSize14,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 90,
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                              ),
                                                          itemCount:
                                                              subList.length,
                                                          itemBuilder: (context, index) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                if (subList[index]
                                                                            .subList ==
                                                                        null ||
                                                                    subList[index]
                                                                        .subList!
                                                                        .isEmpty) {
                                                                  Navigator.push(
                                                                    context,
                                                                    CupertinoPageRoute(
                                                                      builder: (context) => ProductList(
                                                                        name: subList[index]
                                                                            .name,
                                                                        id: subList[index]
                                                                            .id,
                                                                        tag:
                                                                            false,
                                                                        fromSeller:
                                                                            false,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  Navigator.push(
                                                                    context,
                                                                    CupertinoPageRoute(
                                                                      builder: (context) => SubCategory(
                                                                        subList:
                                                                            subList[index].subList,
                                                                        title:
                                                                            subList[index].name ??
                                                                            '',
                                                                        categoryId:
                                                                            subList[index].id,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                width: 90,
                                                                margin:
                                                                    const EdgeInsets.only(
                                                                      right: 12,
                                                                    ),
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child: ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              circularBorderRadius10,
                                                                            ),
                                                                        child: DesignConfiguration.getCacheNotworkImage(
                                                                          boxFit:
                                                                              extendImg
                                                                              ? BoxFit.cover
                                                                              : BoxFit.contain,
                                                                          context:
                                                                              context,
                                                                          heightvalue:
                                                                              null,
                                                                          widthvalue:
                                                                              null,
                                                                          imageurlString:
                                                                              subList[index].image!,
                                                                          placeHolderSize:
                                                                              null,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      subList[index]
                                                                          .name!,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                                        fontFamily:
                                                                            'ubuntu',
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).colorScheme.fontColor,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12.0,
                                                              vertical: 8.0,
                                                            ),
                                                        child: Divider(
                                                          thickness: 1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12.0,
                                                            ),
                                                        child: Text(
                                                          'PRODUCTS'.translate(
                                                            context: context,
                                                          ),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'ubuntu',
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .fontColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                textFontSize14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    // Products grid - shows products when showBoth is true, otherwise shows subcategories
                                                    if (showBoth &&
                                                        !isLoadingProducts)
                                                      GridView.builder(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 8,
                                                            ),
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 2,
                                                              childAspectRatio:
                                                                  0.58,
                                                              crossAxisSpacing:
                                                                  2,
                                                              mainAxisSpacing:
                                                                  2,
                                                            ),
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                            productList.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                              return GridViewProductListWidget(
                                                                productList:
                                                                    productList,

                                                                index: index,
                                                                pad: false,
                                                                setState: () {
                                                                  if (mounted) {
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                  }
                                                                },
                                                              );
                                                            },
                                                      ),
                                                    // Subcategories grid when no products
                                                    if (!showBoth)
                                                      GridView.count(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                        crossAxisCount: 3,
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        childAspectRatio: 0.75,
                                                        children: List.generate(data.length, (
                                                          index,
                                                        ) {
                                                          return GestureDetector(
                                                            child: Column(
                                                              children: <Widget>[
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8.0,
                                                                        ),
                                                                    child: ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            circularBorderRadius10,
                                                                          ),
                                                                      child: DesignConfiguration.getCacheNotworkImage(
                                                                        boxFit:
                                                                            extendImg
                                                                            ? BoxFit.cover
                                                                            : BoxFit.contain,
                                                                        context:
                                                                            context,
                                                                        heightvalue:
                                                                            null,
                                                                        widthvalue:
                                                                            null,
                                                                        imageurlString:
                                                                            data[index].image!,
                                                                        placeHolderSize:
                                                                            null,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${data[index].name!}\n',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: Theme.of(context)
                                                                      .textTheme
                                                                      .bodySmall!
                                                                      .copyWith(
                                                                        fontFamily:
                                                                            'ubuntu',
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).colorScheme.fontColor,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            onTap: () {
                                                              if (context
                                                                          .read<
                                                                            CategoryProvider
                                                                          >()
                                                                          .curCat ==
                                                                      0 &&
                                                                  context
                                                                      .read<
                                                                        HomePageProvider
                                                                      >()
                                                                      .popularList
                                                                      .isNotEmpty) {
                                                                if (context
                                                                            .read<
                                                                              HomePageProvider
                                                                            >()
                                                                            .popularList[index]
                                                                            .subList ==
                                                                        null ||
                                                                    context
                                                                        .read<
                                                                          HomePageProvider
                                                                        >()
                                                                        .popularList[index]
                                                                        .subList!
                                                                        .isEmpty) {
                                                                  Navigator.push(
                                                                    context,
                                                                    CupertinoPageRoute(
                                                                      builder: (context) => ProductList(
                                                                        name: context
                                                                            .read<
                                                                              HomePageProvider
                                                                            >()
                                                                            .popularList[index]
                                                                            .name,
                                                                        id: context
                                                                            .read<
                                                                              HomePageProvider
                                                                            >()
                                                                            .popularList[index]
                                                                            .id,
                                                                        tag:
                                                                            false,
                                                                        fromSeller:
                                                                            false,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  Navigator.push(
                                                                    context,
                                                                    CupertinoPageRoute(
                                                                      builder: (context) => SubCategory(
                                                                        subList: context
                                                                            .read<
                                                                              HomePageProvider
                                                                            >()
                                                                            .popularList[index]
                                                                            .subList,
                                                                        title:
                                                                            context
                                                                                .read<
                                                                                  HomePageProvider
                                                                                >()
                                                                                .popularList[index]
                                                                                .name ??
                                                                            '',
                                                                        categoryId: context
                                                                            .read<
                                                                              HomePageProvider
                                                                            >()
                                                                            .popularList[index]
                                                                            .id,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              } else if (data[index]
                                                                          .subList ==
                                                                      null ||
                                                                  data[index]
                                                                      .subList!
                                                                      .isEmpty) {
                                                                Navigator.push(
                                                                  context,
                                                                  CupertinoPageRoute(
                                                                    builder: (context) => ProductList(
                                                                      name: data[index]
                                                                          .name,
                                                                      id: data[index]
                                                                          .id,
                                                                      tag:
                                                                          false,
                                                                      fromSeller:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                Navigator.push(
                                                                  context,
                                                                  CupertinoPageRoute(
                                                                    builder: (context) => SubCategory(
                                                                      subList:
                                                                          data[index]
                                                                              .subList,
                                                                      title:
                                                                          data[index]
                                                                              .name ??
                                                                          '',
                                                                      categoryId:
                                                                          data[index]
                                                                              .id,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          );
                                                        }),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                'noItem'.translate(
                                                  context: context,
                                                ),
                                                style: const TextStyle(
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
