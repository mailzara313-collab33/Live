import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Section_Model.dart';

class CustomReviewStar extends StatelessWidget {
  final Product model;
  final String star1;
  final String star2;
  final String star3;
  final String star4;
  final String star5;
  final int reviewCount;

  const CustomReviewStar({
    super.key,
    required this.model,
    required this.star1,
    required this.star2,
    required this.star3,
    required this.star4,
    required this.star5,
    required this.reviewCount,
  });

  Widget getText(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 3.5,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.black,
          fontWeight: FontWeight.w400,
          fontFamily: 'Ubuntu',
          fontStyle: FontStyle.normal,
          fontSize: textFontSize10,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget getRatingBarIndicator(double ratingStar, int totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        textDirection: TextDirection.rtl,
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_rate_rounded,
          color: colors.yellow,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  Widget getTotalStarRating(int totalStar) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Text(
        totalStar.toString(),
        style: const TextStyle(
          fontSize: textFontSize10,
          fontWeight: FontWeight.bold,
          color: Color(0xffa0a1a0),
        ),
      ),
    );
  }

  Widget getRatingIndicator(int totalStar, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 5.0,
        left: 0.5,
        top: 7,
        bottom: 8,
      ),
      child: Stack(
        children: [
          Container(
            height: 4,
            width: MediaQuery.of(context).size.width * 0.53,
            decoration: BoxDecoration(
              color: const Color(0xfff0f0f0),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(circularBorderRadius3),
              border: Border.all(width: 0.5, color: const Color(0xfff0f0f0)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(circularBorderRadius50),
              color: index == 5
                  ? const Color(0xff048d63)
                  : index == 4
                      ? const Color(0xff048d63)
                      : index == 3
                          ? const Color(0xff24ba75)
                          : index == 2
                              ? const Color(0xffed7114)
                              : const Color.fromARGB(255, 255, 50, 50),
            ),
            width: reviewCount > 0
                ? ((MediaQuery.of(context).size.width * 0.53) *
                        ((totalStar / reviewCount) * 100)) /
                    100
                : 0,
            height: 4,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              model.rating != null
                  ? Text(
                      '${model.rating!.split('.')[0]}.${model.rating!.split('.')[1].substring(0, 1)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: textFontSize30,
                        color: colors.primary,
                      ),
                    )
                  : const SizedBox(),
              Text(
                "${reviewCount}  ${"RATINGS".translate(context: context)}",
                style: const TextStyle(
                  color: Color(0xffa0a1a0),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Ubuntu',
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize10,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              getText('Excellent'.translate(context: context), context),
              getText('Very Good'.translate(context: context), context),
              getText('Good'.translate(context: context), context),
              getText('Average'.translate(context: context), context),
              getText('Poor'.translate(context: context), context),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getRatingIndicator(int.parse(star5), 5, context),
                getRatingIndicator(int.parse(star4), 4, context),
                getRatingIndicator(int.parse(star3), 3, context),
                getRatingIndicator(int.parse(star2), 2, context),
                getRatingIndicator(int.parse(star1), 1, context),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTotalStarRating(int.parse(star5)),
              getTotalStarRating(int.parse(star4)),
              getTotalStarRating(int.parse(star3)),
              getTotalStarRating(int.parse(star2)),
              getTotalStarRating(int.parse(star1)),
            ],
          ),
        ),
      ],
    );
  }
}
