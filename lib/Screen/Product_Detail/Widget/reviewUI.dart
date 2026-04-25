import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Model/User.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Product_Detail/Widget/reviewList.dart';
import 'package:eshop_multivendor/Screen/ProductPreview/productPreview.dart';
import 'package:eshop_multivendor/widgets/networkAvailablity.dart';
import 'package:eshop_multivendor/widgets/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/ReviewGallleryProvider.dart';
import '../../../Provider/ReviewPreviewProvider.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../../widgets/desing.dart';

import 'reviewStar.dart';

class ReviewWidget extends StatefulWidget {
  final int? secPos;
  final int? widgetindex;
  final Product? model;
  const ReviewWidget({super.key, this.model, this.secPos, this.widgetindex});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  bool _isNetworkAvail = true;
  var star1 = '0',
      star2 = '0',
      star3 = '0',
      star4 = '0',
      star5 = '0',
      averageRating = '0';
  int offset = 0;
  int total = 0;
  String userComment = '';
  String userRating = '';

  @override
  void initState() {
    super.initState();
    // Clear previous product's review data and set current product ID
    // Schedule for after the current frame to avoid calling notifyListeners during build
    final provider = context.read<ProductDetailProvider>();
    if (provider.currentReviewProductId != widget.model!.id) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          provider.clearReviewData();
          provider.setCurrentProductId(widget.model!.id);
        }
      });
    }

    for (var element in context.read<ProductDetailProvider>().reviewList) {
      if (element.userId == context.read<UserProvider>().userId) {
        userComment = element.comment!;
        userRating = element.rating!;
      }
    }
    getReview('0');
  }

  @override
  void didUpdateWidget(ReviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the product changed, refresh the reviews
    if (oldWidget.model?.id != widget.model?.id) {
      final provider = context.read<ProductDetailProvider>();
      provider.clearReviewData();
      provider.setCurrentProductId(widget.model!.id);
      getReview('0');
    }
  }

  Future<void> getReview(var offset) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_ID: widget.model!.id,
          LIMIT: perPage.toString(),
          OFFSET: offset,
        };

        Response response =
            await post(getRatingApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String? msg = getdata['message'];

        if (!error) {
          star1 = getdata['star_1'];
          star2 = getdata['star_2'];
          star3 = getdata['star_3'];
          star4 = getdata['star_4'];
          star5 = getdata['star_5'];
          averageRating = getdata['product_rating'];

          total = int.parse(getdata['total']);

          offset = int.parse(offset);

          if (offset < total) {
            var data = getdata['data'];
            if (!mounted) return;
            final provider = context.read<ProductDetailProvider>();

            // Update review list
            provider.reviewList =
                (data as List).map((data) => User.forReview(data)).toList();

            // Extract and populate review images
            List<imgModel> tempReviewImgList = [];
            for (int reviewIndex = 0;
                reviewIndex < provider.reviewList.length;
                reviewIndex++) {
              var review = provider.reviewList[reviewIndex];
              if (review.imgList != null && review.imgList!.isNotEmpty) {
                for (var img in review.imgList!) {
                  // Use reviewIndex so all images from the same review have the same index
                  tempReviewImgList.add(imgModel(img: img, index: reviewIndex));
                }
              }
            }
            provider.reviewImgList = tempReviewImgList;

            // Set loading to false
            provider.isLoading = false;

            this.offset = offset + perPage;
          }
        } else {
          if (msg != 'No ratings found !') {
            // Handle error silently or show message if needed
          }
          if (!mounted) return;
          context.read<ProductDetailProvider>().isLoading = false;
        }
        if (mounted) {
          setState(() {});
        }
      } on TimeoutException catch (_) {
        // Handle timeout
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Widget _reviewTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Product Ratings & Reviews'.translate(context: context),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Ubuntu',
                fontStyle: FontStyle.normal,
                fontSize: textFontSize16,
                color: Theme.of(context).colorScheme.lightBlack,
              ),
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'VIEW_ALL'.translate(context: context),
                style: const TextStyle(color: colors.primary),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        ReviewList(widget.model!.id, widget.model)),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();

    // Check if reviews are for different product - if so, refresh
    if (provider.currentReviewProductId != null &&
        provider.currentReviewProductId != widget.model!.id &&
        !provider.isLoading) {
      // Schedule refresh for next frame to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          provider.clearReviewData();
          provider.setCurrentProductId(widget.model!.id);
          getReview('0');
        }
      });
    }

    return provider.reviewList.isNotEmpty
        ? Container(
            color: Theme.of(context).colorScheme.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewTitle(context),
                CustomReviewStar(
                  model: widget.model!,
                  star1: star1,
                  star2: star2,
                  star3: star3,
                  star4: star4,
                  star5: star5,
                  reviewCount: provider.reviewList.length,
                ),
                provider.reviewImgList.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(
                          right: 8.0,
                          left: 8.0,
                        ),
                        child: Divider(
                          height: 0,
                        ),
                      )
                    : const SizedBox(),
                provider.reviewImgList.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                          right: 15.0,
                          left: 15,
                          top: 19,
                          bottom: 5,
                        ),
                        child: Text(
                          'Real images from customers'
                              .translate(context: context),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.black,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: textFontSize12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : const SizedBox(),
                ReviewImageWidget(
                  model: widget.model,
                  reviewImgList: provider.reviewImgList,
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Divider(
                    height: 0,
                  ),
                ),
                ReviewPart(
                  secPos: widget.secPos,
                  widgetindex: widget.widgetindex,
                  reviewList: provider.reviewList,
                  isLoading: provider.isLoading,
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}

class ReviewImageWidget extends StatelessWidget {
  final Product? model;
  final List<imgModel> reviewImgList;
  const ReviewImageWidget({
    super.key,
    this.model,
    required this.reviewImgList,
  });

  @override
  Widget build(BuildContext context) {
    return reviewImgList.isNotEmpty
        ? SizedBox(
            height: 60,
            child: ListView.builder(
              itemCount: reviewImgList.length > 6 ? 6 : reviewImgList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 5,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      if (index == 5) {
                        context
                            .read<ReviewGallaryProvider>()
                            .setProductModel(model);
                        Routes.navigateToReviewGallaryScreen(context);
                      } else {
                        context
                            .read<ReviewPreviewProvider>()
                            .setProductModel(model);
                        context.read<ReviewPreviewProvider>().setIndex(index);
                        Routes.navigateToReviewPreviewScreen(context);
                      }
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(circularBorderRadius10)),
                          child: DesignConfiguration.getCacheNotworkImage(
                            boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                            context: context,
                            heightvalue: 45.0,
                            widthvalue: 45.0,
                            placeHolderSize: 45.0,
                            imageurlString: reviewImgList[index].img!,
                          ),
                        ),
                        index == 5
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(circularBorderRadius10)),
                                  color:
                                      Theme.of(context).colorScheme.lightBlack2,
                                ),
                                height: 45.0,
                                width: 45.0,
                                child: Center(
                                  child: Text(
                                    '+${reviewImgList.length - 6}',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox();
  }
}

class ReviewPart extends StatefulWidget {
  final int? secPos;
  final int? widgetindex;
  final List<User> reviewList;
  final bool isLoading;

  const ReviewPart({
    super.key,
    this.secPos,
    this.widgetindex,
    required this.reviewList,
    required this.isLoading,
  });

  @override
  State<ReviewPart> createState() => _ReviewPartState();
}

class _ReviewPartState extends State<ReviewPart> {
  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            itemCount:
                widget.reviewList.length >= 2 ? 2 : widget.reviewList.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: DesignConfiguration.getCacheNotworkImage(
                            imageurlString:
                                widget.reviewList[index].userProfile!,
                            boxFit: BoxFit.fill,
                            heightvalue: 36,
                            widthvalue: 36,
                            context: context,
                            placeHolderSize: 36,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.reviewList[index].username!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RatingBarIndicator(
                          rating:
                              double.parse(widget.reviewList[index].rating!),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
                        ),
                        const Spacer(),
                        Text(
                          widget.reviewList[index].date!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack2,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (widget.reviewList[index].comment != '' &&
                        widget.reviewList[index].comment!.isNotEmpty)
                      Text(
                        widget.reviewList[index].comment ?? '',
                        textAlign: TextAlign.left,
                      ),
                    if (widget.reviewList[index].imgList!.isNotEmpty)
                      ReviewImagesWidget(
                        i: index,
                        secPos: widget.secPos,
                        index: widget.widgetindex,
                        reviewList: widget.reviewList,
                      ),
                  ],
                ),
              );
            },
          );
  }
}

class ReviewImagesWidget extends StatefulWidget {
  final int i;
  final int? secPos;
  final int? index;
  final List<User> reviewList;

  const ReviewImagesWidget({
    super.key,
    required this.i,
    this.index,
    this.secPos,
    required this.reviewList,
  });

  @override
  State<ReviewImagesWidget> createState() => _ReviewImagesWidgetState();
}

class _ReviewImagesWidgetState extends State<ReviewImagesWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: SizedBox(
        height: widget.reviewList[widget.i].imgList!.isNotEmpty ? 60 : 0,
        child: ListView.builder(
          itemCount: widget.reviewList[widget.i].imgList!.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 2.0,
                vertical: 5,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductPreview(
                          pos: index,
                          index: index,
                          id: "$index${widget.reviewList[widget.i].id}",
                          imgList: widget.reviewList[widget.i].imgList,
                          list: true,
                          from: false,
                        ),
                      ));
                },
                child: Hero(
                  tag:
                      '$heroTagUniqueString$index${widget.reviewList[widget.i].id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius10)),
                    child: DesignConfiguration.getCacheNotworkImage(
                      boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                      context: context,
                      heightvalue: 45.0,
                      widthvalue: 45.0,
                      placeHolderSize: 45.0,
                      imageurlString:
                          widget.reviewList[widget.i].imgList![index],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
