import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/homePageProvider.dart';

void hideAppbarAndBottomBarOnScroll(
  ScrollController scrollBottomBarController,
  BuildContext context,
) {
  double lastScrollOffset = 0.0;
  bool isScrollingUp = false;

  scrollBottomBarController.addListener(() {
    double currentScrollOffset = scrollBottomBarController.offset;

    // Prevent negative offset (overscroll at top)
    if (currentScrollOffset <= 0) {
      // Always show bars at top
      if (!context.read<HomePageProvider>().getBars) {
        context.read<HomePageProvider>().animationController.reverse();
        context.read<HomePageProvider>().showAppAndBottomBars(true);
      }
      lastScrollOffset = 0;
      return;
    }

    // Detect scroll direction
    isScrollingUp = currentScrollOffset < lastScrollOffset;
    lastScrollOffset = currentScrollOffset;

    if (!isScrollingUp) {
      // Scrolling down → hide
      if (context.read<HomePageProvider>().getBars) {
        context.read<HomePageProvider>().animationController.forward();
        context.read<HomePageProvider>().showAppAndBottomBars(false);
      }
    } else {
      // Scrolling up → show
      if (!context.read<HomePageProvider>().getBars) {
        context.read<HomePageProvider>().animationController.reverse();
        context.read<HomePageProvider>().showAppAndBottomBars(true);
      }
    }
  });
}
