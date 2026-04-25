import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Helper/Constant.dart';
import '../../../Provider/homePageProvider.dart';
import '../../../widgets/desing.dart';
import '../../SubCategory/SubCategory.dart';

class HorizontalCategoryList extends StatelessWidget {
  const HorizontalCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePageProvider>(
      builder: (context, categoryData, child) {
        return categoryData.catLoading
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: catLoading(context),
                ),
              )
            : categoryData.catList.isEmpty
            ? Center(
                child: Text(
                  'CAT_IS_NOT_AVAILABLE_LBL'.translate(context: context),
                ),
              )
            : SizedBox(
                height: 105,
                child: ListView.builder(
                  itemCount: categoryData.catList.length < 10
                      ? categoryData.catList.length
                      : 10,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const SizedBox();
                    } else {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: GestureDetector(
                          onTap: () async {
                            if (categoryData.catList[index].subList == null ||
                                categoryData.catList[index].subList!.isEmpty) {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ProductList(
                                    name: categoryData.catList[index].name,
                                    id: categoryData.catList[index].id,
                                    tag: false,
                                    fromSeller: false,
                                  ),
                                ),
                              );
                            } else {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => SubCategory(
                                    title: categoryData.catList[index].name!,
                                    subList:
                                        categoryData.catList[index].subList,
                                    categoryId: categoryData.catList[index].id,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: DesignConfiguration.getCacheNotworkImage(
                                  boxFit: BoxFit.cover,
                                  context: context,
                                  heightvalue: 60.0,
                                  widthvalue: 60.0,
                                  placeHolderSize: 60,
                                  imageurlString:
                                      categoryData.catList[index].image!,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: 65,
                                  child: Text(
                                    categoryData.catList[index].name!,
                                    maxLines: 2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontFamily: 'ubuntu',
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.fontColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: textFontSize12,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
      },
    );
  }

  static Widget catLoading(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(10, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    shape: BoxShape.circle,
                  ),
                  width: 50.0,
                  height: 50.0,
                );
              }),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }
}
