import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../widgets/desing.dart';

class NavigationBtnWidget extends StatelessWidget {
  const NavigationBtnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 34.0,
      left: 5.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: DesignConfiguration.shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(circularBorderRadius4),
              onTap: () => Navigator.of(context).pop(),
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: colors.primary,
                  size: 35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GetRattingBarIndicatorWidget extends StatelessWidget {
  final String? rating;
  const GetRattingBarIndicatorWidget({
    super.key,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: double.parse(rating!),
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 12.0,
      direction: Axis.horizontal,
    );
  }
}
