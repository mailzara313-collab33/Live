import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/IntroSlider/Widgets/SliderClass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../widgets/systemChromeSettings.dart';

import 'Widgets/AllBtn.dart';
import 'Widgets/SetSlider.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({super.key});

  @override
  State<IntroSlider> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSlider>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late List slideList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });

    Future.delayed(
      Duration.zero,
      () {
        setState(
          () {
            slideList = [
              Slide(
                imageUrl: Assets.introimageA,
                title: 'TITLE1_LBL'.translate(context: context),
                description: 'DISCRIPTION1'.translate(context: context),
              ),
              Slide(
                imageUrl: Assets.introimageB,
                title: 'TITLE2_LBL'.translate(context: context),
                description: 'DISCRIPTION2'.translate(context: context),
              ),
              Slide(
                imageUrl: Assets.introimageC,
                title: 'TITLE3_LBL'.translate(context: context),
                description: 'DISCRIPTION3'.translate(context: context),
              ),
            ];
          },
        );
      },
    );

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    buttonController!.dispose();
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            skipBtn(
              context,
              _currentPage,
            ),
            slider(
              slideList,
              _pageController,
              context,
              _onPageChanged,
            ),
            SliderBtn(
              currentPage: _currentPage,
              pageController: _pageController,
              sliderList: slideList,
            ),
          ],
        ),
      ),
    );
  }
}
