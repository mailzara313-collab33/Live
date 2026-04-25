import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Product Image Slider Widget
/// Displays product images with pagination indicators
class ProductImageSlider extends StatefulWidget {
  final List<String?> sliderList;
  final Product model;
  final int? index;
  final Function(int) onImageTap;
  final Function(int) onPageChanged;
  final String heroTag;

  const ProductImageSlider({
    super.key,
    required this.sliderList,
    required this.model,
    required this.index,
    required this.onImageTap,
    required this.onPageChanged,
    required this.heroTag,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final PageController _pageController = PageController();
  int _curSlider = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () => widget.onImageTap(_curSlider),
          child: Stack(
            children: <Widget>[
              Hero(
                tag: widget.heroTag,
                child: PageView.builder(
                  itemCount: widget.sliderList.length,
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  reverse: false,
                  onPageChanged: (index) {
                    setState(() {
                      _curSlider = index;
                    });
                    widget.onPageChanged(index);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        widget.sliderList[index] != 'youtube'
                            ? DesignConfiguration.getCacheNotworkImage(
                                boxFit:
                                    extendImg ? BoxFit.cover : BoxFit.contain,
                                context: context,
                                heightvalue: constraints.maxHeight,
                                widthvalue: constraints.maxWidth,
                                placeHolderSize:
                                    MediaQuery.of(context).size.width,
                                imageurlString: widget.sliderList[index]!,
                              )
                            : _playIcon()
                      ],
                    );
                  },
                ),
              ),
              // Pagination indicators
              Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 30,
                height: 20,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicators(),
                    ),
                  ),
                ),
              ),
              // Product indicator (veg/non-veg)
              _buildIndicatorImage(),
            ],
          ),
        );
      },
    );
  }

  Widget _playIcon() {
    return Align(
      alignment: Alignment.center,
      child: (widget.model.videType != '' &&
              widget.model.video!.isNotEmpty &&
              widget.model.video != '')
          ? const Icon(
              Icons.play_circle_fill_outlined,
              color: colors.primary,
              size: 35,
            )
          : const SizedBox(),
    );
  }

  List<Widget> _buildPageIndicators() {
    List<Widget> indicators = [];
    for (int i = 0; i < widget.sliderList.length; i++) {
      indicators.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(
            vertical: 2.0,
            horizontal: 4.0,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(circularBorderRadius4),
            ),
            color: _curSlider == i
                ? colors.primary
                : Theme.of(context).colorScheme.lightWhite,
          ),
        ),
      );
    }
    return indicators;
  }

  Widget _buildIndicatorImage() {
    String? indicator = widget.model.indicator;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: indicator == '1'
              ? SvgPicture.asset(
                  DesignConfiguration.setSvgPath(Assets.vag),
                )
              : indicator == '2'
                  ? SvgPicture.asset(
                      DesignConfiguration.setSvgPath(Assets.nonvag),
                    )
                  : const SizedBox(),
        ),
      ),
    );
  }
}
