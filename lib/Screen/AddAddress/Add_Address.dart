import 'dart:core';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/AddAddress/widget/textfieldContainer.dart';
import 'package:eshop_multivendor/Screen/Map/Map.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/widgets/ButtonDesing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/User.dart';
import '../../Provider/CartProvider.dart';
import '../../Provider/addressProvider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/validation.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class AddAddress extends StatefulWidget {
  final bool? update;
  final int? index;
  final bool fromProfile;

  const AddAddress(
      {super.key, this.update, this.index, required this.fromProfile});

  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

class StateAddress extends State<AddAddress> with TickerProviderStateMixin {
  String? isDefault;
  bool onlyOneTimePress = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController? nameC,
      mobileC,
      addressC,
      landmarkC,
      stateC,
      countryC,
      altMobC,
      cityC,
      areaC,
      zip;

  int? selectedType = 1;
  Animation? buttonSqueezeanimation;
  FocusNode? nameFocus,
      monoFocus,
      almonoFocus,
      addFocus,
      landFocus,
      locationFocus,
      cityFocus,
      areaFocus,
      zipcodeFocus = FocusNode();
  final ScrollController _cityScrollController = ScrollController();
  final ScrollController _zipcodeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    context.read<AddressProvider>().buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: context.read<AddressProvider>().buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cityScrollController.addListener(_scrollListener);
        _zipcodeScrollController.addListener(_zipcodeScrollListener);
        callApi();
        mobileC = TextEditingController();
        nameC = TextEditingController();
        altMobC = TextEditingController();
        context.read<AddressProvider>().zipcodeC = TextEditingController();
        addressC = TextEditingController();
        stateC = TextEditingController();
        countryC = TextEditingController();
        landmarkC = TextEditingController();
        cityC = TextEditingController();
        areaC = TextEditingController();
        zip = TextEditingController();
        mobileC!.text = context.read<UserProvider>().mob;
        if (widget.update!) {
          User item = context.read<CartProvider>().addressList[widget.index!];
          mobileC!.text = item.mobile!;
          nameC!.text = item.name!;
          altMobC!.text = item.altMob!;
          landmarkC!.text = item.landmark!;

          addressC!.text = item.address!;
          stateC!.text = item.state!;
          countryC!.text = item.country!;
          stateC!.text = item.state!;
          context.read<AddressProvider>().setLatitude(item.latitude);
          context.read<AddressProvider>().setLongitude(item.longitude);
          context.read<AddressProvider>().selectedCity = item.city!;
          context.read<AddressProvider>().selectedZipcode = item.pincode!;
          cityC!.text = item.city!;
          areaC!.text = item.area!;
          zip!.text = item.pincode!;
          context.read<AddressProvider>().type = item.type;

          if (item.cityId != '0') {
            /* context.read<AddressProvider>().selCityPos =
                int.parse(item.cityId!);*/
          } else {
            if (IS_SHIPROCKET_ON == '1') {
              context.read<AddressProvider>().cityEnable = true;
            }
          }
          context.read<AddressProvider>().city = item.cityId;
          if (kDebugMode) {
            print('system pincode: ${item.systemZipcode}');
          }
          if (item.systemZipcode != '0') {
            context.read<AddressProvider>().selectedZipcode = item.pincode!;
          } else {
            context.read<AddressProvider>().zipcodeC!.text = item.pincode!;

            context.read<AddressProvider>().zipcodeEnable = true;
          }

          if (context.read<AddressProvider>().type!.toLowerCase() ==
              HOME.toLowerCase()) {
            selectedType = 1;
          } else if (context.read<AddressProvider>().type!.toLowerCase() ==
              OFFICE.toLowerCase()) {
            selectedType = 2;
          } else {
            selectedType = 3;
          }

          context.read<AddressProvider>().checkedDefault =
              item.isDefault == '1' ? true : false;
          setState(() {});
        } else {
          context.read<AddressProvider>().selectedZipcode = null;
          context.read<AddressProvider>().selectedCity = null;

          context.read<AddressProvider>().selCityPos = -1;
          context.read<AddressProvider>().cityName = null;
          context.read<AddressProvider>().areaName = null;
          context.read<AddressProvider>().city = null;
          context.read<AddressProvider>().area = null;
          context.read<AddressProvider>().zipcode = null;
          context.read<AddressProvider>().cityEnable = false;
          context.read<AddressProvider>().zipcodeEnable = false;

          getCurrentLoc();
        }
      }
      setState(() {});
    });
  }

  void setStateNow() {
    setState(() {});
  }

  Future<void> _scrollListener() async {
    if (_cityScrollController.offset >=
            _cityScrollController.position.maxScrollExtent &&
        !_cityScrollController.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            context.read<AddressProvider>().isLoadingMoreCity = true;
            context.read<AddressProvider>().isProgress = true;
          },
        );

        await context
            .read<AddressProvider>()
            .getCities(false, context, setState, widget.update, widget.index);
      }
    }
  }

  Future<void> _zipcodeScrollListener() async {
    if (_zipcodeScrollController.offset >=
            _zipcodeScrollController.position.maxScrollExtent &&
        !_zipcodeScrollController.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            context.read<AddressProvider>().isLoadingMoreZipcode = true;
          },
        );
        await context.read<AddressProvider>().getZipcode(
            context.read<AddressProvider>().city,
            false,
            false,
            context,
            setState,
            widget.update!,
            widget.index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar:
          getSimpleAppBar('ADDRESS_LBL'.translate(context: context), context),
      body: isNetworkAvail
          ? _showContent()
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController:
                  context.read<AddressProvider>().buttonController,
            ),
    );
  }

  Future<void> setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (BuildContext context) => super.widget),
          );
        } else {
          await context.read<AddressProvider>().buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();

    if (form.validate()) {
      if (!context.read<AddressProvider>().cityEnable &&
          (context.read<AddressProvider>().city == null ||
              context.read<AddressProvider>().city!.isEmpty)) {
        setSnackbar('cityWarning'.translate(context: context), context);
        return false;
      }

      if (!context.read<AppSettingsCubit>().isCityWiseDeliverability()) {
        if (!context.read<AddressProvider>().zipcodeEnable &&
            (context.read<AddressProvider>().selectedZipcode == null ||
                context.read<AddressProvider>().selectedZipcode!.isEmpty)) {
          setSnackbar('PIN_REQUIRED'.translate(context: context), context);
          return false;
        } else {
          //passing on the value to the zipcode variable which is used there
          context.read<AddressProvider>().zipcode =
              context.read<AddressProvider>().selectedZipcode;
        }
      }

      if (context.read<AddressProvider>().latitude == null ||
          context.read<AddressProvider>().longitude == null) {
        setSnackbar('locationWarning'.translate(context: context), context);
        return false;
      }

      return true;
    }

    return false;
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      context.read<AddressProvider>().addNewAddress(context, setStateNow,
          widget.update, widget.index!, widget.fromProfile);
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
          await context.read<AddressProvider>().buttonController!.reverse();
        },
      );
    }
  }

  Widget setUserName() {
    return buildTextFormField(
      context: context,
      labelText: 'NAME_LBL',
      hintText: 'FULL_NAME_HERE',
      controller: nameC,
      focusNode: nameFocus,
      nextFocusNode: monoFocus,
      inputType: TextInputType.text,
      capitalization: TextCapitalization.words,
      validator: (val) => StringValidation.validateUserName(
        val!,
        'USER_REQUIRED'.translate(context: context),
        'USER_LENGTH'.translate(context: context),
        'INVALID_USERNAME_LBL'.translate(context: context),
      ),
      onSaved: (val) => context.read<AddressProvider>().name = val,
    );
  }

  Widget setMobileNo() {
    return buildTextFormField(
      context: context,
      labelText: 'PHONE_NUMBER_LBL',
      hintText: 'PHONE_NUMBER_LBL',
      controller: mobileC,
      focusNode: monoFocus,
      nextFocusNode: almonoFocus,
      inputType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 15,
      validator: (val) => StringValidation.validateMob(
        val!,
        'MOB_REQUIRED'.translate(context: context),
        'VALID_MOB'.translate(context: context),
      ),
      onSaved: (val) => context.read<AddressProvider>().mobile = val,
    );
  }

  void pincodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStater) {
          context.read<AddressProvider>().setZipcodeSetter(setStater);
          return PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {
                context.read<AddressProvider>().zipcodeOffset = 0;
                context.read<AddressProvider>().zipcodeController.clear();
                setStater(() {});
              },
              child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(circularBorderRadius5),
                    ),
                  ),
                  content: Consumer<AddressProvider>(
                      builder: (context, data, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                          child: Text(
                            'PINCODESELECT_LBL'.translate(context: context),
                            style: Theme.of(this.context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontFamily: 'ubuntu',
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextField(
                                  controller: data.zipcodeController,
                                  autofocus: false,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        0, 15.0, 0, 15.0),
                                    hintText: 'SEARCH_LBL'
                                        .translate(context: context),
                                    hintStyle: TextStyle(
                                        color: colors.primary
                                            .withValues(alpha: 0.5)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: IconButton(
                                onPressed: () async {
                                  setStater(
                                    () {
                                      data.isLoadingMoreZipcode = true;
                                    },
                                  );
                                  await data.getZipcode(
                                      context.read<AddressProvider>().city,
                                      true,
                                      true,
                                      context,
                                      setStater,
                                      widget.update!,
                                      widget.index);
                                  FocusScope.of(context).unfocus();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.search,
                                  size: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                        Divider(
                            color: Theme.of(context).colorScheme.lightBlack),
                        data.zipcodeLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 50.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Flexible(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: SingleChildScrollView(
                                    controller: _zipcodeScrollController,
                                    child: Column(
                                      children: [
                                        if (IS_SHIPROCKET_ON == '1')
                                          InkWell(
                                            onTap: () {
                                              setStater(() {
                                                data.selZipcode = null;

                                                data.selectedZipcode = null;

                                                data.zipcodeEnable = true;
                                                Navigator.of(context).pop();
                                                setState(() {});
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'OTHER_PINCODE_LBL'.translate(
                                                      context: context),
                                                  textAlign: TextAlign.start,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        (data.zipcodeSearchList.isNotEmpty)
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: getZipCodeList(
                                                    setStater, data),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20.0),
                                                child: DesignConfiguration
                                                    .getNoItem(context),
                                              ),
                                        DesignConfiguration
                                            .showCircularProgress(
                                          data.isLoadingMoreZipcode!,
                                          colors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      ],
                    );
                  })));
        });
      },
    );
  }

  void cityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            context.read<AddressProvider>().setCitySetter(setStater);

            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(circularBorderRadius5),
                ),
              ),
              content:
                  Consumer<AddressProvider>(builder: (context, data, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                      child: Text(
                        'CITYSELECT_LBL'.translate(context: context),
                        style: Theme.of(this.context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontFamily: 'ubuntu',
                                color: Theme.of(context).colorScheme.fontColor),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: data.cityController,
                              autofocus: false,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                              ),
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                                hintText:
                                    'SEARCH_LBL'.translate(context: context),
                                hintStyle: TextStyle(
                                    color:
                                        colors.primary.withValues(alpha: 0.5)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton(
                            onPressed: () async {
                              data.isLoadingMoreCity = true;
                              await data.getCities(
                                true,
                                context,
                                setStater,
                                widget.update,
                                widget.index,
                              );
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.search,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    data.cityLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Flexible(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: SingleChildScrollView(
                                controller: _cityScrollController,
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        if (IS_SHIPROCKET_ON == '1')
                                          InkWell(
                                            onTap: () {
                                              setStater(() {
                                                data.isZipcode = false;

                                                data.selZipcode = null;
                                                data.zipcodeC!.text = '';
                                                data.cityEnable = true;
                                                data.zipcodeEnable = true;
                                                data.selCityPos = -1;
                                                Navigator.of(context).pop();
                                              });
                                              setState(() {});
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'OTHER_CITY_LBL'.translate(
                                                      context: context),
                                                  textAlign: TextAlign.start,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        (data.citySearchLIst.isNotEmpty)
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: getCityList(
                                                    setStater, data),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20.0),
                                                child: DesignConfiguration
                                                    .getNoItem(context),
                                              ),
                                        Center(
                                          child: DesignConfiguration
                                              .showCircularProgress(
                                            data.isLoadingMoreCity!,
                                            colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    DesignConfiguration.showCircularProgress(
                                      data.isProgress,
                                      colors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                  ],
                );
              }),
            );
          },
        );
      },
    );
  }

  List<InkWell> getZipCodeList(
      StateSetter stateSetter, AddressProvider provider) {
    return provider.zipcodeSearchList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  provider.zipcodeOffset = 0;
                  provider.zipcodeController.clear();

                  stateSetter(
                    () {
                      provider.zipcodeEnable = false;
                      provider.zipcode =
                          provider.zipcodeSearchList[index].zipcode;

                      provider.selectedZipcode =
                          provider.zipcodeSearchList[index].zipcode;
                    },
                  );
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    provider.zipcodeSearchList[index].zipcode!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontFamily: 'ubuntu',
                        ),
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  List<InkWell> getCityList(StateSetter setStater, AddressProvider data) {
    return data.citySearchLIst
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  setStater(
                    () {
                      data.isZipcode = false;

                      data.selCityPos = index;
                      data.selectedZipcode = null;

                      data.selZipcode = null;
                      data.zipcodeC!.text = '';
                      cityC!.clear();
                      data.cityName = null;
                      data.cityEnable = false;
                      data.zipcodeName = null;
                      data.zipcodeEnable = false;
                      areaC!.clear();
                      zip!.clear();
                      Navigator.of(context).pop();
                    },
                  );

                  data.city = data.citySearchLIst[data.selCityPos!].id;

                  data.selectedCity =
                      data.citySearchLIst[data.selCityPos!].name;
                  data.zipcodeSearchList.clear();
                  data.getZipcode(data.city, true, true, context, setState,
                      widget.update!, widget.index);
                  setState(() {});
                }
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data.citySearchLIst[index].name!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontFamily: 'ubuntu',
                        ),
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  Widget setCities() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CITYSELECT_LBL'.translate(context: context),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.white,
                  borderRadius: BorderRadius.circular(circularBorderRadius5),
                  border: Border.all(color: Colors.grey.shade300)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: GestureDetector(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).colorScheme.white,
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.read<AddressProvider>().selCityPos !=
                                            null &&
                                        context
                                                .read<AddressProvider>()
                                                .selCityPos !=
                                            -1
                                    ? context
                                        .read<AddressProvider>()
                                        .selectedCity!
                                    : context
                                                .read<AddressProvider>()
                                                .cityEnable &&
                                            IS_SHIPROCKET_ON == '1'
                                        ? 'OTHER_CITY_LBL'
                                            .translate(context: context)
                                        : 'CITYSELECT_LBL'
                                            .translate(context: context),
                                style: TextStyle(
                                  color: context
                                              .read<AddressProvider>()
                                              .selCityPos !=
                                          null
                                      ? Theme.of(context).colorScheme.fontColor
                                      : Colors.grey,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.fontColor,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    cityDialog();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget setZipcode() {
    //done :  add conditions to make optional field for add/edit when the "isCityWiseDeliverability" is on
    if (!context.read<AddressProvider>().cityEnable) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PINCODESELECT_LBL'.translate(context: context),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'ubuntu',
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: BorderRadius.circular(circularBorderRadius5),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  child: GestureDetector(
                    child: InputDecorator(
                      decoration: InputDecoration(
                          fillColor: Theme.of(context).colorScheme.white,
                          isDense: true,
                          border: InputBorder.none),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  /*  context.read<AddressProvider>().selAreaPos !=
                                              null &&
                                          context
                                                  .read<AddressProvider>()
                                                  .selAreaPos !=
                                              -1 */
                                  context
                                                  .read<AddressProvider>()
                                                  .selectedZipcode !=
                                              '' &&
                                          context
                                                  .read<AddressProvider>()
                                                  .selectedZipcode !=
                                              null
                                      ? context
                                          .read<AddressProvider>()
                                          .selectedZipcode!
                                      : context
                                              .read<AddressProvider>()
                                              .zipcodeEnable
                                          ? 'OTHER_PINCODE_LBL'
                                              .translate(context: context)
                                          : 'PINCODESELECT_LBL'
                                              .translate(context: context),
                                  style: TextStyle(
                                    color: context
                                                .read<AddressProvider>()
                                                .selectedZipcode !=
                                            null
                                        ? Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                        : Colors.grey,
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (context.read<AddressProvider>().selCityPos != null &&
                          context.read<AddressProvider>().selCityPos != -1) {
                        pincodeDialog();
                      } else {
                        setSnackbar(
                            'PLZ_START_SEL_CITY_LBL'
                                .translate(context: context),
                            context);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setCityName() {
    if (context.read<AddressProvider>().cityEnable && IS_SHIPROCKET_ON == '1') {
      return buildTextFormField(
        context: context,
        labelText: 'CITY_NAME_LBL',
        hintText: 'CITY_NAME_LBL',
        controller: cityC,
        focusNode: cityFocus,
        inputType: TextInputType.text,
        capitalization: TextCapitalization.sentences,
        validator: (val) => StringValidation.validateField(
            val!, 'FIELD_REQUIRED'.translate(context: context)),
        onSaved: (val) => context.read<AddressProvider>().cityName = val,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setAreaName() {
    return buildTextFormField(
      context: context,
      labelText: 'AREA_NAME_LBL',
      hintText: 'ENTER_THE_AREA_NAME',
      controller: areaC,
      focusNode: areaFocus,
      inputType: TextInputType.text,
      capitalization: TextCapitalization.sentences,
      validator: (val) => StringValidation.validateField(
          val!, 'FIELD_REQUIRED'.translate(context: context)),
      onSaved: (val) => context.read<AddressProvider>().areaName = val,
    );
  }

  Widget setAddress() {
    return buildTextFormField(
      context: context,
      labelText: 'ADDRESS_LBL',
      hintText: 'FULL_ADDRESS_HERE',
      controller: addressC,
      focusNode: addFocus,
      nextFocusNode: locationFocus,
      inputType: TextInputType.text,
      capitalization: TextCapitalization.sentences,
      validator: (val) => StringValidation.validateField(
          val!, 'FIELD_REQUIRED'.translate(context: context)),
      onSaved: (val) => context.read<AddressProvider>().address = val,
      suffixIcon: IconButton(
        icon: Icon(
          Icons.my_location,
          color: Theme.of(context).colorScheme.fontColor,
          size: 20,
        ),
        focusNode: locationFocus,
        onPressed: () async {
          LocationPermission permission;

          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          Position position = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high),
          );
          if (onlyOneTimePress) {
            setState(
              () {
                onlyOneTimePress = false;
              },
            );
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => Map(
                  latitude: context.read<AddressProvider>().latitude == null ||
                          context.read<AddressProvider>().latitude == ''
                      ? position.latitude
                      : double.parse(context.read<AddressProvider>().latitude!),
                  longitude:
                      context.read<AddressProvider>().longitude == null ||
                              context.read<AddressProvider>().longitude == ''
                          ? position.longitude
                          : double.parse(
                              context.read<AddressProvider>().longitude!),
                  from: 'ADDADDRESS'.translate(context: context),
                ),
              ),
            ).then(
              (value) {
                onlyOneTimePress = true;
              },
            );
            if (mounted) setState(() {});
            List<Placemark> placemark = await placemarkFromCoordinates(
              double.parse(context.read<AddressProvider>().latitude!),
              double.parse(context.read<AddressProvider>().longitude!),
            );
            final placemarkItem = placemark[0];

            final address = [
              placemarkItem.name,
              placemarkItem.subLocality,
              placemarkItem.locality,
            ].where((e) => e != null && e.isNotEmpty).join(', ');

            context.read<AddressProvider>().state =
                placemarkItem.administrativeArea ?? '';
            context.read<AddressProvider>().country =
                placemarkItem.country ?? '';

            if (mounted) {
              setState(() {
                countryC?.text = context.read<AddressProvider>().country ?? '';
                stateC?.text = context.read<AddressProvider>().state ?? '';
                addressC?.text = address;
              });
            }
          }
        },
      ),
    );
  }

  Widget setPincode() {
    if (context.read<AddressProvider>().zipcodeEnable) {
      return buildTextFormField(
        context: context,
        labelText: 'PINCODEHINT_LBL',
        hintText: 'PINCODEHINT_LBL',
        controller: zip,
        focusNode: zipcodeFocus,
        inputType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => StringValidation.validateField(
            val!, 'FIELD_REQUIRED'.translate(context: context)),
        onSaved: (val) => context.read<AddressProvider>().zipcodeName = val,
      );
    } else {
      return const SizedBox();
    }
  }

  Future<void> callApi() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      await context.read<AddressProvider>().getCities(
            false,
            context,
            setState,
            widget.update,
            widget.index,
          );
      if (widget.update! &&
          context.read<CartProvider>().addressList[widget.index!].cityId !=
              '0') {
        context.read<AddressProvider>().getZipcode(
            context.read<CartProvider>().addressList[widget.index!].cityId,
            true,
            false,
            context,
            setState,
            widget.update,
            widget.index);
      }
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
        },
      );
    }
  }

  Widget setLandmark() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: landFocus,
      controller: landmarkC,
      style: Theme.of(context)
          .textTheme
          .titleSmall!
          .copyWith(color: Theme.of(context).colorScheme.fontColor),
      validator: (val) => StringValidation.validateField(
          val!, 'FIELD_REQUIRED'.translate(context: context)),
      onSaved: (String? value) {
        context.read<AddressProvider>().landmark = value;
      },
      decoration: const InputDecoration(
        hintText: LANDMARK,
      ),
    );
  }

  Widget setStateField() {
    return buildTextFormField(
      context: context,
      labelText: 'STATE_LBL',
      hintText: 'ENTER_THE_STATE_NAME',
      controller: stateC,
      capitalization: TextCapitalization.sentences,
      onChanged: (v) => setState(() {
        context.read<AddressProvider>().state = v;
      }),
      onSaved: (val) => context.read<AddressProvider>().state = val,
      useCustomContainer: true,
    );
  }

  Widget setCountry() {
    return buildTextFormField(
      context: context,
      labelText: 'COUNTRY_LBL',
      hintText: 'COUNTRY_LBL',
      controller: countryC,
      capitalization: TextCapitalization.sentences,
      readOnly: false,
      validator: (val) => StringValidation.validateField(
        val!,
        'FIELD_REQUIRED'.translate(context: context),
      ),
      onSaved: (val) => context.read<AddressProvider>().country = val,
      useCustomContainer: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AddressProvider>().buttonController!.dispose();
        context.read<AddressProvider>().zipcodeC!.dispose();
        context.read<AddressProvider>().cityController.dispose();
        context.read<AddressProvider>().zipcodeController.dispose();
        context.read<AddressProvider>().selectedZipcode = null;
        context.read<AddressProvider>().selectedCity = null;

        context.read<AddressProvider>().selCityPos = -1;
        context.read<AddressProvider>().cityName = null;
        context.read<AddressProvider>().areaName = null;
        context.read<AddressProvider>().city = null;
        context.read<AddressProvider>().area = null;
        context.read<AddressProvider>().zipcode = null;
      }
    });
    mobileC?.dispose();
    nameC?.dispose();
    stateC?.dispose();
    countryC?.dispose();
    altMobC?.dispose();
    landmarkC?.dispose();
    addressC!.dispose();
    cityC!.dispose();
    areaC!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await context.read<AddressProvider>().buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget typeOfAddress() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        borderRadius: BorderRadius.circular(circularBorderRadius5),
      ),
      child: RadioGroup<int>(
        groupValue: selectedType,
        onChanged: (int? val) {
          if (val != null && mounted) {
            setState(() {
              selectedType = val;
              if (val == 1) context.read<AddressProvider>().type = HOME;
              if (val == 2) context.read<AddressProvider>().type = OFFICE;
              if (val == 3) context.read<AddressProvider>().type = OTHER;
            });
          }
        },
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () =>
                    RadioGroup.maybeOf<int>(context)?.onChanged.call(1),
                child: Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      activeColor: Theme.of(context).colorScheme.fontColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Expanded(
                      child: Text(
                        'HOME_LBL'.translate(context: context),
                        style: const TextStyle(fontFamily: 'ubuntu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () =>
                    RadioGroup.maybeOf<int>(context)?.onChanged.call(2),
                child: Row(
                  children: [
                    Radio<int>(
                      value: 2,
                      activeColor: Theme.of(context).colorScheme.fontColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Expanded(
                      child: Text(
                        'OFFICE_LBL'.translate(context: context),
                        style: const TextStyle(fontFamily: 'ubuntu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () =>
                    RadioGroup.maybeOf<int>(context)?.onChanged.call(3),
                child: Row(
                  children: [
                    Radio<int>(
                      value: 3,
                      activeColor: Theme.of(context).colorScheme.fontColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Expanded(
                      child: Text(
                        'OTHER_LBL'.translate(context: context),
                        style: const TextStyle(fontFamily: 'ubuntu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //   child: Row(
      //     children: [
      //       Expanded(
      //         flex: 1,
      //         child: InkWell(
      //           child: Row(
      //             children: [
      //               Radio(
      //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //                 groupValue: selectedType,
      //                 activeColor: Theme.of(context).colorScheme.fontColor,
      //                 value: 1,
      //                 onChanged: (dynamic val) {
      //                   if (mounted) {
      //                     setState(
      //                       () {
      //                         selectedType = val;
      //                         context.read<AddressProvider>().type = HOME;
      //                       },
      //                     );
      //                   }
      //                 },
      //               ),
      //               Expanded(
      //                 child: Text(
      //                   'HOME_LBL'.translate(context: context),
      //                   style: const TextStyle(
      //                     fontFamily: 'ubuntu',
      //                   ),
      //                 ),
      //               )
      //             ],
      //           ),
      //           onTap: () {
      //             if (mounted) {
      //               setState(
      //                 () {
      //                   selectedType = 1;
      //                   context.read<AddressProvider>().type = HOME;
      //                 },
      //               );
      //             }
      //           },
      //         ),
      //       ),
      //       Expanded(
      //         flex: 1,
      //         child: InkWell(
      //           child: Row(
      //             children: [
      //               Radio(
      //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //                 groupValue: selectedType,
      //                 activeColor: Theme.of(context).colorScheme.fontColor,
      //                 value: 2,
      //                 onChanged: (dynamic val) {
      //                   if (mounted) {
      //                     setState(
      //                       () {
      //                         selectedType = val;
      //                         context.read<AddressProvider>().type = OFFICE;
      //                       },
      //                     );
      //                   }
      //                 },
      //               ),
      //               Expanded(
      //                 child: Text(
      //                   'OFFICE_LBL'.translate(context: context),
      //                   style: const TextStyle(
      //                     fontFamily: 'ubuntu',
      //                   ),
      //                 ),
      //               )
      //             ],
      //           ),
      //           onTap: () {
      //             if (mounted) {
      //               setState(
      //                 () {
      //                   selectedType = 2;
      //                   context.read<AddressProvider>().type = OFFICE;
      //                 },
      //               );
      //             }
      //           },
      //         ),
      //       ),
      //       Expanded(
      //         flex: 1,
      //         child: InkWell(
      //           child: Row(
      //             children: [
      //               Radio(
      //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //                 groupValue: selectedType,
      //                 activeColor: Theme.of(context).colorScheme.fontColor,
      //                 value: 3,
      //                 onChanged: (dynamic val) {
      //                   if (mounted) {
      //                     setState(
      //                       () {
      //                         selectedType = val;
      //                         context.read<AddressProvider>().type = OTHER;
      //                       },
      //                     );
      //                   }
      //                 },
      //               ),
      //               Expanded(
      //                 child: Text(
      //                   'OTHER_LBL'.translate(context: context),
      //                   style: const TextStyle(
      //                     fontFamily: 'ubuntu',
      //                   ),
      //                 ),
      //               )
      //             ],
      //           ),
      //           onTap: () {
      //             if (mounted) {
      //               setState(
      //                 () {
      //                   selectedType = 3;
      //                   context.read<AddressProvider>().type = OTHER;
      //                 },
      //               );
      //             }
      //           },
      //         ),
      //       )
      //     ],
      //   ),
      // );
    );
  }

  Widget defaultAdd() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        borderRadius: BorderRadius.circular(circularBorderRadius5),
      ),
      child: SwitchListTile(
        value: context.read<AddressProvider>().checkedDefault,
        activeThumbColor: Theme.of(context).colorScheme.secondary,
        dense: true,
        onChanged: (newValue) {
          if (mounted) {
            setState(
              () {
                context.read<AddressProvider>().checkedDefault = newValue;
              },
            );
          }
        },
        title: Text(
          'DEFAULT_ADD'.translate(context: context),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.lightBlack,
                fontWeight: FontWeight.bold,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
    );
  }

  Widget _showContent() {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: <Widget>[
                    setUserName(),
                    setMobileNo(),
                    setAddress(),
                    setCities(),
                    setCityName(),
                    setAreaName(),
                    setZipcode(),
                    setPincode(),
                    setStateField(),
                    setCountry(),
                    typeOfAddress(),
                    defaultAdd(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(20),
            child: AppBtn(
              title: 'SAVE_LBL'.translate(context: context),
              removeTopPadding: true,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: context.read<AddressProvider>().buttonController,
              onBtnSelected: () async {
                FocusScope.of(context).unfocus();
                validateAndSubmit();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> getCurrentLoc() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    List<Placemark> placemark =
        await GeocodingPlatform.instance!.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    context.read<AddressProvider>().state = placemark[0].administrativeArea;
    context.read<AddressProvider>().country = placemark[0].country;
    if (mounted) {
      setState(
        () {
          countryC!.text = context.read<AddressProvider>().country!;
          stateC!.text = context.read<AddressProvider>().state!;
        },
      );
    }
  }
}
