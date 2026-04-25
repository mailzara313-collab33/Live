import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/explore_provider.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/widgets/gridViewSection.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/widgets/shortOptionWidget.dart';
// import 'package:eshop_multivendor/Screen/ProductList&SectionView/widgets/listView.dart';

import 'package:eshop_multivendor/widgets/ListViewProdusct.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/productListProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';

import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';

// ignore: must_be_immutable
class SectionList extends StatefulWidget {
  final int? index;
  SectionModel? section_model;
  List<Product>? productList;
  final int from;

  SectionList(
      {super.key,
      this.index,
      this.section_model,
      required this.from,
      this.productList});

  @override
  State<StatefulWidget> createState() => StateSection();
}

RangeValues? currentRangeValues;
late UserProvider userProvider;
bool isProgress = false;

class StateSection extends State<SectionList> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoadingMore = true, _isLoading = true;
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeAnimation;
  AnimationController? buttonController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String sortBy = '', orderBy = 'DESC';
  void setStateNow() {
    setState(() {});
  }

  late List<String> attsubList;
  late List<String> attListId;
  String? filter = '', selId = '';
  bool listType = true;
  int? total = 0, offset;
  bool filterApply = false;
  String minPrice = '0', maxPrice = '0';
  ChoiceChip? choiceChip;
  int _selectedValue = 0;

  AnimationController? _animationController;
  AnimationController? _animationController1;

  late AnimationController listViewIconController;

  @override
  void initState() {
    super.initState();
    widget.section_model!.productList!.clear();
    widget.section_model!.offset = widget.section_model!.productList!.length;

    widget.section_model!.selectedId = [];
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    if (widget.from == 1) {
      getSection('0');
      controller.addListener(_scrollListener);
    } else {
      _isLoading = false;
    }

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    listViewIconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    buttonSqueezeAnimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    _animationController1!.dispose();
    _animationController!.dispose();
    listViewIconController.dispose();
    currentRangeValues = null;
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void getAvailVarient(List<Product> productList) {
    for (int j = 0; j < productList.length; j++) {
      if (productList[j].stockType == '2') {
        for (int i = 0; i < productList[j].prVarientList!.length; i++) {
          if (productList[j].prVarientList![i].availability == '1') {
            productList[j].selVarient = i;
            break;
          }
        }
      }
    }
    widget.section_model!.productList!.addAll(productList);
  }

  void setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then((_) async {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => super.widget));
      } else {
        await buttonController!.reverse();
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _refresh() {
    if (widget.from == 1) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          isLoadingMore = true;
          widget.section_model!.offset = 0;
          widget.section_model!.totalItem = 0;
          widget.section_model!.selectedId = [];
          selId = '';
        });
      }

      total = 0;
      offset = 0;
      widget.section_model!.productList!.clear();
      return getSection('0');
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        key: scaffoldKey,
        appBar: getAppBar(
          widget.from == 1
              ? widget.section_model!.title!
              : 'You might also like'.translate(context: context),
          context,
          setStateNow,
        ),
        body: isNetworkAvail
            ? RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: _isLoading
                    ? context.watch<ExploreProvider>().getCurrentView !=
                            'GridView'
                        ? ShimmerEffect()
                        : ShimmerEffectGrid()
                    : widget.section_model!.productList!.isEmpty
                        ? DesignConfiguration.getNoItem(context)
                        : Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: <Widget>[
                                    widget.from == 1
                                        ? context
                                                    .watch<ExploreProvider>()
                                                    .getCurrentView !=
                                                'GridView'
                                            ? NotificationListener<
                                                OverscrollIndicatorNotification>(
                                                onNotification: (overscroll) {
                                                  overscroll
                                                      .disallowIndicator();
                                                  return true;
                                                },
                                                child: ListView.builder(
                                                  controller: controller,
                                                  itemCount: (widget
                                                              .section_model!
                                                              .offset! <
                                                          widget.section_model!
                                                              .totalItem!)
                                                      ? widget
                                                              .section_model!
                                                              .productList!
                                                              .length +
                                                          1
                                                      : widget.section_model!
                                                          .productList!.length,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return (index ==
                                                                widget
                                                                    .section_model!
                                                                    .productList!
                                                                    .length &&
                                                            isLoadingMore)
                                                        ? const SingleItemSimmer()
                                                        : ListIteamListWidget(
                                                            index: index,
                                                            productList: widget
                                                                .section_model
                                                                ?.productList!,
                                                            length: widget
                                                                .section_model
                                                                ?.productList!
                                                                .length,
                                                            setState:
                                                                setStateNow,
                                                          );
                                                  },
                                                ),
                                              )
                                            : NotificationListener<
                                                OverscrollIndicatorNotification>(
                                                onNotification: (overscroll) {
                                                  overscroll
                                                      .disallowIndicator();
                                                  return true;
                                                },
                                                child: GridView.count(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .only(
                                                          top: 10, start: 10),
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 0.62,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  controller: controller,
                                                  children: List.generate(
                                                    (widget.section_model!
                                                                .offset! <
                                                            widget
                                                                .section_model!
                                                                .totalItem!)
                                                        ? widget
                                                                .section_model!
                                                                .productList!
                                                                .length +
                                                            1
                                                        : widget
                                                            .section_model!
                                                            .productList!
                                                            .length,
                                                    (index) {
                                                      return (index ==
                                                                  widget
                                                                      .section_model!
                                                                      .productList!
                                                                      .length &&
                                                              isLoadingMore)
                                                          ? const SimmerSingleProduct()
                                                          : GridViewWidget(
                                                              index: index,
                                                              from: widget.from,
                                                              setState:
                                                                  setStateNow,
                                                              section_model: widget
                                                                  .section_model,
                                                            );
                                                    },
                                                  ),
                                                ),
                                              )
                                        : NotificationListener<
                                            OverscrollIndicatorNotification>(
                                            onNotification: (overscroll) {
                                              overscroll.disallowIndicator();
                                              return true;
                                            },
                                            child: ListView.builder(
                                              controller: controller,
                                              itemCount:
                                                  widget.productList!.length,
                                              shrinkWrap: true,
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return ListIteamListWidget(
                                                  index: index,
                                                  productList:
                                                      widget.productList,
                                                  length: widget
                                                      .productList!.length,
                                                  setState: setStateNow,
                                                );
                                              },
                                            ),
                                          ),
                                    DesignConfiguration.showCircularProgress(
                                      isProgress,
                                      colors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
              )
            : NoInterNet(
                setStateNoInternate: setStateNoInternate,
                buttonSqueezeanimation: buttonSqueezeAnimation,
                buttonController: buttonController,
              ),
        bottomNavigationBar: widget.productList!.isNotEmpty
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
                child: widget.from == 1 ? sortAndFilterOption() : null)
            : null);
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
                    Column(
                      children: [
                        SortOptionTile(
                          value: 1,
                          groupValue: _selectedValue,
                          title: 'TOP_RATED'.translate(context: context),
                          sortBy: '',
                          orderBy: 'DESC',
                          result: 'option 1',
                          apiParam: '1',
                          onSelected: (val, sort, order, result, apiParam) {
                            setState(() {
                              _selectedValue = val;
                              sortBy = sort;
                              orderBy = order;
                              clearList(apiParam);
                              Navigator.pop(context, result);
                            });
                          },
                        ),
                        SortOptionTile(
                          value: 2,
                          groupValue: _selectedValue,
                          title: 'F_NEWEST'.translate(context: context),
                          sortBy: 'p.date_added',
                          orderBy: 'DESC',
                          result: 'option 1',
                          apiParam: '0',
                          onSelected: (val, sort, order, result, apiParam) {
                            setState(() {
                              _selectedValue = val;
                              sortBy = sort;
                              orderBy = order;
                              clearList(apiParam);
                              Navigator.pop(context, result);
                            });
                          },
                        ),
                        SortOptionTile(
                          value: 3,
                          groupValue: _selectedValue,
                          title: 'F_OLDEST'.translate(context: context),
                          sortBy: 'p.date_added',
                          orderBy: 'ASC',
                          result: 'option 2',
                          apiParam: '0',
                          onSelected: (val, sort, order, result, apiParam) {
                            setState(() {
                              _selectedValue = val;
                              sortBy = sort;
                              orderBy = order;
                              clearList(apiParam);
                              Navigator.pop(context, result);
                            });
                          },
                        ),
                        SortOptionTile(
                          value: 4,
                          groupValue: _selectedValue,
                          title: 'F_LOW'.translate(context: context),
                          sortBy: 'pv.special_price',
                          orderBy: 'ASC',
                          result: 'option 3',
                          apiParam: '0',
                          onSelected: (val, sort, order, result, apiParam) {
                            setState(() {
                              _selectedValue = val;
                              sortBy = sort;
                              orderBy = order;
                              clearList(apiParam);
                              Navigator.pop(context, result);
                            });
                          },
                        ),
                        SortOptionTile(
                          value: 5,
                          groupValue: _selectedValue,
                          title: 'F_HIGH'.translate(context: context),
                          sortBy: 'pv.special_price',
                          orderBy: 'DESC',
                          result: 'option 4',
                          apiParam: '0',
                          onSelected: (val, sort, order, result, apiParam) {
                            setState(() {
                              _selectedValue = val;
                              sortBy = sort;
                              orderBy = order;
                              clearList(apiParam);
                              Navigator.pop(context, result);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void filterDialog() {
    // print(widget.section_model!.filterList[].toString());
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(circularBorderRadius10),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                    child: widget.section_model!.filterList != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding:
                                const EdgeInsetsDirectional.only(top: 10.0),
                            itemCount:
                                widget.section_model!.filterList!.length + 1,
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
                                                          FontWeight.normal),
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
                                          setState(() {});
                                        },
                                      ),
                                  ],
                                );
                              } else {
                                index = index - 1;
                                attsubList = widget.section_model!
                                    .filterList![index].attributeValues!
                                    .split(',');

                                attListId = widget.section_model!
                                    .filterList![index].attributeValId!
                                    .split(',');

                                List<Widget?> chips = [];
                                List<String> att = widget.section_model!
                                    .filterList![index].attributeValues!
                                    .split(',');

                                List<String> attSType = widget.section_model!
                                    .filterList![index].swatchType!
                                    .split(',');

                                List<String> attSValue = widget.section_model!
                                    .filterList![index].swatchValue!
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
                                      child: Text(att[i],
                                          style: TextStyle(
                                              color: widget.section_model!
                                                      .selectedId!
                                                      .contains(attListId[i])
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .white
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .fontColor)),
                                    );
                                  }

                                  choiceChip = ChoiceChip(
                                    selected: widget.section_model!.selectedId!
                                        .contains(attListId[i]),
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
                                          color: widget
                                                  .section_model!.selectedId!
                                                  .contains(attListId[i])
                                              ? colors.primary
                                              : colors.secondary,
                                          width: 1.5),
                                    ),
                                    onSelected: (bool selected) {
                                      attListId = widget.section_model!
                                          .filterList![index].attributeValId!
                                          .split(',');

                                      if (mounted) {
                                        setState(
                                          () {
                                            if (selected == true) {
                                              widget.section_model!.selectedId!
                                                  .add(attListId[i]);
                                            } else {
                                              widget.section_model!.selectedId!
                                                  .remove(attListId[i]);
                                            }
                                          },
                                        );
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
                                            widget.section_model!
                                                .filterList![index].name!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
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
                            if (mounted) {
                              setState(
                                () {
                                  widget.section_model!.selectedId!.clear();
                                  currentRangeValues = RangeValues(
                                      double.parse(minPrice),
                                      double.parse(maxPrice));
                                },
                              );
                            }
                          },
                          child: Text('DISCARD'.translate(context: context)),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 0),
                        child: SimBtn(
                          borderRadius: circularBorderRadius5,
                          size: 0.4,
                          title: 'APPLY'.translate(context: context),
                          onBtnSelected: () {
                            filterApply = true;
                            if (widget.section_model!.selectedId != null) {
                              selId =
                                  widget.section_model!.selectedId!.join(',');
                              clearList('0');
                              Navigator.pop(context, 'Product Filter');
                            }
                          },
                        ),
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

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            isLoadingMore = true;
            if (widget.section_model!.offset! <
                widget.section_model!.totalItem!) {
              getSection('0');
            }
          },
        );
      }
    }
  }

  void clearList(String top) {
    if (mounted) {
      setState(
        () {
          _isLoading = true;
          total = 0;
          offset = 0;
          widget.section_model!.totalItem = 0;
          widget.section_model!.offset = 0;
          widget.section_model!.productList = [];
          getSection(top);
        },
      );
    }
  }

  void updateSectionList() {
    if (mounted) setState(() {});
  }

  Future<void> getSection(String top) async {
    isProgress = true;
    setStateNow();
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      var parameter = {
        PRODUCT_LIMIT: perPage.toString(),
        PRODUCT_OFFSET: widget.section_model!.productList!.length.toString(),
        SEC_ID: widget.section_model!.id,
        TOP_RETAED: top,
        PSORT: sortBy,
        PORDER: orderBy,
      };
      // if (context.read<UserProvider>().userId != '') {
      // // parameter[USER_ID] = context.read<UserProvider>().userId;
      // }
      if (selId != null && selId != '') {
        parameter[ATTRIBUTE_VALUE_ID] = selId;
      }
      if (currentRangeValues != null &&
          currentRangeValues!.start.round().toString() != '0') {
        parameter[MINPRICE] = currentRangeValues!.start.round().toString();
      }

      if (currentRangeValues != null &&
          currentRangeValues!.end.round().toString() != '0') {
        parameter[MAXPRICE] = currentRangeValues!.end.round().toString();
      }
      context.read<ProductListProvider>().setSectionListParameter(parameter);

      await Future.delayed(Duration.zero).then(
        (value) => context.read<ProductListProvider>().getSectionList().then(
          (
            value,
          ) async {
            bool error = value['error'];
            String? msg = value['message'];
            if (!error) {
              var data = value['data'];
              print('${value[MINPRICE]} ${value[MAXPRICE]}');
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
              offset = widget.section_model!.productList!.length;
              total = int.parse(data[0]['total']);
              if (offset! < total!) {
                List<SectionModel> temp = (data as List)
                    .map((data) => SectionModel.fromJson(data))
                    .toList();
                getAvailVarient(temp[0].productList!);
                offset = widget.section_model!.offset! + perPage;
                widget.section_model!.offset = offset;
                widget.section_model!.totalItem = total;
              }
            } else {
              isLoadingMore = false;
              if (msg != 'Sections not found') setSnackbar(msg!, context);
            }
            if (mounted) {
              setState(
                () {
                  _isLoading = false;
                },
              );
            }
          },
        ),
      );
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
    isProgress = false;
    setStateNow();
    return;
  }

  Widget sortAndFilterOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Container(
          color: Theme.of(context).colorScheme.white,
          height: Platform.isIOS ? 65 : 45,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    if (widget.productList!.isNotEmpty &&
                        context.read<ExploreProvider>().view == 'GridView') {
                      setState(() {});
                      context.read<ExploreProvider>().changeViewTo('ListView');
                    } else if (widget.productList!.isNotEmpty &&
                        context.read<ExploreProvider>().view == 'ListView') {
                      setState(() {});
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
                  onTap: () {
                    sortDialog();
                  },
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
                    if (widget.section_model!.filterList!.isNotEmpty) {
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
          )),
    );
  }
}
