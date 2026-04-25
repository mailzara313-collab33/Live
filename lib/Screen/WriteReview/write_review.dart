import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/routes.dart';
import '../../Provider/writeReviewProvider.dart';

import '../../widgets/snackbar.dart';
import 'Widget/ImageField.dart';
import 'Widget/rattingwidget.dart';

class Write_Review extends StatefulWidget {
  final BuildContext screenContext;
  final String productId;
  final String userReview;
  final double userStarRating;

  const Write_Review(
      this.screenContext, this.productId, this.userReview, this.userStarRating,
      {super.key});

  @override
  State<Write_Review> createState() => _Write_ReviewState();
}

class _Write_ReviewState extends State<Write_Review> {
  @override
  void initState() {
    context.read<WriteReviewProvider>().commentTextController.text =
        widget.userReview;
    super.initState();
  }

  void setStateNow() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              bottomSheetHandle(),
              rateTextLabel(),
              RattingWidget(
                userStarRating: widget.userStarRating,
              ),
              writeReviewLabel(),
              writeReviewField(),
              getImageField(),
              sendReviewButton(widget.productId),
            ],
          ),
        ),
      ],
    );
  }

  Widget bottomSheetHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularBorderRadius50),
            color: Theme.of(context).colorScheme.lightBlack),
        height: 5,
        width: MediaQuery.of(context).size.width * 0.3,
      ),
    );
  }

  Widget rateTextLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: getHeading('PRODUCT_REVIEW'),
    );
  }

  Widget writeReviewLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        'REVIEW_OPINION'.translate(context: context),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontFamily: 'ubuntu',
        ),
      ),
    );
  }

  Widget writeReviewField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: TextField(
        controller: context.read<WriteReviewProvider>().commentTextController,
        style: Theme.of(context).textTheme.titleSmall,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.lightBlack, width: 1.0)),
          hintText: 'REVIEW_HINT_LBL'.translate(context: context),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .lightBlack2
                    .withValues(alpha: 0.7),
              ),
        ),
      ),
    );
  }

  Widget sendReviewButton(var productID) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: MaterialButton(
              height: 45.0,
              textColor: Theme.of(context).colorScheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(circularBorderRadius10)),
              onPressed: () {
                if (context.read<WriteReviewProvider>().curRating != 0 ||
                    context
                            .read<WriteReviewProvider>()
                            .commentTextController
                            .text !=
                        '' ||
                    (context
                        .read<WriteReviewProvider>()
                        .reviewPhotos
                        .isNotEmpty)) {
                  context.read<WriteReviewProvider>().setRating(
                        productID,
                        context,
                        widget.screenContext,
                        setStateNow,
                      );
                } else {
                  Routes.pop(context);
                  setSnackbar('REVIEW_W'.translate(context: context),
                      widget.screenContext);
                }
              },
              color: colors.primary,
              child: Text(
                widget.userStarRating == 0.0
                    ? 'SEND_REVIEW'.translate(context: context)
                    : 'UPDATE_REVIEW_LBL'.translate(context: context),
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Text getHeading(
    String title,
  ) {
    return Text(
      title.translate(context: context),
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.fontColor,
            fontFamily: 'ubuntu',
          ),
    );
  }
}
