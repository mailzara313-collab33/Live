import 'dart:async';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/IntroSlider/Intro_Slider.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/widgets/errorContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../widgets/desing.dart';
import '../../widgets/systemChromeSettings.dart';

// PetCep açılış ekranı
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // NoInternet ekranı için mevcut controller (değiştirilmedi)
  late AnimationController buttonController;
  late Animation buttonSqueezeanimation;
  bool from = false;
  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  // PetCep açılış animasyon controller'ları
  late AnimationController _splashController;
  late Animation<double> _logoScale;
  late Animation<double> _titleFade;
  late Animation<double> _sloganFade;

  @override
  void initState() {
    super.initState();

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Açılış animasyonu — toplam 1800ms, hafif ve akıcı
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Logo: 0.9 → 1.0 scale-in (easeOutBack ile hafif sıçrama)
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // "PetCep" yazısı: fade-in
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.28, 0.62, curve: Curves.easeIn),
      ),
    );

    // Slogan: fade-in (başlıktan biraz sonra)
    _sloganFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.52, 0.88, curve: Curves.easeIn),
      ),
    );

    _splashController.forward();

    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
        isDarkTheme:
            Provider.of<ThemeNotifier>(context, listen: false).getThemeMode() ==
                ThemeMode.dark,
      );
    });

    initializeAnimationController();

    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().fetchAndStoreAppSettings();
    });
  }

  void initializeAnimationController() {
    Future.delayed(
      Duration.zero,
      () {
        context.read<HomePageProvider>()
          ..setAnimationController(navigationContainerAnimationController)
          ..setBottomBarOffsetToAnimateController(
              navigationContainerAnimationController)
          ..setAppBarOffsetToAnimateController(
              navigationContainerAnimationController);
      },
    );
  }

  @override
  void dispose() {
    _splashController.dispose();
    buttonController.dispose();
    navigationContainerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    // NoInternet ekranı için animasyon (mevcut mantık korundu)
    buttonSqueezeanimation = Tween(
      begin: MediaQuery.of(context).size.width * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(0.0, 0.150),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      // PetCep krem arka plan
      backgroundColor: const Color(0xFFFFF8F0),
      body: BlocConsumer<AppSettingsCubit, AppSettingsState>(
        listener: (context, state) {
          if (state is AppSettingsSuccess) {
            navigationPage();
          }
        },
        builder: (context, state) {
          // Hata durumları (mevcut mantık korundu)
          if (state is AppSettingsFailure) {
            if (state.message.contains('No Internet connection')) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: NoInterNet(
                    buttonController: buttonController,
                    buttonSqueezeanimation: buttonSqueezeanimation,
                    setStateNoInternate: () {
                      buttonController.forward().then((value) {
                        buttonController.value = 0;
                        context
                            .read<AppSettingsCubit>()
                            .fetchAndStoreAppSettings();
                      });
                    },
                  ),
                ),
              );
            }
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<AppSettingsCubit>().fetchAndStoreAppSettings();
                },
                errorMessage: state.message,
              ),
            );
          }

          // PetCep açılış ekranı
          return _buildSplashContent();
        },
      ),
    );
  }

  Widget _buildSplashContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo — scale-in animasyonu
          ScaleTransition(
            scale: _logoScale,
            child: SvgPicture.asset(
              DesignConfiguration.setSvgPath(Assets.splashlogo),
              width: 145,
              height: 145,
            ),
          ),

          const SizedBox(height: 32),

          // "PetCep" başlığı — fade-in
          FadeTransition(
            opacity: _titleFade,
            child: const Text(
              'PetCep',
              style: TextStyle(
                fontFamily: 'ubuntu',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7A00),
                letterSpacing: 2.0,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Slogan — fade-in
          FadeTransition(
            opacity: _sloganFade,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                'Evcil dostun için her şey cebinde',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ubuntu',
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  letterSpacing: 0.3,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
    if (isFirstTime) {
      setState(() {
        from = true;
      });
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        from = false;
      });
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => const IntroSlider(),
        ),
      );
    }
  }
}
