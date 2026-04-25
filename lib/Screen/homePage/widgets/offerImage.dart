import 'package:flutter/material.dart';
import '../../../Helper/Constant.dart';
import '../../../widgets/desing.dart';

// ignore: must_be_immutable
class OfferImage extends StatelessWidget {
  String offerImage;
  VoidCallback onOfferClick;
  OfferImage({
    super.key,
    required this.onOfferClick,
    required this.offerImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onOfferClick();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circularBorderRadius5),
        child: DesignConfiguration.getCacheNotworkImage(
          boxFit: null,
          context: context,
          heightvalue: null,
          widthvalue: double.maxFinite,
          imageurlString: offerImage,
          placeHolderSize: 50,
        ),
      ),
    );
  }
}
