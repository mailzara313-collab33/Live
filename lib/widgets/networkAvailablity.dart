// global netWork Variable

import 'package:connectivity_plus/connectivity_plus.dart';

bool isNetworkAvail = true;

//checking the network
Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult.any((element) =>
      element == ConnectivityResult.mobile ||
      element == ConnectivityResult.wifi ||
      element == ConnectivityResult.ethernet ||
      element == ConnectivityResult.vpn)) {
    return true;
  }
  return false;
}
