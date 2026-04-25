import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:eshop_multivendor/cubits/brandsListCubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Helper/Constant.dart';
import '../../../widgets/desing.dart';

class BrandsListWidget extends StatelessWidget {
  const BrandsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandsListCubit, BrandsListState>(
      builder: (context, state) {
        if (state is BrandsListSuccess) {
          return state.brands.isNotEmpty
              ? SizedBox(
                  height: 105,
                  child: ListView.builder(
                    itemCount: state.brands.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ProductList(
                                  name: state.brands[index].name,
                                  id: state.brands[index].id,
                                  fromBrands: true,
                                  tag: false,
                                  fromSeller: false,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    circularBorderRadius4),
                                child: DesignConfiguration.getCacheNotworkImage(
                                  boxFit: BoxFit.contain,
                                  context: context,
                                  heightvalue: 60.0,
                                  widthvalue: 60.0,
                                  placeHolderSize: 60,
                                  imageurlString: state.brands[index].image,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: 60,
                                  child: Text(
                                    state.brands[index].name,
                                    maxLines: 2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontFamily: 'ubuntu',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
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
                    },
                  ),
                )
              : const SizedBox.shrink();
        } else if (state is BrandsListInProgress) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: brandLoading(context),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  static Widget brandLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(10, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.white,
                  borderRadius: BorderRadius.circular(circularBorderRadius4),
                ),
                width: 50.0,
                height: 50.0,
              );
            })),
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
